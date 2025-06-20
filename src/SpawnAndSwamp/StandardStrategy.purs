module SpawnAndSwamp.StandardStrategy where

import Prelude

import Data.Array as Array
import Data.Foldable (sum, traverse_)
import Data.Maybe (Maybe, maybe)
import Effect (Effect)
import Effect.Exception (throw)
import Screeps.Constants (attackPart, movePart)
import Screeps.Creep (body, moveTo)
import Screeps.Functions (class HasLocation, Pos(..), attack, getObjectsByPrototype, my, x, y)
import Screeps.GameObjects (creepPrototype, spawnPrototype)
import Screeps.Spawn (spawnCreep)

orNotFound :: ∀ a. String -> Maybe a -> Effect a
orNotFound name = maybe (throw ("No " <> name <> " found")) pure

centerOfMass :: ∀ t. HasLocation t => Array t -> Pos
centerOfMass objs = 
  let 
    xs = objs <#> x
    ys = objs <#> y
  in Pos { x: sum xs / Array.length xs, y: sum ys / Array.length ys }

main :: Effect Unit
main = do
  creeps <- getObjectsByPrototype creepPrototype
  spawns <- getObjectsByPrototype spawnPrototype
  mySpawn <- spawns # Array.find my # orNotFound "my spawn"
  enemySpawn <- spawns # Array.find (not my) # orNotFound "enemy spawn"
  let
    myCreeps = creeps # Array.filter my
    meleeAttackers = myCreeps # Array.filter (body >>> map _.type >>> Array.elem attackPart)

  if Array.null meleeAttackers then
    void $ mySpawn `spawnCreep` [movePart, attackPart]
  else 
    meleeAttackers # traverse_ \attacker -> do
      void $ attacker `moveTo` enemySpawn
      void $ attacker `attack` enemySpawn
