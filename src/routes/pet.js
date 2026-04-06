// src/routes/pet.js
const express = require('express');
const router = express.Router();
const { mockAuth, authMiddleware } = require('../middleware/auth');
const petController = require('../controllers/petController');

// router.use(mockAuth);
router.use(authMiddleware);

// POST /api/pet — создать питомца
router.post('/', petController.createPet);

// GET /api/pet — информация о питомце
router.get('/', petController.getPet);

// PUT /api/pet/name — изменить имя питомца
router.put('/name', petController.updatePetName);

// GET /api/pet/types — список типов питомцев
router.get('/types', petController.getPetTypes);

module.exports = router;