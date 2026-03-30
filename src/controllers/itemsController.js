// src/controllers/itemsController.js

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
    const userId = req.userId;
    const zoneId = req.query.zoneId ? parseInt(req.query.zoneId) : null;
    
    let filteredItems = [...items];
    
    // Фильтр по зоне
    if (zoneId) {
      filteredItems = filteredItems.filter(item => item.zoneId === zoneId);
    }
    
    // Добавляем информацию о редкости и зоне
    const result = filteredItems.map(item => {
      const itemRarity = rarity.find(r => r.id === item.rarityId);
      const itemZone = zones.find(z => z.id === item.zoneId);
      
      return {
        id: item.id,
        name: item.name,
        icon: item.icon,
        rarity: {
          id: itemRarity.id,
          type: itemRarity.type,
          dropChance: itemRarity.dropChance
        },
        zone: itemZone ? {
          id: itemZone.id,
          name: itemZone.name
        } : null
      };
    });
    
    res.json({
      total: result.length,
      items: result
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
    
    const item = items.find(i => i.id === itemId);
    if (!item) {
      return res.status(404).json({ error: 'Item not found' });
    }
    
    const itemRarity = rarity.find(r => r.id === item.rarityId);
    const itemZone = zones.find(z => z.id === item.zoneId);
    
    res.json({
      id: item.id,
      name: item.name,
      icon: item.icon,
      rarity: {
        id: itemRarity.id,
        type: itemRarity.type,
        dropChance: itemRarity.dropChance
      },
      zone: itemZone ? {
        id: itemZone.id,
        name: itemZone.name
      } : null
    });
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
 */
async function getCollectedItems(req, res) {
  try {
    const userId = req.userId;
    const limit = parseInt(req.query.limit) || 50;
    const offset = parseInt(req.query.offset) || 0;
    
    // Получаем все коллекции пользователя
    const userCollections = collections.filter(c => c.UserId === userId);
    
    // Группируем по предметам для подсчета количества
    const itemCountMap = new Map();
    for (const col of userCollections) {
      const count = itemCountMap.get(col.ItemId) || 0;
      itemCountMap.set(col.ItemId, count + 1);
    }
    
    // Формируем результат
    let result = [];
    for (const [itemId, count] of itemCountMap) {
      const item = items.find(i => i.id === itemId);
      if (item) {
        const itemRarity = rarity.find(r => r.id === item.rarityId);
        result.push({
          id: item.id,
          name: item.name,
          icon: item.icon,
          rarity: {
            type: itemRarity.type,
            dropChance: itemRarity.dropChance
          },
          count: count
        });
      }
    }
    
    // Сортируем по редкости (сначала легендарные) и по имени
    result.sort((a, b) => {
      const rarityOrder = { legendary: 0, rare: 1, common: 2 };
      const rarityDiff = rarityOrder[a.rarity.type] - rarityOrder[b.rarity.type];
      if (rarityDiff !== 0) return rarityDiff;
      return a.name.localeCompare(b.name);
    });
    
    // Пагинация
    const total = result.length;
    const paginatedResult = result.slice(offset, offset + limit);
    
    res.json({
      total: total,
      limit: limit,
      offset: offset,
      items: paginatedResult
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Получить историю сборов предметов (с привязкой к прогулкам)
 * GET /api/items/history
 * 
 * Query параметры:
 * - limit (опционально, по умолчанию 50)
 * - offset (опционально, по умолчанию 0)
 */
async function getCollectionHistory(req, res) {
  try {
    const userId = req.userId;
    const limit = parseInt(req.query.limit) || 50;
    const offset = parseInt(req.query.offset) || 0;
    
    // Получаем все коллекции пользователя, сортируем от новых к старым
    // В моках нет времени сбора, поэтому сортируем по id (чем больше id, тем новее)
    const userCollections = collections
      .filter(c => c.UserId === userId)
      .sort((a, b) => b.id - a.id);
    
    // Пагинация
    const paginatedCollections = userCollections.slice(offset, offset + limit);
    
    // Добавляем информацию о предметах
    const result = [];
    for (const col of paginatedCollections) {
      const item = items.find(i => i.id === col.ItemId);
      if (item) {
        const itemRarity = rarity.find(r => r.id === item.rarityId);
        result.push({
          id: col.id,
          item: {
            id: item.id,
            name: item.name,
            icon: item.icon,
            rarity: {
              type: itemRarity.type,
              dropChance: itemRarity.dropChance
            }
          },
          walk_id: col.WalkId,
          collected_at: null
        });
      }
    }
    
    res.json({
      total: userCollections.length,
      limit: limit,
      offset: offset,
      collections: result
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
    res.json({
      rarities: rarity.map(r => ({
        id: r.id,
        type: r.type,
        dropChance: r.dropChance
      }))
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

module.exports = {
  getAllItems,
  getItemById,
  getCollectedItems,
  getCollectionHistory,
  getRarities
};