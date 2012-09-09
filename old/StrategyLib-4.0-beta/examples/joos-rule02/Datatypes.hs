{----------------------------------------------------------------------------

Abstract syntax of JOOS, based on:

    David A. Watt. JOOS action semantics. Version 1, available from
    http://www.dcs.gla.ac.uk/~daw/publications/JOOS.ps, October 1997. 

----------------------------------------------------------------------------}

module Datatypes where



data Program		= Program [Class] Block
                          deriving (Show,Eq)

data Assignment		= Assignment Identifier Expression
                          deriving (Show,Eq)
data InstanceCreation	= InstanceCreation Identifier Arguments
                          deriving (Show,Eq)
data MethodInvocation	= ExpressionInvocation Expression Identifier Arguments
			| SuperInvocation Identifier Arguments
                          deriving (Show,Eq)
data Arguments		= Arguments [Expression]
                          deriving (Show,Eq)
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
                          deriving (Show,Eq)
data AndOr		= AND | OR
                          deriving (Show,Eq)

data PrefixOperator	= Neg | Fac
                          deriving (Show,Eq)
data InfixOperator	= Eq | NEQ | Lt | Gt | LEQ | GEQ
			| PLUS | MINUS | MUL | DIV | MOD
                          deriving (Show,Eq)
data Literal		= BooleanLit BooleanLiteral
			| IntegerLit IntegerLiteral
			| Null
			| StringLit StringLiteral
                          deriving (Show,Eq)
data BooleanLiteral	= TRUE | FALSE
                          deriving (Show,Eq)
type IntegerLiteral	= Integer
type StringLiteral	= String
type Identifier		= String

data Block	= Block [VarDecl] [Statement]
                          deriving (Show,Eq)
data Statement		= Skip
			| BlockStat Block
			| AssignmentStat Assignment
			| InstanceCreationStat InstanceCreation
			| MethodInvocationStat MethodInvocation
			| ReturnStat (Maybe Expression)
			| IfStat Expression Statement Statement
			| WhileStat Expression Statement
                       --- Additions
                        | StatementFocus Statement
                          deriving (Show,Eq)

data Class	= ClassDecl FinalOpt Identifier Identifier
                            [FieldDeclaration]
                            Constructor
			    [MethodDecl]
                          deriving (Show,Eq)
type FinalOpt		= Bool
data FieldDeclaration	= FieldDecl Type Identifier
                          deriving (Show,Eq)
data Constructor
			= ConstructorDecl Identifier Formals
                            Arguments Block
                          deriving (Show,Eq)
data MethodDecl	= MethodDecl (Maybe Type) Identifier Formals Block
                       --- Additions
                        | MethodDeclFocus [MethodDecl]
                          deriving (Show,Eq)
data Formals	= Formals [Formal]
                          deriving (Show,Eq)
data Formal	= Formal Type Identifier
                          deriving (Show,Eq)
data VarDecl	= VarDecl Type Identifier
                  deriving (Show,Eq)
data Type	= INT | BOOLEAN | Type Identifier
                  deriving (Show,Eq)
