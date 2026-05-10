const db = require('../config/db');

const ok = (res, data) => res.json({ success: true, ...data });
const fail = (res, msg, code = 400) => res.status(code).json({ success: false, message: msg });

const VALID_STATUSES = ['En attente', 'En préparation', 'En livraison', 'Livré', 'Annulé'];

exports.allOrders = async (req, res) => {
  const { status, search } = req.query;
  let q = `SELECT o.*, u.name, u.magasin_name, u.phone, u.address
           FROM orders o JOIN users u ON u.id=o.user_id WHERE 1=1`;
  const params = [];
  if (status) { params.push(status); q += ` AND o.status=$${params.length}`; }
  if (search) { params.push(`%${search}%`); q += ` AND (u.magasin_name ILIKE $${params.length} OR u.name ILIKE $${params.length})`; }
  q += ' ORDER BY o.created_at DESC';
  const { rows } = await db.query(q, params);
  ok(res, { orders: rows });
};

exports.updateStatus = async (req, res) => {
  const { status } = req.body;
  if (!VALID_STATUSES.includes(status)) return fail(res, 'Invalid status');

  const client = await db.connect();
  try {
    await client.query('BEGIN');
    const { rows: [order] } = await client.query('SELECT * FROM orders WHERE id=$1', [req.params.id]);
    if (!order) return fail(res, 'Order not found', 404);

    await client.query('UPDATE orders SET status=$1 WHERE id=$2', [status, order.id]);

    // Earn points on delivery (only once)
    if (status === 'Livré' && order.status !== 'Livré') {
      const points = Math.floor(order.final_total);
      await client.query('UPDATE orders SET points_earned=$1 WHERE id=$2', [points, order.id]);
      await client.query('UPDATE users SET points_balance=points_balance+$1 WHERE id=$2', [points, order.user_id]);
      await client.query(
        'INSERT INTO points_transactions (user_id,order_id,type,points,amount_value) VALUES ($1,$2,$3,$4,$5)',
        [order.user_id, order.id, 'EARN', points, order.final_total]
      );
    }

    // Restore stock and points on cancellation
    if (status === 'Annulé' && order.status !== 'Annulé') {
      const { rows: items } = await client.query('SELECT * FROM order_items WHERE order_id=$1', [order.id]);
      for (const item of items) {
        await client.query('UPDATE products SET stock=stock+$1 WHERE id=$2', [item.quantity, item.product_id]);
      }
      // Restore points if used
      if (order.points_used > 0) {
        await client.query('UPDATE users SET points_balance=points_balance+$1 WHERE id=$2', [order.points_used, order.user_id]);
        await client.query(
          'INSERT INTO points_transactions (user_id,order_id,type,points) VALUES ($1,$2,$3,$4)',
          [order.user_id, order.id, 'EARN', order.points_used]
        );
      }
      // Deduct points if earned (if it was already delivered)
      if (order.status === 'Livré' && order.points_earned > 0) {
        await client.query('UPDATE users SET points_balance=points_balance-$1 WHERE id=$2', [order.points_earned, order.user_id]);
        await client.query(
          'INSERT INTO points_transactions (user_id,order_id,type,points) VALUES ($1,$2,$3,$4)',
          [order.user_id, order.id, 'USE', order.points_earned]
        );
      }
    }

    await client.query('COMMIT');
    ok(res, { message: 'Status updated' });
  } catch (e) {
    await client.query('ROLLBACK');
    fail(res, e.message);
  } finally {
    client.release();
  }
};

exports.dashboard = async (req, res) => {
  const [totals, revenue, topMagasins, recent, monthlyRevenue] = await Promise.all([
    db.query(`SELECT
      COUNT(*) AS total,
      COUNT(*) FILTER (WHERE status='En attente') AS pending,
      COUNT(*) FILTER (WHERE status='Livré') AS delivered
      FROM orders`),
    db.query(`SELECT COALESCE(SUM(final_total),0) AS total_revenue FROM orders WHERE status='Livré'`),
    db.query(`SELECT u.magasin_name, u.name, COUNT(o.id) AS order_count, SUM(o.final_total) AS total_spent
              FROM orders o JOIN users u ON u.id=o.user_id
              GROUP BY u.id, u.magasin_name, u.name ORDER BY total_spent DESC LIMIT 5`),
    db.query(`SELECT o.*, u.magasin_name, u.name FROM orders o JOIN users u ON u.id=o.user_id
              ORDER BY o.created_at DESC LIMIT 10`),
    db.query(`SELECT TO_CHAR(created_at, 'YYYY-MM') AS month, SUM(final_total) AS revenue
              FROM orders WHERE status='Livré' GROUP BY month ORDER BY month DESC LIMIT 6`),
  ]);
  ok(res, {
    stats: { ...totals.rows[0], ...revenue.rows[0] },
    top_magasins: topMagasins.rows,
    recent_orders: recent.rows,
    monthly_revenue: monthlyRevenue.rows,
  });
};

exports.allProducts = async (req, res) => {
  const { rows } = await db.query('SELECT * FROM products ORDER BY category, name');
  ok(res, { products: rows });
};

exports.allMagasins = async (req, res) => {
  const { search } = req.query;
  let q = "SELECT id, name, email, magasin_name, phone, address, points_balance, created_at FROM users WHERE role='magasin'";
  const params = [];
  if (search) {
    params.push(`%${search}%`);
    q += ` AND (magasin_name ILIKE $1 OR name ILIKE $1 OR email ILIKE $1)`;
  }
  q += ' ORDER BY magasin_name, name';
  const { rows } = await db.query(q, params);
  ok(res, { magasins: rows });
};
