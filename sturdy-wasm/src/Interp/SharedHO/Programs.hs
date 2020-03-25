module Interp.SharedHO.Programs
where

import Interp.SharedHO.ToyInterpreter

addition :: Expr
addition = Add (Const 2) (Const 5)

variables :: Expr
variables = Seq [Assign "x" (Const 0),
                 Assign "y" (Const 1),
                 Assign "x" $ Add (Var "x") (Const 2),
                 Assign "y" $ Add (Var "x") (Var "y"),
                 Var "y"]

ifStatement :: Expr
ifStatement = Seq [Assign "x" (Const 0),
                   Assign "y" (Const 1),
                   If (Lt (Const 1) (Var "x"))
                       (Assign "y" (Const 2))
                       (Assign "y" (Const 3)),
                   Var "y"]

finiteLoop :: Expr
finiteLoop = Seq [Assign "x" (Const 0),
                  Loop $ If (Lt (Var "x") (Const 5))
                            (Seq [Assign "x" $ Add (Const 1) (Var "x"),
                                  Branch 0])
                            (Var "x")]

infiniteLoop :: Expr
infiniteLoop = Seq [Assign "x" (Const 0),
                    Loop $ Seq [Assign "x" $ Add (Const 1) (Var "x"),
                                Branch 0],
                    Var "x"]

undecidableIf :: Expr
undecidableIf = Seq [Assign "x" (Const 1),
                     If (Loop $ Branch 0)
                         (Assign "x" (Const 2))
                         (Assign "x" (Const 3)),
                     Var "x"]