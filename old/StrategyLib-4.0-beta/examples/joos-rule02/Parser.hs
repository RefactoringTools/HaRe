{-----------------------------------------------------------------------------

This parser for JOOS is based on:

    David A. Watt. JOOS action semantics. Version 1, available from
    http://www.dcs.gla.ac.uk/~daw/publications/JOOS.ps, October 1997. 

Several small adaptations were made to parse more Java fragments:

  - Identifiers may now contain underscores.
  - method invocations of the form m(args) are now accepted, and 
    interpreted as this.m(args).

-----------------------------------------------------------------------------}

module Parser where

import ParseLib
import Datatypes


parseAssignment
  = do i <- parseIdentifier 
       parseSymbol ":="
       e <- parseExpression
       return (Assignment i e) 


parseInstanceCreation
  = do parseSymbol "new"
       i    <- parseIdentifier
       args <- bracket (parseSymbol "(") parseArguments (parseSymbol ")")
       return (InstanceCreation i args)


parseMethodInvocation
  = do e <- parseExpression
       case e of
         (MethodInvocationExpr mi) -> return mi
         _                         -> mzero


parseSuperMethodInvocation
  = do parseSymbol "super"
       parseSymbol "."
       i <- parseIdentifier
       args <- bracket (parseSymbol "(") parseArguments (parseSymbol ")")
       return (SuperInvocation i args)


parseMethodInvocationRemainder e
  = do parseSymbol "."
       i <- parseIdentifier
       parseSymbol "("
       args <- parseArguments
       parseSymbol ")"
       return (ExpressionInvocation e i args)
    +++
    case e of
      (Identifier i) -> do parseSymbol "("
                           args <- parseArguments
                           parseSymbol ")"
                           return (ExpressionInvocation This i args)
      _              -> mzero


parseArguments
  = fmap Arguments (sepby parseExpression (parseSymbol ","))


parseExpression 
  = do e <- parseExpression1
       parseExpressionRemainder e


parseExpressionRemainder e
  = do e' <- (fmap MethodInvocationExpr (parseMethodInvocationRemainder e))
             +++
             do op <- parseInfixOperator
                e2 <- parseExpression
                return (InfixExpr e op e2)
             +++
             do parseSymbol "instanceof"
                i <- parseIdentifier
                return (InstanceOf e i)
             +++
             do ao <- parseAndOr
                e2 <- parseExpression
                return (AndOrExpr e ao e2)
       parseExpressionRemainder e'
    +++
    return e

      
parseExpression1
  = fmap Literal parseLiteral
    +++
    fmap Identifier parseIdentifier
    +++
    do { parseSymbol "this"; return This }
    +++
    do op <- parsePrefixOperator
       e  <- parseExpression
       return (PrefixExpr op e)
    +++
    do t <- bracket (parseSymbol "(") parseType (parseSymbol ")")
       e <- parseExpression
       return (TypeCast t e)
    +++
    do (bracket (parseSymbol "(") parseExpression (parseSymbol ")"))
    +++
    fmap AssignmentExpr parseAssignment
    +++
    fmap InstanceCreationExpr parseInstanceCreation
    +++
    fmap MethodInvocationExpr parseSuperMethodInvocation


parsePrefixOperator
  = do { parseSymbol "-"; return Neg }
    +++
    do { parseSymbol "!"; return Fac }


parseInfixOperator
  = symbols [("==",Eq),("!=",NEQ),("<",Lt),(">",Gt),("<=",LEQ),(">=",GEQ),
             ("+",PLUS),("-",MINUS),("*",MUL),("/",DIV),("%",MOD)]


parseAndOr
  = do { parseSymbol "||"; return OR }
    +++ 
    do { parseSymbol "&&"; return AND }


parseLiteral
  = fmap BooleanLit parseBooleanLiteral
    +++
    fmap IntegerLit parseIntegerLiteral
    +++
    do { parseSymbol "null"; return Null }
    +++
    fmap StringLit parseStringLiteral


parseBooleanLiteral
  = do { parseSymbol "true"; return TRUE }
    +++
    do { parseSymbol "false"; return FALSE }


parseIntegerLiteral
  = fmap toInteger natural


parseStringLiteral
  = token (bracket (char '"') (many (sat (/='"') )) (char '"'))


parseIdentifier
  = parse joosIdent


parseBlock
  = do vds <- many parseVarDeclaration
       ss  <- many parseStatement
       return (Block vds ss)


parseStatement
  = parseStatementNoBlock
    +++
    fmap BlockStat ( bracket (parseSymbol "{") 
                              parseBlock
                             (parseSymbol "}") )


