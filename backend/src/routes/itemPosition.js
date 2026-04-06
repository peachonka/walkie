// src/routes/itemPosition.js
const express = require('express');
const router = express.Router();
<<<<<<< HEAD
const { mockAuth } = require('../middleware/auth');
const itemPositionController = require('../controllers/itemPositionController');

router.use(mockAuth);
=======
const { mockAuth, authMiddleware } = require('../middleware/auth');
const itemPositionController = require('../controllers/itemPositionController');

// router.use(mockAuth);
router.use(authMiddleware);
>>>>>>> 50318123edf43ae04403988df9a7bd10109516a1

// GET /api/item-positions — все размещенные предметы
router.get('/', itemPositionController.getAllItemPositions);

// GET /api/item-positions?type=wearable — по типу
router.get('/', itemPositionController.getItemPositionsByType);

// GET /api/item-positions/item/:itemId — проверка размещения предмета
router.get('/item/:itemId', itemPositionController.getPositionByItemId);

// POST /api/item-positions — разместить предмет
router.post('/', itemPositionController.placeItem);

// PUT /api/item-positions/:positionId — переместить предмет
router.put('/:positionId', itemPositionController.moveItem);

// DELETE /api/item-positions/:positionId — убрать предмет
router.delete('/:positionId', itemPositionController.removeItem);

// DELETE /api/item-positions — очистить все позиции
router.delete('/', itemPositionController.clearAllPositions);

module.exports = router;