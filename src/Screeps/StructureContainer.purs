module Screeps.StructureContainer where

import Screeps.Inheritance (class Inherits)
import Screeps.Structure (Structure)
import Unsafe.Coerce (unsafeCoerce)

data StructureContainer

instance Inherits StructureContainer Structure where
  upcast = unsafeCoerce
  downcast = unsafeCoerce
