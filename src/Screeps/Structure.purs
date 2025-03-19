module Screeps.Structure where

import Screeps.GameObject (GameObject)
import Screeps.Inheritance (class DirectlyInherits)
import Unsafe.Coerce (unsafeCoerce)

data Structure

instance DirectlyInherits Structure GameObject where
  directUpcast = unsafeCoerce
  directDowncast = unsafeCoerce
