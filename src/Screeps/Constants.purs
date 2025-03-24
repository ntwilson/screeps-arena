module Screeps.Constants where

import Prelude

import Data.Function.Uncurried (Fn2, runFn2)
import Unsafe.Coerce (unsafeCoerce)

data Code
instance Eq Code where
  eq a b = runFn2 eqCode a b
instance Show Code where
  show code = show @Int (unsafeCoerce code)


foreign import eqCode :: Fn2 Code Code Boolean

foreign import ok :: Code
foreign import errNotOwner :: Code
foreign import errInvalidTarget :: Code
foreign import errNotInRange :: Code
foreign import errNoBodypart :: Code

data BodyPartType
instance Eq BodyPartType where
  eq a b = runFn2 eqBodyPartType a b

foreign import eqBodyPartType :: Fn2 BodyPartType BodyPartType Boolean

foreign import movePart :: BodyPartType
foreign import workPart :: BodyPartType
foreign import carryPart :: BodyPartType
foreign import attackPart :: BodyPartType
foreign import rangedAttackPart :: BodyPartType
foreign import toughPart :: BodyPartType
foreign import healPart :: BodyPartType
