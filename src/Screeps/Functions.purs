module Screeps.Functions where

import Prelude

import Effect (Effect)
import Effect.Uncurried (EffectFn1, EffectFn2, runEffectFn1, runEffectFn2)
import Foreign (Foreign, unsafeToForeign)
import Screeps.Constants (Code)
import Screeps.GameObjects (Creep, GameObject, Store, StructureTower)
import Screeps.Inheritance (class Inherits, class Prototype)
import Unsafe.Coerce (unsafeCoerce)

getObjectsByPrototype :: ∀ p t. Prototype p t => p -> Effect (Array t)
getObjectsByPrototype prototype = runEffectFn1 getObjectsByPrototypeImpl (unsafeToForeign prototype)

foreign import getObjectsByPrototypeImpl :: ∀ t. EffectFn1 Foreign (Array t)

class CanAttack a where
  attack :: ∀ t. Inherits t GameObject => a -> t -> Effect Code

instance CanAttack StructureTower where
  attack source target = runEffectFn2 attackImpl (unsafeToForeign source) (unsafeToForeign target)

instance CanAttack Creep where
  attack source target = runEffectFn2 attackImpl (unsafeToForeign source) (unsafeToForeign target)

foreign import attackImpl :: EffectFn2 Foreign Foreign Code

class HasStore a where
  store :: a -> Store

instance HasStore Creep where
  store = storeImpl <<< unsafeToForeign

instance HasStore StructureTower where
  store = storeImpl <<< unsafeToForeign

storeImpl :: Foreign -> Store
storeImpl x = (unsafeCoerce x).store

class HasHits a where
  hits :: a -> Int
  hitsMax :: a -> Int

instance HasHits Creep where
  hits = hitsImpl <<< unsafeToForeign
  hitsMax = hitsMaxImpl <<< unsafeToForeign

instance HasHits StructureTower where
  hits = hitsImpl <<< unsafeToForeign
  hitsMax = hitsMaxImpl <<< unsafeToForeign

hitsImpl :: Foreign -> Int
hitsImpl x = (unsafeCoerce x).hits

hitsMaxImpl :: Foreign -> Int
hitsMaxImpl x = (unsafeCoerce x).hitsMax
