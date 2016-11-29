{-# LANGUAGE PartialTypeSignatures #-}

module Renaming.WildCard where

-- | This will be read from a configuration, eventually
taggedPlugins2 :: Plugin _
taggedPlugins2 = undefined

data Plugin  a = Plugin a

