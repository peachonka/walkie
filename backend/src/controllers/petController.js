// src/controllers/petController.js

const db = require('../lib/db');

// ============================================================
// ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
// ============================================================

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

    const result = await db.query(`
      SELECT
        up.id,
        up.name,
        up.level,
        up.exp,
        p.type,
        p.avatar
      FROM user_pet up
      JOIN pet p
        ON up.pet_id = p.id
      WHERE up.user_id = $1
      LIMIT 1
    `, [userId]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        error: 'Pet not found for this user'
      });
    }

    const data = result.rows[0];

    const expToNextLevel = getExpToNextLevel(
      data.level,
      data.exp
    );

    res.json({
      id: data.id,
      name: data.name,
      type: data.type,
      avatar: data.avatar,
      level: data.level,
      exp: data.exp,
      exp_to_next_level: expToNextLevel
    });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Обновить имя питомца
 * PUT /api/pet/name
 */
async function updatePetName(req, res) {
  try {
    const userId = req.userId;
    const { name } = req.body;

    if (!name || name.trim().length === 0) {
      return res.status(400).json({
        error: 'Name is required'
      });
    }

    if (name.length > 50) {
      return res.status(400).json({
        error: 'Name too long (max 50 characters)'
      });
    }

    const result = await db.query(`
      UPDATE user_pet
      SET name = $1
      WHERE user_id = $2
      RETURNING name
    `, [name.trim(), userId]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        error: 'Pet not found'
      });
    }

    res.json({
      success: true,
      new_name: result.rows[0].name
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
    const result = await db.query(`
      SELECT id, type, avatar
      FROM pet
    `);

    res.json({
      pets: result.rows
    });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Создать пользователю питомца
 * POST /api/pet
 */
async function createPet(req, res) {
  try {
    const { petId, name } = req.body;
    const userId = req.userId;

    if (!petId) {
      return res.status(400).json({
        error: 'petId is required'
      });
    }

    if (!name || name.trim().length === 0) {
      return res.status(400).json({
        error: 'Name is required'
      });
    }

    if (name.length > 50) {
      return res.status(400).json({
        error: 'Name too long (max 50 characters)'
      });
    }

    const result = await db.query(`
      INSERT INTO user_pet (
        user_id,
        pet_id,
        name,
        level,
        exp
      )
      VALUES ($1, $2, $3, 1, 0)
      RETURNING *
    `, [
      userId,
      petId,
      name.trim()
    ]);

    res.status(201).json({
      success: true,
      pet: result.rows[0]
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