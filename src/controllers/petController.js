// src/controllers/petController.js
const supabase = require('../lib/supabaseClient');
// ============================================================
// ВРЕМЕННОЕ ХРАНИЛИЩЕ (МОКИ)
// ============================================================

// pets —  ERD: id, Type, Avatar
const pets = [
  { id: 1, type: 'dog', avatar: '/avatars/dog_default.png' },
  { id: 2, type: 'cat', avatar: '/avatars/cat_default.png' },
  { id: 3, type: 'bird', avatar: '/avatars/bird_default.png' },
  { id: 4, type: 'hamster', avatar: '/avatars/hamster_default.png' }
];

// user_pets —  ERD: id, UserId, PetId, Name, Level, Exp
let userPets = [
  { id: 1, UserId: 1, PetId: 1, Name: 'Бобик', Level: 5, Exp: 320 }
];

// items — для использования предметов
const items = [
  { id: 1, name: 'Листочек', rarityId: 1, zoneId: 1, icon: '/icons/leaf.png' },
  { id: 10, name: 'Яблоко', rarityId: 1, zoneId: null, icon: '/icons/apple.png' },
  { id: 11, name: 'Морковка', rarityId: 1, zoneId: null, icon: '/icons/carrot.png' }
];

// collections — для проверки, есть ли предмет у пользователя
let collections = [
  { id: 1, UserId: 1, ItemId: 10, WalkId: 1 },
  { id: 2, UserId: 1, ItemId: 11, WalkId: 2 },
  { id: 3, UserId: 1, ItemId: 1, WalkId: 3 }
];

// ============================================================
// ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
// ============================================================

// Опыт, необходимый для каждого уровня
const EXP_PER_LEVEL = 100;

function getExpToNextLevel(currentLevel, currentExp) {
  const neededForNext = currentLevel * EXP_PER_LEVEL;
  return Math.max(0, neededForNext - currentExp);
}

function calculateNewLevel(exp) {
  let level = 1;
  let remainingExp = exp;
  
  while (remainingExp >= level * EXP_PER_LEVEL) {
    remainingExp -= level * EXP_PER_LEVEL;
    level++;
  }
  
  return { level, exp: remainingExp };
}

// ============================================================
// КОНТРОЛЛЕРЫ
// ============================================================

/**
 * SUPABASE
 * Получить информацию о питомце пользователя
 * GET /api/pet
 */
async function getPet(req, res) {
  try {
    const userId = req.userId;

    const { data, error } = await supabase
      .from('user_pet')
      .select(`
        id,
        name,
        level,
        exp,
        pet:pet_id (
          type,
          avatar
        )
      `)
      .eq('user_id', userId)
      .single();

    if (error) {
      return res.status(500).json({ error: error.message });
    }

    if (!data) {
      return res.status(404).json({ error: 'Pet not found for this user' });
    }

    const expToNextLevel = getExpToNextLevel(data.level, data.exp);

    res.json({
      id: data.id,
      name: data.name,
      type: data.pet.type,
      avatar: data.pet.avatar,
      level: data.level,
      exp: data.exp,
      exp_to_next_level: expToNextLevel
    });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * SUPABASE
 * Обновить имя питомца
 * PUT /api/pet/name
 * Body: { name: string }
 */
async function updatePetName(req, res) {
  try {
    const userId = req.userId;
    const { name } = req.body;
    
    if (!name || name.trim().length === 0) {
      return res.status(400).json({ error: 'Name is required' });
    }
    
    if (name.length > 50) {
      return res.status(400).json({ error: 'Name too long (max 50 characters)' });
    }

    const { data, error } = await supabase
    .from('user_pet')
    .update({ name: name.trim() })
    .eq('user_id', userId)
    .select();
    
    if (error) {
      return res.status(500).json({ error: error.message });
    }

    if (!data || data.length === 0) {
      return res.status(404).json({ error: 'Pet not found' });
    }

    res.json({
      success: true,
      new_name: data[0].name
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * SUPABASE
 * Получить список доступных типов питомцев
 * GET /api/pet/types
 */
async function getPetTypes(req, res) {
  try {
    const { data, error } = await supabase
      .from('pet')
      .select('id, type, avatar');

    if (error) {
      return res.status(500).json({ error: error.message });
    }
    res.json({
      pets: data
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}
/**
 * SUPABASE
 * Создать пользователю питомцы
 * POST /api/pet
 * Body: { name: string, petId: int }
 */
async function createPet(req, res) {
  try {

    const { petId, name } = req.body;
    const userId = req.userId;

    if (!petId) {
      return res.status(400).json({ error: 'petId is required' });
    }

    if (!name || name.trim().length === 0) {
      return res.status(400).json({ error: 'Name is required' });
    }

    if (name.length > 50) {
      return res.status(400).json({ error: 'Name too long (max 50 characters)' });
    }

    const { data, error } = await supabase
      .from('user_pet')
      .insert([
        {
          user_id: userId,
          pet_id: petId,
          name: name.trim(),
          level: 1,
          exp: 0
        }
      ])
      .select(); // чтобы сразу вернуть созданную запись

    if (error) {
      return res.status(500).json({ error: error.message });
    }

    res.status(201).json({
      success: true,
      pet: data[0]
    });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

module.exports = {
  getPet,
  updatePetName,
  getPetTypes,
  createPet
};