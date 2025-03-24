module Screeps.Functions where

import Prelude

import Data.Function.Uncurried (Fn2, Fn3, runFn2, runFn3)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Uncurried (EffectFn1, EffectFn2, runEffectFn1, runEffectFn2)
import Foreign (Foreign, unsafeToForeign)
import Screeps.Constants (Code)
import Screeps.GameObjects (Creep, Flag, GameObject, OwnedStructure, Store, StructureTower)
import Screeps.Inheritance (class Inherits, class Prototype)
import Unsafe.Coerce (unsafeCoerce)

getObjectsByPrototype :: ∀ p t. Prototype p t => p -> Effect (Array t)
getObjectsByPrototype prototype = runEffectFn1 getObjectsByPrototypeImpl (unsafeToForeign prototype)

foreign import getObjectsByPrototypeImpl :: ∀ t. EffectFn1 Foreign (Array t)

class HasMy a where 
  my :: a -> Boolean

instance HasMy Creep where
  my creep = (unsafeCoerce creep).my

else instance HasMy Flag where
  my flag = (unsafeCoerce flag).my

else instance Inherits a OwnedStructure => HasMy a where
  my s = (unsafeCoerce s).my

class CanAttack a where
  attack :: ∀ t. Inherits t GameObject => a -> t -> Effect Code

instance CanAttack StructureTower where
  attack source target = runEffectFn2 attackImpl (unsafeToForeign source) (unsafeToForeign target)

instance CanAttack Creep where
  attack source target = runEffectFn2 attackImpl (unsafeToForeign source) (unsafeToForeign target)

foreign import attackImpl :: EffectFn2 Foreign Foreign Code

class CanHeal a where
  heal :: a -> Creep -> Effect Code

instance CanHeal Creep where
  heal source target = runEffectFn2 healImpl (unsafeToForeign source) target

instance CanHeal StructureTower where
  heal source target = runEffectFn2 healImpl (unsafeToForeign source) target

foreign import healImpl :: EffectFn2 Foreign Creep Code

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

class HasLocation a where
  x :: a -> Int
  y :: a -> Int

pos :: ∀ a. HasLocation a => a -> { x :: Int, y :: Int }
pos a = { x: x a, y: y a }

newtype Pos = Pos { x :: Int, y :: Int }
instance HasLocation Pos where
  x (Pos a) = a.x
  y (Pos a) = a.y

else instance (Inherits a GameObject) => HasLocation a where
  x a = (unsafeCoerce a).x
  y a = (unsafeCoerce a).y

foreign import findClosestByPathImpl :: ∀ t. Fn2 Foreign (Array Foreign) t

findClosestByPath :: ∀ s t. HasLocation s => HasLocation t => s -> Array t -> Maybe t
findClosestByPath source targets = 
  case targets of 
    [] -> Nothing
    _ -> Just $ runFn2 findClosestByPathImpl (unsafeToForeign source) (unsafeToForeign <$> targets)

findInRange :: ∀ s t. HasLocation s => HasLocation t => s -> Array t -> Int -> Array t
findInRange source targets range = runFn3 findInRangeImpl (unsafeToForeign source) (unsafeToForeign <$> targets) range

foreign import findInRangeImpl :: ∀ t. Fn3 Foreign (Array Foreign) Int (Array t)

getRange :: ∀ s t. HasLocation s => HasLocation t => s -> t -> Int
getRange source target = runFn2 getRangeImpl (unsafeToForeign source) (unsafeToForeign target)

foreign import getRangeImpl :: Fn2 Foreign Foreign Int

foreign import getTicks :: Effect Int