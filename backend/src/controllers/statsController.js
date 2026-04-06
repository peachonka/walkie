// src/controllers/statsController.js

// ============================================================
// ВРЕМЕННОЕ ХРАНИЛИЩЕ (МОКИ)
// ============================================================

// walks — данные о прогулках (для пересчета статистики)
let walks = [
  { id: 1, UserId: 1, StartTime: '2026-03-01T10:00:00Z', EndTime: '2026-03-01T10:30:00Z', Distance: 1250, Duration: 1800 },
  { id: 2, UserId: 1, StartTime: '2026-03-03T15:00:00Z', EndTime: '2026-03-03T15:45:00Z', Distance: 2200, Duration: 2700 },
  { id: 3, UserId: 1, StartTime: '2026-03-05T09:00:00Z', EndTime: '2026-03-05T09:20:00Z', Distance: 800, Duration: 1200 },
  { id: 4, UserId: 1, StartTime: '2026-03-10T16:30:00Z', EndTime: '2026-03-10T17:15:00Z', Distance: 1800, Duration: 2700 },
  { id: 5, UserId: 1, StartTime: '2026-03-12T11:00:00Z', EndTime: '2026-03-12T12:00:00Z', Distance: 3000, Duration: 3600 },
  { id: 6, UserId: 1, StartTime: '2026-03-15T14:00:00Z', EndTime: '2026-03-15T14:25:00Z', Distance: 950, Duration: 1500 },
  { id: 7, UserId: 1, StartTime: '2026-03-18T09:30:00Z', EndTime: '2026-03-18T10:30:00Z', Distance: 2800, Duration: 3600 },
  { id: 8, UserId: 1, StartTime: '2026-03-20T17:00:00Z', EndTime: '2026-03-20T17:40:00Z', Distance: 1600, Duration: 2400 },
  { id: 9, UserId: 1, StartTime: '2026-03-25T12:00:00Z', EndTime: '2026-03-25T12:35:00Z', Distance: 1400, Duration: 2100 },
  { id: 10, UserId: 1, StartTime: '2026-03-28T15:30:00Z', EndTime: '2026-03-28T16:10:00Z', Distance: 2100, Duration: 2400 }
];

// user_stats — ERD: id, UserId, TotalDistance, TotalDuration, TotalWalks, TotalSteps
let userStats = [
  {
    id: 1,
    UserId: 1,
    TotalDistance: 17900,    // в метрах = 17.9 км
    TotalDuration: 23700,    // в секундах = 6.58 часов
    TotalWalks: 10,
    TotalSteps: 23867        // TotalDistance / 0.75
  }
];

// collections — для подсчета собранных предметов
let collections = [
  { id: 1, UserId: 1, ItemId: 1, WalkId: 1 },
  { id: 2, UserId: 1, ItemId: 2, WalkId: 1 },
  { id: 3, UserId: 1, ItemId: 1, WalkId: 2 },
  { id: 4, UserId: 1, ItemId: 5, WalkId: 3 },
  { id: 5, UserId: 1, ItemId: 3, WalkId: 4 },
  { id: 6, UserId: 1, ItemId: 1, WalkId: 5 },
  { id: 7, UserId: 1, ItemId: 1, WalkId: 6 },
  { id: 8, UserId: 1, ItemId: 2, WalkId: 7 },
  { id: 9, UserId: 1, ItemId: 1, WalkId: 8 },
  { id: 10, UserId: 1, ItemId: 4, WalkId: 9 },
  { id: 11, UserId: 1, ItemId: 1, WalkId: 10 },
  { id: 12, UserId: 1, ItemId: 6, WalkId: 10 }
];

// ============================================================
// ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
// ============================================================

/**
 * Пересчитать статистику пользователя на основе прогулок
 */
function recalculateUserStats(userId) {
  const userWalks = walks.filter(w => w.UserId === userId && w.EndTime);
  
  const totalDistance = userWalks.reduce((sum, w) => sum + (w.Distance || 0), 0);
  const totalDuration = userWalks.reduce((sum, w) => sum + (w.Duration || 0), 0);
  const totalWalks = userWalks.length;
  const totalSteps = Math.floor(totalDistance / 0.75);
  
  const existing = userStats.find(s => s.UserId === userId);
  if (existing) {
    existing.TotalDistance = totalDistance;
    existing.TotalDuration = totalDuration;
    existing.TotalWalks = totalWalks;
    existing.TotalSteps = totalSteps;
  } else {
    userStats.push({
      id: userStats.length + 1,
      UserId: userId,
      TotalDistance: totalDistance,
      TotalDuration: totalDuration,
      TotalWalks: totalWalks,
      TotalSteps: totalSteps
    });
  }
  
  return { totalDistance, totalDuration, totalWalks, totalSteps };
}

// ============================================================
// КОНТРОЛЛЕРЫ
// ============================================================

/**
 * Получить общую статистику пользователя
 * GET /api/stats
 */
