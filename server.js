// server.js (добавляем новый маршрут)

const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');

dotenv.config();

const walksRoutes = require('./src/routes/walks');
const itemsRoutes = require('./src/routes/items');
const statsRoutes = require('./src/routes/stats');
const petRoutes = require('./src/routes/pet');
const zonesRoutes = require('./src/routes/zones');
const achievementsRoutes = require('./src/routes/achievements');
const itemPositionRoutes = require('./src/routes/itemPosition');  // НОВЫЙ

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.path}`);
  next();
});

app.use('/api/walks', walksRoutes);
app.use('/api/items', itemsRoutes);
app.use('/api/stats', statsRoutes);
app.use('/api/pet', petRoutes);
app.use('/api/zones', zonesRoutes);
app.use('/api/achievements', achievementsRoutes);
app.use('/api/item-positions', itemPositionRoutes);  // НОВЫЙ

app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.use((req, res) => {
  res.status(404).json({ error: 'Endpoint not found' });
});

app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).json({ error: 'Internal server error' });
});

app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
  console.log(`📋 Health: http://localhost:${PORT}/health`);
  console.log(`🎁 Items: http://localhost:${PORT}/api/items`);
  console.log(`📊 Stats: http://localhost:${PORT}/api/stats`);
  console.log(`🐾 Pet: http://localhost:${PORT}/api/pet`);
  console.log(`🗺️ Zones: http://localhost:${PORT}/api/zones`);
  console.log(`🏆 Achievements: http://localhost:${PORT}/api/achievements`);
  console.log(`📍 Item Positions: http://localhost:${PORT}/api/item-positions`);
});