const express = require('express');
const router = express.Router();
const { mockAuth, authMiddleware } = require('../middleware/auth');
const walksController = require('../controllers/walksController');

// router.use(mockAuth);
router.use(authMiddleware);

/**
 * @swagger
 * /walks/start:
 *   post:
 *     summary: Start a new walk
 *     tags: [Walks]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Walk started successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 walk_id:
 *                   type: integer
 *                   example: 12
 *                 start_time:
 *                   type: string
 *                   example: "2026-04-10T10:00:00.000Z"
 *       409:
 *         description: Active walk already exists
 *       500:
 *         description: Server error
 */
router.post('/start', walksController.startWalk);
/**
 * @swagger
 * /walks/{walkId}/end:
 *   post:
 *     summary: Finish a walk
 *     tags: [Walks]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: walkId
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID of the walk
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - distance
 *               - duration
 *               - steps
 *             properties:
 *               distance:
 *                 type: number
 *                 example: 700
 *                 description: Walk distance in meters
 *               duration:
 *                 type: number
 *                 example: 4500
 *                 description: Walk duration in seconds
 *               steps:
 *                 type: integer
 *                 example: 2000
 *                 description: Total steps during the walk
 *     responses:
 *       200:
 *         description: Walk finished successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 walk_id:
 *                   type: integer
 *                   example: 65
 *                 distance:
 *                   type: number
 *                   example: 700
 *                 duration:
 *                   type: number
 *                   example: 4500
 *                 steps:
 *                   type: integer
 *                   example: 2000
 *                 items_collected:
 *                   type: array
 *                   description: Items received after the walk
 *                   items:
 *                     type: object
 *                     properties:
 *                       id:
 *                         type: integer
 *                       name:
 *                         type: string
 *                       icon:
 *                         type:
 *                           - string
 *                           - "null"
 *                       rarity_id:
 *                         type: integer
 *                       rarity:
 *                         type: object
 *                         properties:
 *                           id:
 *                             type: integer
 *                           type:
 *                             type: string
 *                       quantity:
 *                         type: integer
 *                         example: 4
 *                 new_achievements:
 *                   type: array
 *                   description: Newly unlocked achievements
 *                   items:
 *                     type: object
 *                     properties:
 *                       id:
 *                         type: integer
 *                       created_at:
 *                         type: string
 *                       name:
 *                         type: string
 *                       achieve_type:
 *                         type: integer
 *                       description:
 *                         type: string
 *                       score:
 *                         type: number
 *                       icon:
 *                         type:
 *                           - string
 *                           - "null"
 *                       type:
 *                         type: object
 *                         properties:
 *                           name:
 *                             type: string
 *       404:
 *         description: Walk not found
 *       400:
 *         description: Walk already finished
 *       500:
 *         description: Server error
 */
router.post('/:walkId/end', walksController.endWalk);
/**
 * @swagger
 * /walks/history:
 *   get:
 *     summary: Get walk history
 *     tags: [Walks]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           example: 20
 *       - in: query
 *         name: offset
 *         schema:
 *           type: integer
 *           example: 0
 *     responses:
 *       200:
 *         description: List of walks
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 walks:
 *                   type: array
 *                   items:
 *                     type: object
 *       500:
 *         description: Server error
 */
router.get('/history', walksController.getWalkHistory);
/**
 * @swagger
 * /walks/{walkId}:
 *   get:
 *     summary: Get walk details
 *     tags: [Walks]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: walkId
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Walk details
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 id:
 *                   type: integer
 *                 start_time:
 *                   type: string
 *                 end_time:
 *                   type: string
 *                   nullable: true
 *                 distance:
 *                   type: number
 *                 duration:
 *                   type: number
 *                 items:
 *                   type: array
 *                   items:
 *                     type: object
 *       404:
 *         description: Walk not found
 *       500:
 *         description: Server error
 */
router.get('/:walkId', walksController.getWalkDetails);

module.exports = router;