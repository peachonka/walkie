// src/routes/itemPosition.js
const express = require('express');
const router = express.Router();
const { mockAuth, authMiddleware } = require('../middleware/auth');
const itemPositionController = require('../controllers/itemPositionController');

// router.use(mockAuth);
router.use(authMiddleware);

// GET /api/item-positions — все размещенные предметы
/**
 * @swagger
 * /item-positions:
 *   get:
 *     summary: Get all user item positions
 *     tags: [Item Positions]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of item positions
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 total:
 *                   type: integer
 *                   example: 2
 *                 positions:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       id:
 *                         type: integer
 *                       item_id:
 *                         type: integer
 *                       item_name:
 *                         type: string
 *                       item_icon:
 *                         type: string
 *                       x:
 *                         type: number
 *                       y:
 *                         type: number
 *       500:
 *         description: Server error
 */
router.get('/', itemPositionController.getAllItemPositions);

// GET /api/item-positions/item/:itemId — проверка размещения предмета
/**
 * @swagger
 * /item-positions/item/{itemId}:
 *   get:
 *     summary: Check if item is placed
 *     tags: [Item Positions]
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
 *         description: Placement status
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 is_placed:
 *                   type: boolean
 *                 position:
 *                   type:
 *                     - object
 *                     - "null"
 *                   properties:
 *                     id:
 *                       type: integer
 *                     x:
 *                       type: number
 *                     y:
 *                       type: number
 *       500:
 *         description: Server error
 */
router.get('/item/:itemId', itemPositionController.getPositionByItemId);

// POST /api/item-positions — разместить предмет
/**
 * @swagger
 * /item-positions:
 *   post:
 *     summary: Place or update item position
 *     tags: [Item Positions]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - item_id
 *               - x
 *               - y
 *             properties:
 *               item_id:
 *                 type: integer
 *                 example: 5
 *               x:
 *                 type: number
 *                 example: 120.5
 *               y:
 *                 type: number
 *                 example: 300.2
 *     responses:
 *       200:
 *         description: Item placed successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 position:
 *                   type: object
 *                   properties:
 *                     id:
 *                       type: integer
 *                     item_id:
 *                       type: integer
 *                     item_name:
 *                       type: string
 *                     item_icon:
 *                       type: string
 *                     x:
 *                       type: number
 *                     y:
 *                       type: number
 *       400:
 *         description: Missing fields
 *       403:
 *         description: Item not owned by user
 *       404:
 *         description: Item not found
 *       500:
 *         description: Server error
 */
router.post('/', itemPositionController.upsertItemPosition);

// DELETE /api/item-positions/:positionId — убрать предмет
/**
 * @swagger
 * /item-positions/{positionId}:
 *   delete:
 *     summary: Remove item position
 *     tags: [Item Positions]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: positionId
 *         required: true
 *         schema:
 *           type: integer
 *         description: Position ID
 *     responses:
 *       200:
 *         description: Item removed successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 removed_id:
 *                   type: integer
 *       404:
 *         description: Position not found
 *       500:
 *         description: Server error
 */
router.delete('/:positionId', itemPositionController.removeItem);

// DELETE /api/item-positions — очистить все позиции
/**
 * @swagger
 * /item-positions:
 *   delete:
 *     summary: Clear all item positions for user
 *     tags: [Item Positions]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: All positions cleared
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *       500:
 *         description: Server error
 */
router.delete('/', itemPositionController.clearAllPositions);

module.exports = router;