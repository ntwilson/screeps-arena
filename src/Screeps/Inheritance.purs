module Screeps.Inheritance where

import Data.Maybe (Maybe)

class Inherits child parent where
  upcast :: child -> parent
  downcast :: parent -> Maybe child

-- instance (Inherits child parent, Inherits parent grandparent) => Inherits child grandparent where
--   upcast child = upcast (upcast child :: parent)
--   downcast grandparent = (downcast grandparent :: Maybe parent) >>= downcast

