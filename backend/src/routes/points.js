const router = require('express').Router();
const { auth } = require('../middleware/auth');
const c = require('../controllers/pointsController');
router.get('/balance', auth, c.balance);
router.get('/history', auth, c.history);
module.exports = router;
