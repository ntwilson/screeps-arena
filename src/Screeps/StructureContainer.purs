module Screeps.StructureContainer where

import Screeps.Inheritance (class DirectlyInherits)
import Screeps.Structure (Structure)
import Unsafe.Coerce (unsafeCoerce)

data StructureContainer

instance DirectlyInherits StructureContainer Structure where
  directUpcast = unsafeCoerce
  directDowncast = unsafeCoerce
