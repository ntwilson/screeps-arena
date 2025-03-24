module CaptureTheFlag.StandardStrategy where

import Prelude

import Control.Alt ((<|>))
import Data.Array as Array
import Data.Foldable (find, for_, minimumBy, sum)
import Data.Maybe (Maybe(..), fromMaybe, maybe)
import Effect (Effect)
import Effect.Exception (throw)
import Screeps.Constants (attackPart, errNotInRange, healPart, rangedAttackPart)
import Screeps.Creep (body, moveTo, rangedAttack, rangedHeal, rangedMassAttack)
import Screeps.Functions (class HasLocation, Pos(..), attack, findClosestByPath, findInRange, getObjectsByPrototype, getRange, getTicks, heal, hits, hitsMax, my, store, x, y)
import Screeps.GameObjects (Creep, GameObject, creepPrototype, flagPrototype, structureTowerPrototype)
import Screeps.Inheritance (upcast)
import Screeps.Store (getFreeEnergyCapacity)

orNotFound :: ∀ a. String -> Maybe a -> Effect a
orNotFound name = maybe (throw ("No " <> name <> " found")) pure

centerOfMass :: ∀ t. HasLocation t => Array t -> Pos
centerOfMass objs = 
  let 
    xs = objs <#> x
    ys = objs <#> y
  in Pos { x: sum xs / Array.length xs, y: sum ys / Array.length ys }

