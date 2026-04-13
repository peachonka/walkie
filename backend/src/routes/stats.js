// src/routes/stats.js
const express = require('express');
const router = express.Router();
const { mockAuth, authMiddleware } = require('../middleware/auth');
const statsController = require('../controllers/statsController');

// router.use(mockAuth);
router.use(authMiddleware);

// GET /api/stats — общая статистика
/**
 * @swagger
 * /stats:
 *   get:
 *     summary: Get user overall statistics
 *     tags: [Stats]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Aggregated user statistics
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 total_distance_km:
 *                   type: number
 *                   example: 12.5
 *                   description: Total distance in kilometers
 *                 total_duration_hours:
 *                   type: number
 *                   example: 5.2
 *                   description: Total duration in hours
 *                 total_walks:
 *                   type: integer
 *                   example: 8
 *                 total_steps:
 *                   type: integer
 *                   example: 15432
 *                 total_items_collected:
 *                   type: integer
 *                   example: 23
 *                 first_walk_date:
 *                   type:
 *                     - string
 *                     - "null"
 *                   example: "2026-04-01"
 *                 last_walk_date:
 *                   type:
 *                     - string
 *                     - "null"
 *                   example: "2026-04-10"
 *       500:
 *         description: Server error
 */
router.get('/', statsController.getUserStats);

// GET /api/stats/daily — статистика по дням
/**
 * @swagger
 * /stats/daily:
 *   get:
 *     summary: Get user daily statistics
 *     description: Returns aggregated stats per day (distance, duration, walks, items)
 *     tags: [Stats]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: start_date
 *         required: false
 *         schema:
 *           type: string
 *           format: date
 *           example: "2026-04-01"
 *         description: Filter from date (inclusive)
 *       - in: query
 *         name: end_date
 *         required: false
 *         schema:
 *           type: string
 *           format: date
 *           example: "2026-04-10"
 *         description: Filter to date (inclusive)
 *       - in: query
 *         name: limit
 *         required: false
 *         schema:
 *           type: integer
 *           example: 7
 *         description: Limit number of days returned
 *     responses:
 *       200:
 *         description: Daily statistics
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 total_days:
 *                   type: integer
 *                   example: 5
 *                 daily_stats:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       date:
 *                         type: string
 *                         example: "2026-04-10"
 *                       distance_km:
 *                         type: number
 *                         example: 3.25
 *                       duration_min:
 *                         type: number
 *                         example: 45.5
 *                       walks_count:
 *                         type: integer
 *                         example: 2
 *                       items_collected:
 *                         type: integer
 *                         example: 4
 *       500:
 *         description: Server error
 */
router.get('/daily', statsController.getDailyStats);

module.exports = router;