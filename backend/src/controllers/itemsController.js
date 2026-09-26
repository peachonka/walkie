// src/controllers/itemsController.js

const db = require('../lib/db');

// ============================================================
// КОНТРОЛЛЕРЫ
// ============================================================

/**
 * Получить все предметы
 * GET /api/items
 */
async function getAllItems(req, res) {
  try {
    const zoneId = req.query.zoneId
      ? parseInt(req.query.zoneId)
      : null;

    let query = `
      SELECT
        i.id,
        i.name,
        i.icon,
        i.created_at,
        json_build_object(
          'id', r.id,
          'type', r.type,
          'drop_chance', r.drop_chance
        ) AS rarity,
        json_build_object(
          'id', z.id,
          'name', z.name
        ) AS zone
      FROM items i
      JOIN rarity r
        ON i.rarity_id = r.id
      JOIN zones z
        ON i.zone_id = z.id
    `;

    const params = [];

    if (zoneId) {
      params.push(zoneId);
      query += `
        WHERE i.zone_id = $1
      `;
    }

    query += `
      ORDER BY i.created_at DESC
    `;

    const result = await db.query(query, params);

    res.json({
      total: result.rows.length,
      items: result.rows
    });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Получить предмет по ID
 * GET /api/items/:itemId
 */
async function getItemById(req, res) {
  try {
    const itemId = parseInt(req.params.itemId);

    const result = await db.query(`
      SELECT
        i.id,
        i.name,
        i.icon,
        json_build_object(
          'id', r.id,
          'type', r.type,
          'drop_chance', r.drop_chance
        ) AS rarity,
        json_build_object(
          'id', z.id,
          'name', z.name
        ) AS zone
      FROM items i
      JOIN rarity r
        ON i.rarity_id = r.id
      JOIN zones z
        ON i.zone_id = z.id
      WHERE i.id = $1
    `, [itemId]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        error: 'Item not found'
      });
    }

    res.json(result.rows[0]);

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Получить все предметы, собранные пользователем
 * GET /api/items/collected
 */
async function getUserItems(req, res) {
  try {
    const userId = req.userId;
    const limit = parseInt(req.query.limit) || 50;
    const offset = parseInt(req.query.offset) || 0;

    const result = await db.query(`
      SELECT
        ui.id,
        ui.created_at,
        ui.walk_id,
        json_build_object(
          'id', i.id,
          'name', i.name,
          'icon', i.icon,
          'rarity', json_build_object(
            'type', r.type,
            'drop_chance', r.drop_chance
          )
        ) AS item
      FROM user_item ui
      JOIN items i
        ON ui.item_id = i.id
      JOIN rarity r
        ON i.rarity_id = r.id
      WHERE ui.user_id = $1
      ORDER BY ui.created_at DESC
      LIMIT $2
      OFFSET $3
    `, [userId, limit, offset]);

    res.json({
      total: result.rows.length,
      limit,
      offset,
      items: result.rows
    });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Получить редкости предметов
 * GET /api/items/rarities
 */
async function getRarities(req, res) {
  try {
    const result = await db.query(`
      SELECT *
      FROM rarity
    `);

    res.json({
      rarities: result.rows
    });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

module.exports = {
  getAllItems,
  getItemById,
  getUserItems,
  getRarities
};