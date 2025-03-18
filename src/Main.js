
export function getCreeps() {
  return utils.getObjectsByPrototype(prototypes.Creep);
}

export function getFlags() { 
  return utils.getObjectsByPrototype(prototypes.Flag);
}