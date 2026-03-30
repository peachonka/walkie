// src/controllers/petController.js

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
 * Получить информацию о питомце пользователя
 * GET /api/pet
 */
async function getPet(req, res) {
  try {
    const userId = req.userId;
    
    const userPet = userPets.find(up => up.UserId === userId);
    if (!userPet) {
      return res.status(404).json({ error: 'Pet not found for this user' });
    }
    
    const petInfo = pets.find(p => p.id === userPet.PetId);
    
    const expToNextLevel = getExpToNextLevel(userPet.Level, userPet.Exp);
    
    res.json({
      id: userPet.id,
      name: userPet.Name,
      type: petInfo.type,
      avatar: petInfo.avatar,
      level: userPet.Level,
      exp: userPet.Exp,
      exp_to_next_level: expToNextLevel
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Обновить имя питомца
 * PUT /api/pet/name
 * 
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
    
    const userPet = userPets.find(up => up.UserId === userId);
    if (!userPet) {
      return res.status(404).json({ error: 'Pet not found' });
    }
    
    const oldName = userPet.Name;
    userPet.Name = name.trim();
    
    res.json({
      success: true,
      old_name: oldName,
      new_name: userPet.Name
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Получить список доступных типов питомцев
 * GET /api/pet/types
 */
async function getPetTypes(req, res) {
  try {
    res.json({
      pets: pets.map(p => ({
        id: p.id,
        type: p.type,
        avatar: p.avatar
      }))
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

module.exports = {
  getPet,
  updatePetName,
  getPetTypes
};