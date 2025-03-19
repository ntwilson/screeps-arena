
export function withdrawEnergyImpl(creep, target) {
  creep.withdraw(target, constants.RESOURCE_ENERGY);
}

export function transferEnergyImpl(creep, target) {
  creep.transfer(target, constants.RESOURCE_ENERGY);
}