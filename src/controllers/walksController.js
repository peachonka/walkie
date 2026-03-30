// src/controllers/walksController.js (обновленный)

const { calculateDistance, isPointInSquareZone } = require('../utils/calculations');
const { updateUserProgress, checkAndAwardAchievements } = require('./achievementsController');

// ============================================================
// ВРЕМЕННОЕ ХРАНИЛИЩЕ (МОКИ)
// ============================================================

let walks = [];
let walkCounter = 1;
let trackPoints = [];
let trackPointCounter = 1;
let collections = [];
let collectionCounter = 1;

// Зоны
const zones = [
  {
    id: 1,
    name: 'Центральный парк',
    sideLengthMeters: 200,
    centerLat: 55.751244,
    centerLng: 37.618423,
    isActive: true
  },
  {
    id: 2,
    name: 'Городская площадь',
    sideLengthMeters: 150,
    centerLat: 55.755000,
    centerLng: 37.620000,
    isActive: true
  }
];

// Предметы
const items = [
  { id: 1, name: 'Листочек', rarityId: 1, zoneId: 1, icon: '/icons/leaf.png' },
  { id: 2, name: 'Желудь', rarityId: 1, zoneId: 1, icon: '/icons/acorn.png' },
  { id: 5, name: 'Редкий гриб', rarityId: 2, zoneId: 2, icon: '/icons/mushroom.png' }
];

const rarity = [
  { id: 1, type: 'common', dropChance: 15 },
  { id: 2, type: 'rare', dropChance: 5 }
];

// Статистика пользователя
let userStats = [];

// Прогресс пользователя для достижений (хранится в achievementsController,
// но для доступа создадим локальную переменную)
let userProgress = {
  1: { totalSteps: 15000, totalWalks: 0, totalDuration: 0 }
};

// ============================================================
// ФУНКЦИЯ ОКОНЧАНИЯ ПРОГУЛКИ
// ============================================================

async function endWalk(req, res) {
  try {
    const userId = req.userId;
    const walkId = parseInt(req.params.walkId);
    
    // 1. Находим прогулку
    const walk = walks.find(w => w.id === walkId && w.UserId === userId);
    if (!walk) {
      return res.status(404).json({ error: 'Walk not found' });
    }
    if (walk.EndTime) {
      return res.status(400).json({ error: 'Walk already completed' });
    }
    
    // 2. Получаем все точки маршрута в правильном порядке
    const points = trackPoints
      .filter(p => p.WalkId === walkId)
      .sort((a, b) => a.SequenceNumber - b.SequenceNumber);
    
    // 3. Рассчитываем общую дистанцию
    let totalDistance = 0;
    if (points.length > 1) {
      for (let i = 0; i < points.length - 1; i++) {
        totalDistance += calculateDistance(
          points[i].Lat, points[i].Lng,
          points[i + 1].Lat, points[i + 1].Lng
        );
      }
    }
    
    // 4. Рассчитываем длительность прогулки
    const startTime = new Date(walk.StartTime);
    const endTime = new Date();
    const durationSeconds = Math.floor((endTime - startTime) / 1000);
    
    // 5. Обновляем запись прогулки
    walk.EndTime = endTime.toISOString();
    walk.Distance = totalDistance;
    walk.Duration = durationSeconds;
    
    // 6. Подсчитываем собранные предметы в этой прогулке
    const itemsCollected = collections.filter(c => c.UserId === userId && c.WalkId === walkId).length;
    
    // 7. Обновляем общую статистику пользователя
    const userWalks = walks.filter(w => w.UserId === userId && w.EndTime);
    const totalDistanceAll = userWalks.reduce((sum, w) => sum + (w.Distance || 0), 0);
    const totalDurationAll = userWalks.reduce((sum, w) => sum + (w.Duration || 0), 0);
    const totalWalks = userWalks.length;
    const totalSteps = Math.floor(totalDistanceAll / 0.75); // 1 шаг ≈ 0.75 метра
    
    // Сохраняем в userStats
    const existingStats = userStats.find(s => s.UserId === userId);
    if (existingStats) {
      existingStats.TotalDistance = totalDistanceAll;
      existingStats.TotalDuration = totalDurationAll;
      existingStats.TotalWalks = totalWalks;
      existingStats.TotalSteps = totalSteps;
    } else {
      userStats.push({
        id: userStats.length + 1,
        UserId: userId,
        TotalDistance: totalDistanceAll,
        TotalDuration: totalDurationAll,
        TotalWalks: totalWalks,
        TotalSteps: totalSteps
      });
    }
    
    // 8. ОБНОВЛЯЕМ ПРОГРЕСС ДЛЯ ДОСТИЖЕНИЙ
    updateUserProgress(userId, totalSteps, totalWalks, totalDurationAll);
    
    // 9. ПРОВЕРЯЕМ И ВЫДАЕМ НОВЫЕ ДОСТИЖЕНИЯ
    const progress = { totalSteps, totalWalks, totalDuration: totalDurationAll };
    const newAchievements = checkAndAwardAchievements(userId, progress);
    
    // 10. Формируем ответ
    const distanceKm = (totalDistance / 1000).toFixed(2);
    const durationMin = (durationSeconds / 60).toFixed(1);
    const avgSpeed = durationSeconds > 0 ? ((totalDistance / 1000) / (durationSeconds / 3600)).toFixed(2) : 0;
    
    const response = {
      walk_id: walkId,
      distance_meters: totalDistance,
      duration_seconds: durationSeconds,
      items_collected: itemsCollected,
      summary: {
        distance_km: parseFloat(distanceKm),
        duration_min: parseFloat(durationMin),
        avg_speed_kmh: parseFloat(avgSpeed)
      }
    };
    
    // Если есть новые достижения, добавляем их в ответ
    if (newAchievements && newAchievements.length > 0) {
      response.new_achievements = newAchievements;
    }
    
    res.json(response);
    
  } catch (error) {
    console.error('Error in endWalk:', error);
    res.status(500).json({ error: error.message });
  }
}

