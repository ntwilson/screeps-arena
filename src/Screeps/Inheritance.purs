module Screeps.Inheritance where

import Prelude

import Data.Maybe (Maybe)

class DirectlyInherits child parent | child -> parent where
  directUpcast :: child -> parent
  directDowncast :: parent -> Maybe child

class Inherits child parent where
  upcast :: child -> parent
  downcast :: parent -> Maybe child

instance DirectlyInherits child parent => Inherits child parent where
  upcast = directUpcast
  downcast = directDowncast

else instance (DirectlyInherits child parent, DirectlyInherits parent grandparent) => Inherits child grandparent where
  upcast = directUpcast >>> directUpcast 
  downcast = directDowncast >=> directDowncast

else instance (DirectlyInherits child parent, DirectlyInherits parent grandparent, DirectlyInherits grandparent greatgrandparent) => Inherits child greatgrandparent where
  upcast = directUpcast >>> directUpcast >>> directUpcast
  downcast = directDowncast >=> directDowncast >=> directDowncast
