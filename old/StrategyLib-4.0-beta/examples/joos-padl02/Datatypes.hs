{----------------------------------------------------------------------------

Abstract syntax of JOOS, based on:

    David A. Watt. JOOS action semantics. Version 1, available from
    http://www.dcs.gla.ac.uk/~daw/publications/JOOS.ps, October 1997. 

Modifications:

  o StatFocus
  o StringLiterals

----------------------------------------------------------------------------}

module Datatypes where

import TermRep
import Monad

data Assignment		= Assignment Identifier Expression
                          deriving (Eq, Show)
data InstanceCreation	= InstanceCreation Identifier Arguments
                          deriving (Eq, Show)
data MethodInvocation	= ExpressionInvocation Expression Identifier Arguments
			| SuperInvocation Identifier Arguments
                          deriving (Eq, Show)
data Arguments		= Arguments [Expression]
                          deriving (Eq, Show)
data Expression		= Literal Literal
			| Identifier Identifier
			| This
			| PrefixExpr PrefixOperator Expression
			| InfixExpr Expression InfixOperator Expression
			| AndOrExpr Expression AndOr Expression
			| InstanceOf Expression Identifier
			| TypeCast Type Expression
			| BracketExpr Expression
			| AssignmentExpr Assignment
			| InstanceCreationExpr InstanceCreation
			| MethodInvocationExpr MethodInvocation
                          deriving (Eq, Show)
data AndOr		= AND | OR
                          deriving (Eq, Show)
data PrefixOperator	= Neg | Fac
                          deriving (Eq, Show)
data InfixOperator	= Eq | NEQ | Lt | Gt | LEQ | GEQ
			| PLUS | MINUS | MUL | DIV | MOD
                          deriving (Eq, Show)
data Literal		= BooleanLit BooleanLiteral
			| IntegerLit IntegerLiteral
			| Null
			| StringLit StringLiteral
                          deriving (Eq, Show)
data BooleanLiteral	= TRUE | FALSE
                          deriving (Eq, Show)
type IntegerLiteral	= Integer
type StringLiteral	= String
type Identifier		= String

data BlockStatements	= BlockStatements [VariableDeclaration] [Statement]
                          deriving (Eq, Show)
data Statement		= Skip
			| Block BlockStatements
			| AssignmentStat Assignment
			| InstanceCreationStat InstanceCreation
			| MethodInvocationStat MethodInvocation
			| ReturnStat (Maybe Expression)
			| IfStat Expression Statement Statement
			| WhileStat Expression Statement
                       --- Additions
                        | StatFocus Statement
                          deriving (Eq, Show)

data ClassDeclaration	= ClassDecl FinalOpt Identifier Identifier
                            [FieldDeclaration]
                            ConstructorDeclaration
			    [MethodDeclaration]
                          deriving (Eq, Show)
type FinalOpt		= Bool
data FieldDeclaration	= FieldDecl Type Identifier
                          deriving (Eq, Show)
data ConstructorDeclaration
			= ConstructorDecl Identifier FormalParameters
                            Arguments BlockStatements
                          deriving (Eq, Show)
data MethodDeclaration	= MethodDecl (Maybe Type) Identifier FormalParameters
                            BlockStatements
                          deriving (Eq, Show)
data FormalParameters	= FormalParams [FormalParameter]
                          deriving (Eq, Show)
data FormalParameter	= FormalParam Type Identifier
                          deriving (Eq, Show)
data VariableDeclaration
			= VariableDecl Type Identifier
                          deriving (Eq, Show)
data Type		= INT | BOOLEAN | Type Identifier
                          deriving (Eq, Show)

