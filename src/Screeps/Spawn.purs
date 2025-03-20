module Screeps.Spawn where

import Effect (Effect)
import Effect.Uncurried (EffectFn2, runEffectFn2)
import Screeps.Constants (BodyPartType)
import Screeps.GameObjects (Creep, Spawn)

spawnCreep :: Spawn -> Array BodyPartType -> Effect Creep
spawnCreep spawn body = 
  runEffectFn2 spawnCreepImpl spawn body

foreign import spawnCreepImpl :: EffectFn2 Spawn (Array BodyPartType) Creep
