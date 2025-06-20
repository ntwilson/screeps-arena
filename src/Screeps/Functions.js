
export function getObjectsByPrototypeImpl(prototype) {
  return utils.getObjectsByPrototype(prototype);
}

export function attackImpl(source, target) {
  return source.attack(target);
}

export function healImpl(source, target) {
  return source.heal(target);
}

export function findClosestByPathImpl(just, nothing, fromPos, positions) {
  let x = utils.findClosestByPath(fromPos, positions);
  if (x) {
    return just(x);
  } else {
    return nothing;
  }
}

export function findClosestByRangeImpl(just, nothing, fromPos, positions) {
  let x = utils.findClosestByRange(fromPos, positions);
  if (x) {
    return just(x);
  } else {
    return nothing;
  }
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