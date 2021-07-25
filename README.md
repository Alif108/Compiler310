# Compiler310

These repository contains the assigments I have done on the Compiler course of BUET CSE Level 3-Term 1. The course attempts to build a (partial) compiler for the C language.

## SymbolTable
SymbolTable contains the token informations. SymbolTable is basically a hashtable of hashtables.

## Lexical Analyzer
A scanner is built for recognizing tokens. This analyzer uses a tool named "Flex". The previously built SymbolTable is used here. Compiling the lex file with the target txt file will generate a "token.txt" file and a "log.txt" file. Script to compile the lex file is attached. 

## Syntax and Semantic Analyzer
A parser is built to perform syntax and semantic analysis. This analyzer uses a tool named "Yacc/Bison". The previously built SymbolTable and Lexical Analayzer is used here. Compiling the bison file with the target txt file will generate a "log.txt" and an "error.txt" file. Script to compile the yacc file is attached.

## Code Generation
Finally, an assembly code is generated from the target C file. The generated assembly code follows 8086 microprocessor convention. Compiling the bison file with the target txt file will generate a "code.asm", "optimized_code.asm", "log.txt" and an "error.txt" file. Script to compile the yacc file is attached. The asm files can be run on any 8086 simulator (e.g. emu8086).
