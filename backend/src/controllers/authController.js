const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const db = require('../lib/db');

/**
 * Регистрация пользователя
 * POST /api/auth/register
 */
async function register(req, res) {
  try {
    const { email, password } = req.body;

    // 1. Проверяем входные данные
    if (!email || !password) {
      return res.status(400).json({
        error: 'Email and password are required'
      });
    }

    // 2. Проверяем, существует ли пользователь
    const existingUser = await db.query(
      `
        SELECT id
        FROM users
        WHERE email = $1
      `,
      [email]
    );

    if (existingUser.rows.length > 0) {
      return res.status(409).json({
        error: 'User already exists'
      });
    }

    // 3. Хешируем пароль
    const passwordHash = await bcrypt.hash(password, 10);

    // 4. Создаём пользователя
    const result = await db.query(
      `
        INSERT INTO users (email, password_hash)
        VALUES ($1, $2)
        RETURNING id, email, created_at
      `,
      [email, passwordHash]
    );

    const user = result.rows[0];

    // 5. Возвращаем данные пользователя
    res.status(201).json({
      user: {
        id: user.id,
        email: user.email,
        created_at: user.created_at
      }
    });

  } catch (error) {
    console.error('Register error:', error);

    res.status(500).json({
      error: 'Internal server error'
    });
  }
}

/**
 * Вход пользователя
 * POST /api/auth/login
 */
async function login(req, res) {
  try {
    const { email, password } = req.body;

    // 1. Проверяем входные данные
    if (!email || !password) {
      return res.status(400).json({
        error: 'Email and password are required'
      });
    }

    // 2. Ищем пользователя
    const result = await db.query(
      `
        SELECT id, email, password_hash
        FROM users
        WHERE email = $1
      `,
      [email]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({
        error: 'Invalid email or password'
      });
    }

    const user = result.rows[0];

    // 3. Проверяем пароль
    const passwordValid = await bcrypt.compare(
      password,
      user.password_hash
    );

    if (!passwordValid) {
      return res.status(401).json({
        error: 'Invalid email or password'
      });
    }

    // 4. Создаём JWT
    const token = jwt.sign(
      {
        userId: user.id
      },
      process.env.JWT_SECRET,
      {
        expiresIn: '7d'
      }
    );

    // 5. Возвращаем токен
    res.json({
      token,
      user: {
        id: user.id,
        email: user.email
      }
    });

  } catch (error) {
    console.error('Login error:', error);

    res.status(500).json({
      error: 'Internal server error'
    });
  }
}

module.exports = {
  register,
  login
};