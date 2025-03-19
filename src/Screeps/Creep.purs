module Screeps.Creep where

import Prelude

import Effect (Effect)
import Effect.Uncurried (EffectFn2, runEffectFn2)
import Foreign (Foreign)
import Screeps.GameObject (GameObject)
import Screeps.Inheritance (class Inherits)
import Screeps.Store (Store)
import Screeps.Structure (Structure)
import Unsafe.Coerce (unsafeCoerce)

data Creep

instance Inherits Creep GameObject where
  upcast = unsafeCoerce
  downcast = unsafeCoerce

foreign import withdrawEnergyImpl :: EffectFn2 Creep Foreign Unit
foreign import transferEnergyImpl :: EffectFn2 Creep Foreign Unit

transferEnergy :: ∀ t. Inherits t Structure => Creep -> t -> Effect Unit
transferEnergy creep target = 
  runEffectFn2 transferEnergyImpl creep (unsafeCoerce target)

withdrawEnergy :: ∀ t. Inherits t Structure => Creep -> t -> Effect Unit
withdrawEnergy creep target = 
  runEffectFn2 withdrawEnergyImpl creep (unsafeCoerce target)

moveTo :: ∀ t. Inherits t GameObject => Creep -> t -> Effect Unit
moveTo creep target = 
  (unsafeCoerce creep).moveTo(target)

my :: Creep -> Boolean
my creep = 
  (unsafeCoerce creep).my

store :: Creep -> Store
store creep = 
  (unsafeCoerce creep).store
