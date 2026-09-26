const {
  generateDrops,
  updateUserStats,
  checkAchievements
} = require('../utils/walksLogic');

const db = require('../lib/db');

// ============================================================
// КОНТРОЛЛЕРЫ
// ============================================================

/**
 * Начать прогулку
 * POST /api/walks/start
 */
async function startWalk(req, res) {
  try {
    const userId = req.userId;

    // Проверка активной прогулки
    const activeWalkResult = await db.query(`
      SELECT *
      FROM walk
      WHERE user_id = $1
        AND end_time IS NULL
      LIMIT 1
    `, [userId]);

    if (activeWalkResult.rows.length > 0) {
      const activeWalk = activeWalkResult.rows[0];

      return res.status(409).json({
        error: 'Active walk already exists',
        walkId: activeWalk.id
      });
    }

    const result = await db.query(`
      INSERT INTO walk (
        user_id,
        start_time
      )
      VALUES ($1, $2)
      RETURNING *
    `, [
      userId,
      new Date().toISOString()
    ]);

    const walk = result.rows[0];

    res.json({
      walk_id: walk.id,
      start_time: walk.start_time
    });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Завершить прогулку
 * POST /api/walks/:walkId/end
 */
async function endWalk(req, res) {
  try {
    const userId = req.userId;
    const walkId = parseInt(req.params.walkId);

    const { distance, duration, steps } = req.body;

    // 1. Получаем прогулку
    const walkResult = await db.query(`
      SELECT *
      FROM walk
      WHERE id = $1
        AND user_id = $2
    `, [walkId, userId]);

    if (walkResult.rows.length === 0) {
      return res.status(404).json({
        error: 'Walk not found'
      });
    }

    const walk = walkResult.rows[0];

    if (walk.end_time) {
      return res.status(400).json({
        error: 'Walk already finished'
      });
    }

    // 2. Закрываем прогулку
    const endTime = new Date().toISOString();

    const updateResult = await db.query(`
      UPDATE walk
      SET
        end_time = $1,
        distance = $2,
        duration = $3,
        steps = $4
      WHERE id = $5
      RETURNING *
    `, [
      endTime,
      distance,
      duration,
      steps,
      walkId
    ]);

    // 3. Генерация предметов
    const droppedItems = await generateDrops(duration);

    // 4. Сохраняем предметы
    if (droppedItems.length > 0) {
      for (const itemId of droppedItems) {
        await db.query(`
          INSERT INTO user_item (
            user_id,
            item_id,
            walk_id
          )
          VALUES ($1, $2, $3)
        `, [
          userId,
          itemId,
          walkId
        ]);
      }
    }

    // 5. Обновляем user_stats
    await updateUserStats(userId);

    // 6. Достижения
    const newAchievements =
      await checkAchievements(userId);

    // 7. Получение списка предметов
    let itemsData = [];

    if (droppedItems.length > 0) {

      // Считаем количество каждого предмета
      const counts = {};

      for (const itemId of droppedItems) {
        counts[itemId] =
          (counts[itemId] || 0) + 1;
      }

      // Уникальные ID
      const uniqueIds = [
        ...new Set(droppedItems)
      ];

      // Получаем предметы
      const placeholders = uniqueIds
        .map((_, index) => `$${index + 1}`)
        .join(', ');

      const itemsResult = await db.query(`
        SELECT
          i.id,
          i.name,
          i.icon,
          i.rarity_id,
          json_build_object(
            'id', r.id,
            'type', r.type
          ) AS rarity
        FROM items i
        JOIN rarity r
          ON i.rarity_id = r.id
        WHERE i.id IN (${placeholders})
      `, uniqueIds);

      itemsData = itemsResult.rows.map(item => ({
        ...item,
        quantity: counts[item.id]
      }));
    }

    res.json({
      walk_id: walkId,
      distance,
      duration,
      steps,
      items_collected: itemsData,
      new_achievements: newAchievements || []
    });

  } catch (error) {
    console.error(error);

    res.status(500).json({
      error: error.message
    });
  }
}

/**
 * Получить историю прогулок
 * GET /api/walks/history
 */
async function getWalkHistory(req, res) {
  try {
    const userId = req.userId;
    const limit = parseInt(req.query.limit) || 20;
    const offset = parseInt(req.query.offset) || 0;

    const result = await db.query(`
      SELECT *
      FROM walk
      WHERE user_id = $1
        AND end_time IS NOT NULL
      ORDER BY start_time DESC
      LIMIT $2
      OFFSET $3
    `, [
      userId,
      limit,
      offset
    ]);

    res.json({
      walks: result.rows
    });

  } catch (error) {
    res.status(500).json({
      error: error.message
    });
  }
}

/**
 * Получить детали прогулки
 * GET /api/walks/:walkId
 */
async function getWalkDetails(req, res) {
  try {
    const userId = req.userId;
    const walkId = parseInt(req.params.walkId);

    const result = await db.query(`
      SELECT
        w.id,
        w.start_time,
        w.end_time,
        w.distance,
        w.duration
      FROM walk w
      WHERE w.id = $1
        AND w.user_id = $2
    `, [walkId, userId]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        error: 'Walk not found'
      });
    }

    const walk = result.rows[0];

    const itemsResult = await db.query(`
      SELECT
        ui.id,
        i.id AS item_id,
        i.name,
        i.icon
      FROM user_item ui
      JOIN items i
        ON ui.item_id = i.id
      WHERE ui.walk_id = $1
    `, [walkId]);

    res.json({
      id: walk.id,
      start_time: walk.start_time,
      end_time: walk.end_time,
      distance: walk.distance,
      duration: walk.duration,
      items: itemsResult.rows.map(item => ({
        id: item.id,
        item: {
          id: item.item_id,
          name: item.name,
          icon: item.icon
        }
      }))
    });

  } catch (error) {
    res.status(500).json({
      error: error.message
    });
  }
}

module.exports = {
  startWalk,
  endWalk,
  getWalkHistory,
  getWalkDetails
};