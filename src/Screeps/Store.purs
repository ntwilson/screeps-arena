module Screeps.Store where

import Screeps.GameObjects (Store)

foreign import resourceEnergy :: Store -> Int

foreign import getFreeEnergyCapacity :: Store -> Int