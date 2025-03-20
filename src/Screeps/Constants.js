
export function eqCode(a, b) {
  return a == b;
}

export var ok = constants.OK
export var errNotOwner = constants.ERR_NOT_OWNER
export var errInvalidTarget = constants.ERR_INVALID_TARGET
export var errNotInRange = constants.ERR_NOT_IN_RANGE
export var errNoBodypart = constants.ERR_NO_BODYPART

export function eqBodyPartType(a, b) {
  return a == b;
}

export var movePart = constants.MOVE
export var workPart = constants.WORK
export var carryPart = constants.CARRY
export var attackPart = constants.ATTACK
export var rangedAttackPart = constants.RANGED_ATTACK
export var healPart = constants.HEAL
export var toughPart = constants.TOUGH