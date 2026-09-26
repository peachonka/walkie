// src/controllers/itemPositionController.js

const db = require('../lib/db');

// ============================================================
// КОНТРОЛЛЕРЫ
// ============================================================

/**
 * Получить все размещенные предметы пользователя
 * GET /api/item-positions
 */
async function getAllItemPositions(req, res) {
  try {
    const userId = req.userId;

    const result = await db.query(`
      SELECT
        ip.id,
        ip.x,
        ip.y,
        i.id AS item_id,
        i.name AS item_name,
        i.icon AS item_icon
      FROM item_position ip
      JOIN items i
        ON ip.item_id = i.id
      WHERE ip.user_id = $1
    `, [userId]);

    res.json({
      total: result.rows.length,
      positions: result.rows.map(p => ({
        id: p.id,
        item_id: p.item_id,
        item_name: p.item_name,
        item_icon: p.item_icon,
        x: p.x,
        y: p.y
      }))
    });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Разместить предмет на позиции
 * POST /api/item-positions
 * Body: { item_id, x, y }
 */
async function upsertItemPosition(req, res) {
  try {
    const userId = req.userId;
    const { item_id, x, y } = req.body;

    if (!item_id || x === undefined || y === undefined) {
      return res.status(400).json({
        error: 'Missing fields: item_id, x, y'
      });
    }

    // 1. Проверяем, что предмет существует
    const itemResult = await db.query(`
      SELECT id, name, icon
      FROM items
      WHERE id = $1
    `, [item_id]);

    if (itemResult.rows.length === 0) {
      return res.status(404).json({
        error: 'Item not found'
      });
    }

    const item = itemResult.rows[0];

    // 2. Проверяем, что предмет есть у пользователя
    const userItemResult = await db.query(`
      SELECT id
      FROM user_item
      WHERE user_id = $1
        AND item_id = $2
      LIMIT 1
    `, [userId, item_id]);

    if (userItemResult.rows.length === 0) {
      return res.status(403).json({
        error: 'You do not own this item'
      });
    }

    // 3. UPSERT
    const positionResult = await db.query(`
      INSERT INTO item_position (
        user_id,
        item_id,
        x,
        y
      )
      VALUES ($1, $2, $3, $4)
      ON CONFLICT (user_id, item_id)
      DO UPDATE SET
        x = EXCLUDED.x,
        y = EXCLUDED.y
      RETURNING id, x, y
    `, [userId, item_id, x, y]);

    const position = positionResult.rows[0];

    res.json({
      success: true,
      position: {
        id: position.id,
        item_id,
        item_name: item.name,
        item_icon: item.icon,
        x: position.x,
        y: position.y
      }
    });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Убрать предмет с позиции (снять)
 * DELETE /api/item-positions/:positionId
 */
async function removeItem(req, res) {
  try {
    const userId = req.userId;
    const positionId = parseInt(req.params.positionId);

    const result = await db.query(`
      DELETE FROM item_position
      WHERE id = $1
        AND user_id = $2
      RETURNING id
    `, [positionId, userId]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        error: 'Position not found'
      });
    }

    res.json({
      success: true,
      removed_id: result.rows[0].id
    });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Получить размещенные предметы для конкретного предмета
 * GET /api/item-positions/item/:itemId
 */
async function getPositionByItemId(req, res) {
  try {
    const userId = req.userId;
    const itemId = parseInt(req.params.itemId);

    const result = await db.query(`
      SELECT id, x, y
      FROM item_position
      WHERE user_id = $1
        AND item_id = $2
      LIMIT 1
    `, [userId, itemId]);

    if (result.rows.length === 0) {
      return res.json({
        is_placed: false,
        position: null
      });
    }

    res.json({
      is_placed: true,
      position: result.rows[0]
    });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Очистить все позиции пользователя
 * DELETE /api/item-positions
 */
async function clearAllPositions(req, res) {
  try {
    const userId = req.userId;

    await db.query(`
      DELETE FROM item_position
      WHERE user_id = $1
    `, [userId]);

    res.json({
      success: true
    });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

module.exports = {
  getAllItemPositions,
  upsertItemPosition,
  removeItem,
  getPositionByItemId,
  clearAllPositions
};