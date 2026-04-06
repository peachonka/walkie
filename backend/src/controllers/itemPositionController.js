// src/controllers/itemPositionController.js

// ============================================================
// ВРЕМЕННОЕ ХРАНИЛИЩЕ (МОКИ)
// ============================================================

// item_positions — ERD: id, UserId, ItemId, X, Y
let itemPositions = [
  // Пример: пользователь 1 уже разместил очки на позиции (100, 150)
  { id: 1, UserId: 1, ItemId: 20, X: 100, Y: 150 },
  // Пример: ковер на позиции (50, 200)
  { id: 2, UserId: 1, ItemId: 21, X: 50, Y: 200 }
];

let positionCounter = 3;

// Предметы (для проверки существования)
const items = [
  { id: 20, name: 'Очки', icon: '/items/glasses.png', type: 'wearable' },
  { id: 21, name: 'Ковер', icon: '/items/carpet.png', type: 'furniture' },
  { id: 22, name: 'Шляпа', icon: '/items/hat.png', type: 'wearable' },
  { id: 23, name: 'Лежанка', icon: '/items/bed.png', type: 'furniture' },
  { id: 24, name: 'Мячик', icon: '/items/ball.png', type: 'toy' }
];

// collections — для проверки, есть ли предмет у пользователя
let collections = [
  { id: 1, UserId: 1, ItemId: 20, WalkId: 1 },
  { id: 2, UserId: 1, ItemId: 21, WalkId: 2 },
  { id: 3, UserId: 1, ItemId: 22, WalkId: 3 },
  { id: 4, UserId: 1, ItemId: 23, WalkId: 4 }
];

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
    
    const userPositions = itemPositions.filter(ip => ip.UserId === userId);
    
    // Добавляем информацию о предмете
    const result = userPositions.map(pos => {
      const item = items.find(i => i.id === pos.ItemId);
      return {
        id: pos.id,
        item_id: pos.ItemId,
        item_name: item ? item.name : 'Unknown',
        item_icon: item ? item.icon : null,
        item_type: item ? item.type : null,
        x: pos.X,
        y: pos.Y
      };
    });
    
    res.json({
      total: result.length,
      positions: result
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Получить размещенные предметы по типу
 * GET /api/item-positions?type=wearable
 */
async function getItemPositionsByType(req, res) {
  try {
    const userId = req.userId;
    const { type } = req.query;
    
    if (!type) {
      return res.status(400).json({ error: 'Missing type parameter' });
    }
    
    const userPositions = itemPositions.filter(ip => ip.UserId === userId);
    
    const result = [];
    for (const pos of userPositions) {
      const item = items.find(i => i.id === pos.ItemId);
      if (item && item.type === type) {
        result.push({
          id: pos.id,
          item_id: pos.ItemId,
          item_name: item.name,
          item_icon: item.icon,
          item_type: item.type,
          x: pos.X,
          y: pos.Y
        });
      }
    }
    
    res.json({
      type: type,
      total: result.length,
      positions: result
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
async function placeItem(req, res) {
  try {
    const userId = req.userId;
    const { item_id, x, y } = req.body;
    
    if (!item_id || x === undefined || y === undefined) {
      return res.status(400).json({ error: 'Missing required fields: item_id, x, y' });
    }
    
    // Проверяем, существует ли предмет
    const item = items.find(i => i.id === item_id);
    if (!item) {
      return res.status(404).json({ error: 'Item not found' });
    }
    
    // Проверяем, есть ли этот предмет у пользователя в коллекции
    const hasItem = collections.some(c => c.UserId === userId && c.ItemId === item_id);
    if (!hasItem) {
      return res.status(403).json({ error: 'You do not own this item' });
    }
    
    // Проверяем, не размещен ли уже этот предмет
    const alreadyPlaced = itemPositions.some(ip => ip.UserId === userId && ip.ItemId === item_id);
    if (alreadyPlaced) {
      return res.status(409).json({ error: 'Item already placed' });
    }
    
    // Создаем новую позицию
    const newPosition = {
      id: positionCounter++,
      UserId: userId,
      ItemId: item_id,
      X: x,
      Y: y
    };
    
    itemPositions.push(newPosition);
    
    res.status(201).json({
      success: true,
      message: 'Item placed successfully',
      position: {
        id: newPosition.id,
        item_id: newPosition.ItemId,
        item_name: item.name,
        item_icon: item.icon,
        item_type: item.type,
        x: newPosition.X,
        y: newPosition.Y
      }
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Переместить предмет на новую позицию
 * PUT /api/item-positions/:positionId
 * Body: { x, y }
 */
async function moveItem(req, res) {
  try {
    const userId = req.userId;
    const positionId = parseInt(req.params.positionId);
    const { x, y } = req.body;
    
    if (x === undefined || y === undefined) {
      return res.status(400).json({ error: 'Missing required fields: x, y' });
    }
    
    const position = itemPositions.find(ip => ip.id === positionId && ip.UserId === userId);
    if (!position) {
      return res.status(404).json({ error: 'Position not found' });
    }
    
    const item = items.find(i => i.id === position.ItemId);
    
    // Обновляем координаты
    position.X = x;
    position.Y = y;
    
    res.json({
      success: true,
      message: 'Item moved successfully',
      position: {
        id: position.id,
        item_id: position.ItemId,
        item_name: item ? item.name : 'Unknown',
        item_icon: item ? item.icon : null,
        item_type: item ? item.type : null,
        x: position.X,
        y: position.Y
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
    
    const positionIndex = itemPositions.findIndex(ip => ip.id === positionId && ip.UserId === userId);
    if (positionIndex === -1) {
      return res.status(404).json({ error: 'Position not found' });
    }
    
    const removed = itemPositions.splice(positionIndex, 1)[0];
    const item = items.find(i => i.id === removed.ItemId);
    
    res.json({
      success: true,
      message: 'Item removed successfully',
      removed_item: {
        id: removed.id,
        item_id: removed.ItemId,
        item_name: item ? item.name : 'Unknown',
        x: removed.X,
        y: removed.Y
      }
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Получить размещенные предметы для конкретного предмета (проверить, размещен ли)
 * GET /api/item-positions/item/:itemId
 */
async function getPositionByItemId(req, res) {
  try {
    const userId = req.userId;
    const itemId = parseInt(req.params.itemId);
    
    const position = itemPositions.find(ip => ip.UserId === userId && ip.ItemId === itemId);
    
    if (!position) {
      return res.json({
        is_placed: false,
        position: null
      });
    }
    
    const item = items.find(i => i.id === itemId);
    
    res.json({
      is_placed: true,
      position: {
        id: position.id,
        item_id: position.ItemId,
        item_name: item ? item.name : 'Unknown',
        item_icon: item ? item.icon : null,
        item_type: item ? item.type : null,
        x: position.X,
        y: position.Y
      }
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Очистить все позиции пользователя (сбросить все предметы)
 * DELETE /api/item-positions
 */
async function clearAllPositions(req, res) {
  try {
    const userId = req.userId;
    
    const removedCount = itemPositions.filter(ip => ip.UserId === userId).length;
    itemPositions = itemPositions.filter(ip => ip.UserId !== userId);
    
    res.json({
      success: true,
      message: 'All positions cleared',
      removed_count: removedCount
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

module.exports = {
  getAllItemPositions,
  getItemPositionsByType,
  placeItem,
  moveItem,
  removeItem,
  getPositionByItemId,
  clearAllPositions
};