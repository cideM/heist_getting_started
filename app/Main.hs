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
      -- I need to replace <apply-content /> in index.tpl with the body-greeting splice, but I don't know how.
      -- I do not want to add the splice to "mainSplices" since in a server environment I would like to
      -- precompile the base splices once and then "add overlays" in each route handler

      -- This has <body-greeting /> inside of it, which we've already compiled and handled through "mainSplices"
      let (bodyTpl :: C.Splice IO) = C.callTemplate "body"
      -- ^-- stick this into the index.tpl template somehow, replacing the <apply-content /> tag

      case C.renderTemplate heistState "index" of
        Nothing -> do
          putStrLn "Index not found!"
        Just (docRuntime, _) -> do
          docBuilder <- runReaderT docRuntime dbData
          print $ toByteString docBuilder
