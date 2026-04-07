// src/controllers/achievementsController.js

// ============================================================
// ВРЕМЕННОЕ ХРАНИЛИЩЕ (МОКИ)
// ============================================================

// achieve_types — ERD: id, Name
const achieveTypes = [
  { id: 1, name: 'steps' },      // достижения по шагам
  { id: 2, name: 'walks' },      // достижения по количеству прогулок
  { id: 3, name: 'duration' }    // достижения по времени прогулок
];

// achievements — ERD: id, Name, AchieveTypeId, Description, Score, Icon
// Score — это ЦЕЛЬ (сколько нужно достичь)
const achievements = [
  // Достижения по шагам (type: steps)
  {
    id: 1,
    name: 'Первый шаг',
    achieveTypeId: 1,
    description: 'Сделать первые 1000 шагов',
    score: 1000,      // цель: 1000 шагов
    icon: '/achievements/first-step.png'
  },
  {
    id: 2,
    name: 'Начинающий ходок',
    achieveTypeId: 1,
    description: 'Сделать 5000 шагов',
    score: 5000,      // цель: 5000 шагов
    icon: '/achievements/walker.png'
  },
  {
    id: 3,
    name: 'Марафонец',
    achieveTypeId: 1,
    description: 'Сделать 10000 шагов',
    score: 10000,     // цель: 10000 шагов
    icon: '/achievements/marathon.png'
  },
  
  // Достижения по количеству прогулок (type: walks)
  {
    id: 4,
    name: 'Первая прогулка',
    achieveTypeId: 2,
    description: 'Совершить 1 прогулку',
    score: 1,         // цель: 1 прогулка
    icon: '/achievements/first-walk.png'
  },
  {
    id: 5,
    name: 'Любитель прогулок',
    achieveTypeId: 2,
    description: 'Совершить 10 прогулок',
    score: 10,        // цель: 10 прогулок
    icon: '/achievements/lover.png'
  },
  
  // Достижения по времени прогулок (type: duration) — в СЕКУНДАХ
  {
    id: 6,
    name: 'Час на свежем воздухе',
    achieveTypeId: 3,
    description: 'Нагулять 1 час',
    score: 3600,      // цель: 3600 секунд (1 час)
    icon: '/achievements/one-hour.png'
  },
  {
    id: 7,
    name: 'Исследователь',
    achieveTypeId: 3,
    description: 'Нагулять 10 часов',
    score: 36000,     // цель: 36000 секунд (10 часов)
    icon: '/achievements/explorer.png'
  }
];

// showcase_achievements — ERD: id, UserId, AchievementId
// Это ВСЕ полученные достижения пользователя (как collection)
let showcaseAchievements = [
  // Пример: пользователь с id=1 уже получил достижение 4 (Первая прогулка)
  { id: 1, UserId: 1, AchievementId: 4, earnedAt: '2026-03-28T10:00:00Z' }
];

// Данные пользователя для проверки достижений
let userProgress = {
  1: {  // userId = 1
    totalSteps: 15000,      // 15000 шагов (уже есть достижения 1,2,3)
    totalWalks: 5,          // 5 прогулок (есть достижение 4, нет 5)
    totalDuration: 18000,   // 18000 секунд = 5 часов (есть достижение 6, нет 7)
    lastCheckedAt: new Date().toISOString()
  }
};

// ============================================================
// ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
// ============================================================

/**
 * Обновить прогресс пользователя
 */
function updateUserProgress(userId, steps, walks, duration) {
  if (!userProgress[userId]) {
    userProgress[userId] = { totalSteps: 0, totalWalks: 0, totalDuration: 0 };
  }
  userProgress[userId].totalSteps = steps;
  userProgress[userId].totalWalks = walks;
  userProgress[userId].totalDuration = duration;
  userProgress[userId].lastCheckedAt = new Date().toISOString();
}

/**
 * Проверить и выдать новые достижения пользователя
 * Возвращает массив новых полученных достижений
 */
function checkAndAwardAchievements(userId, progress) {
  const newlyEarned = [];
  
  // Получаем уже полученные достижения пользователя
  const earnedIds = showcaseAchievements
    .filter(sa => sa.UserId === userId)
    .map(sa => sa.AchievementId);
  
  for (const achievement of achievements) {
    // Пропускаем уже полученные
    if (earnedIds.includes(achievement.id)) continue;
    
    let isEarned = false;
    
    switch (achievement.achieveTypeId) {
      case 1: // steps — сравниваем шаги с целью (score)
        if (progress.totalSteps >= achievement.score) {
          isEarned = true;
        }
        break;
      case 2: // walks — сравниваем количество прогулок с целью (score)
        if (progress.totalWalks >= achievement.score) {
          isEarned = true;
        }
        break;
      case 3: // duration — сравниваем время с целью (score)
        if (progress.totalDuration >= achievement.score) {
          isEarned = true;
        }
        break;
    }
    
    if (isEarned) {
      // Выдаем достижение — добавляем в showcase_achievements
      const newId = showcaseAchievements.length + 1;
      showcaseAchievements.push({
        id: newId,
        UserId: userId,
        AchievementId: achievement.id,
        earnedAt: new Date().toISOString()
      });
      
      newlyEarned.push({
        id: achievement.id,
        name: achievement.name,
        description: achievement.description,
        score: achievement.score,
        icon: achievement.icon,
        earned_at: new Date().toISOString()
      });
    }
  }
  
  return newlyEarned;
}

