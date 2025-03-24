module Tutorial.HarvestEnergy where

import Prelude

import Data.Array as Array
import Data.Maybe (maybe)
import Effect (Effect)
import Effect.Exception (throw)
import Screeps.Constants (errNotInRange)
import Screeps.Creep (harvest, moveTo, transferEnergy)
import Screeps.Functions (getObjectsByPrototype, my, store)
import Screeps.GameObjects (creepPrototype, sourcePrototype, spawnPrototype)
import Screeps.Store (getFreeEnergyCapacity)

main :: Effect Unit
main = do
  creep <- getObjectsByPrototype creepPrototype >>= (Array.find my >>> maybe (throw "No creeps found") pure)
  source <- getObjectsByPrototype sourcePrototype >>= (Array.head >>> maybe (throw "No sources found") pure)
  spawn <- getObjectsByPrototype spawnPrototype >>= (Array.find my >>> maybe (throw "No spawns found") pure)

  if (getFreeEnergyCapacity (store creep) > 0) then
    whenM (creep `harvest` source <#> (_ == errNotInRange)) do
      void $ creep `moveTo` source
  else
    whenM (creep `transferEnergy` spawn <#> (_ == errNotInRange)) do
      void $ creep `moveTo` spawn
