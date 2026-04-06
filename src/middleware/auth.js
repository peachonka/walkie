const jwt = require('jsonwebtoken');
const supabase = require('../lib/supabaseClient');

const JWT_SECRET = process.env.JWT_SECRET || 'walkie-super-secret-key-for-development';

function verifyToken(req, res, next) {
  const authHeader = req.headers.authorization;
  
  if (!authHeader) {
    return res.status(401).json({ error: 'No token provided' });
  }
  
  const token = authHeader.replace('Bearer ', '');
  
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.userId = decoded.sub || decoded.userId || 1;
    next();
  } catch (error) {
    return res.status(401).json({ error: 'Invalid token' });
  }
}

function mockAuth(req, res, next) {
  req.userId = '60a762b6-3d6f-4790-9998-2de78a472b34';
  next();
}

async function authMiddleware(req, res, next) {
  try {
    // 1. Проверяем header
    const authHeader = req.headers.authorization;

    if (!authHeader) {
      return res.status(401).json({ error: 'No authorization header' });
    }

    // 2. Достаём токен
    const token = authHeader.replace('Bearer ', '');

    if (!token) {
      return res.status(401).json({ error: 'No token provided' });
    }

    // 3. Проверяем токен через Supabase
    const { data, error } = await supabase.auth.getUser(token);

    if (error || !data.user) {
      return res.status(401).json({ error: 'Invalid token' });
    }

    // 4. Кладём userId в req
    req.userId = data.user.id;
    req.user = data.user;

    next();
  } catch (err) {
    console.error('Auth error:', err);
    res.status(500).json({ error: 'Internal auth error' });
  }
}


module.exports = { verifyToken, mockAuth, authMiddleware };