// ============================================================
// КОНТРОЛЛЕРЫ
// ============================================================

/**
 * Получить все достижения (список с целями)
 * GET /api/achievements
 */
async function getAllAchievements(req, res) {
  try {
    const result = achievements.map(ach => {
      const type = achieveTypes.find(t => t.id === ach.achieveTypeId);
      return {
        id: ach.id,
        name: ach.name,
        description: ach.description,
        target: ach.score,        // цель (сколько нужно достичь)
        icon: ach.icon,
        type: type ? type.name : 'unknown'
      };
    });
    
    res.json({
      total: result.length,
      achievements: result
    });
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
    
    // Получаем ВСЕ полученные достижения пользователя
    const userAchievements = showcaseAchievements.filter(sa => sa.UserId === userId);
    
    const result = [];
    for (const ua of userAchievements) {
      const ach = achievements.find(a => a.id === ua.AchievementId);
      if (ach) {
        const type = achieveTypes.find(t => t.id === ach.achieveTypeId);
        result.push({
          id: ach.id,
          name: ach.name,
          description: ach.description,
          target: ach.score,
          icon: ach.icon,
          type: type ? type.name : 'unknown',
          earned_at: ua.earnedAt
        });
      }
    }
    
    // Сортируем по дате получения (сначала новые)
    result.sort((a, b) => new Date(b.earned_at) - new Date(a.earned_at));
    
    res.json({
      total: result.length,
      achievements: result
    });
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
    
    const progress = userProgress[userId] || { totalSteps: 0, totalWalks: 0, totalDuration: 0 };
    const earnedIds = showcaseAchievements
      .filter(sa => sa.UserId === userId)
      .map(sa => sa.AchievementId);
    
    const result = [];
    
    for (const achievement of achievements) {
      let currentValue = 0;
      let isEarned = earnedIds.includes(achievement.id);
      
      switch (achievement.achieveTypeId) {
        case 1: // steps
          currentValue = progress.totalSteps;
          break;
        case 2: // walks
          currentValue = progress.totalWalks;
          break;
        case 3: // duration
          currentValue = progress.totalDuration;
          break;
      }
      
      const targetValue = achievement.score;
      const progressPercent = Math.min(100, Math.floor((currentValue / targetValue) * 100));
      
      result.push({
        id: achievement.id,
        name: achievement.name,
        description: achievement.description,
        target: targetValue,
        current_value: currentValue,
        progress_percent: isEarned ? 100 : progressPercent,
        is_earned: isEarned,
        earned_at: isEarned ? showcaseAchievements.find(sa => sa.UserId === userId && sa.AchievementId === achievement.id)?.earnedAt : null,
        icon: achievement.icon
      });
    }
    
    // Сортируем: сначала неполученные, потом полученные
    result.sort((a, b) => {
      if (a.is_earned !== b.is_earned) {
        return a.is_earned ? 1 : -1;
      }
      return b.progress_percent - a.progress_percent;
    });
    
    res.json({
      achievements: result
    });
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
    res.json({
      types: achieveTypes.map(t => ({
        id: t.id,
        name: t.name
      }))
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Принудительно проверить и выдать достижения (вызывается после обновления статистики)
 * POST /api/achievements/check
 */
async function checkAchievements(req, res) {
  try {
    const userId = req.userId;
    const progress = userProgress[userId];
    
    if (!progress) {
      return res.json({
        success: true,
        new_achievements: [],
        message: 'No progress data yet'
      });
    }
    
    const newAchievements = checkAndAwardAchievements(userId, progress);
    
    res.json({
      success: true,
      new_achievements: newAchievements,
      message: newAchievements.length > 0 ? 'New achievements earned!' : 'No new achievements'
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

// Экспортируем вспомогательные функции для интеграции с walksController
module.exports = {
  getAllAchievements,
  getUserAchievements,
  getAchievementProgress,
  getAchievementTypes,
  checkAchievements,
  updateUserProgress,
  checkAndAwardAchievements
};