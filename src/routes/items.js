// src/routes/items.js
const express = require('express');
const router = express.Router();
<<<<<<< HEAD
const { mockAuth } = require('../middleware/auth');
const itemsController = require('../controllers/itemsController');

router.use(mockAuth);
=======
const { mockAuth, authMiddleware } = require('../middleware/auth');
const itemsController = require('../controllers/itemsController');

// router.use(mockAuth);
router.use(authMiddleware);
>>>>>>> 50318123edf43ae04403988df9a7bd10109516a1

// GET /api/items — все предметы
router.get('/', itemsController.getAllItems);

// GET /api/items/collected — собранные предметы пользователя
router.get('/collected', itemsController.getUserItems);

// GET /api/items/rarities — все редкости
router.get('/rarities', itemsController.getRarities);

// GET /api/items/:itemId — конкретный предмет
router.get('/:itemId', itemsController.getItemById);

module.exports = router;