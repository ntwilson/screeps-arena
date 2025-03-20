module Screeps.GameObjects where

import Prelude

import Data.Function.Uncurried (Fn2, runFn2)
import Screeps.Inheritance (class Inherits, class Prototype, defaultDowncast, defaultUpcast)

data GameObject

data Creep
data CreepPrototype
foreign import creepPrototype :: CreepPrototype
instance Prototype CreepPrototype Creep

instance Eq Creep where eq a b = runFn2 creepEq a b
instance Inherits Creep GameObject where
  upcast = defaultUpcast
  downcast = defaultDowncast creepPrototype
foreign import creepEq :: Fn2 Creep Creep Boolean

data Structure
data StructurePrototype
foreign import structurePrototype :: StructurePrototype
instance Prototype StructurePrototype Structure

instance Inherits Structure GameObject where
  upcast = defaultUpcast
  downcast = defaultDowncast structurePrototype

data StructureContainer
data StructureContainerPrototype
foreign import structureContainerPrototype :: StructureContainerPrototype
instance Prototype StructureContainerPrototype StructureContainer

instance Inherits StructureContainer Structure where
  upcast = defaultUpcast
  downcast = defaultDowncast structureContainerPrototype

data StructureTower
data StructureTowerPrototype
foreign import structureTowerPrototype :: StructureTowerPrototype
instance Prototype StructureTowerPrototype StructureTower

instance Inherits StructureTower GameObject where
  upcast = defaultUpcast
  downcast = defaultDowncast structureTowerPrototype

instance Inherits StructureTower Structure where
  upcast = defaultUpcast
  downcast = defaultDowncast structureTowerPrototype

data Flag
data FlagPrototype
foreign import flagPrototype :: FlagPrototype
instance Prototype FlagPrototype Flag

instance Inherits Flag GameObject where
  upcast = defaultUpcast
  downcast = defaultDowncast flagPrototype

data Store
data StorePrototype
foreign import storePrototype :: StorePrototype
instance Prototype StorePrototype Store

data Spawn
data SpawnPrototype
foreign import spawnPrototype :: SpawnPrototype
instance Prototype SpawnPrototype Spawn

instance Inherits Spawn GameObject where
  upcast = defaultUpcast
  downcast = defaultDowncast spawnPrototype
