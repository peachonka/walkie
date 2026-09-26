// src/controllers/statsController.js

const db = require('../lib/db');

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
    const statsResult = await db.query(`
      SELECT
        total_distance,
        total_duration,
        total_walks,
        total_steps
      FROM user_stats
      WHERE user_id = $1
      LIMIT 1
    `, [userId]);

    const stats = statsResult.rows[0] || null;

    const safeStats = stats || {
      total_distance: 0,
      total_duration: 0,
      total_walks: 0,
      total_steps: 0
    };

    // 2. Количество предметов
    const itemsResult = await db.query(`
      SELECT COUNT(*) AS count
      FROM user_item
      WHERE user_id = $1
    `, [userId]);

    const itemsCount = parseInt(itemsResult.rows[0].count);

    // 3. Первая прогулка
    const firstWalkResult = await db.query(`
      SELECT start_time
      FROM walk
      WHERE user_id = $1
        AND end_time IS NOT NULL
      ORDER BY start_time ASC
      LIMIT 1
    `, [userId]);

    const firstWalk = firstWalkResult.rows[0] || null;

    // 4. Последняя прогулка
    const lastWalkResult = await db.query(`
      SELECT start_time
      FROM walk
      WHERE user_id = $1
        AND end_time IS NOT NULL
      ORDER BY start_time DESC
      LIMIT 1
    `, [userId]);

    const lastWalk = lastWalkResult.rows[0] || null;

    // PostgreSQL / node-postgres может вернуть timestamp
    // не в том же виде, что Supabase.
    const getDateOnly = value => {
      if (!value) return null;

      return new Date(value)
        .toISOString()
        .split('T')[0];
    };

    res.json({
      total_distance_km: parseFloat(
        (safeStats.total_distance / 1000).toFixed(2)
      ),

      total_duration_hours: parseFloat(
        (safeStats.total_duration / 3600).toFixed(1)
      ),

      total_walks: safeStats.total_walks,
      total_steps: safeStats.total_steps,
      total_items_collected: itemsCount || 0,

      first_walk_date: getDateOnly(
        firstWalk?.start_time
      ),

      last_walk_date: getDateOnly(
        lastWalk?.start_time
      )
    });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Получить статистику по дням
 * GET /api/stats/daily?limit=30
 */
async function getDailyStats(req, res) {
  try {
    const userId = req.userId;
    const { start_date, end_date } = req.query;
    const limit = parseInt(req.query.limit) || null;

    // 1. Получаем прогулки
    let query = `
      SELECT
        id,
        start_time,
        distance,
        duration
      FROM walk
      WHERE user_id = $1
        AND end_time IS NOT NULL
    `;

    const params = [userId];
    let paramIndex = 2;

    if (start_date) {
      query += `
        AND start_time >= $${paramIndex}
      `;
      params.push(start_date);
      paramIndex++;
    }

    if (end_date) {
      const end = new Date(end_date);
      end.setHours(23, 59, 59, 999);

      query += `
        AND start_time <= $${paramIndex}
      `;
      params.push(end.toISOString());
      paramIndex++;
    }

    const walksResult = await db.query(query, params);
    const walks = walksResult.rows;

    if (walks.length === 0) {
      return res.json({
        daily_stats: []
      });
    }

    // 2. Получаем предметы пользователя
    const itemsResult = await db.query(`
      SELECT walk_id
      FROM user_item
      WHERE user_id = $1
    `, [userId]);

    const items = itemsResult.rows;

    // 3. Группируем предметы по прогулкам
    const itemsMap = {};

    for (const item of items) {
      if (!itemsMap[item.walk_id]) {
        itemsMap[item.walk_id] = 0;
      }

      itemsMap[item.walk_id]++;
    }

    // 4. Группируем по дням
    const dailyMap = {};

    for (const walk of walks) {
      const date = new Date(walk.start_time)
        .toISOString()
        .split('T')[0];

      if (!dailyMap[date]) {
        dailyMap[date] = {
          date,
          distance_km: 0,
          duration_min: 0,
          walks_count: 0,
          items_collected: 0
        };
      }

      dailyMap[date].distance_km +=
        (walk.distance || 0) / 1000;

      dailyMap[date].duration_min +=
        (walk.duration || 0) / 60;

      dailyMap[date].walks_count++;

      dailyMap[date].items_collected +=
        itemsMap[walk.id] || 0;
    }

    // 5. Преобразуем в массив
    let result = Object.values(dailyMap);

    // 6. Сортировка
    result.sort((a, b) =>
      b.date.localeCompare(a.date)
    );

    // 7. Limit
    if (limit) {
      result = result.slice(0, limit);
    }

    // 8. Округление
    result.forEach(day => {
      day.distance_km = parseFloat(
        day.distance_km.toFixed(2)
      );

      day.duration_min = parseFloat(
        day.duration_min.toFixed(1)
      );
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
  getDailyStats
};