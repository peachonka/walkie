const jwt = require('jsonwebtoken');

async function authMiddleware(req, res, next) {
  try {
    // 1. Проверяем Authorization header
    const authHeader = req.headers.authorization;

    if (!authHeader) {
      return res.status(401).json({
        error: 'No authorization header'
      });
    }

    // 2. Проверяем формат Bearer token
    if (!authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        error: 'Invalid authorization format'
      });
    }

    // 3. Достаём токен
    const token = authHeader.substring(7);

    if (!token) {
      return res.status(401).json({
        error: 'No token provided'
      });
    }

    // 4. Проверяем JWT
    const decoded = jwt.verify(
      token,
      process.env.JWT_SECRET
    );

    // 5. Кладём userId в req
    req.userId = decoded.userId;

    // Можно также сохранить весь payload токена
    req.user = decoded;

    // 6. Передаём управление контроллеру
    next();

  } catch (err) {
    console.error('Auth error:', err);

    // JWT может быть просрочен, повреждён или подписан другим секретом
    if (
      err.name === 'JsonWebTokenError' ||
      err.name === 'TokenExpiredError'
    ) {
      return res.status(401).json({
        error: 'Invalid or expired token'
      });
    }

    res.status(500).json({
      error: 'Internal auth error'
    });
  }
}

module.exports = authMiddleware;