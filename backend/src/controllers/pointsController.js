const db = require('../config/db');

const ok = (res, data) => res.json({ success: true, ...data });

exports.balance = async (req, res) => {
  const { rows: [user] } = await db.query('SELECT points_balance FROM users WHERE id=$1', [req.user.id]);
  ok(res, { points_balance: user.points_balance });
};

exports.history = async (req, res) => {
  const { rows } = await db.query(
    'SELECT * FROM points_transactions WHERE user_id=$1 ORDER BY created_at DESC',
    [req.user.id]
  );
  ok(res, { transactions: rows });
};
