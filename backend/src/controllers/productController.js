const db = require('../config/db');

const ok = (res, data) => res.json({ success: true, ...data });
const fail = (res, msg, code = 400) => res.status(code).json({ success: false, message: msg });

exports.list = async (req, res) => {
  const { category, search } = req.query;
  let q = 'SELECT * FROM products WHERE is_active=TRUE';
  const params = [];
  if (category) { params.push(category); q += ` AND category=$${params.length}`; }
  if (search) { params.push(`%${search}%`); q += ` AND name ILIKE $${params.length}`; }
  q += ' ORDER BY category, name';
  const { rows } = await db.query(q, params);
  ok(res, { products: rows });
};

exports.create = async (req, res) => {
  const { name, description, image, category, price, stock } = req.body;
  if (!name || !price) return fail(res, 'Name and price required');
  const { rows } = await db.query(
    `INSERT INTO products (name,description,image,category,price,stock)
     VALUES ($1,$2,$3,$4,$5,$6) RETURNING *`,
    [name, description, image, category, price, stock || 0]
  );
  ok(res, { product: rows[0] });
};

exports.update = async (req, res) => {
  const { name, description, image, category, price, stock, is_active } = req.body;
  const { rows } = await db.query(
    `UPDATE products SET name=COALESCE($1,name), description=COALESCE($2,description),
     image=COALESCE($3,image), category=COALESCE($4,category), price=COALESCE($5,price),
     stock=COALESCE($6,stock), is_active=COALESCE($7,is_active)
     WHERE id=$8 RETURNING *`,
    [name, description, image, category, price, stock, is_active, req.params.id]
  );
  if (!rows.length) return fail(res, 'Product not found', 404);
  ok(res, { product: rows[0] });
};

exports.remove = async (req, res) => {
  await db.query('UPDATE products SET is_active=FALSE WHERE id=$1', [req.params.id]);
  ok(res, { message: 'Product disabled' });
};
