const db = require('../lib/db');

// ============================================================
// ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
// ============================================================

// Выбор редкости
function pickRarity(rarities) {
  const rand = Math.random();
  let cumulative = 0;

  for (const rarity of rarities) {
    cumulative += rarity.drop_chance;

    if (rand <= cumulative) {
      return rarity;
    }
  }

  return rarities[rarities.length - 1];
}

// ============================================================
// Генерация предметов за прогулку
// ============================================================

async function generateDrops(duration, client=db) {
  const attempts = Math.floor(duration / 600);

  if (attempts <= 0) {
    return [];
  }

  // 1. Получаем редкости
  const raritiesResult = await client.query(`
    SELECT *
    FROM rarity
  `);

  const rarities = raritiesResult.rows;

  // 2. Получаем все предметы
  const itemsResult = await client.query(`
    SELECT id, rarity_id
    FROM items
  `);

  const items = itemsResult.rows;

  const drops = [];

  for (let i = 0; i < attempts; i++) {

    // Шанс выпадения предмета вообще 80%
    if (Math.random() > 0.8) {
      continue;
    }

    // 3. Выбираем редкость
    const rarity = pickRarity(rarities);

    // 4. Фильтруем предметы этой редкости
    const itemsOfRarity =
      items.filter(item =>
        item.rarity_id === rarity.id
      );

    if (itemsOfRarity.length === 0) {
      continue;
    }

    // 5. Выбираем случайный предмет
    const randomItem =
      itemsOfRarity[
        Math.floor(
          Math.random() * itemsOfRarity.length
        )
      ];

    drops.push(randomItem.id);
  }

  return drops;
}

// ============================================================
// Обновление статистики пользователя
// ============================================================

async function updateUserStats(userId, client = db) {

  const result = await client.query(`
    SELECT
      distance,
      duration,
      steps
    FROM walk
    WHERE user_id = $1
      AND end_time IS NOT NULL
  `, [userId]);

  const walks = result.rows;

  const totalDistance = walks.reduce(
    (sum, walk) =>
      sum + (walk.distance || 0),
    0
  );

  const totalDuration = walks.reduce(
    (sum, walk) =>
      sum + (walk.duration || 0),
    0
  );

  const totalSteps = walks.reduce(
    (sum, walk) =>
      sum + (walk.steps || 0),
    0
  );

  await client.query(`
    INSERT INTO user_stats (
      user_id,
      total_distance,
      total_duration,
      total_steps,
      total_walks
    )
    VALUES ($1, $2, $3, $4, $5)
    ON CONFLICT (user_id)
    DO UPDATE SET
      total_distance = EXCLUDED.total_distance,
      total_duration = EXCLUDED.total_duration,
      total_steps = EXCLUDED.total_steps,
      total_walks = EXCLUDED.total_walks
  `, [
    userId,
    totalDistance,
    totalDuration,
    totalSteps,
    walks.length
  ]);
}

// ============================================================
// Проверка достижений
// ============================================================

async function checkAchievements(userId, client = db) {

  // 1. Получаем прогресс
  const statsResult = await client.query(`
    SELECT *
    FROM user_stats
    WHERE user_id = $1
    LIMIT 1
  `, [userId]);

  if (statsResult.rows.length === 0) {
    return [];
  }

  const stats = statsResult.rows[0];

  // 2. Получаем все достижения
  const achievementsResult = await client.query(`
    SELECT
      a.id,
      a.name,
      a.description,
      a.score,
      a.icon,
      json_build_object(
        'name', at.name
      ) AS type
    FROM achievement a
    JOIN achieve_types at
      ON a.achieve_type = at.id
  `);

  const achievements =
    achievementsResult.rows;

  // 3. Получаем уже полученные
  const userAchievementsResult =
    await client.query(`
      SELECT achievement_id
      FROM user_achievement
      WHERE user_id = $1
    `, [userId]);

  const userAchievements =
    userAchievementsResult.rows;

  const earnedIds =
    userAchievements.map(
      achievement => achievement.achievement_id
    );

  const newAchievements = [];

  // 4. Группируем по типу
  const grouped = {};

  for (const achievement of achievements) {
    const type = achievement.type.name;

    if (!grouped[type]) {
      grouped[type] = [];
    }

    grouped[type].push(achievement);
  }

  // 5. По каждому типу
  for (const type in grouped) {

    const list = grouped[type]
      .filter(
        achievement =>
          !earnedIds.includes(achievement.id)
      )
      .sort(
        (a, b) =>
          a.score - b.score
      );

    if (list.length === 0) {
      continue;
    }

    const nextAchievement = list[0];

    let value = 0;

    switch (type) {
      case 'Шаги':
        value = stats.total_steps;
        break;

      case 'Расстояние':
        value = stats.total_distance;
        break;

      case 'Время':
        value = stats.total_duration;
        break;

      case 'Прогулки':
        value = stats.total_walks;
        break;
    }

    if (value >= nextAchievement.score) {

      // Выдаём достижение
      await client.query(`
        INSERT INTO user_achievement (
          user_id,
          achievement_id
        )
        VALUES ($1, $2)
      `, [
        userId,
        nextAchievement.id
      ]);

      newAchievements.push(
        nextAchievement
      );
    }
  }

  return newAchievements;
}

/**
 * Начисление опыта питомцу за прогулку
 */
async function updatePetExp(userId, distance, client = db) {
  // 1. Рассчитываем опыт за прогулку
  const earnedExp = Math.floor(distance / 100);

  if (earnedExp <= 0) {
    return null;
  }

  // 2. Получаем питомца пользователя
  const petResult = await client.query(`
    SELECT *
    FROM user_pet
    WHERE user_id = $1
    FOR UPDATE
  `, [userId]);

  if (petResult.rows.length === 0) {
    return null;
  }

  const pet = petResult.rows[0];

  // 3. Начисляем опыт
  let exp = pet.exp + earnedExp;
  let level = pet.level;

  // 4. Проверяем повышение уровня
  while (exp >= 100) {
    exp -= 100;
    level += 1;
  }

  // 5. Сохраняем изменения
  const updateResult = await client.query(`
    UPDATE user_pet
    SET
      exp = $1,
      level = $2
    WHERE id = $3
    RETURNING *
  `, [exp, level, pet.id]);

  return {
    ...updateResult.rows[0],
    earned_exp: earnedExp
  };
}

module.exports = {
  generateDrops,
  updateUserStats,
  checkAchievements,
  updatePetExp
};