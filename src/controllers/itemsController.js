// src/controllers/itemsController.js
const supabase = require('../lib/supabaseClient');

// ============================================================
// КОНТРОЛЛЕРЫ
// ============================================================

/**
 * Получить все предметы
 * GET /api/items
 * 
 * Query параметры:
 * - zoneId (опционально) — фильтр по зоне
 */
async function getAllItems(req, res) {
  try {
    const zoneId = req.query.zoneId ? parseInt(req.query.zoneId) : null;

    let query = supabase
      .from('items')
      .select(`
        id,
        name,
        icon,
        created_at,
        rarity:rarity_id (
          id,
          type,
          drop_chance
        ),
        zone:zone_id (
          id,
          name
        )
      `)
      .order('created_at', { ascending: false });

    if (zoneId) {
      query = query.eq('zone_id', zoneId);
    }

    const { data, error } = await query;

    if (error) {
      return res.status(500).json({ error: error.message });
    }

    res.json({
      total: data.length,
      items: data
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

    const { data, error } = await supabase
      .from('items')
      .select(`
        id,
        name,
        icon,
        rarity:rarity_id (
          id,
          type,
          drop_chance
        ),
        zone:zone_id (
          id,
          name
        )
      `)
      .eq('id', itemId)
      .single();

    if (error) {
      return res.status(500).json({ error: error.message });
    }

    if (!data) {
      return res.status(404).json({ error: 'Item not found' });
    }

    res.json(data);

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Получить все предметы, собранные пользователем
 * GET /api/items/collected
 * 
 * Query параметры:
 * - limit (опционально, по умолчанию 50)
 * - offset (опционально, по умолчанию 0)
 * 
 * Сортировка по времени получения
 */
async function getUserItems(req, res) {
  try {
    const userId = req.userId;
    const limit = parseInt(req.query.limit) || 50;
    const offset = parseInt(req.query.offset) || 0;

    const { data, error } = await supabase
      .from('user_item')
      .select(`
        id,
        created_at,
        walk_id,
        item:items (
          id,
          name,
          icon,
          rarity:rarity_id (
            type,
            drop_chance
          )
        )
      `)
      .eq('user_id', userId)
      .order('created_at', { ascending: false })
      .range(offset, offset + limit - 1);

    if (error) {
      return res.status(500).json({ error: error.message });
    }

    res.json({
      total: data.length,
      limit,
      offset,
      items: data
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
    const { data, error } = await supabase
      .from('rarity')
      .select('*');

    if (error) {
      return res.status(500).json({ error: error.message });
    }

    res.json({
      rarities: data
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