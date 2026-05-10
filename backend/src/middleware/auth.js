const jwt = require('jsonwebtoken');

const auth = (req, res, next) => {
  const header = req.headers.authorization;
  if (!header) return res.status(401).json({ success: false, message: 'No token' });
  const token = header.split(' ')[1];
  try {
    req.user = jwt.verify(token, process.env.JWT_SECRET);
    next();
  } catch {
    res.status(401).json({ success: false, message: 'Invalid token' });
  }
};

const adminOnly = (req, res, next) => {
  if (req.user.role !== 'admin')
    return res.status(403).json({ success: false, message: 'Admin only' });
  next();
};

const magasinOnly = (req, res, next) => {
  if (req.user.role !== 'magasin')
    return res.status(403).json({ success: false, message: 'Magasin only' });
  next();
};

module.exports = { auth, adminOnly, magasinOnly };
