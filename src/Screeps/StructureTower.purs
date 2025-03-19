module Screeps.StructureTower where

import Prelude

import Effect (Effect)
import Effect.Uncurried (EffectFn2, runEffectFn2)
import Screeps.GameObject (GameObject)
import Screeps.Inheritance (class Inherits, upcast)
import Screeps.Store (Store)
import Screeps.Structure (Structure)
import Unsafe.Coerce (unsafeCoerce)

data StructureTower

instance Inherits StructureTower GameObject where
  upcast = unsafeCoerce
  downcast = unsafeCoerce

instance Inherits StructureTower Structure where
  upcast = unsafeCoerce
  downcast = unsafeCoerce

store :: StructureTower -> Store
store tower = (unsafeCoerce tower).store

foreign import attackImpl :: EffectFn2 StructureTower GameObject Unit 

attack :: ∀ t. Inherits t GameObject => StructureTower -> t -> Effect Unit
attack tower target = runEffectFn2 attackImpl tower (upcast target)
