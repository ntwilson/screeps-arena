module Tutorial.SpawnCreeps where

import Prelude

import Data.Array as Array
import Data.Maybe (Maybe(..), maybe)
import Effect (Effect)
import Effect.Exception (throw)
import Screeps.Constants (movePart)
import Screeps.Creep (moveTo)
import Screeps.Functions (findClosestByPath, getObjectsByPrototype)
import Screeps.GameObjects (creepPrototype, flagPrototype, spawnPrototype)
import Screeps.Spawn (spawnCreep)

main :: Effect Unit
main = do
  mySpawns <- getObjectsByPrototype spawnPrototype
  myCreeps <- getObjectsByPrototype creepPrototype
  flags <- getObjectsByPrototype flagPrototype
  {flag1, flag2} <- case flags of
    [flag1, flag2] -> pure {flag1, flag2}
    _ -> throw "Expected exactly two flags"

  mySpawn <- Array.head mySpawns # maybe (throw "No spawn found") pure

  when (Array.length myCreeps < 2) (void (mySpawn `spawnCreep` [movePart]))

  case findClosestByPath flag1 myCreeps of
    Just closestCreep -> do
      void $ closestCreep `moveTo` flag1
      myCreeps # Array.find (_ /= closestCreep) # maybe (pure unit) (void <<< (_ `moveTo` flag2))
    Nothing -> pure unit