// ============================================================
// ОСТАЛЬНЫЕ ФУНКЦИИ (startWalk, addTrackPoint, и т.д.)
// ============================================================

async function startWalk(req, res) {
  try {
    const userId = req.userId;
    
    const activeWalk = walks.find(w => w.UserId === userId && !w.EndTime);
    if (activeWalk) {
      return res.status(409).json({ error: 'Active walk already exists' });
    }
    
    const newWalk = {
      id: walkCounter++,
      UserId: userId,
      StartTime: new Date().toISOString(),
      EndTime: null,
      Distance: 0,
      Duration: 0
    };
    
    walks.push(newWalk);
    
    res.json({
      walk_id: newWalk.id,
      start_time: newWalk.StartTime,
      message: 'Walk started'
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

async function addTrackPoint(req, res) {
  try {
    const userId = req.userId;
    const walkId = parseInt(req.params.walkId);
    const { lat, lng, sequenceNumber } = req.body;
    
    if (!lat || !lng || sequenceNumber === undefined) {
      return res.status(400).json({ error: 'Missing: lat, lng, sequenceNumber' });
    }
    
    const walk = walks.find(w => w.id === walkId && w.UserId === userId);
    if (!walk) {
      return res.status(404).json({ error: 'Walk not found' });
    }
    if (walk.EndTime) {
      return res.status(400).json({ error: 'Walk already completed' });
    }
    
    // Сохраняем точку
    trackPoints.push({
      id: trackPointCounter++,
      WalkId: walkId,
      Lat: lat,
      Lng: lng,
      SequenceNumber: sequenceNumber,
      Created: new Date().toISOString()
    });
    
    // Проверка зон и выдача предметов
    let collectedItem = null;
    
    for (const zone of zones) {
      if (isPointInSquareZone(lat, lng, zone)) {
        const zoneItems = items.filter(item => item.zoneId === zone.id);
        
        for (const item of zoneItems) {
          const itemRarity = rarity.find(r => r.id === item.rarityId);
          const random = Math.random() * 100;
          
          if (random <= itemRarity.dropChance) {
            const alreadyCollected = collections.some(
              c => c.UserId === userId && c.WalkId === walkId && c.ItemId === item.id
            );
            
            if (!alreadyCollected) {
              collectedItem = {
                id: item.id,
                name: item.name,
                icon: item.icon,
                rarity: { type: itemRarity.type, dropChance: itemRarity.dropChance }
              };
              
              collections.push({
                id: collectionCounter++,
                UserId: userId,
                ItemId: item.id,
                WalkId: walkId
              });
              
              break;
            }
          }
        }
        
        if (collectedItem) break;
      }
    }
    
    res.json({
      success: true,
      collected_item: collectedItem
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

async function getWalkHistory(req, res) {
  try {
    const userId = req.userId;
    const limit = parseInt(req.query.limit) || 20;
    const offset = parseInt(req.query.offset) || 0;
    
    const userWalks = walks
      .filter(w => w.UserId === userId && w.EndTime)
      .sort((a, b) => new Date(b.StartTime) - new Date(a.StartTime))
      .slice(offset, offset + limit);
    
    res.json({
      total: walks.filter(w => w.UserId === userId && w.EndTime).length,
      walks: userWalks.map(w => ({
        id: w.id,
        start_time: w.StartTime,
        end_time: w.EndTime,
        distance_meters: w.Distance,
        duration_seconds: w.Duration,
        items_collected: collections.filter(c => c.UserId === userId && c.WalkId === w.id).length
      }))
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

async function getWalkDetails(req, res) {
  try {
    const userId = req.userId;
    const walkId = parseInt(req.params.walkId);
    
    const walk = walks.find(w => w.id === walkId && w.UserId === userId);
    if (!walk) {
      return res.status(404).json({ error: 'Walk not found' });
    }
    
    const points = trackPoints
      .filter(p => p.WalkId === walkId)
      .sort((a, b) => a.SequenceNumber - b.SequenceNumber);
    
    const walkCollections = collections.filter(c => c.UserId === userId && c.WalkId === walkId);
    
    const collectedItems = [];
    for (const col of walkCollections) {
      const item = items.find(i => i.id === col.ItemId);
      if (item) {
        collectedItems.push({
          id: item.id,
          name: item.name,
          icon: item.icon
        });
      }
    }
    
    res.json({
      id: walk.id,
      start_time: walk.StartTime,
      end_time: walk.EndTime,
      distance_meters: walk.Distance,
      duration_seconds: walk.Duration,
      route: points.map(p => ({
        lat: p.Lat,
        lng: p.Lng,
        sequence: p.SequenceNumber,
        time: p.Created
      })),
      collected_items: collectedItems
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

module.exports = {
  startWalk,
  addTrackPoint,
  endWalk,
  getWalkHistory,
  getWalkDetails
};