module Completion (complete)
       where

import Data.Trie           (Trie)
import Control.Monad.State (get)
import System.Console.Haskeline.Completion

import qualified Data.ByteString.Char8 as BS
import qualified Data.Trie             as Trie

import Monad (ReplM)

import qualified Environment as Env

complete :: CompletionFunc ReplM
complete = completeWord Nothing " \t" lookupCompletions

lookupCompletions :: String -> ReplM [Completion]
lookupCompletions s = do
  env <- get
  return $ completions s . removeReserveds . Env.defs $ env
    where removeReserveds = Trie.delete Env.firstVar . Trie.delete Env.lastVar

completions :: String -> Trie a  -> [Completion]
completions s = Trie.lookupBy go (BS.pack s)
  where go :: Maybe a -> Trie a -> [Completion]
        go isElem suffixesTrie = maybeCurrent ++ suffixCompletions
          where maybeCurrent = case isElem of
                  Nothing -> []
                  Just _  -> [current]
                current = Completion s s True

                suffixCompletions = map (suffixCompletion . BS.unpack) . Trie.keys $ suffixesTrie
                suffixCompletion suf = Completion full full False
                  where full = s ++ suf
