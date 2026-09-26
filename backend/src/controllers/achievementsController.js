// src/controllers/achievementsController.js

const db = require('../lib/db');

// ============================================================
// КОНТРОЛЛЕРЫ
// ============================================================

/**
 * Получить все достижения (список с целями)
 * GET /api/achievements
 */
async function getAllAchievements(req, res) {
  try {
    const result = await db.query(`
      SELECT
        a.id,
        a.name,
        a.description,
        a.score,
        a.icon,
        json_build_object(
          'id', at.id,
          'name', at.name
        ) AS achieve_type
      FROM achievement a
      JOIN achieve_types at
        ON a.achieve_type = at.id
      ORDER BY a.id
    `);

    res.json({ achievements: result.rows });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}


/**
 * Получить типы достижений
 * GET /api/achievements/types
 */
async function getAchievementTypes(req, res) {
  try {
    const result = await db.query(`
      SELECT *
      FROM achieve_types
      ORDER BY id
    `);

    res.json({ types: result.rows });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}


/**
 * Получить полученные достижения пользователя
 * GET /api/achievements/user
 */
async function getUserAchievements(req, res) {
  try {
    const userId = req.userId;

    const result = await db.query(`
      SELECT
        ua.id,
        ua.created_at,
        json_build_object(
          'id', a.id,
          'name', a.name,
          'description', a.description,
          'score', a.score,
          'icon', a.icon,
          'achieve_type', json_build_object(
            'id', at.id,
            'name', at.name
          )
        ) AS achievement
      FROM user_achievement ua
      JOIN achievement a
        ON ua.achievement_id = a.id
      JOIN achieve_types at
        ON a.achieve_type = at.id
      WHERE ua.user_id = $1
      ORDER BY ua.created_at
    `, [userId]);

    res.json({ achievements: result.rows });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}


/**
 * Получить прогресс пользователя по достижениям
 * GET /api/achievements/progress
 */
async function getAchievementProgress(req, res) {
  try {
    const userId = req.userId;

    // ========================================================
    // 1. Получаем статистику пользователя
    // ========================================================

    const statsResult = await db.query(`
      SELECT
        total_steps,
        total_walks,
        total_duration,
        total_distance
      FROM user_stats
      WHERE user_id = $1
      LIMIT 1
    `, [userId]);

    const stats = statsResult.rows[0] || null;

    const safeStats = stats || {
      total_steps: 0,
      total_walks: 0,
      total_duration: 0,
      total_distance: 0
    };


    // ========================================================
    // 2. Получаем все достижения
    // ========================================================

    const achievementsResult = await db.query(`
      SELECT
        a.id,
        a.name,
        a.description,
        a.score,
        a.icon,
        at.name AS achieve_type_name
      FROM achievement a
      JOIN achieve_types at
        ON a.achieve_type = at.id
      ORDER BY a.id
    `);

    const achievements = achievementsResult.rows;


    // ========================================================
    // 3. Получаем достижения пользователя
    // ========================================================

    const userAchievementsResult = await db.query(`
      SELECT
        achievement_id,
        created_at
      FROM user_achievement
      WHERE user_id = $1
    `, [userId]);

    const userAchievements = userAchievementsResult.rows;


    // ========================================================
    // 4. Создаём Map полученных достижений
    // ========================================================

    const earnedMap = new Map(
      userAchievements.map(a => [
        a.achievement_id,
        a.created_at
      ])
    );


    // ========================================================
    // 5. Формируем ответ
    // ========================================================

    const result = achievements.map(ach => {
      const type = ach.achieve_type_name;

      let currentValue = 0;

      switch (type) {
        case 'Шаги':
          currentValue = safeStats.total_steps;
          break;

        case 'Расстояние':
          currentValue = safeStats.total_distance;
          break;

        case 'Время':
          currentValue = safeStats.total_duration;
          break;

        case 'Прогулки':
          currentValue = safeStats.total_walks;
          break;
      }

      const target = ach.score;

      const progress = Math.min(
        100,
        Math.floor((currentValue / target) * 100)
      );

      const isEarned = earnedMap.has(ach.id);

      return {
        id: ach.id,
        name: ach.name,
        description: ach.description,
        icon: ach.icon,
        target,
        current_value: currentValue,
        progress_percent: isEarned ? 100 : progress,
        is_earned: isEarned,
        earned_at: earnedMap.get(ach.id) || null
      };
    });


    // ========================================================
    // 6. Сортировка
    // ========================================================

    result.sort((a, b) => {
      if (a.is_earned !== b.is_earned) {
        return a.is_earned ? 1 : -1;
      }

      return b.progress_percent - a.progress_percent;
    });


    res.json({ achievements: result });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}


// ============================================================
// ЭКСПОРТ
// ============================================================

module.exports = {
  getAllAchievements,
  getUserAchievements,
  getAchievementProgress,
  getAchievementTypes
};