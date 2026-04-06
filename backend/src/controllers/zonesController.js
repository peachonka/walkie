// src/controllers/zonesController.js
const { isPointInSquareZone } = require('../utils/calculations');

// ============================================================
// ВРЕМЕННОЕ ХРАНИЛИЩЕ (МОКИ)
// ============================================================

// zones — ERD: id, Name, SideLengthMeters, CenterLat, CentreLng
const zones = [
  {
    id: 1,
    name: 'Центральный парк',
    sideLengthMeters: 200,
    centerLat: 55.751244,
    centerLng: 37.618423,
    description: 'Красивый парк в центре города. Здесь можно найти листочки, желуди и веточки.',
    isActive: true
  },
  {
    id: 2,
    name: 'Городская площадь',
    sideLengthMeters: 150,
    centerLat: 55.755000,
    centerLng: 37.620000,
    description: 'Оживленная площадь с фонтаном. Здесь можно найти редкие предметы.',
    isActive: true
  },
  {
    id: 3,
    name: 'Старый сад',
    sideLengthMeters: 180,
    centerLat: 55.748500,
    centerLng: 37.615000,
    description: 'Тихий старый сад. Здесь можно найти легендарные предметы.',
    isActive: true
  },
  {
    id: 4,
    name: 'Набережная',
    sideLengthMeters: 250,
    centerLat: 55.760000,
    centerLng: 37.625000,
    description: 'Прогулка вдоль реки. Здесь водятся особые предметы.',
    isActive: false  // временно отключена
  }
];

// items — для получения предметов в зоне
const items = [
  { id: 1, name: 'Листочек', rarityId: 1, zoneId: 1, icon: '/icons/leaf.png' },
  { id: 2, name: 'Желудь', rarityId: 1, zoneId: 1, icon: '/icons/acorn.png' },
  { id: 3, name: 'Веточка', rarityId: 1, zoneId: 1, icon: '/icons/twig.png' },
  { id: 4, name: 'Каштан', rarityId: 1, zoneId: 1, icon: '/icons/chestnut.png' },
  { id: 5, name: 'Редкий гриб', rarityId: 2, zoneId: 2, icon: '/icons/mushroom.png' },
  { id: 6, name: 'Перо птицы', rarityId: 2, zoneId: 2, icon: '/icons/feather.png' },
  { id: 7, name: 'Камушек', rarityId: 1, zoneId: 2, icon: '/icons/stone.png' },
  { id: 8, name: 'Ягодка', rarityId: 1, zoneId: 2, icon: '/icons/berry.png' },
  { id: 9, name: 'Золотой лист', rarityId: 3, zoneId: 3, icon: '/icons/gold-leaf.png' },
  { id: 10, name: 'Волшебный желудь', rarityId: 3, zoneId: 3, icon: '/icons/magic-acorn.png' }
];

// rarity — для информации о редкости
const rarity = [
  { id: 1, type: 'common', dropChance: 15 },
  { id: 2, type: 'rare', dropChance: 5 },
  { id: 3, type: 'legendary', dropChance: 1 }
];

// ============================================================
// КОНТРОЛЛЕРЫ
// ============================================================

/**
 * Получить все активные зоны
 * GET /api/zones
 * 
 * Query параметры:
 * - include_inactive (опционально) — показать неактивные зоны
 */
