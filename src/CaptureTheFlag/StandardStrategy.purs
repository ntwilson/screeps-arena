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
import Screeps.Functions (class HasLocation, Pos(..), attack, findClosestByPath, findClosestByRange, findClosestPreferrablyByPath, findInRange, getObjectsByPrototype, getRange, getTicks, heal, hits, hitsMax, my, pos, store, x, y)
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

rendezvousPoint :: Effect Pos
rendezvousPoint = do
  homeBase <- getObjectsByPrototype flagPrototype <#> Array.find my >>= orNotFound "home base"
  let candidates = Pos <$> [ { x: 70, y: 70 }, { x: 30, y: 30 } ]
  findClosestByRange homeBase candidates # orNotFound "rendezvous point"

attackStrategy :: Creep -> Effect Unit
attackStrategy creep = do
  creeps <- getObjectsByPrototype creepPrototype
  towers <- getObjectsByPrototype structureTowerPrototype <#> Array.filter my
  homeBase <- getObjectsByPrototype flagPrototype <#> Array.find my >>= orNotFound "home base"
  flag <- getObjectsByPrototype flagPrototype <#> Array.find (not my) >>= orNotFound "enemy flag"
  ticks <- getTicks
  rendezvous <- rendezvousPoint

  let 
    { yes: friends, no: enemies } = creeps # Array.partition my
    { yes: healers, no: attackers } = friends # Array.partition (body >>> map _.type >>> Array.elem healPart)
    enemiesOutOfRangeOfTurret = enemies # Array.filter (\enemy -> getRange enemy flag > 55)
    enemiesInRangeOfOurTurret = enemies # Array.filter (\enemy -> getRange enemy homeBase < 50)
    preferredSharedTarget = 
      if ticks < 100 then
        findClosestPreferrablyByPath homeBase enemiesInRangeOfOurTurret
        <|>
        findClosestPreferrablyByPath (centerOfMass attackers) enemiesInRangeOfOurTurret
      else
        findClosestPreferrablyByPath homeBase enemiesInRangeOfOurTurret
        <|>
        findClosestPreferrablyByPath (centerOfMass attackers) enemiesOutOfRangeOfTurret 
        <|> 
        findClosestPreferrablyByPath (centerOfMass attackers) enemies

    preferredTarget = 
      let 
        nearbyEnemies = findInRange creep enemiesOutOfRangeOfTurret 1
      in
        find (_ `Array.elem` nearbyEnemies) preferredSharedTarget
        <|> 
        findClosestByPath creep (nearbyEnemies # Array.filter (body >>> map _.type >>> Array.elem healPart)) 
        <|>
        findClosestByPath creep nearbyEnemies 
        <|> 
        case preferredSharedTarget of
          Nothing -> Nothing 
          Just target ->
            findClosestByPath creep [target]
            <|>
            findClosestByPath creep enemies

    closestHealer = findClosestByPath creep ((upcast <$> towers) <> (upcast <$> healers) :: Array GameObject)

    moveTarget = 
      if hits creep < hitsMax creep then
        case preferredTarget of
          Just target | getRange homeBase target < getRange homeBase creep -> homeBase # pos
          Just _ -> closestHealer # fromMaybe (upcast homeBase) # pos
          _ -> pos flag
      else
        if Array.length friends >= Array.length enemies * 3 then
          pos flag
        else case preferredTarget of 
          Just target -> pos target
          Nothing -> pos rendezvous

  void $ creep `moveTo` (Pos moveTarget)

  when ((findInRange creep enemies 2 # Array.length) > 2) $
    void $ rangedMassAttack creep

  case preferredTarget of
    Just target -> do
      void $ creep `rangedAttack` target
      void $ creep `attack` target
    Nothing -> pure unit

healerStrategy :: Creep -> Effect Unit
healerStrategy creep = do
  creeps <- getObjectsByPrototype creepPrototype

  let 
    { yes: friends } = creeps # Array.partition my
    attackers = friends # Array.filter (body >>> map _.type >>> not Array.elem healPart)
    hurtFriends = friends # Array.filter (\c -> hits c < hitsMax c)
    hurtFrindsNotMe = hurtFriends # Array.filter (_ /= creep)
    closestHurtFriend = findClosestByPath creep hurtFriends
    closestHurtFriendNotMe = findClosestByPath creep hurtFrindsNotMe

  case closestHurtFriend of
    Just target -> do
      whenM (creep `heal` target <#> (_ == errNotInRange)) do
        void $ creep `rangedHeal` target
    Nothing -> pure unit

  case closestHurtFriendNotMe of
    Just target -> void $ creep `moveTo` target
    Nothing -> void $ creep `moveTo` (centerOfMass attackers)


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
      preferredTarget = shortRangeTarget <|> if getFreeEnergyCapacity (store tower) == 0 then longRangeTarget else Nothing
    case preferredTarget of
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
      distance * distance * distance + health

