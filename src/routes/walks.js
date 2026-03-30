const express = require('express');
const router = express.Router();
const { mockAuth } = require('../middleware/auth');
const walksController = require('../controllers/walksController');

router.use(mockAuth);

router.post('/start', walksController.startWalk);
router.post('/:walkId/track', walksController.addTrackPoint);
router.post('/:walkId/end', walksController.endWalk);
router.get('/history', walksController.getWalkHistory);
router.get('/:walkId', walksController.getWalkDetails);

module.exports = router;