parseStatementNoBlock
  = symbols [(";",Skip)]
    +++
    do a <- parseAssignment
       parseSymbol ";"
       return (AssignmentStat a)
    +++
    do i <- parseInstanceCreation
       parseSymbol ";"
       return (InstanceCreationStat i)
    +++
    do m <- parseMethodInvocation
       parseSymbol ";"
       return (MethodInvocationStat m)
    +++
    do parseSymbol "return"
       e <- optional parseExpression
       parseSymbol ";"
       return (ReturnStat e)
    +++
    do parseSymbol "if"
       c <- bracket (parseSymbol "(") parseExpression (parseSymbol ")")
       parseSymbol "then"
       t <- parseStatement
       parseSymbol "else"
       e <- parseStatement
       return (IfStat c t e)
    +++
    do parseSymbol "while" 
       c <- bracket (parseSymbol "(") parseExpression (parseSymbol ")")
       s <- parseStatement
       return (WhileStat c s)
    +++
    fmap StatementFocus ( bracket (parseSymbol "<")
                                  parseStatement
                                  (parseSymbol ">") )


parseClassDeclaration
  = do parseSymbol "public"
       f <- do { parseSymbol "final"; return True } +++ return False
       parseSymbol "class"
       cn <- parseIdentifier
       parseSymbol "extends"
       scn <- parseIdentifier
       parseSymbol "{"
       fds <- many parseFieldDeclaration
       cd  <- parseConstructorDeclaration
       mds <- parseMethodDecls
       parseSymbol "}"
       return (ClassDecl f cn scn fds cd mds)


parseProgram
  = do cds <- many parseClassDeclaration
       bs  <- parseBlock
       return (Program cds bs)


parseFieldDeclaration
  = do parseSymbol "private"
       t <- parseType 
       i <- parseIdentifier
       return (FieldDecl t i)


parseConstructorDeclaration
  = do parseSymbol "public"
       mn <- parseIdentifier
       parseSymbol "("
       pars <- parseFormals
       parseSymbol ")"
       parseSymbol "{"
       parseSymbol "super"
       args <- bracket (parseSymbol "(") parseArguments (parseSymbol ")")
       body <- parseBlock
       parseSymbol "}"
       return (ConstructorDecl mn pars args body)


parseMethodDecls
  = 
    do {
         mds <- ( bracket (parseSymbol "<<")
                          (many1 parseMethodDecl)
                          (parseSymbol ">>") );
         return [MethodDeclFocus mds]
       }
    +++
    ( many ( parseMethodDecl
             +++
             parseFocusedMethodDecl
           )
    )


parseFocusedMethodDecl
  = do { parseSymbol "<";
         md <- parseMethodDecl;
         parseSymbol ">";
         return (MethodDeclFocus [md])
       }


parseMethodDecl
  = do parseSymbol "public"
       t <- ( do { parseSymbol "void"; return Nothing }
              +++
              fmap Just parseType )
       mn <- parseIdentifier
       parseSymbol "("
       pars <- parseFormals
       parseSymbol ")"
       parseSymbol "{"
       body <- parseBlock
       parseSymbol "}"
       return (MethodDecl t mn pars body)


parseFormals
  = fmap Formals (sepby parseFormal (parseSymbol ","))


parseFormal
  = do t <- parseType
       i <- parseIdentifier
       return (Formal t i)


parseVarDeclaration
  = do t <- parseType
       i <- parseIdentifier
       parseSymbol ";"
       return (VarDecl t i)


parseType
  = do { parseSymbol "int"; return INT }
    +++
    do { parseSymbol "boolean"; return BOOLEAN }
    +++
    fmap Type parseIdentifier



--- Auxiliary ---------------------------------------------------------------

parseSymbol = parse . symbol

joosIdent :: Parser String
joosIdent = token (do{ i <- joos_ident; if not (elem i ks) then return i
                                                           else mzero })
            where ks = ["new","super","this","instanceof","null",
                        "true","false","return","if","else","while",
                        "public","final","extends","private","int","boolean"]

joos_ident = do {x <- sat isJOOSalpha; xs <- many joos_alphanum; return (x:xs)}
             where joos_alphanum = sat isJOOSalphanum
                   isJOOSalphanum c = isAlphaNum' c || (c=='_')
                   isJOOSalpha c    = isAlpha' c    || (c=='_')

symbols :: [(String,a)] -> Parser a
symbols ss
  = foldr (\(sym,a) p -> do {parseSymbol sym; return a} +++ p ) mzero ss

optional p = fmap Just p +++ return Nothing

-- These are not present in all preludes.
-- Therefore, we repeat them with primed names.
isUpper' c              =  c >= 'A'   &&  c <= 'Z'
isLower' c              =  c >= 'a'   &&  c <= 'z'
isAlpha' c              =  isUpper' c  ||  isLower' c
isDigit' c              =  c >= '0'   &&  c <= '9'
isAlphaNum' c           =  isAlpha' c  ||  isDigit' c

-----------------------------------------------------------------------------
