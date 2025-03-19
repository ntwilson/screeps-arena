module Screeps.Structure where

import Screeps.GameObject (GameObject)
import Screeps.Inheritance (class Inherits)
import Unsafe.Coerce (unsafeCoerce)

data Structure

instance Inherits Structure GameObject where
  upcast = unsafeCoerce
  downcast = unsafeCoerce
