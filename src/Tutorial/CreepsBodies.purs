module Tutorial.CreepsBodies where

import Prelude

import Data.Array as Array
import Data.Foldable (for_)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Screeps.Constants (attackPart, errNotInRange, healPart, rangedAttackPart)
import Screeps.Creep (body, heal, moveTo, my, rangedAttack)
import Screeps.Functions (attack, getObjectsByPrototype, hits, hitsMax)
import Screeps.GameObjects (creepPrototype)

main :: Effect Unit
main = do
  myCreeps <- getObjectsByPrototype creepPrototype <#> Array.filter my
  tryEnemyCreep <- getObjectsByPrototype creepPrototype <#> Array.find (not my)
  case tryEnemyCreep of 
    Nothing -> do
      pure unit
    Just enemyCreep -> do
      for_ myCreeps \creep -> do
        when (body creep # Array.any (\bodyPart -> bodyPart.type == attackPart)) do
          attackResult <- creep `attack` enemyCreep
          when (attackResult == errNotInRange) do
            creep `moveTo` enemyCreep
        when (body creep # Array.any (\bodyPart -> bodyPart.type == rangedAttackPart)) do
          attackResult <- creep `rangedAttack` enemyCreep
          when (attackResult == errNotInRange) do
            creep `moveTo` enemyCreep
        when (body creep # Array.any (\bodyPart -> bodyPart.type == healPart)) do
          let myDamagedCreeps = myCreeps # Array.filter (\i -> hits i < hitsMax i)
          case Array.head myDamagedCreeps of
            Nothing -> do
              pure unit
            Just myDamagedCreep -> do
              healResult <- creep `heal` myDamagedCreep
              when (healResult == errNotInRange) do
                creep `moveTo` myDamagedCreep
