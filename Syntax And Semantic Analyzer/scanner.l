%option noyywrap
%{
#include<bits/stdc++.h>
#include<iostream>
#include<fstream>
//#define YYSTYPE SymbolInfo*

#include "SymbolTable.h"
#include "y.tab.h"

using namespace std;

//SymbolTable st(7);

//extern YYSTYPE yylval;

int line_count = 1;
int error_count = 0;

//extern SymbolTable st(7);
void yyerror(char *);


//ofstream logout;
//ofstream tokenout;
////string str = "";
//int comment_line = 0;

//char modifyChar(string &s);
//void modifyString(string &s);
//void removeCharacter(string &str, char a);


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


//int main(int argc,char *argv[]){
//	
//	if(argc!=2){
//		printf("Please provide input file name and try again\n");
//		return 0;
//	}
//	
//	FILE *fin=fopen(argv[1],"r");
//	if(fin==NULL){
//		printf("Cannot open specified file\n");
//		return 0;
//	}
//	
//	logout.open("1705108_log.txt");
//	tokenout.open("1705108_token.txt");

//	yyin= fin;
//	yylex();
//	fclose(yyin);
//	
//	st.printAllScopeTable(logout);
//	
//	logout<<"Total Lines: "<<line_count<<endl;
//	logout<<"Total Errors: "<<error_count<<endl;
//	
//	logout.close();
//	tokenout.close();
//	
//	return 0;
//}
