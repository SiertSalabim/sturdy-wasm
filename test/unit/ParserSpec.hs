module ParserSpec (spec) where

import Test.QuickCheck
import Test.Hspec
import Tokens
import Parser
import Lexer

-- Test suites --

spec :: Spec
spec = do 
    tsOfType
    tsToWasmI
    tsToWasmF
    tsParse
    
-- Linking tests to Test Suites --

tsOfType :: Spec
tsOfType = describe "ofType" $ do
    testOfTypeI32
    testOfTypeI64
    testOfTypeF32
    testOfTypeF64
    testOfTypeI64NotI32
    testOfTypeF32NotI32
    
tsToWasmI :: Spec
tsToWasmI = describe "toWasmI" $ do
    testToWasmI32
    testToWasmI64
    testToWasmIF32
    testToWasmIF64

tsToWasmF :: Spec
tsToWasmF = describe "toWasmF" $ do
    testToWasmFI32
    testToWasmFI64
    testToWasmF32
    testToWasmF64

tsParse :: Spec
tsParse = describe "parse" $ do
    testParse

-- Tests --

--- ofType ---
testOfTypeI32 = it "A I32Val's type is I32" $
    property $ \x -> ofType (I32Val (x::Integer)) I32 `shouldBe` True

testOfTypeI64 = it "A I64Val's type is I64" $
    property $ \x -> ofType (I64Val (x::Integer)) I64 `shouldBe` True

testOfTypeF32 = it "A F32Val's type is F32" $
    property $ \x -> ofType (F32Val (x::Double)) F32 `shouldBe` True

testOfTypeF64 = it "A F64Val's type is F64" $
    property $ \x -> ofType (F64Val (x::Double)) F64 `shouldBe` True

testOfTypeI64NotI32 = it "A I64Val's type is not I32" $
    property $ \x -> ofType (I64Val (x::Integer)) I32 `shouldBe` False

testOfTypeF32NotI32 = it "A F32Val's type is not I32" $
    property $ \x -> ofType (F32Val (x::Double)) I32 `shouldBe` False

--- toWasmI ---
testToWasmI32 = it "Creating an I32Val" $
    property $ \x -> toWasmI I32 (x::Integer) `shouldBe` I32Val x

testToWasmI64 = it "Creating an I64Val" $
    property $ \x -> toWasmI I64 (x::Integer) `shouldBe` I64Val x

testToWasmIF32 = it "Creating an F32Val" $
    property $ \x -> toWasmI F32 (x::Integer) `shouldBe` F32Val (fromIntegral x)

testToWasmIF64 = it "Creating an F64Val" $
    property $ \x -> toWasmI F64 (x::Integer) `shouldBe` F64Val (fromIntegral x)

--- toWasmF --- 

testToWasmFI32 = it "Creating an I32Val" $
    property $ \x -> toWasmF I32 (x::Double) `shouldBe` I32Val (round x)

testToWasmFI64 = it "Creating an I64Val" $
    property $ \x -> toWasmF I64 (x::Double) `shouldBe` I64Val (round x)

testToWasmF32 = it "Creating an F32Val" $
    property $ \x -> toWasmF F32 (x::Double) `shouldBe` F32Val x

testToWasmF64 = it "Creating an F64Val" $
    property $ \x -> toWasmF F64 (x::Double) `shouldBe` F64Val x


--- parse ---

testParse = it "Should be able to parse a simple add function" $
    parse Parser.function [LP,Keyword "func",ID "add",LP,Keyword "param",ID "lhs",Keyword "i32",RP,LP,Keyword "param",ID "rhs",Keyword "i32",RP,LP,Keyword "result",Keyword "i32",RP,Keyword "get_local",ID "lhs",Keyword "get_local",ID "rhs",Keyword "i32.add",RP] `shouldBe`
    [(Func "add" [Param "lhs" I32,Param "rhs" I32] (Block [Result I32] [LocalGet "lhs",LocalGet "rhs",Numeric (Add I32)]),[])]
