const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('../config/db');

const ok = (res, data) => res.json({ success: true, ...data });
const fail = (res, msg, code = 400) => res.status(code).json({ success: false, message: msg });

exports.register = async (req, res) => {
  const { name, email, password, magasin_name, phone, address } = req.body;
  if (!name || !email || !password) return fail(res, 'Name, email and password required');
  const hash = await bcrypt.hash(password, 10);
  try {
    const { rows } = await db.query(
      `INSERT INTO users (name,email,password,role,magasin_name,phone,address)
       VALUES ($1,$2,$3,'magasin',$4,$5,$6) RETURNING id,name,email,role,magasin_name,phone,address,points_balance`,
      [name, email, hash, magasin_name, phone, address]
    );
    const token = jwt.sign({ id: rows[0].id, role: rows[0].role }, process.env.JWT_SECRET, { expiresIn: '7d' });
    ok(res, { user: rows[0], token });
  } catch (e) {
    if (e.code === '23505') return fail(res, 'Email already exists');
    throw e;
  }
};

exports.login = async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) return fail(res, 'Email and password required');
  const { rows } = await db.query('SELECT * FROM users WHERE email=$1', [email]);
  if (!rows.length) return fail(res, 'Invalid credentials', 401);
  const valid = await bcrypt.compare(password, rows[0].password);
  if (!valid) return fail(res, 'Invalid credentials', 401);
  const { password: _, ...user } = rows[0];
  const token = jwt.sign({ id: user.id, role: user.role }, process.env.JWT_SECRET, { expiresIn: '7d' });
  ok(res, { user, token });
};

exports.getMe = async (req, res) => {
  const { rows } = await db.query('SELECT * FROM users WHERE id=$1', [req.user.id]);
  if (!rows.length) return fail(res, 'User not found', 404);
  const { password: _, ...user } = rows[0];
  ok(res, { user });
};
