{-# LANGUAGE PartialTypeSignatures #-}

module Renaming.WildCard where

-- | This will be read from a configuration, eventually
taggedPlugins :: Plugin _
taggedPlugins = undefined

data Plugin  a = Plugin a

