HARE_VERSION=HaRe 15/08/2012
HAPPY=happy
LEX_PARSE_DIR= tools/base/parse2
PARSER_DIR= ${LEX_PARSE_DIR}/Parser
LEXER_DIR= ${LEX_PARSE_DIR}/Lexer
LEXERGEN_DIR= ${LEX_PARSE_DIR}/LexerGen
LEXERSPEC_DIR= ${LEX_PARSE_DIR}/LexerSpec
LEXERGEN_IMPORTS= ../${LEXERGEN_DIR}:../${LEXERSPEC_DIR}:../tools/base/tests/HbcLibraries
LOCAL_IMPORTS=../editors/
SYSTEM= `uname`

REFACTORER_FILES=refactorer/PfeRefactoringCmds.hs refactorer/pfe refactorer/pfe_client

all: prepare editors-all ${REFACTORER_FILES}

quick: editors-all ${REFACTORER_FILES}

clean:	files-clean editors-clean refactorer-clean exe-clean

files-clean:
	rm -f ghc_path
	rm -f mergecache

exe-clean:
	rm -f refactorer/pfe
	rm -f refactorer/pfe.exe
	rm -f refactorer/pfe_client
	rm -f refactorer/pfe_client.exe

refactorer-clean:
	rm -rf refactorer/odir
	rm -rf refactorer/hidir
	rm -f refactorer/log.txt

editors-clean:
	cd editors; make clean

prepare: ${PARSER_DIR}/HsParser.hs refactorer/hidir/${SYSTEM} refactorer/odir/${SYSTEM} ${LEXERGEN_DIR}/HsLexerGen ${LEXER_DIR}/HsLex.hs

editors-all:
	cd editors; make all HARE_VERSION="${HARE_VERSION}"

# This will be done autoamtically via cabal
${PARSER_DIR}/HsParser.hs: ${PARSER_DIR}/HsParser.y
	cd ${PARSER_DIR}; ${HAPPY} HsParser.y

# This will be managed by cabal
refactorer/hidir/${SYSTEM}:
	mkdir -p refactorer/hidir/${SYSTEM}

# This will be managed by cabal
refactorer/odir/${SYSTEM}:
	mkdir -p refactorer/odir/${SYSTEM}

# tools/base/parse2/LexerGen
${LEXERGEN_DIR}/HsLexerGen:
	cd refactorer; ./myghc--make -i${LEXERGEN_IMPORTS} -i${LOCAL_IMPORTS} -o ../${LEXERGEN_DIR}/HsLexerGen ../${LEXERGEN_DIR}/HsLexerGen.hs


${LEXER_DIR}/HsLex.hs:
	cd ${LEXER_DIR}; ../LexerGen/HsLexerGen >HsLex.hs

refactorer/PfeRefactoringCmds.hs: editors/GenEditorInterfaces
	editors/GenEditorInterfaces pfeRefactoringCmds > refactorer/PfeRefactoringCmds.hs

refactorer/pfe: editors/GenEditorInterfaces
	cd refactorer; rm -f hidir/${SYSTEM}/Main.hi; ./myghc--make -i${LOCAL_IMPORTS} -o pfe pfe.hs 2>&1 | tee log.txt

refactorer/pfe_client:
	cd refactorer; rm -f hidir/${SYSTEM}/Main.hi; ./myghc--make -i${LOCAL_IMPORTS} -o pfe_client pfe_client.hs 2>&1 | tee -a log.txt
