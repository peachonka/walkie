// src/controllers/itemsController.js
const supabase = require('../lib/supabaseClient');
// ============================================================
// ВРЕМЕННОЕ ХРАНИЛИЩЕ (МОКИ)
// ============================================================

// items — ERD: id, Name, RarityId, ZoneId, Icon
const items = [
  { id: 1, name: 'Листочек', rarityId: 1, zoneId: 1, icon: '/icons/leaf.png' },
  { id: 2, name: 'Желудь', rarityId: 1, zoneId: 1, icon: '/icons/acorn.png' },
  { id: 3, name: 'Веточка', rarityId: 1, zoneId: 1, icon: '/icons/twig.png' },
  { id: 4, name: 'Каштан', rarityId: 1, zoneId: 1, icon: '/icons/chestnut.png' },
  { id: 5, name: 'Редкий гриб', rarityId: 2, zoneId: 2, icon: '/icons/mushroom.png' },
  { id: 6, name: 'Перо птицы', rarityId: 2, zoneId: 2, icon: '/icons/feather.png' },
  { id: 7, name: 'Камушек', rarityId: 1, zoneId: 2, icon: '/icons/stone.png' },
  { id: 8, name: 'Ягодка', rarityId: 1, zoneId: 2, icon: '/icons/berry.png' },
  { id: 9, name: 'Золотой лист', rarityId: 3, zoneId: 3, icon: '/icons/gold-leaf.png' }
];

// rarity — ERD: id, Type, DropChance
const rarity = [
  { id: 1, type: 'common', dropChance: 15 },
  { id: 2, type: 'rare', dropChance: 5 },
  { id: 3, type: 'legendary', dropChance: 1 }
];

// zones — для связи с зонами (добавим позже, пока минимально)
const zones = [
  { id: 1, name: 'Центральный парк' },
  { id: 2, name: 'Площадь' },
  { id: 3, name: 'Старый сад' }
];

// collections — для получения собранных предметов пользователя
// Эти данные будут приходить из walksController, но для мока добавим
let collections = [
  { id: 1, UserId: 1, ItemId: 1, WalkId: 1 },
  { id: 2, UserId: 1, ItemId: 2, WalkId: 1 },
  { id: 3, UserId: 1, ItemId: 1, WalkId: 2 },
  { id: 4, UserId: 1, ItemId: 5, WalkId: 3 },
  { id: 5, UserId: 1, ItemId: 3, WalkId: 4 },
  { id: 6, UserId: 1, ItemId: 1, WalkId: 5 },
  { id: 7, UserId: 1, ItemId: 1, WalkId: 6 },
  { id: 8, UserId: 1, ItemId: 2, WalkId: 7 }
];

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