
export function withdrawEnergyImpl(creep, target) {
  return creep.withdraw(target, constants.RESOURCE_ENERGY);
}

export function transferEnergyImpl(creep, target) {
  return creep.transfer(target, constants.RESOURCE_ENERGY);
}

export function moveToImpl(creep, target) {
  return creep.moveTo(target);
}

export function rangedAttackImpl(creep, target) {
  return creep.rangedAttack(target);
}

export function rangedMassAttackImpl(creep) {
  return creep.rangedMassAttack();
}

export function rangedHealImpl(creep, target) {
  return creep.rangedHeal(target);
}

export function harvestImpl(creep, target) {
  return creep.harvest(target);
}