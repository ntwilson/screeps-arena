
export function resourceEnergy(store) {
  return store[constants.RESOURCE_ENERGY];
}

export function getFreeEnergyCapacity(store) {
  return store.getFreeCapacity(constants.RESOURCE_ENERGY);
}
