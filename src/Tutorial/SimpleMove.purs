module Tutorial.SimpleMove where

import Prelude

import Data.Array as Array
import Data.Maybe (maybe)
import Effect (Effect)
import Effect.Exception (throw)
import Screeps.Creep (moveTo)
import Screeps.Functions (getObjectsByPrototype)
import Screeps.GameObjects (creepPrototype, flagPrototype)

main :: Effect Unit
main = do
    creeps <- getObjectsByPrototype(creepPrototype)
    creep <- Array.head creeps # maybe (throw "No creeps found") pure

    flags <- getObjectsByPrototype(flagPrototype)
    flag <- Array.head flags # maybe (throw "No flags found") pure
    creep `moveTo` flag