module Main where

import Blaze.ByteString.Builder
import Control.Monad.Reader
import Data.Map.Syntax
import Data.Text (Text)
import qualified Data.Text as T
import Heist
import qualified Heist.Compiled as C
import Lens.Micro.Platform

class HasFoo a where
  foo :: a -> Int

class HasPerson a where
  person :: a -> Text

class HasCount a where
  count :: a -> Int

data ViewA = ViewA
  { viewAName :: Text,
    viewAFoo :: Int
  }

data ViewB = ViewB
  { viewBCount :: Int,
    viewBFoo :: Int
  }

instance HasFoo ViewA where
  foo = viewAFoo

instance HasFoo ViewB where
  foo = viewBFoo

instance HasPerson ViewA where
  person = viewAName

instance HasCount ViewB where
  count = viewBCount

personSplice :: (MonadIO m, MonadReader e m, HasPerson e) => C.Splice m
personSplice = return $ C.yieldRuntimeText $ do
  personName <- lift $ asks person
  return personName

fooSplice :: (MonadIO m, MonadReader e m, HasFoo e) => C.Splice m
fooSplice = do
  return $ C.yieldRuntimeText $ do
    fooValue <- lift $ asks foo
    return $ T.pack $ show fooValue

countSplice :: (MonadIO m, MonadReader e m, HasCount e) => C.Splice m
countSplice = do
  return $ C.yieldRuntimeText $ do
    countValue <- lift $ asks count
    return $ T.pack $ show countValue

mainSplices ::
  ( MonadIO m,
    MonadReader e m,
    HasPerson e,
    HasFoo e
    -- HasCount e
    -- Uncomment this line and add a comma in the line above to see the error
  ) =>
  Splices (C.Splice m)
mainSplices = do
  -- "count" ## countSplice
  -- Uncomment this line to see the error
  "person" ## personSplice
  "foo" ## fooSplice

main :: IO ()
main = do
  let spliceConfig =
        mempty
          & scLoadTimeSplices .~ defaultLoadTimeSplices
          & scTemplateLocations .~ [loadTemplates "app"]

  eitherHeistState <-
    initHeist $
      emptyHeistConfig
        & hcNamespace .~ ""
        & hcErrorNotBound .~ False
        & hcSpliceConfig .~ spliceConfig
        & hcCompiledSplices .~ mainSplices

  -- The fake database call
  let viewAData = ViewA "John" 10

  case eitherHeistState of
    Left err ->
      putStrLn $ "Heist init failed: " ++ show err
    Right heistState -> do
      case C.renderTemplate heistState "view_a" of
        Nothing -> do
          putStrLn "Index not found!"
        Just (docRuntime, _) -> do
          docBuilder <- runReaderT docRuntime viewAData
          print $ toByteString docBuilder
