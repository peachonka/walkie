// src/routes/items.js
const express = require('express');
const router = express.Router();
const { mockAuth, authMiddleware } = require('../middleware/auth');
const itemsController = require('../controllers/itemsController');

// router.use(mockAuth);
router.use(authMiddleware);

// GET /api/items — все предметы
router.get('/', itemsController.getAllItems);

// GET /api/items/collected — собранные предметы пользователя
router.get('/collected', itemsController.getUserItems);

// GET /api/items/rarities — все редкости
router.get('/rarities', itemsController.getRarities);

// GET /api/items/:itemId — конкретный предмет
router.get('/:itemId', itemsController.getItemById);

module.exports = router;