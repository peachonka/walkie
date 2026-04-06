// src/routes/stats.js
const express = require('express');
const router = express.Router();
<<<<<<< HEAD
const { mockAuth } = require('../middleware/auth');
const statsController = require('../controllers/statsController');

router.use(mockAuth);
=======
const { mockAuth, authMiddleware } = require('../middleware/auth');
const statsController = require('../controllers/statsController');

// router.use(mockAuth);
router.use(authMiddleware);
>>>>>>> 50318123edf43ae04403988df9a7bd10109516a1

// GET /api/stats — общая статистика
router.get('/', statsController.getUserStats);

// GET /api/stats/period — статистика за период
router.get('/period', statsController.getStatsByPeriod);

// GET /api/stats/daily — статистика по дням
router.get('/daily', statsController.getDailyStats);

module.exports = router;