// src/controllers/walksController.js (обновленный)

// const { calculateDistance, isPointInSquareZone } = require('../utils/calculations');
// const { updateUserProgress, checkAndAwardAchievements } = require('./achievementsController');
const { generateDrops,  updateUserStats, checkAchievements} = require('../utils/walksLogic')
const supabase = require('../lib/supabaseClient');


// ============================================================
// ФУНКЦИИ
// ============================================================

/**
 * Начать прогулку
 * POST /api/walks/start
 * 
 * body: { userId }
 */
async function startWalk(req, res) {
  try {
    const userId = req.userId;

    // проверка активной прогулки
    const { data: activeWalk } = await supabase
      .from('walk')
      .select('*')
      .eq('user_id', userId)
      .is('end_time', null)
      .single();

    if (activeWalk) {
      return res.status(409).json({ error: 'Active walk already exists' });
    }

    const { data, error } = await supabase
      .from('walk')
      .insert({
        user_id: userId,
        start_time: new Date().toISOString()
      })
      .select()
      .single();

    if (error) {
      return res.status(500).json({ error: error.message });
    }

    res.json({
      walk_id: data.id,
      start_time: data.start_time
    });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Завершить прогулку
 * POST /api/walks/:walkId/end
 * 
 * body: { userId}
 */
async function endWalk(req, res) {
  try {
    const userId = req.userId;
    const walkId = parseInt(req.params.walkId);

    const { distance, duration } = req.body; 
    // приходит с фронта
    // 1. Получаем прогулку
    const { data: walk, error: walkError } = await supabase
      .from('walk')
      .select('*')
      .eq('id', walkId)
      .eq('user_id', userId)
      .single();
    
    if (walkError || !walk) {
      return res.status(404).json({ error: 'Walk not found' });
    }

    if (walk.end_time) {
      return res.status(400).json({ error: 'Walk already finished' });
    }

    // 2. Закрываем прогулку
    const endTime = new Date().toISOString();
    const { error: updateError } = await supabase
      .from('walk')
      .update({
        end_time: endTime,
        distance: distance,
        duration: duration
      })
      .eq('id', walkId);

    if (updateError) {
      return res.status(500).json({ error: updateError.message });
    }

    // 3. Генерация предметов
    const droppedItems = await generateDrops(duration);

    // 4. Сохраняем предметы
    if (droppedItems.length > 0) {
      const inserts = droppedItems.map(itemId => ({
        user_id: userId,
        item_id: itemId,
        walk_id: walkId
      }));

      await supabase.from('user_item').insert(inserts);
    }
    // 5. Обновляем user_stats
    await updateUserStats(userId);

    // 6. Достижения
    const newAchievements = await checkAchievements(userId);

    res.json({
      walk_id: walkId,
      distance,
      duration,
      items_collected: droppedItems.length,
      new_achievements: newAchievements || []
    });

  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message });
  }
}

// async function addTrackPoint(req, res) {
//   try {
//     const userId = req.userId;
//     const walkId = parseInt(req.params.walkId);
//     const { lat, lng, sequenceNumber } = req.body;
    
//     if (!lat || !lng || sequenceNumber === undefined) {
//       return res.status(400).json({ error: 'Missing: lat, lng, sequenceNumber' });
//     }
    
//     const walk = walks.find(w => w.id === walkId && w.UserId === userId);
//     if (!walk) {
//       return res.status(404).json({ error: 'Walk not found' });
//     }
//     if (walk.EndTime) {
//       return res.status(400).json({ error: 'Walk already completed' });
//     }
    
//     // Сохраняем точку
//     trackPoints.push({
//       id: trackPointCounter++,
//       WalkId: walkId,
//       Lat: lat,
//       Lng: lng,
//       SequenceNumber: sequenceNumber,
//       Created: new Date().toISOString()
//     });
    
//     // Проверка зон и выдача предметов
//     let collectedItem = null;
    
//     for (const zone of zones) {
//       if (isPointInSquareZone(lat, lng, zone)) {
//         const zoneItems = items.filter(item => item.zoneId === zone.id);
        
//         for (const item of zoneItems) {
//           const itemRarity = rarity.find(r => r.id === item.rarityId);
//           const random = Math.random() * 100;
          
//           if (random <= itemRarity.dropChance) {
//             const alreadyCollected = collections.some(
//               c => c.UserId === userId && c.WalkId === walkId && c.ItemId === item.id
//             );
            
//             if (!alreadyCollected) {
//               collectedItem = {
//                 id: item.id,
//                 name: item.name,
//                 icon: item.icon,
//                 rarity: { type: itemRarity.type, dropChance: itemRarity.dropChance }
//               };
              
//               collections.push({
//                 id: collectionCounter++,
//                 UserId: userId,
//                 ItemId: item.id,
//                 WalkId: walkId
//               });
              
//               break;
//             }
//           }
//         }
        
//         if (collectedItem) break;
//       }
//     }
    
//     res.json({
//       success: true,
//       collected_item: collectedItem
//     });
//   } catch (error) {
//     res.status(500).json({ error: error.message });
//   }
// }


/**
 * Завершить прогулку
 * GET /api/walks/history
 * 
 * body: { userId }
 */
async function getWalkHistory(req, res) {
  try {
    const userId = req.userId;
    const limit = parseInt(req.query.limit) || 20;
    const offset = parseInt(req.query.offset) || 0;

    const { data, error } = await supabase
      .from('walk')
      .select('*')
      .eq('user_id', userId)
      .not('end_time', 'is', null)
      .order('start_time', { ascending: false })
      .range(offset, offset + limit - 1);

    if (error) {
      return res.status(500).json({ error: error.message });
    }

    res.json({
      walks: data
    });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}


/**
 * Завершить прогулку
 * GET /api/walks/:walkId
 * 
 * body: { userId }
 */
async function getWalkDetails(req, res) {
  try {
    const userId = req.userId;
    const walkId = parseInt(req.params.walkId);

    const { data, error } = await supabase
      .from('walk')
      .select(`
        id,
        start_time,
        end_time,
        distance,
        duration,
        items:user_item (
          item:items (
            id,
            name,
            icon
          )
        )
      `)
      .eq('id', walkId)
      .eq('user_id', userId)
      .single();

    if (error || !data) {
      return res.status(404).json({ error: 'Walk not found' });
    }

    res.json(data);

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

module.exports = {
  startWalk,
  endWalk,
  getWalkHistory,
  getWalkDetails
};