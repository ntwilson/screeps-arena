module Tutorial.Terrain where

import Prelude

import Data.Array as Array
import Data.Foldable (for_)
import Data.Maybe (maybe)
import Effect (Effect)
import Screeps.Creep (moveTo, my)
import Screeps.Functions (findClosestByPath, getObjectsByPrototype)
import Screeps.GameObjects (creepPrototype, flagPrototype)

main :: Effect Unit
main = do
  myCreeps <- getObjectsByPrototype creepPrototype <#> Array.filter my
  flags <- getObjectsByPrototype flagPrototype
  for_ myCreeps \creep -> do
    let flag = creep `findClosestByPath` flags
    flag # maybe (pure unit) (creep `moveTo` _)
