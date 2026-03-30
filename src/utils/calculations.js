function calculateDistance(lat1, lon1, lat2, lon2) {
  const R = 6371000;
  const φ1 = lat1 * Math.PI / 180;
  const φ2 = lat2 * Math.PI / 180;
  const Δφ = (lat2 - lat1) * Math.PI / 180;
  const Δλ = (lon2 - lon1) * Math.PI / 180;
  
  const a = Math.sin(Δφ/2) * Math.sin(Δφ/2) +
            Math.cos(φ1) * Math.cos(φ2) *
            Math.sin(Δλ/2) * Math.sin(Δλ/2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
  
  return Math.round(R * c);
}

function isPointInSquareZone(pointLat, pointLng, zone) {
  const halfSide = zone.sideLengthMeters / 2;
  const latDegPerMeter = 1 / 111320;
  const lngDegPerMeter = 1 / (111320 * Math.cos(zone.centerLat * Math.PI / 180));
  
  const latMin = zone.centerLat - halfSide * latDegPerMeter;
  const latMax = zone.centerLat + halfSide * latDegPerMeter;
  const lngMin = zone.centerLng - halfSide * lngDegPerMeter;
  const lngMax = zone.centerLng + halfSide * lngDegPerMeter;
  
  return pointLat >= latMin && pointLat <= latMax && 
         pointLng >= lngMin && pointLng <= lngMax;
}

module.exports = { calculateDistance, isPointInSquareZone };