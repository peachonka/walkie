// src/controllers/achievementsController.js
const supabase = require('../lib/supabaseClient');
// ============================================================
// КОНТРОЛЛЕРЫ
// ============================================================

/**
 * Получить все достижения (список с целями)
 * GET /api/achievements
 */
async function getAllAchievements(req, res) {
  try {
    const { data, error } = await supabase
      .from('achievement')
      .select(`
        id,
        name,
        description,
        score,
        icon,
        achieve_type (
          id,
          name
        )
      `);

    if (error) {
      return res.status(500).json({ error: error.message });
    }

    res.json({ achievements: data });
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
    const { data, error } = await supabase
      .from('achieve_type')
      .select('*');

    if (error) {
      return res.status(500).json({ error: error.message });
    }

    res.json({ types: data });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Получить полученные достижения пользователя (showcase_achievements)
 * GET /api/achievements/user
 */
async function getUserAchievements(req, res) {
  try {
    const userId = req.userId;

    const { data, error } = await supabase
      .from('user_achievement')
      .select(`
        id,
        created_at,
        achievement (
          id,
          name,
          description,
          score,
          icon,
          achieve_type (
            id,
            name
          )
        )
      `)
      .eq('user_id', userId);

    if (error) {
      return res.status(500).json({ error: error.message });
    }

    res.json({ achievements: data });
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

    // 1. stats
    const { data: stats, error: statsError } = await supabase
      .from('user_stats')
      .select('*')
      .eq('user_id', userId)
      .maybeSingle();

    if (statsError && statsError.code !== 'PGRST116') {
      return res.status(500).json({ error: statsError.message });
    }

    const safeStats = stats || {
      total_steps: 0,
      total_walks: 0,
      total_duration: 0,
      total_distance: 0
    };

    // 2. achievements
    const { data: achievements, error: achError } = await supabase
      .from('achievement')
      .select(`
        *,
        achieve_type (
          name
        )
      `);

    if (achError) {
      return res.status(500).json({ error: achError.message });
    }

    // 3. user achievements
    const { data: userAchievements, error: userAchError } = await supabase
      .from('user_achievement')
      .select('achievement_id, created_at')
      .eq('user_id', userId);

    if (userAchError) {
      return res.status(500).json({ error: userAchError.message });
    }

    const earnedMap = new Map(
      userAchievements.map(a => [a.achievement_id, a.created_at])
    );

    // 4. build response
    const result = achievements.map(ach => {
      const type = ach.achieve_type.name;

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
      const progress = Math.min(100, Math.floor((currentValue / target) * 100));

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

    // sort
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


// Экспортируем вспомогательные функции для интеграции с walksController
module.exports = {
  getAllAchievements,
  getUserAchievements,
  getAchievementProgress,
  getAchievementTypes
};