async function getUserStats(req, res) {
  try {
    const userId = req.userId;
    
    // Получаем или пересчитываем статистику
    let stats = userStats.find(s => s.UserId === userId);
    if (!stats) {
      stats = recalculateUserStats(userId);
    }
    
    // Подсчитываем общее количество собранных предметов
    const totalItemsCollected = collections.filter(c => c.UserId === userId).length;
    
    // Находим первую и последнюю прогулку
    const userWalks = walks.filter(w => w.UserId === userId && w.EndTime);
    const sortedWalks = userWalks.sort((a, b) => new Date(a.StartTime) - new Date(b.StartTime));
    
    const firstWalkDate = sortedWalks.length > 0 ? sortedWalks[0].StartTime.split('T')[0] : null;
    const lastWalkDate = sortedWalks.length > 0 ? sortedWalks[sortedWalks.length - 1].StartTime.split('T')[0] : null;
    
    res.json({
      total_distance_km: parseFloat((stats.TotalDistance / 1000).toFixed(2)),
      total_duration_hours: parseFloat((stats.TotalDuration / 3600).toFixed(1)),
      total_walks: stats.TotalWalks,
      total_steps: stats.TotalSteps,
      total_items_collected: totalItemsCollected,
      first_walk_date: firstWalkDate,
      last_walk_date: lastWalkDate
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Получить статистику за период
 * GET /api/stats/period?start_date=YYYY-MM-DD&end_date=YYYY-MM-DD
 */
async function getStatsByPeriod(req, res) {
  try {
    const userId = req.userId;
    const { start_date, end_date } = req.query;
    
    if (!start_date || !end_date) {
      return res.status(400).json({ error: 'Missing required params: start_date, end_date' });
    }
    
    const startDate = new Date(start_date);
    const endDate = new Date(end_date);
    endDate.setHours(23, 59, 59, 999);
    
    // Фильтруем прогулки за период
    const periodWalks = walks.filter(w => {
      if (w.UserId !== userId) return false;
      if (!w.EndTime) return false;
      const walkDate = new Date(w.StartTime);
      return walkDate >= startDate && walkDate <= endDate;
    });
    
    // Агрегируем данные
    let totalDistance = 0;
    let totalDuration = 0;
    let totalItemsCollected = 0;
    
    // Получаем все коллекции пользователя
    const userCollections = collections.filter(c => c.UserId === userId);
    
    for (const walk of periodWalks) {
      totalDistance += walk.Distance || 0;
      totalDuration += walk.Duration || 0;
      
      const walkCollections = userCollections.filter(c => c.WalkId === walk.id);
      totalItemsCollected += walkCollections.length;
    }
    
    const totalWalks = periodWalks.length;
    const totalSteps = Math.floor(totalDistance / 0.75);
    
    // Дневная разбивка
    const dailyBreakdown = {};
    for (const walk of periodWalks) {
      const date = walk.StartTime.split('T')[0];
      if (!dailyBreakdown[date]) {
        dailyBreakdown[date] = {
          date: date,
          distance_km: 0,
          duration_min: 0,
          walks_count: 0,
          items_collected: 0
        };
      }
      dailyBreakdown[date].distance_km += (walk.Distance || 0) / 1000;
      dailyBreakdown[date].duration_min += (walk.Duration || 0) / 60;
      dailyBreakdown[date].walks_count++;
      
      const walkCollections = collections.filter(c => c.UserId === userId && c.WalkId === walk.id);
      dailyBreakdown[date].items_collected += walkCollections.length;
    }
    
    // Округляем значения
    for (const date in dailyBreakdown) {
      dailyBreakdown[date].distance_km = parseFloat(dailyBreakdown[date].distance_km.toFixed(2));
      dailyBreakdown[date].duration_min = parseFloat(dailyBreakdown[date].duration_min.toFixed(1));
    }
    
    res.json({
      start_date: start_date,
      end_date: end_date,
      total_distance_km: parseFloat((totalDistance / 1000).toFixed(2)),
      total_duration_hours: parseFloat((totalDuration / 3600).toFixed(1)),
      total_walks: totalWalks,
      total_steps: totalSteps,
      total_items_collected: totalItemsCollected,
      daily_breakdown: Object.values(dailyBreakdown).sort((a, b) => a.date.localeCompare(b.date))
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Получить статистику по дням (для графика)
 * GET /api/stats/daily?limit=30
 */
async function getDailyStats(req, res) {
  try {
    const userId = req.userId;
    const limit = parseInt(req.query.limit) || 30;
    
    const userWalks = walks
      .filter(w => w.UserId === userId && w.EndTime)
      .sort((a, b) => new Date(b.StartTime) - new Date(a.StartTime));
    
    const dailyMap = new Map();
    
    for (const walk of userWalks) {
      const date = walk.StartTime.split('T')[0];
      if (!dailyMap.has(date)) {
        dailyMap.set(date, {
          date: date,
          distance_km: 0,
          duration_min: 0,
          walks_count: 0,
          items_collected: 0
        });
      }
      const day = dailyMap.get(date);
      day.distance_km += (walk.Distance || 0) / 1000;
      day.duration_min += (walk.Duration || 0) / 60;
      day.walks_count++;
      
      const walkCollections = collections.filter(c => c.UserId === userId && c.WalkId === walk.id);
      day.items_collected += walkCollections.length;
    }
    
    // Преобразуем в массив, сортируем по дате (сначала новые), берем limit
    let result = Array.from(dailyMap.values());
    result.sort((a, b) => b.date.localeCompare(a.date));
    result = result.slice(0, limit);
    
    // Округляем
    result.forEach(day => {
      day.distance_km = parseFloat(day.distance_km.toFixed(2));
      day.duration_min = parseFloat(day.duration_min.toFixed(1));
    });
    
    res.json({
      limit: limit,
      total_days: result.length,
      daily_stats: result
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

module.exports = {
  getUserStats,
  getStatsByPeriod,
  getDailyStats,
  recalculateUserStats  // экспортируем для использования в других контроллерах
};