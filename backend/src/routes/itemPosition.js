// src/routes/itemPosition.js
const express = require('express');
const router = express.Router();
const { mockAuth, authMiddleware } = require('../middleware/auth');
const itemPositionController = require('../controllers/itemPositionController');

// router.use(mockAuth);
router.use(authMiddleware);

// GET /api/item-positions — все размещенные предметы
router.get('/', itemPositionController.getAllItemPositions);

// GET /api/item-positions/item/:itemId — проверка размещения предмета
router.get('/item/:itemId', itemPositionController.getPositionByItemId);

// POST /api/item-positions — разместить предмет
router.post('/', itemPositionController.upsertItemPosition);

// DELETE /api/item-positions/:positionId — убрать предмет
router.delete('/:positionId', itemPositionController.removeItem);

// DELETE /api/item-positions — очистить все позиции
router.delete('/', itemPositionController.clearAllPositions);

module.exports = router;