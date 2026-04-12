// src/routes/items.js
const express = require('express');
const router = express.Router();
const { mockAuth, authMiddleware } = require('../middleware/auth');
const itemsController = require('../controllers/itemsController');

// router.use(mockAuth);
router.use(authMiddleware);

// GET /api/items — все предметы
/**
 * @swagger
 * /items:
 *   get:
 *     summary: Get all items
 *     tags: [Items]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: zoneId
 *         required: false
 *         schema:
 *           type: integer
 *         description: Filter items by zone ID
 *     responses:
 *       200:
 *         description: List of all items
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 total:
 *                   type: integer
 *                   example: 10
 *                 items:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       id:
 *                         type: integer
 *                       name:
 *                         type: string
 *                       icon:
 *                         type: string
 *                       created_at:
 *                         type: string
 *                       rarity:
 *                         type: object
 *                         properties:
 *                           id:
 *                             type: integer
 *                           type:
 *                             type: string
 *                           drop_chance:
 *                             type: number
 *                       zone:
 *                         type: object
 *                         properties:
 *                           id:
 *                             type: integer
 *                           name:
 *                             type: string
 *       500:
 *         description: Server error
 */
router.get('/', itemsController.getAllItems);

// GET /api/items/collected — собранные предметы пользователя
/**
 * @swagger
 * /items/collected:
 *   get:
 *     summary: Get user collected items
 *     tags: [Items]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: limit
 *         required: false
 *         schema:
 *           type: integer
 *           default: 50
 *         description: Number of items to return
 *       - in: query
 *         name: offset
 *         required: false
 *         schema:
 *           type: integer
 *           default: 0
 *         description: Pagination offset
 *     responses:
 *       200:
 *         description: List of user collected items
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 total:
 *                   type: integer
 *                 limit:
 *                   type: integer
 *                 offset:
 *                   type: integer
 *                 items:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       id:
 *                         type: integer
 *                       created_at:
 *                         type: string
 *                       walk_id:
 *                         type: integer
 *                       item:
 *                         type: object
 *                         properties:
 *                           id:
 *                             type: integer
 *                           name:
 *                             type: string
 *                           icon:
 *                             type: string
 *                           rarity:
 *                             type: object
 *                             properties:
 *                               type:
 *                                 type: string
 *                               drop_chance:
 *                                 type: number
 *       500:
 *         description: Server error
 */
router.get('/collected', itemsController.getUserItems);

// GET /api/items/rarities — все редкости
/**
 * @swagger
 * /items/rarities:
 *   get:
 *     summary: Get all item rarities
 *     tags: [Items]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of rarities
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 rarities:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       id:
 *                         type: integer
 *                       type:
 *                         type: string
 *                       drop_chance:
 *                         type: number
 *       500:
 *         description: Server error
 */
router.get('/rarities', itemsController.getRarities);

// GET /api/items/:itemId — конкретный предмет
/**
 * @swagger
 * /items/{itemId}:
 *   get:
 *     summary: Get item by ID
 *     tags: [Items]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: itemId
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID of the item
 *     responses:
 *       200:
 *         description: Item details
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 id:
 *                   type: integer
 *                 name:
 *                   type: string
 *                 icon:
 *                   type: string
 *                 rarity:
 *                   type: object
 *                   properties:
 *                     id:
 *                       type: integer
 *                     type:
 *                       type: string
 *                     drop_chance:
 *                       type: number
 *                 zone:
 *                   type: object
 *                   properties:
 *                     id:
 *                       type: integer
 *                     name:
 *                       type: string
 *       404:
 *         description: Item not found
 *       500:
 *         description: Server error
 */
router.get('/:itemId', itemsController.getItemById);

module.exports = router;