const router = require('express').Router();
const { auth, magasinOnly } = require('../middleware/auth');
const c = require('../controllers/orderController');
router.post('/', auth, magasinOnly, c.create);
router.get('/my', auth, magasinOnly, c.myOrders);
router.get('/:id', auth, c.getOne);
module.exports = router;
