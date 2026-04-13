// src/controllers/statsController.js
const supabase = require('../lib/supabaseClient');
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

    // 1. Получаем агрегированную статистику
    const { data: stats, error: statsError } = await supabase
      .from('user_stats')
      .select('*')
      .eq('user_id', userId)
      .maybeSingle();

    if (statsError && statsError.code !== 'PGRST116') {
      return res.status(500).json({ error: statsError.message });
    }

    const safeStats = stats || {
      total_distance: 0,
      total_duration: 0,
      total_walks: 0,
      total_steps: 0
    };

    // 2. Количество предметов
    const { count: itemsCount, error: itemsError } = await supabase
      .from('user_item')
      .select('*', { count: 'exact', head: true })
      .eq('user_id', userId);

    if (itemsError) {
      return res.status(500).json({ error: itemsError.message });
    }

    // 3. Первая прогулка
    const { data: firstWalk } = await supabase
      .from('walk')
      .select('start_time')
      .eq('user_id', userId)
      .not('end_time', 'is', null)
      .order('start_time', { ascending: true })
      .limit(1)
      .single();

    // 4. Последняя прогулка
    const { data: lastWalk } = await supabase
      .from('walk')
      .select('start_time')
      .eq('user_id', userId)
      .not('end_time', 'is', null)
      .order('start_time', { ascending: false })
      .limit(1)
      .single();

    res.json({
      total_distance_km: parseFloat((safeStats.total_distance / 1000).toFixed(2)),
      total_duration_hours: parseFloat((safeStats.total_duration / 3600).toFixed(1)),
      total_walks: safeStats.total_walks,
      total_steps: safeStats.total_steps,
      total_items_collected: itemsCount || 0,
      first_walk_date: firstWalk ? firstWalk.start_time.split('T')[0] : null,
      last_walk_date: lastWalk ? lastWalk.start_time.split('T')[0] : null
    });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Получить статистику за период
 * GET /api/stats/period?start_date=YYYY-MM-DD&end_date=YYYY-MM-DD
 */
// async function getStatsByPeriod(req, res) {
//   try {
//     const userId = req.userId;
//     const { start_date, end_date } = req.query;
    
//     if (!start_date || !end_date) {
//       return res.status(400).json({ error: 'Missing required params: start_date, end_date' });
//     }
    
//     const startDate = new Date(start_date);
//     const endDate = new Date(end_date);
//     endDate.setHours(23, 59, 59, 999);
    
//     // Фильтруем прогулки за период
//     const periodWalks = walks.filter(w => {
//       if (w.UserId !== userId) return false;
//       if (!w.EndTime) return false;
//       const walkDate = new Date(w.StartTime);
//       return walkDate >= startDate && walkDate <= endDate;
//     });
    
//     // Агрегируем данные
//     let totalDistance = 0;
//     let totalDuration = 0;
//     let totalItemsCollected = 0;
    
//     // Получаем все коллекции пользователя
//     const userCollections = collections.filter(c => c.UserId === userId);
    
//     for (const walk of periodWalks) {
//       totalDistance += walk.Distance || 0;
//       totalDuration += walk.Duration || 0;
      
//       const walkCollections = userCollections.filter(c => c.WalkId === walk.id);
//       totalItemsCollected += walkCollections.length;
//     }
    
//     const totalWalks = periodWalks.length;
//     const totalSteps = Math.floor(totalDistance / 0.75);
    
//     // Дневная разбивка
//     const dailyBreakdown = {};
//     for (const walk of periodWalks) {
//       const date = walk.StartTime.split('T')[0];
//       if (!dailyBreakdown[date]) {
//         dailyBreakdown[date] = {
//           date: date,
//           distance_km: 0,
//           duration_min: 0,
//           walks_count: 0,
//           items_collected: 0
//         };
//       }
//       dailyBreakdown[date].distance_km += (walk.Distance || 0) / 1000;
//       dailyBreakdown[date].duration_min += (walk.Duration || 0) / 60;
//       dailyBreakdown[date].walks_count++;
      
