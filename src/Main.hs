module Main where

import Data.Traversable (sequence)
import Control.Monad (liftM)
import Data.Either (rights)
import Data.Map.Ordered (OMap, (|>), assocs, empty)

import qualified Data.HashMap.Strict as M

main :: IO ()
main = putStrLn "Hello, Haskell!"

type NodeName = [Char]

data Node =
    Node NodeName [NodeName]
  deriving (Eq, Show)

nodeList =
  [ Node "a" [ "b", "d" ]
  , Node "b" [ "c", "e" ]
  , Node "c" [ "d", "e" ]
  , Node "d" []
  , Node "e" []
  ]

toMap :: [Node] -> M.HashMap NodeName Node
toMap nodeList = 
  M.fromList (fmap (\(Node n ns) -> (n, Node n ns)) nodeList)

findDep :: M.HashMap NodeName Node -> Node -> OMap NodeName NodeName
findDep nodes (Node nodeName es) =
  let
    lookup :: NodeName -> Either String Node
    lookup name = 
      case M.lookup name nodes of
        Just n -> Right n
        Nothing -> Left ("Unknown dependency: " ++ name ++ ", of " ++ nodeName)
    
    getNodes :: [NodeName] -> [Either String Node]
    getNodes ns = fmap (\n -> lookup n) ns

    --probably should return `Either [String] [Node]` but seqence cant handle that
    --ignore any errors for now
    
    aggregateDeps :: [NodeName] -> [OMap NodeName NodeName]
    aggregateDeps ns = fmap (\n -> findDep nodes n) (rights (getNodes ns))

  in
    addToOrderedMap nodeName (mergeOMap (aggregateDeps es))

findDeps :: 
  M.HashMap NodeName Node -> 
  [Node] -> 
  OMap NodeName NodeName
findDeps m (n:ns) =
  appendOMap (findDep m n) (findDeps m ns)
findDeps m [] =
  empty

mergeOMap :: [OMap NodeName NodeName] -> OMap NodeName NodeName
mergeOMap l =
  foldl appendOMap empty l

appendOMap ::
  OMap NodeName NodeName ->
  OMap NodeName NodeName ->
  OMap NodeName NodeName
appendOMap i j =
  foldl (\b a -> b |> a) i (assocs j)

addToOrderedMap :: 
  NodeName ->
  OMap NodeName NodeName ->
  OMap NodeName NodeName
addToOrderedMap n m =
  m |> (,) n n

lift (x:xs) = x ++ (lift xs)
lift [] = []

run =
  findDeps (toMap nodeList) nodeList

-- blog post used to get started
-- https://www.electricmonk.nl/log/2008/08/07/dependency-resolving-algorithm/

--query for table deps
-- https://stackoverflow.com/questions/22005698/how-to-find-all-the-dependencies-of-a-table-in-sql-server

--Cross database dependancies
-- https://stackoverflow.com/questions/13757387/getting-sql-server-cross-database-dependencies
