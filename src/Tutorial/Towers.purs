module Tutorial.Towers where

import Prelude

import Data.Array as Array
import Data.Maybe (maybe)
import Effect (Effect)
import Effect.Exception (throw)
import Screeps.Creep (my, transferEnergy, withdrawEnergy)
import Screeps.Functions (attack, getObjectsByPrototype, store)
import Screeps.GameObjects (creepPrototype, structureContainerPrototype, structureTowerPrototype)
import Screeps.Store as Store

main :: Effect Unit
main = do
  towers <- getObjectsByPrototype structureTowerPrototype
  tower <- Array.head towers # maybe (throw "No towers found") pure

  creeps <- getObjectsByPrototype creepPrototype
  if (tower # store # Store.resourceEnergy) < 10 then do
    myCreep <- creeps # Array.find my # maybe (throw "No creeps found") pure
    if (myCreep # store # Store.resourceEnergy) == 0 then do
      containers <- getObjectsByPrototype structureContainerPrototype
      container <- Array.head containers # maybe (throw "No containers found") pure
      myCreep `withdrawEnergy` container 
    else
      myCreep `transferEnergy` tower
  else do
    target <- creeps # Array.find (not my) # maybe (throw "No targets found") pure 
    void $ tower `attack` target
