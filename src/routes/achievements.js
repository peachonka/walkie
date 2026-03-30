// src/routes/achievements.js
const express = require('express');
const router = express.Router();
const { mockAuth } = require('../middleware/auth');
const achievementsController = require('../controllers/achievementsController');

router.use(mockAuth);

// GET /api/achievements — все достижения (с целями)
router.get('/', achievementsController.getAllAchievements);

// GET /api/achievements/user — полученные достижения пользователя
router.get('/user', achievementsController.getUserAchievements);

// GET /api/achievements/progress — прогресс по достижениям
router.get('/progress', achievementsController.getAchievementProgress);

// GET /api/achievements/types — типы достижений
router.get('/types', achievementsController.getAchievementTypes);

// POST /api/achievements/check — проверить и выдать достижения
router.post('/check', achievementsController.checkAchievements);

module.exports = router;