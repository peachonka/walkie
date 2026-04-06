const express = require('express');
const router = express.Router();
<<<<<<< HEAD
const { mockAuth } = require('../middleware/auth');
const walksController = require('../controllers/walksController');

router.use(mockAuth);
=======
const { mockAuth, authMiddleware } = require('../middleware/auth');
const walksController = require('../controllers/walksController');

// router.use(mockAuth);
router.use(authMiddleware);
>>>>>>> 50318123edf43ae04403988df9a7bd10109516a1

router.post('/start', walksController.startWalk);
router.post('/:walkId/end', walksController.endWalk);
router.get('/history', walksController.getWalkHistory);
router.get('/:walkId', walksController.getWalkDetails);

module.exports = router;