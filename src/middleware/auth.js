const jwt = require('jsonwebtoken');

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

module.exports = { verifyToken, mockAuth };