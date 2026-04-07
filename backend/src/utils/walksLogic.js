const supabase = require('../lib/supabaseClient');

// выбор редкости
function pickRarity(rarities) {
  const rand = Math.random();
  let cumulative = 0;

  for (const rarity of rarities) {
    cumulative += rarity.drop_chance;
    if (rand <= cumulative) {
      return rarity;
    }
  }

  return rarities[rarities.length - 1]; // fallback
}

// генерация предметов за прогулку
async function generateDrops(duration) {
  const attempts = Math.floor(duration / 600); // каждые 10 минут

  if (attempts <= 0) return [];

  // 1. Получаем редкости
  const { data: rarities } = await supabase
    .from('rarity')
    .select('*');

  // 2. Получаем все предметы
  const { data: items } = await supabase
    .from('items')
    .select('id, rarity_id');

  const drops = [];

  for (let i = 0; i < attempts; i++) {
    // шанс выпадения предмета вообще 80%
    if (Math.random() > 0.8) continue;


    // 3. выбираем редкость
    const rarity = pickRarity(rarities);

    // 4. фильтруем предметы этой редкости
    const itemsOfRarity = items.filter(i => i.rarity_id === rarity.id);

    if (itemsOfRarity.length === 0) continue;

    // 5. выбираем случайный предмет
    const randomItem = itemsOfRarity[Math.floor(Math.random() * itemsOfRarity.length)];

    drops.push(randomItem.id);
  }
  return drops;
}

// обновление статистики пользователя
// для каждого пользователя - одна строка в таблице
async function updateUserStats(userId) {
  const { data: walks } = await supabase
    .from('walk')
    .select('distance, duration')
    .eq('user_id', userId)
    .not('end_time', 'is', null);

  const totalDistance = walks.reduce((sum, w) => sum + (w.distance || 0), 0);
  const totalDuration = walks.reduce((sum, w) => sum + (w.duration || 0), 0);

  await supabase
    .from('user_stats')
    .upsert({
      user_id: userId,
      total_distance: totalDistance,
      total_duration: totalDuration,
      total_walks: walks.length
    });
}

// проверка достижений
async function checkAchievements(userId) {
  // 1. Получаем прогресс
  const { data: stats } = await supabase
    .from('user_stats')
    .select('*')
    .eq('user_id', userId)
    .single();

  if (!stats) return [];

  // 2. Получаем все достижения
  const { data: achievements } = await supabase
    .from('achievement')
    .select(`
      *,
      type:achieve_type (name)
    `);

  // 3. Получаем уже полученные
  const { data: userAchievements } = await supabase
    .from('user_achievement')
    .select('achievement_id')
    .eq('user_id', userId);

  const earnedIds = userAchievements.map(a => a.achievement_id);

  const newAchievements = [];

  // 4. группируем по типу
  const grouped = {};

  for (const ach of achievements) {
    const type = ach.type.name;

    if (!grouped[type]) grouped[type] = [];
    grouped[type].push(ach);
  }

  // 5. по каждому типу
  for (const type in grouped) {
    const list = grouped[type]
      .filter(a => !earnedIds.includes(a.id))
      .sort((a, b) => a.score - b.score);

    if (list.length === 0) continue;

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
      // выдаем
      await supabase.from('user_achievement').insert({
        user_id: userId,
        achievement_id: nextAchievement.id
      });

      newAchievements.push(nextAchievement);
    }
  }

  return newAchievements;
}

module.exports = { generateDrops,  updateUserStats, checkAchievements};