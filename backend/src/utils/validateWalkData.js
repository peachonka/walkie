function validateWalkData(distance, duration, steps) {
  // Проверка типов
  if (
    typeof distance !== 'number' ||
    typeof duration !== 'number' ||
    typeof steps !== 'number' ||
    !Number.isFinite(distance) ||
    !Number.isFinite(duration) ||
    !Number.isFinite(steps)
  ) {
    return 'Distance, duration and steps must be valid numbers';
  }

  // Проверка минимальных значений
  if (distance <= 0 || duration <= 0 || steps < 0) {
    return 'Distance and duration must be positive, steps must be non-negative';
  }

  // Проверка целочисленности шагов
  if (!Number.isInteger(steps)) {
    return 'Steps must be an integer';
  }

  // Проверка верхних границ
  if (distance > 100000 || duration > 86400 || steps > 200000) {
    return 'Walk data exceeds allowed limits';
  }

  // Проверка скорости
  const speed = distance / duration;

  if (speed > 4) {
    return 'Walking speed is too high';
  }

  // Проверка средней длины шага, если шаги есть
  if (steps > 0) {
    const stepLength = distance / steps;

    if (stepLength < 0.2 || stepLength > 2.5) {
      return 'Average step length is outside allowed limits';
    }
  }

  return null;
}

module.exports = validateWalkData;