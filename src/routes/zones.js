// src/routes/zones.js
const express = require('express');
const router = express.Router();
<<<<<<< HEAD
const { mockAuth } = require('../middleware/auth');
=======
const { mockAuth, authMiddleware } = require('../middleware/auth');
>>>>>>> 50318123edf43ae04403988df9a7bd10109516a1
const zonesController = require('../controllers/zonesController');

// Все маршруты зон доступны без авторизации (для отображения на карте)
// Но для проверки точки используем mockAuth для совместимости
<<<<<<< HEAD
router.use(mockAuth);
=======
// router.use(mockAuth);
router.use(authMiddleware);
>>>>>>> 50318123edf43ae04403988df9a7bd10109516a1

// GET /api/zones — все зоны
router.get('/', zonesController.getAllZones);

// GET /api/zones/nearby — ближайшие зоны
router.get('/nearby', zonesController.getNearbyZones);

// POST /api/zones/check — проверить точку
router.post('/check', zonesController.checkPointInZone);

// GET /api/zones/:zoneId — конкретная зона
router.get('/:zoneId', zonesController.getZoneById);

// GET /api/zones/:zoneId/items — предметы в зоне
router.get('/:zoneId/items', zonesController.getZoneItems);

module.exports = router;