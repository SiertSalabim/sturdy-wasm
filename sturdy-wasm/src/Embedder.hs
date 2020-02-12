module Embedder
  ( runWasm
) where

import qualified Data.Map as Map
import qualified Data.Text as T (strip, pack, unpack)
import Data.List
import System.IO
import System.Environment
import System.Exit

import Parsing.Parser
import Syntax
import Types
import Interp.Monadic.Executor

runWasm :: IO ()
runWasm = getArgs >>= parseArgs

parseArgs :: [String] -> IO ()
parseArgs ["-h"] = printUsage >> exit
parseArgs ["-i"] = runWasmRepl
parseArgs _ = printUsage >> exit

exit :: IO a
exit = exitWith ExitSuccess

printUsage :: IO ()
printUsage = putStrLn $ 
    "Usage:\n\
    \   -h : Print this message\n\
    \   -i : Run in interactive mode\n"

printReplUsage :: IO ()
printReplUsage = putStrLn $
    "Commands:\n\
    \   :q        : exits the repl\n\
    \   :l <PATH> : loads module in WAT file given by PATH\n\n\
    \To Execute a function when a module is loaded:\n\n\
    \program.wat\n\
    \(module\n\
    \   (func $increment (param $a i32) (result i32)\n\
    \       local.get $a\n\
    \       i32.const 1\n\
    \       i32.add\n\
    \   )\n\
    \)\n\n\
    \e.g.\n\
    \$> :l program.wat\n\
    \Module loaded: ...\n\
    \$> increment 1 \n\
    \Result: [I32Val 2]\n"

runWasmRepl :: IO ()
runWasmRepl = do
    printReplUsage    
    wasmRepl (WasmModule [])

wasmRepl :: WasmModule -> IO ()
wasmRepl module' = do
    putStr $ "$> "
    hFlush stdout
    input <- getLine
    argv <- return $ words input
    processRepl module' argv

processRepl :: WasmModule -> [String] -> IO ()
processRepl module' argv = case argv of
    ":q":_   -> goodbye
    ":l":xs  -> loadFile $ head xs
    vs ->       callFunc module' vs
    where goodbye = putStrLn "Goodbye!"

cleanInput :: String -> String
cleanInput str = intercalate " " (filter (/="") (map (T.unpack . T.strip . T.pack) (lines str)))

loadFile :: String -> IO ()
loadFile filename = do
    contents <- readFile filename
    module' <- return $ parseWasm wasmModule $ cleanInput contents
    putStrLn ("Module loaded: " ++ (show module'))
    wasmRepl module'

callFunc :: WasmModule -> [String] -> IO ()
callFunc module' (f:xs) = do
    res <- return $ execFunc ('$':f) (toWasmVals xs) module'
    case res of
        Right vs -> putStrLn ("Result: " ++ show vs)
        Left msg -> putStrLn ("Error: " ++ msg)
    wasmRepl module'

toWasmVals :: [String] -> [WasmVal]
toWasmVals xs = case xs of
    [] -> []
    h:t -> (I32Val (read h :: Integer)) : (toWasmVals t)
