// src/routes/pet.js
const express = require('express');
const router = express.Router();
<<<<<<< HEAD
const { mockAuth } = require('../middleware/auth');
const petController = require('../controllers/petController');

router.use(mockAuth);
=======
const { mockAuth, authMiddleware } = require('../middleware/auth');
const petController = require('../controllers/petController');

// router.use(mockAuth);
router.use(authMiddleware);
>>>>>>> 50318123edf43ae04403988df9a7bd10109516a1

// POST /api/pet — создать питомца
router.post('/', petController.createPet);

// GET /api/pet — информация о питомце
router.get('/', petController.getPet);

// PUT /api/pet/name — изменить имя питомца
router.put('/name', petController.updatePetName);

// GET /api/pet/types — список типов питомцев
router.get('/types', petController.getPetTypes);

module.exports = router;