//       const walkCollections = collections.filter(c => c.UserId === userId && c.WalkId === walk.id);
//       dailyBreakdown[date].items_collected += walkCollections.length;
//     }
    
//     // Округляем значения
//     for (const date in dailyBreakdown) {
//       dailyBreakdown[date].distance_km = parseFloat(dailyBreakdown[date].distance_km.toFixed(2));
//       dailyBreakdown[date].duration_min = parseFloat(dailyBreakdown[date].duration_min.toFixed(1));
//     }
    
//     res.json({
//       start_date: start_date,
//       end_date: end_date,
//       total_distance_km: parseFloat((totalDistance / 1000).toFixed(2)),
//       total_duration_hours: parseFloat((totalDuration / 3600).toFixed(1)),
//       total_walks: totalWalks,
//       total_steps: totalSteps,
//       total_items_collected: totalItemsCollected,
//       daily_breakdown: Object.values(dailyBreakdown).sort((a, b) => a.date.localeCompare(b.date))
//     });
//   } catch (error) {
//     res.status(500).json({ error: error.message });
//   }
// }

/**
 * Получить статистику по дням (для графика)
 * GET /api/stats/daily?limit=30
 */
async function getDailyStats(req, res) {
  try {
    const userId = req.userId;
    const { start_date, end_date } = req.query;
    const limit = parseInt(req.query.limit) || null;

    // 1. Получаем прогулки
    let query = supabase
      .from('walk')
      .select('id, start_time, distance, duration')
      .eq('user_id', userId)
      .not('end_time', 'is', null);

    if (start_date) {
      query = query.gte('start_time', start_date);
    }

    if (end_date) {
      const end = new Date(end_date);
      end.setHours(23, 59, 59, 999);
      query = query.lte('start_time', end.toISOString());
    }

    const { data: walks, error: walksError } = await query;

    if (walksError) {
      return res.status(500).json({ error: walksError.message });
    }

    if (!walks || walks.length === 0) {
      return res.json({ daily_stats: [] });
    }

    // 2. Получаем предметы пользователя
    const { data: items, error: itemsError } = await supabase
      .from('user_item')
      .select('walk_id')
      .eq('user_id', userId);

    if (itemsError) {
      return res.status(500).json({ error: itemsError.message });
    }

    // 3. Группируем предметы по прогулкам
    const itemsMap = {};
    for (const item of items) {
      if (!itemsMap[item.walk_id]) itemsMap[item.walk_id] = 0;
      itemsMap[item.walk_id]++;
    }

    // 4. Группируем по дням
    const dailyMap = {};

    for (const walk of walks) {
      const date = walk.start_time.split('T')[0];

      if (!dailyMap[date]) {
        dailyMap[date] = {
          date,
          distance_km: 0,
          duration_min: 0,
          walks_count: 0,
          items_collected: 0
        };
      }

      dailyMap[date].distance_km += (walk.distance || 0) / 1000;
      dailyMap[date].duration_min += (walk.duration || 0) / 60;
      dailyMap[date].walks_count++;

      dailyMap[date].items_collected += itemsMap[walk.id] || 0;
    }

    // 5. Преобразуем в массив
    let result = Object.values(dailyMap);

    // 6. Сортировка
    result.sort((a, b) => b.date.localeCompare(a.date));

    // 7. Limit
    if (limit) {
      result = result.slice(0, limit);
    }

    // 8. Округление
    result.forEach(day => {
      day.distance_km = parseFloat(day.distance_km.toFixed(2));
      day.duration_min = parseFloat(day.duration_min.toFixed(1));
    });

    res.json({
      total_days: result.length,
      daily_stats: result
    });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

module.exports = {
  getUserStats,
  getDailyStats,
};