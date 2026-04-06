// src/routes/stats.js
const express = require('express');
const router = express.Router();
const { mockAuth } = require('../middleware/auth');
const statsController = require('../controllers/statsController');

router.use(mockAuth);

// GET /api/stats — общая статистика
router.get('/', statsController.getUserStats);

// GET /api/stats/period — статистика за период
router.get('/period', statsController.getStatsByPeriod);

// GET /api/stats/daily — статистика по дням
router.get('/daily', statsController.getDailyStats);

module.exports = router;