async function getAllZones(req, res) {
  try {
    const includeInactive = req.query.include_inactive === 'true';
    
    let filteredZones = zones;
    if (!includeInactive) {
      filteredZones = zones.filter(z => z.isActive !== false);
    }
    
    const result = filteredZones.map(zone => ({
      id: zone.id,
      name: zone.name,
      side_length_meters: zone.sideLengthMeters,
      center_lat: zone.centerLat,
      center_lng: zone.centerLng,
      description: zone.description,
      is_active: zone.isActive !== false
    }));
    
    res.json({
      total: result.length,
      zones: result
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Получить зону по ID
 * GET /api/zones/:zoneId
 */
async function getZoneById(req, res) {
  try {
    const zoneId = parseInt(req.params.zoneId);
    
    const zone = zones.find(z => z.id === zoneId);
    if (!zone) {
      return res.status(404).json({ error: 'Zone not found' });
    }
    
    res.json({
      id: zone.id,
      name: zone.name,
      side_length_meters: zone.sideLengthMeters,
      center_lat: zone.centerLat,
      center_lng: zone.centerLng,
      description: zone.description,
      is_active: zone.isActive !== false
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Получить предметы в зоне
 * GET /api/zones/:zoneId/items
 */
async function getZoneItems(req, res) {
  try {
    const zoneId = parseInt(req.params.zoneId);
    
    const zone = zones.find(z => z.id === zoneId);
    if (!zone) {
      return res.status(404).json({ error: 'Zone not found' });
    }
    
    const zoneItems = items.filter(item => item.zoneId === zoneId);
    
    const result = zoneItems.map(item => {
      const itemRarity = rarity.find(r => r.id === item.rarityId);
      return {
        id: item.id,
        name: item.name,
        icon: item.icon,
        rarity: {
          id: itemRarity.id,
          type: itemRarity.type,
          drop_chance: itemRarity.dropChance
        }
      };
    });
    
    res.json({
      zone_id: zoneId,
      zone_name: zone.name,
      total_items: result.length,
      items: result
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Проверить, находится ли точка в зоне
 * POST /api/zones/check
 * 
 * Body: { lat, lng }
 */
async function checkPointInZone(req, res) {
  try {
    const { lat, lng } = req.body;
    
    if (!lat || !lng) {
      return res.status(400).json({ error: 'Missing required fields: lat, lng' });
    }
    
    const activeZones = zones.filter(z => z.isActive !== false);
    const foundZones = [];
    
    for (const zone of activeZones) {
      if (isPointInSquareZone(lat, lng, zone)) {
        foundZones.push({
          id: zone.id,
          name: zone.name,
          side_length_meters: zone.sideLengthMeters,
          center_lat: zone.centerLat,
          center_lng: zone.centerLng
        });
      }
    }
    
    res.json({
      point: { lat, lng },
      in_zone: foundZones.length > 0,
      zones: foundZones
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Получить ближайшие зоны к точке
 * GET /api/zones/nearby?lat=55.75&lng=37.61&radius=500
 * 
 * Query параметры:
 * - lat — широта точки
 * - lng — долгота точки
 * - radius — радиус поиска в метрах (по умолчанию 500)
 */
async function getNearbyZones(req, res) {
  try {
    const lat = parseFloat(req.query.lat);
    const lng = parseFloat(req.query.lng);
    const radius = parseFloat(req.query.radius) || 500;
    
    if (isNaN(lat) || isNaN(lng)) {
      return res.status(400).json({ error: 'Missing required params: lat, lng' });
    }
    
    const activeZones = zones.filter(z => z.isActive !== false);
    const nearbyZones = [];
    
    for (const zone of activeZones) {
      // Рассчитываем расстояние от центра зоны до точки
      const distanceToCenter = calculateDistance(
        lat, lng,
        zone.centerLat, zone.centerLng
      );
      
      // Если расстояние до центра меньше радиуса + половина стороны зоны
      const halfSide = zone.sideLengthMeters / 2;
      if (distanceToCenter <= radius + halfSide) {
        nearbyZones.push({
          id: zone.id,
          name: zone.name,
          side_length_meters: zone.sideLengthMeters,
          center_lat: zone.centerLat,
          center_lng: zone.centerLng,
          distance_to_center_meters: distanceToCenter,
          description: zone.description
        });
      }
    }
    
    // Сортируем по расстоянию
    nearbyZones.sort((a, b) => a.distance_to_center_meters - b.distance_to_center_meters);
    
    res.json({
      point: { lat, lng },
      radius_meters: radius,
      total: nearbyZones.length,
      zones: nearbyZones
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

// Вспомогательная функция расчета расстояния
function calculateDistance(lat1, lon1, lat2, lon2) {
  const R = 6371000;
  const φ1 = lat1 * Math.PI / 180;
  const φ2 = lat2 * Math.PI / 180;
  const Δφ = (lat2 - lat1) * Math.PI / 180;
  const Δλ = (lon2 - lon1) * Math.PI / 180;
  
  const a = Math.sin(Δφ/2) * Math.sin(Δφ/2) +
            Math.cos(φ1) * Math.cos(φ2) *
            Math.sin(Δλ/2) * Math.sin(Δλ/2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
  
  return Math.round(R * c);
}

module.exports = {
  getAllZones,
  getZoneById,
  getZoneItems,
  checkPointInZone,
  getNearbyZones
};