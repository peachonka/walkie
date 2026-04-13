// src/routes/achievements.js
const express = require('express');
const router = express.Router();
const { mockAuth, authMiddleware } = require('../middleware/auth');
const achievementsController = require('../controllers/achievementsController');

// router.use(mockAuth);
router.use(authMiddleware);

// GET /api/achievements — все достижения (с целями)
/**
 * @swagger
 * /achievements:
 *   get:
 *     summary: Get all achievements with targets
 *     tags: [Achievements]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of all achievements
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 achievements:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       id:
 *                         type: integer
 *                       name:
 *                         type: string
 *                       description:
 *                         type: string
 *                       score:
 *                         type: number
 *                       icon:
 *                         type: string
 *                       achieve_type:
 *                         type: object
 *                         properties:
 *                           id:
 *                             type: integer
 *                           name:
 *                             type: string
 *       500:
 *         description: Server error
 */
router.get('/', achievementsController.getAllAchievements);

// GET /api/achievements/user — полученные достижения пользователя
/**
 * @swagger
 * /achievements/user:
 *   get:
 *     summary: Get user earned achievements
 *     tags: [Achievements]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of user achievements
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 achievements:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       id:
 *                         type: integer
 *                       created_at:
 *                         type: string
 *                       achievement:
 *                         type: object
 *                         properties:
 *                           id:
 *                             type: integer
 *                           name:
 *                             type: string
 *                           description:
 *                             type: string
 *                           score:
 *                             type: number
 *                           icon:
 *                             type: string
 *                           achieve_type:
 *                             type: object
 *                             properties:
 *                               id:
 *                                 type: integer
 *                               name:
 *                                 type: string
 *       500:
 *         description: Server error
 */
router.get('/user', achievementsController.getUserAchievements);

// GET /api/achievements/progress — прогресс по достижениям
/**
 * @swagger
 * /achievements/progress:
 *   get:
 *     summary: Get user achievement progress
 *     description: Returns achievements with current progress and completion status
 *     tags: [Achievements]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Achievement progress list
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 achievements:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       id:
 *                         type: integer
 *                       name:
 *                         type: string
 *                       description:
 *                         type: string
 *                       icon:
 *                         type: string
 *                       target:
 *                         type: number
 *                         description: Required value to complete achievement
 *                       current_value:
 *                         type: number
 *                         description: Current user progress value
 *                       progress_percent:
 *                         type: integer
 *                         example: 75
 *                       is_earned:
 *                         type: boolean
 *                         example: false
 *                       earned_at:
 *                         type:
 *                           - string
 *                           - "null"
 *                         example: null
 *       500:
 *         description: Server error
 */
router.get('/progress', achievementsController.getAchievementProgress);

// GET /api/achievements/types — типы достижений
/**
 * @swagger
 * /achievements/types:
 *   get:
 *     summary: Get achievement types
 *     tags: [Achievements]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of achievement types
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 types:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       id:
 *                         type: integer
 *                       name:
 *                         type: string
 *       500:
 *         description: Server error
 */
router.get('/types', achievementsController.getAchievementTypes);

module.exports = router;