
export function getCreeps() {
  return utils.getObjectsByPrototype(prototypes.Creep);
}

export function getFlags() { 
  return utils.getObjectsByPrototype(prototypes.Flag);
}

export function getTowers() {
  return utils.getObjectsByPrototype(prototypes.StructureTower);
}

export function getContainers() {
  return utils.getObjectsByPrototype(prototypes.StructureContainer);
}