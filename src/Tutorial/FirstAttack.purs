module Tutorial.FirstAttack where

import Prelude

import Data.Array as Array
import Data.Maybe (maybe)
import Effect (Effect)
import Effect.Exception (throw)
import Screeps.Constants (errNotInRange)
import Screeps.Creep (moveTo, my)
import Screeps.Functions (attack, getObjectsByPrototype)
import Screeps.GameObjects (creepPrototype)

main :: Effect Unit
main = do
  creeps <- getObjectsByPrototype creepPrototype
  myCreep <- creeps # Array.find (my) # maybe (throw "No creeps found") pure
  enemyCreep <- creeps # Array.find (not <<< my) # maybe (throw "No enemy creeps found") pure

  attackResult <- myCreep `attack` enemyCreep
  when (attackResult == errNotInRange) do
    myCreep `moveTo` enemyCreep