attackStrategy :: Creep -> Effect Unit
attackStrategy creep = do
  creeps <- getObjectsByPrototype creepPrototype
  towers <- getObjectsByPrototype structureTowerPrototype <#> Array.filter my
  homeBase <- getObjectsByPrototype flagPrototype <#> Array.find my >>= orNotFound "home base"
  flag <- getObjectsByPrototype flagPrototype <#> Array.find (not my) >>= orNotFound "enemy flag"
  ticks <- getTicks

  let 
    { yes: friends, no: enemies } = creeps # Array.partition my
    { yes: healers, no: attackers } = friends # Array.partition (body >>> map _.type >>> Array.elem healPart)
    preferredSharedTarget = 
      let 
        enemiesOutOfRangeOfTurret = enemies # Array.filter (\enemy -> getRange enemy flag > 55)
        enemiesInRangeOfOurTurret = enemies # Array.filter (\enemy -> getRange enemy homeBase < 60)
      in
        if ticks < 100 then
          findClosestByPath (centerOfMass attackers) enemiesInRangeOfOurTurret
        else
          findClosestByPath (centerOfMass attackers) enemiesOutOfRangeOfTurret 
          <|>
          findClosestByPath homeBase enemiesOutOfRangeOfTurret 

    closestHealer = findClosestByPath creep ((upcast <$> towers) <> (upcast <$> healers) :: Array GameObject)

    closestEnemy = findClosestByPath creep enemies
    preferredTarget = 
      let 
        enemiesOutOfRangeOfTurret = enemies # Array.filter (\enemy -> getRange enemy flag > 55)
        nearbyEnemies = findInRange creep enemiesOutOfRangeOfTurret 6
      in
        find (_ `Array.elem` nearbyEnemies) preferredSharedTarget
        <|> 
        findClosestByPath creep (nearbyEnemies # Array.filter (body >>> map _.type >>> Array.elem healPart)) 
        <|>
        findClosestByPath creep nearbyEnemies 
        <|> 
        preferredSharedTarget


  case closestEnemy of
    Just target -> do
      void $ creep `attack` target
      if (findInRange creep enemies 2 # Array.length) > 2 then
        void $ rangedMassAttack creep
      else
        void $ creep `rangedAttack` target
    Nothing -> pure unit

  if hits creep < hitsMax creep then
    void $ creep `moveTo` (closestHealer # fromMaybe (upcast homeBase))
  else 
    case preferredTarget of
      Just preferredTarget -> void $ creep `moveTo` preferredTarget
      Nothing -> 
        if Array.length friends > Array.length enemies * 3 then
          void $ creep `moveTo` flag
        else 
          if Array.length friends < (Array.length enemies * 8 / 10) then
            void $ creep `moveTo` homeBase
          else
            if ticks < 100 then
              void $ creep `moveTo` homeBase
            else 
              void $ creep `moveTo` (Pos { x: 83, y: 22 })

healerStrategy :: Creep -> Effect Unit
healerStrategy creep = do
  creeps <- getObjectsByPrototype creepPrototype
  homeBase <- getObjectsByPrototype flagPrototype <#> Array.find my >>= orNotFound "home base"
  flag <- getObjectsByPrototype flagPrototype <#> Array.find (not my) >>= orNotFound "enemy flag"
  ticks <- getTicks

  let 
    { yes: friends, no: enemies } = creeps # Array.partition my
    attackers = friends # Array.filter (body >>> map _.type >>> not Array.elem healPart)
    closestHurtFriend = findClosestByPath creep (friends # Array.filter (\c -> hits c < hitsMax c))
    preferredTarget = 
      let 
        enemiesOutOfRangeOfTurret = enemies # Array.filter (\enemy -> getRange enemy flag > 55)
        hurtFriends = friends # Array.filter (\c -> hits c < hitsMax c)
        enemiesInRangeOfOurTurret = enemies # Array.filter (\enemy -> getRange enemy homeBase < 60)
      in
        findClosestByPath creep hurtFriends 
        <|>
        if ticks < 100 then
          findClosestByPath (centerOfMass attackers) enemiesInRangeOfOurTurret
        else
          findClosestByPath (centerOfMass attackers) enemiesOutOfRangeOfTurret 
          <|>
          findClosestByPath homeBase enemiesOutOfRangeOfTurret 


  case closestHurtFriend of
    Just target -> do
      whenM (creep `heal` target <#> (_ == errNotInRange)) do
        void $ creep `rangedHeal` target
    Nothing -> pure unit

  case preferredTarget of
    Just preferredTarget -> void $ creep `moveTo` preferredTarget
    Nothing -> 
      if Array.length friends > Array.length enemies * 3 then
        void $ creep `moveTo` flag
      else 
        if Array.length friends < (Array.length enemies * 8 / 10) then
          void $ creep `moveTo` homeBase
        else
          if ticks < 100 then
            void $ creep `moveTo` homeBase
          else 
            void $ creep `moveTo` (Pos { x: 83, y: 22 })


main :: Effect Unit
main = do
  towers <- getObjectsByPrototype structureTowerPrototype <#> Array.filter my
  creeps <- getObjectsByPrototype creepPrototype

  let 
    myCreeps = creeps # Array.filter my
    healers = myCreeps # Array.filter (body >>> map _.type >>> Array.elem healPart)
    meleeAttackers = myCreeps # Array.filter (body >>> map _.type >>> Array.elem attackPart)
    rangedAttackers = myCreeps # Array.filter (body >>> map _.type >>> Array.elem rangedAttackPart)
    attackers = meleeAttackers <> rangedAttackers

  for_ healers healerStrategy
  for_ attackers attackStrategy

  for_ towers \tower -> do
    let
      potentialTargets = creeps # Array.filter (\c -> not (my c && hits c == hitsMax c))
      longRangeTargets = findInRange tower potentialTargets 50
      shortRangeTargets = findInRange tower potentialTargets 25
      longRangeTarget = longRangeTargets # minimumBy (comparing (targetingScore tower))
      shortRangeTarget = shortRangeTargets # minimumBy (comparing (targetingScore tower))
      target = shortRangeTarget <|> if getFreeEnergyCapacity (store tower) == 0 then Nothing else longRangeTarget
    case target of
      Just target
        | my target -> void $ tower `heal` target
        | otherwise -> void $ tower `attack` target
      Nothing -> pure unit

  where

  targetingScore tower creep = 
    let
      distance = getRange tower creep
      health = hits creep
    in
      distance * distance + health * health

