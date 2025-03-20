
export function getObjectsByPrototypeImpl(prototype) {
  return utils.getObjectsByPrototype(prototype);
}

export function attackImpl(source, target) {
  return source.attack(target);
}

export function findClosestByPathImpl(fromPos, positions) {
  return utils.findClosestByPath(fromPos, positions);
}