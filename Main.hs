{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE OverloadedStrings #-}

module Main where
import Network.JMacroRPC.Snap
import Snap.Http.Server
import Snap.Core
import Language.Javascript.JMacro
import Control.Concurrent
import Control.Monad.Trans
import Network.JMacroRPC.Base
import qualified Data.Text as T
import Text.XHtml hiding(dir)
import Text.XHtml.Transitional

jsScript f = script (primHtml f) ! [thetype "text/javascript"]
jsScript' = jsScript . show . renderJs

testPage = mkConversationPageNoCulling pageFun (newMVar (1::Int)) jRpcs
    where pageFun :: JStat ->  Snap ()
          pageFun js = do
            modifyResponse $ setContentType "text/html"
            writeText $ T.pack $ show $ toHtml $
                       (header << [script ! [src "https://ajax.googleapis.com/ajax/libs/jquery/1.6.2/jquery.min.js"] << noHtml]) +++
                       jsScript' js +++
                       jsScript' ([jmacro|$(\
                                     {
                                           var b = $("<button>click me!</button>");
                                           $("body").append(b);
                                           b.click(\ {
                                               var c = getCounter();
                                               alert ("counter is: " + c);
                                           });
                                     });
                                  |]);
          jRpcs = [getCounterRPC]
          getCounterRPC =
              toJsonConvRPC "getCounter" $ \s -> (liftIO $ retRight =<< modifyMVar s (\i -> return (i+1,i)) :: Snap (Either String Int))

retRight :: a -> IO (Either String a)
retRight = return . Right

main = quickHttpServe =<< testPage
