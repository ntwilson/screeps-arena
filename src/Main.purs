module Main where

import Prelude

import Data.Array as Array
import Data.Maybe (maybe)
import Effect (Effect)
import Effect.Exception (throw)
import Screeps.Creep (Creep, my, transferEnergy, withdrawEnergy)
import Screeps.Creep as Creep
import Screeps.GameObject (GameObject)
import Screeps.Inheritance (class DirectlyInherits, class Inherits)
import Screeps.Store as Store
import Screeps.StructureContainer (StructureContainer)
import Screeps.StructureTower (StructureTower, attack)
import Screeps.StructureTower as Tower
import Unsafe.Coerce (unsafeCoerce)

data Flag

instance DirectlyInherits Flag GameObject where
  directUpcast = unsafeCoerce
  directDowncast = unsafeCoerce

foreign import getCreeps :: Effect (Array Creep)
foreign import getFlags :: Effect (Array Flag)
foreign import getTowers :: Effect (Array StructureTower)
foreign import getContainers :: Effect (Array StructureContainer)

main :: Effect Unit
main = do
  towers <- getTowers
  tower <- Array.head towers # maybe (throw "No towers found") pure

  creeps <- getCreeps
  if (tower # Tower.store # Store.resourceEnergy) < 10 then do
    myCreep <- creeps # Array.find my # maybe (throw "No creeps found") pure
    if (myCreep # Creep.store # Store.resourceEnergy) == 0 then do
      containers <- getContainers
      container <- Array.head containers # maybe (throw "No containers found") pure
      myCreep `withdrawEnergy` container 
    else
      myCreep `transferEnergy` tower
  else do
    target <- creeps # Array.find (not my) # maybe (throw "No targets found") pure 
    tower `attack` target


