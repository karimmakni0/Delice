const db = require('../config/db');

const ok = (res, data) => res.json({ success: true, ...data });
const fail = (res, msg, code = 400) => res.status(code).json({ success: false, message: msg });

exports.create = async (req, res) => {
  const { items, points_used = 0 } = req.body;
  if (!items || !items.length) return fail(res, 'Order items required');

  const client = await db.connect();
  try {
    await client.query('BEGIN');

    // Validate stock and compute total
    let total = 0;
    const enriched = [];
    for (const item of items) {
      const { rows } = await client.query('SELECT * FROM products WHERE id=$1 AND is_active=TRUE', [item.product_id]);
      if (!rows.length) throw new Error(`Product ${item.product_id} not found`);
      if (rows[0].stock < item.quantity) throw new Error(`Insufficient stock for ${rows[0].name}`);
      const subtotal = rows[0].price * item.quantity;
      total += subtotal;
      enriched.push({ ...item, unit_price: rows[0].price, subtotal });
    }

    // Validate points
    const { rows: [user] } = await client.query('SELECT points_balance FROM users WHERE id=$1', [req.user.id]);
    if (points_used > user.points_balance) throw new Error('Insufficient points');
    if (points_used % 100 !== 0) throw new Error('Points must be used in multiples of 100');

    const discount = (points_used / 100) * 5;
    const final_total = Math.max(0, total - discount);

    // Create order
    const { rows: [order] } = await client.query(
      `INSERT INTO orders (user_id,total_amount,points_used,discount_amount,final_total,points_earned)
       VALUES ($1,$2,$3,$4,$5,0) RETURNING *`,
      [req.user.id, total, points_used, discount, final_total]
    );

    // Insert items and decrease stock
    for (const item of enriched) {
      await client.query(
        'INSERT INTO order_items (order_id,product_id,quantity,unit_price,subtotal) VALUES ($1,$2,$3,$4,$5)',
        [order.id, item.product_id, item.quantity, item.unit_price, item.subtotal]
      );
      await client.query('UPDATE products SET stock=stock-$1 WHERE id=$2', [item.quantity, item.product_id]);
    }

    // Deduct points
    if (points_used > 0) {
      await client.query('UPDATE users SET points_balance=points_balance-$1 WHERE id=$2', [points_used, req.user.id]);
      await client.query(
        'INSERT INTO points_transactions (user_id,order_id,type,points,amount_value) VALUES ($1,$2,$3,$4,$5)',
        [req.user.id, order.id, 'USE', points_used, discount]
      );
    }

    await client.query('COMMIT');
    ok(res, { order });
  } catch (e) {
    await client.query('ROLLBACK');
    fail(res, e.message);
  } finally {
    client.release();
  }
};

exports.myOrders = async (req, res) => {
  const { rows } = await db.query(
    'SELECT * FROM orders WHERE user_id=$1 ORDER BY created_at DESC',
    [req.user.id]
  );
  ok(res, { orders: rows });
};

exports.getOne = async (req, res) => {
  const { rows: [order] } = await db.query('SELECT * FROM orders WHERE id=$1', [req.params.id]);
  if (!order) return fail(res, 'Order not found', 404);
  if (order.user_id !== req.user.id && req.user.role !== 'admin')
    return fail(res, 'Forbidden', 403);
  const { rows: items } = await db.query(
    `SELECT oi.*, p.name, p.image, p.category FROM order_items oi
     JOIN products p ON p.id=oi.product_id WHERE oi.order_id=$1`,
    [req.params.id]
  );
  ok(res, { order, items });
};
