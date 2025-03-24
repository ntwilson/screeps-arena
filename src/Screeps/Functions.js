
export function getObjectsByPrototypeImpl(prototype) {
  return utils.getObjectsByPrototype(prototype);
}

export function attackImpl(source, target) {
  return source.attack(target);
}

export function healImpl(source, target) {
  return source.heal(target);
}

export function findClosestByPathImpl(fromPos, positions) {
  return utils.findClosestByPath(fromPos, positions);
}

export function findInRangeImpl(fromPos, positions, range) {
  return utils.findInRange(fromPos, positions, range);
}

export function getRangeImpl(fromPos, toPos) {
  return utils.getRange(fromPos, toPos);
}

export function getTicks() {
  return utils.getTicks();
}