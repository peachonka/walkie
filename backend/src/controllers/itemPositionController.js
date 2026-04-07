// src/controllers/itemPositionController.js
const supabase = require('../lib/supabaseClient');
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

    const { data, error } = await supabase
      .from('item_position')
      .select(`
        id,
        x,
        y,
        item:item_id (
          id,
          name,
          icon
        )
      `)
      .eq('user_id', userId);

    if (error) throw error;

    res.json({
      total: data.length,
      positions: data.map(p => ({
        id: p.id,
        item_id: p.item.id,
        item_name: p.item.name,
        item_icon: p.item.icon,
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
      return res.status(400).json({ error: 'Missing fields: item_id, x, y' });
    }

    // 1. Проверяем, что предмет существует
    const { data: item, error: itemError } = await supabase
      .from('items')
      .select('id, name, icon')
      .eq('id', item_id)
      .single();

    if (itemError || !item) {
      return res.status(404).json({ error: 'Item not found' });
    }

    // 2. Проверяем, что предмет есть у пользователя
    const { data: userItem } = await supabase
      .from('user_item')
      .select('id')
      .eq('user_id', userId)
      .eq('item_id', item_id)
      .limit(1);

    if (!userItem || userItem.length === 0) {
      return res.status(403).json({ error: 'You do not own this item' });
    }

    // 3. UPSERT
    const { data, error } = await supabase
      .from('item_position')
      .upsert({
        user_id: userId,
        item_id,
        x,
        y
      }, {
        onConflict: ['user_id', 'item_id']
      })
      .select()
      .single();

    if (error) throw error;

    res.json({
      success: true,
      position: {
        id: data.id,
        item_id,
        item_name: item.name,
        item_icon: item.icon,
        x: data.x,
        y: data.y
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

    const { data, error } = await supabase
      .from('item_position')
      .delete()
      .eq('id', positionId)
      .eq('user_id', userId)
      .select()
      .single();

    if (error || !data) {
      return res.status(404).json({ error: 'Position not found' });
    }

    res.json({
      success: true,
      removed_id: data.id
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

    const { data } = await supabase
      .from('item_position')
      .select('id, x, y')
      .eq('user_id', userId)
      .eq('item_id', itemId)
      .single();

    if (!data) {
      return res.json({
        is_placed: false,
        position: null
      });
    }

    res.json({
      is_placed: true,
      position: data
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

    const { error } = await supabase
      .from('item_position')
      .delete()
      .eq('user_id', userId);

    if (error) throw error;

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