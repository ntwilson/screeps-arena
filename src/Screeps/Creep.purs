module Screeps.Creep where

import Effect (Effect)
import Effect.Uncurried (EffectFn1, EffectFn2, runEffectFn1, runEffectFn2)
import Foreign (Foreign, unsafeToForeign)
import Screeps.Constants (BodyPartType, Code)
import Screeps.Functions (class HasLocation)
import Screeps.GameObjects (Creep, GameObject, Source, Structure)
import Screeps.Inheritance (class Inherits)
import Unsafe.Coerce (unsafeCoerce)

foreign import withdrawEnergyImpl :: EffectFn2 Creep Foreign Code
foreign import transferEnergyImpl :: EffectFn2 Creep Foreign Code

transferEnergy :: ∀ t. Inherits t Structure => Creep -> t -> Effect Code
transferEnergy creep target = 
  runEffectFn2 transferEnergyImpl creep (unsafeCoerce target)

withdrawEnergy :: ∀ t. Inherits t Structure => Creep -> t -> Effect Code
withdrawEnergy creep target = 
  runEffectFn2 withdrawEnergyImpl creep (unsafeCoerce target)

moveTo :: ∀ t. HasLocation t => Creep -> t -> Effect Code
moveTo creep target = runEffectFn2 moveToImpl creep (unsafeToForeign target)

foreign import moveToImpl :: EffectFn2 Creep Foreign Code

type BodyPart = { "type" :: BodyPartType, hits :: Int }
body :: Creep -> Array BodyPart
body creep = 
  (unsafeCoerce creep).body

rangedAttack :: ∀ t. Inherits t GameObject => Creep -> t -> Effect Code
rangedAttack creep target = 
  runEffectFn2 rangedAttackImpl creep (unsafeToForeign target)

foreign import rangedAttackImpl :: EffectFn2 Creep Foreign Code

rangedMassAttack :: Creep -> Effect Code
rangedMassAttack creep = 
  runEffectFn1 rangedMassAttackImpl creep

foreign import rangedMassAttackImpl :: EffectFn1 Creep Code

rangedHeal :: Creep -> Creep -> Effect Code
rangedHeal creep target = 
  runEffectFn2 rangedHealImpl creep target

foreign import rangedHealImpl :: EffectFn2 Creep Creep Code

harvest :: Creep -> Source -> Effect Code
harvest creep source = 
  runEffectFn2 harvestImpl creep source

foreign import harvestImpl :: EffectFn2 Creep Source Code
