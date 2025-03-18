module Main where

import Prelude

import Data.Array as Array
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Console (log)
import Unsafe.Coerce (unsafeCoerce)

class MoveTarget :: Type -> Constraint
class MoveTarget a

data Creep
data Flag

instance MoveTarget Creep
instance MoveTarget Flag

foreign import getCreeps :: Effect (Array Creep)
foreign import getFlags :: Effect (Array Flag)

moveTo :: ∀ t. MoveTarget t => Creep -> t -> Effect Unit
moveTo creep target = 
  (unsafeCoerce creep).moveTo(target)

main :: Effect Unit
main = do
  creeps <- getCreeps
  flags <- getFlags
  case Array.head creeps, Array.head flags of
    Just creep, Just flag -> creep `moveTo` flag
    _, _ -> log "No creeps or flags found" 

