%option noyywrap
%{
#include<bits/stdc++.h>
#include<iostream>
#include<fstream>
//#define YYSTYPE SymbolInfo*

#include "1705108_SymbolTable.h"
#include "y.tab.h"

using namespace std;

//SymbolTable st(7);

//extern YYSTYPE yylval;

extern int line_count;
extern int error_count;

void yyerror(char *);


%}

WHITESPACE [ \t\f\r\v]+ 
LETTER [a-zA-Z]
DIGIT [0-9]
NEWLINE \n
SYMBOL	[\.@#$%^*()_+{}|:><?,;=-\\\/]

%%

{NEWLINE} {line_count++;}

{WHITESPACE}*	{}

"if"		{	return IF;	}
"else"		{	return ELSE;	}
"for"		{	return FOR;	}
"while"		{	return WHILE;	}
"return"	{	return RETURN;	}
"println"	{	return PRINTLN;	}		
			
"+"		|
"-"		{	
			SymbolInfo* s = new SymbolInfo(yytext, "ADDOP");
			yylval.si = s;	
			return ADDOP;	
		}

"*"		|
"/"		|
"%"		{	SymbolInfo* s = new SymbolInfo(yytext, "MULOP");
			yylval.si = s;	
			return MULOP;	
		}

"++"		{	return INCOP;	}
"--"		{	return DECOP;	}

"<"		|
"<="		|
">"		|
">="		|
"=="		|
"!="		{	SymbolInfo* s = new SymbolInfo(yytext, "RELOP");
			yylval.si = s;	
			return RELOP;	
		}
		
"="		{	return ASSIGNOP;	}
		
"&&"		|
"||"		{
			SymbolInfo* s = new SymbolInfo(yytext, "LOGICOP");
			yylval.si = s;	
			return LOGICOP;	
		}
	
"!"		{
			return NOT;
		}
		
"("		{
			return LPAREN;
		}						

")"		{
			return RPAREN;
		}
		
"{"		{
			return LCURL;
		}
		
"}"		{
			return RCURL;
		}
		
"["		{
			return LTHIRD;
		}
		
"]"		{
			return RTHIRD;
		}
		
","		{
			return COMMA;
		}
		
";"		{
			return SEMICOLON;
		}
		
"int"		{
			SymbolInfo* s = new SymbolInfo(yytext, "INT");
			s->setTypeSpecifier("int");
			yylval.si = s;	
			return INT;	
		}
		
"float"		{
			SymbolInfo* s = new SymbolInfo(yytext, "FLOAT");
			s->setTypeSpecifier("float");
			yylval.si = s;	
			return FLOAT;	
		}
		
"void"		{	SymbolInfo* s = new SymbolInfo(yytext, "VOID");
			s->setTypeSpecifier("void");
			yylval.si = s;	
			return VOID;	
		}								
		
		
{DIGIT}+ 	{
				SymbolInfo* s = new SymbolInfo(yytext, "CONST_INT");
				s->setTypeSpecifier("int");
				yylval.si = s;
				return CONST_INT;
		}
		
{DIGIT}*\.{DIGIT}+([Ee][+-]?{DIGIT}+)? 	|
{DIGIT}+[Ee][+-]?{DIGIT}+		{
						SymbolInfo* s = new SymbolInfo(yytext, "CONST_FLOAT");
						s->setTypeSpecifier("float");
						yylval.si = s;
						return CONST_FLOAT;
					}	
		
[a-zA-Z_]([a-zA-Z_]|{DIGIT})* 	{
					SymbolInfo* s = new SymbolInfo(yytext, "ID");
					yylval.si = s;
					return ID;
				}
%%
