module Main where

import Blaze.ByteString.Builder
import Control.Monad.Trans.Class (lift)
import Control.Monad.Trans.Reader
import Data.Map.Syntax
import Data.Text (Text)
import Heist
import qualified Heist.Compiled as C
import Lens.Micro.Platform

data ViewData = ViewData {viewDataGreeting :: Text}

bodyGreetingSplice :: C.Splice (ReaderT ViewData IO)
bodyGreetingSplice = do
  return $ C.yieldRuntimeText $ do
    greeting <- lift $ asks viewDataGreeting
    return $ "Hello " <> greeting <> "!"

mainSplices :: Splices (C.Splice (ReaderT ViewData IO))
mainSplices = do
  "body-greeting" ## bodyGreetingSplice

main :: IO ()
main = do
  let spliceConfig =
        mempty
          & scLoadTimeSplices .~ defaultLoadTimeSplices
          & scTemplateLocations .~ [loadTemplates "app"]

  -- 1. Load and precompile all templates
  eitherHeistState <-
    initHeist $
      emptyHeistConfig
        & hcNamespace .~ ""
        & hcErrorNotBound .~ False
        & hcSpliceConfig .~ spliceConfig
        & hcCompiledSplices .~ mainSplices

  -- 2. Make a fake database call outside of any splice/template/Heist functions
  let dbData = ViewData "World"

  case eitherHeistState of
    Left err ->
      putStrLn $ "Heist init failed: " ++ show err
    Right heistState -> do
      -- 3. Apply the precompiled templates to data
      case C.renderTemplate heistState "body" of
        Nothing -> do
          putStrLn "Index not found!"
        Just (docRuntime, _) -> do
          docBuilder <- runReaderT docRuntime dbData
          print $ toByteString docBuilder
