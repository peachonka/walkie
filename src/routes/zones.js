// src/routes/zones.js
const express = require('express');
const router = express.Router();
const { mockAuth } = require('../middleware/auth');
const zonesController = require('../controllers/zonesController');

// Все маршруты зон доступны без авторизации (для отображения на карте)
// Но для проверки точки используем mockAuth для совместимости
router.use(mockAuth);

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