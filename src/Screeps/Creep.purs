module Screeps.Creep where

import Prelude

import Effect (Effect)
import Effect.Uncurried (EffectFn2, runEffectFn2)
import Foreign (Foreign, unsafeToForeign)
import Screeps.Constants (BodyPartType, Code)
import Screeps.GameObjects (Creep, GameObject, Structure)
import Screeps.Inheritance (class Inherits)
import Unsafe.Coerce (unsafeCoerce)

foreign import withdrawEnergyImpl :: EffectFn2 Creep Foreign Unit
foreign import transferEnergyImpl :: EffectFn2 Creep Foreign Unit

transferEnergy :: ∀ t. Inherits t Structure => Creep -> t -> Effect Unit
transferEnergy creep target = 
  runEffectFn2 transferEnergyImpl creep (unsafeCoerce target)

withdrawEnergy :: ∀ t. Inherits t Structure => Creep -> t -> Effect Unit
withdrawEnergy creep target = 
  runEffectFn2 withdrawEnergyImpl creep (unsafeCoerce target)

moveTo :: ∀ t. Inherits t GameObject => Creep -> t -> Effect Unit
moveTo creep target = runEffectFn2 moveToImpl creep (unsafeToForeign target)

foreign import moveToImpl :: EffectFn2 Creep Foreign Unit

my :: Creep -> Boolean
my creep = 
  (unsafeCoerce creep).my

type BodyPart = { "type" :: BodyPartType, hits :: Int }
body :: Creep -> Array BodyPart
body creep = 
  (unsafeCoerce creep).body

rangedAttack :: ∀ t. Inherits t GameObject => Creep -> t -> Effect Code
rangedAttack creep target = 
  runEffectFn2 rangedAttackImpl creep (unsafeToForeign target)

foreign import rangedAttackImpl :: EffectFn2 Creep Foreign Code

heal :: ∀ t. Inherits t GameObject => Creep -> t -> Effect Code
heal creep target = 
  runEffectFn2 healImpl creep (unsafeToForeign target)

foreign import healImpl :: EffectFn2 Creep Foreign Code