module Screeps.Inheritance where

import Data.Function.Uncurried (Fn4, runFn4)
import Data.Maybe (Maybe(..))
import Unsafe.Coerce (unsafeCoerce)

class Prototype :: Type -> Type -> Constraint
class Prototype p t | p -> t, t -> p

class Inherits child parent where
  upcast :: child -> parent
  downcast :: parent -> Maybe child

defaultUpcast :: forall a b. a -> b
defaultUpcast = unsafeCoerce

defaultDowncast :: ∀ proto parent child. Prototype proto child => proto -> parent -> Maybe child
defaultDowncast prototype parent = runFn4 downcastImpl prototype parent Just Nothing

foreign import downcastImpl :: ∀ p a b. Fn4 p a (b -> Maybe b) (Maybe b) (Maybe b)

-- instance (Inherits child parent, Inherits parent grandparent) => Inherits child grandparent where
--   upcast child = upcast (upcast child :: parent)
--   downcast grandparent = (downcast grandparent :: Maybe parent) >>= downcast

