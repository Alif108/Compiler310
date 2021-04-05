%option noyywrap

%x SINCOMSTATE
%x MULCOMSTATE
%x STRINGSTATE

%{
#include<bits/stdc++.h>
#include<iostream>
#include<fstream>
#include "SymbolTable.h"

using namespace std;

SymbolTable st(7);

int line_count = 1;
ofstream logout;
ofstream tokenout;
string str = "";
int error_count = 0;
int comment_line = 0;

char modifyChar(string &s);
void modifyString(string &s);
//void newLineIncrease(string &str);
//void removeCharacterString(string &str, char a);
void removeCharacter(string &str, char a);
//string swap(string &s, char a, char b);

%}

WHITESPACE [ \t\f\r\v]+ 
LETTER [a-zA-Z]
DIGIT [0-9]
NEWLINE \n
SYMBOL	[\.@#$%^*()_+{}|:><?,;=-\\\/]

%%

{NEWLINE} {line_count++;}

{WHITESPACE}*	{}

"if"		{
			tokenout<<"<IF> ";
			logout<<"Line no "<<line_count<<": TOKEN <IF> Lexeme "<<yytext<<" found"<<endl<<endl;
		}
		
"else"		{
			tokenout<<"<ELSE> ";
			logout<<"Line no "<<line_count<<": TOKEN <ELSE> Lexeme "<<yytext<<" found"<<endl<<endl;
		}

"for"		{
			tokenout<<"<FOR> ";
			logout<<"Line no "<<line_count<<": TOKEN <FOR> Lexeme "<<yytext<<" found"<<endl<<endl;
		}

"while"		{
			tokenout<<"<WHILE> ";
			logout<<"Line no "<<line_count<<": TOKEN <WHILE> Lexeme "<<yytext<<" found"<<endl<<endl;
		}
		
"do"		{
			tokenout<<"<DO> ";
			logout<<"Line no "<<line_count<<": TOKEN <DO> Lexeme "<<yytext<<" found"<<endl<<endl;
		}
		
"break"		{
			tokenout<<"<BREAK> ";
			logout<<"Line no "<<line_count<<": TOKEN <BREAK> Lexeme "<<yytext<<" found"<<endl<<endl;
		}

"int"		{
			tokenout<<"<INT> ";
			logout<<"Line no "<<line_count<<": TOKEN <INT> Lexeme "<<yytext<<" found"<<endl<<endl;
		}	
		
"char"		{
			tokenout<<"<CHAR> ";
			logout<<"Line no "<<line_count<<": TOKEN <CHAR> Lexeme "<<yytext<<" found"<<endl<<endl;
		}
		
"float"		{
			tokenout<<"<FLOAT> ";
			logout<<"Line no "<<line_count<<": TOKEN <FLOAT> Lexeme "<<yytext<<" found"<<endl<<endl;
		}
		
"double"	{
			tokenout<<"<DOUBLE> ";
			logout<<"Line no "<<line_count<<": TOKEN <DOUBLE> Lexeme "<<yytext<<" found"<<endl<<endl;
		}
		
"void"		{
			tokenout<<"<VOID> ";
			logout<<"Line no "<<line_count<<": TOKEN <VOID> Lexeme "<<yytext<<" found"<<endl<<endl;
		}
		
"return"	{
			tokenout<<"<RETURN> ";
			logout<<"Line no "<<line_count<<": TOKEN <RETURN> Lexeme "<<yytext<<" found"<<endl<<endl;
		}
		
"switch"	{
			tokenout<<"<SWITCH> ";
			logout<<"Line no "<<line_count<<": TOKEN <SWITCH> Lexeme "<<yytext<<" found"<<endl<<endl;
		}
		
"case"		{
			tokenout<<"<CASE> ";
			logout<<"Line no "<<line_count<<": TOKEN <CASE> Lexeme "<<yytext<<" found"<<endl<<endl;
		}
		
"default"	{
			tokenout<<"<DEFAULT> ";
			logout<<"Line no "<<line_count<<": TOKEN <DEFAULT> Lexeme "<<yytext<<" found"<<endl<<endl;
		}

"continue"	{
			tokenout<<"<CONTINUE> ";
			logout<<"Line no "<<line_count<<": TOKEN <CONTINUE> Lexeme "<<yytext<<" found"<<endl<<endl;
		}		
			
"+"		|
"-"		{
			tokenout<<"<ADDOP, "<<yytext<<"> ";
			logout<<"Line no "<<line_count<<": TOKEN <ADDOP> Lexeme "<<yytext<<" found"<<endl<<endl;
		}

"*"		|
"/"		|
"%"		{
			tokenout<<"<MULOP, "<<yytext<<"> ";
			logout<<"Line no "<<line_count<<": TOKEN <MULOP> Lexeme "<<yytext<<" found"<<endl<<endl;
		}

"++"		|
"--"		{
			tokenout<<"<INCOP, "<<yytext<<"> ";
			logout<<"Line no "<<line_count<<": TOKEN <INCOP> Lexeme "<<yytext<<" found"<<endl<<endl;
		}

"<"		|
"<="		|
">"		|
">="		|
"=="		|
"!="		{
			tokenout<<"<RELOP, "<<yytext<<"> ";
			logout<<"Line no "<<line_count<<": TOKEN <RELOP> Lexeme "<<yytext<<" found"<<endl<<endl;
		}
		
"="		{
			tokenout<<"<ASSIGNOP, "<<yytext<<"> ";
			logout<<"Line no "<<line_count<<": TOKEN <ASSIGNOP> Lexeme "<<yytext<<" found"<<endl<<endl;
		}
		
"&&"		|
"||"		{
			tokenout<<"<LOGICOP, "<<yytext<<"> ";
			logout<<"Line no "<<line_count<<": TOKEN <LOGICOP> Lexeme "<<yytext<<" found"<<endl<<endl;
		}
	
"!"		{
			tokenout<<"<NOT, "<<yytext<<"> ";
			logout<<"Line no "<<line_count<<": TOKEN <NOT> Lexeme "<<yytext<<" found"<<endl<<endl;
		}
		
"("		{
			tokenout<<"<LPAREN, "<<yytext<<"> ";
			logout<<"Line no "<<line_count<<": TOKEN <LPAREN> Lexeme "<<yytext<<" found"<<endl<<endl;
		}						

")"		{
			tokenout<<"<RPAREN, "<<yytext<<"> ";
			logout<<"Line no "<<line_count<<": TOKEN <RPAREN> Lexeme "<<yytext<<" found"<<endl<<endl;
		}
		
"{"		{
			tokenout<<"<LCURL, "<<yytext<<"> ";
			logout<<"Line no "<<line_count<<": TOKEN <LCURL> Lexeme "<<yytext<<" found"<<endl<<endl;
			st.EnterScope();
		}
		
"}"		{
			tokenout<<"<RCURL, "<<yytext<<"> ";
			logout<<"Line no "<<line_count<<": TOKEN <RCURL> Lexeme "<<yytext<<" found"<<endl<<endl;
			st.ExitScope();
		}
		
"["		{
			tokenout<<"<LTHIRD, "<<yytext<<"> ";
			logout<<"Line no "<<line_count<<": TOKEN <LTHIRD> Lexeme "<<yytext<<" found"<<endl<<endl;
		}
		
"]"		{
			tokenout<<"<RTHIRD, "<<yytext<<"> ";
			logout<<"Line no "<<line_count<<": TOKEN <RTHIRD> Lexeme "<<yytext<<" found"<<endl<<endl;
		}
		
","		{
			tokenout<<"<COMMA, "<<yytext<<"> ";
			logout<<"Line no "<<line_count<<": TOKEN <COMMA> Lexeme "<<yytext<<" found"<<endl<<endl;
		}
		
";"		{
			tokenout<<"<SEMICOLON, "<<yytext<<"> ";
			logout<<"Line no "<<line_count<<": TOKEN <SEMICOLON> Lexeme "<<yytext<<" found"<<endl<<endl;
		}								
		
		
{DIGIT}+ 	{
				tokenout<<"<CONST_INT, "<<yytext<<"> ";
				logout<<"Line no "<<line_count<<": TOKEN <CONST_INT> Lexeme "<<yytext<<" found"<<endl<<endl;
				st.Insert(yytext, "CONST_INT", logout);
		}
		
{DIGIT}*\.{DIGIT}+([Ee][+-]?{DIGIT}+)? 	|
{DIGIT}+[Ee][+-]?{DIGIT}+		{
				tokenout<<"<CONST_FLOAT, "<<yytext<<"> ";
				logout<<"Line no "<<line_count<<": TOKEN <CONST_FLOAT> Lexeme "<<yytext<<" found"<<endl<<endl;
				st.Insert(yytext, "CONST_FLOAT", logout);
				}	
		
[a-zA-Z_]([a-zA-Z_]|{DIGIT})* 	{
				tokenout<<"<ID, "<<yytext<<"> ";
				logout<<"Line no "<<line_count<<": TOKEN <ID> Lexeme "<<yytext<<" found"<<endl<<endl;
				st.Insert(yytext, "ID", logout);
				}
	
\'{LETTER}\'	|
\'\\n\'		|
\'\\t\'		|
\'\\\\\'	|
\'\\\'\'	|
\'\\\"\'	|
\'\\\?\'	|
\'\\a\'		|
\'\\f\'		|
\'\\r\'		|
\'\\b\'		|
\'\\v\'				{
				string x = string(strdup(yytext));				// converting yytext to string
				string y = x.substr(1, x.size()-2);				//taking the substring without the ''
				char ch = modifyChar(y);					//converting to character				
				tokenout<<"<CONST_CHAR, "<<ch<<"> ";
				logout<<"Line no "<<line_count<<": TOKEN <CONST_CHAR> Lexeme "<<yytext<<" found "<<"--> <CONST_CHAR, "<<ch<<">"<<endl<<endl;
				st.Insert(x, "CONST_CHAR", logout);
		}
		
\/\/		{		comment_line = line_count;
				str.append(string(strdup(yytext)));
				BEGIN SINCOMSTATE;
				//logout<<"here"<<endl;	
		}
		

<SINCOMSTATE>(\\\n)			{	
						line_count++;
						str.append(string(strdup(yytext)));
					}
<SINCOMSTATE>{NEWLINE}			{
						str.append(string(strdup(yytext)));
						removeCharacter(str, '\n');
						logout<<"Line no "<<comment_line<<": TOKEN <COMMENT> Lexeme "<<str<<" found"<<endl<<endl;
						str = "";
						BEGIN INITIAL;
						line_count++;
					}
<SINCOMSTATE>.				{	str.append(string(strdup(yytext)));		}
					

\/\*					{	comment_line = line_count;
						str.append(string(strdup(yytext)));
						BEGIN MULCOMSTATE;
						//logout<<"here"<<endl;	
					}
					
					
					
<MULCOMSTATE>\*\/			{
						str.append(string(strdup(yytext)));
						//removeCharacter(str, '\n');
						logout<<"Line no "<<comment_line<<": TOKEN <COMMENT> Lexeme "<<str<<" found"<<endl<<endl;
						str = "";
						BEGIN INITIAL;
					}
<MULCOMSTATE>{NEWLINE}			{	
						line_count++;
						str.append(string(strdup(yytext)));
					}		
					
<MULCOMSTATE>.				{	str.append(string(strdup(yytext)));	}

<MULCOMSTATE><<EOF>>			{	error_count++;
						//string str = string(strdup(yytext));
						logout<<"Error at line no "<<comment_line<<": Unterminated Comment "<<str<<endl<<endl;
						
						return 0;
					}
					
					
					
					

\"					{	comment_line = line_count;	
						BEGIN STRINGSTATE;
						str.append(string(strdup(yytext)));
					}
					
<STRINGSTATE>\"				{	str.append(string(strdup(yytext)));
						string str2 = str;
						modifyString(str);
						//removeCharacter(str, '\n');
						//removeCharacter(str, '\\');
						tokenout<<"<STRING, "<<str<<"> ";
						logout<<"Line no "<<comment_line<<": TOKEN <STRING> Lexeme "<<str2<<" found"<<" --> <STRING, "<<str<<">"<<endl<<endl;
						str = "";
						BEGIN INITIAL;	}
								
<STRINGSTATE>(\\\")			{	str.append(string(strdup(yytext)));	}

<STRINGSTATE>(\\\n)			{	str.append(string(strdup(yytext)));
						line_count++;				
					}
<STRINGSTATE>(\\t)			{	str.append("\t");	}
<STRINGSTATE>(\\a)			{	str.append("\a");	}
<STRINGSTATE>(\\b)			{	str.append("\b");	}
<STRINGSTATE>(\\v)			{	str.append("\v");	}
<STRINGSTATE>(\\f)			{	str.append("\f");	}
<STRINGSTATE>(\\n)			{	str.append("\n");	}
<STRINGSTATE>(\\r)			{	str.append("\r");	}
						
<STRINGSTATE>{NEWLINE}			{	line_count++;	
						error_count++;
						//string str = string(strdup(yytext));
						logout<<"Error at line no "<<comment_line<<": Unterminated String "<<str<<endl<<endl;
						str = "";
						BEGIN INITIAL;	}

<STRINGSTATE>.				{	str.append(string(strdup(yytext)));	}


{DIGIT}*\.{DIGIT}*(\.{DIGIT}*)+		{
						error_count++;
						logout<<"Error at line no "<<line_count<<": Too many decimal points "<<yytext<<endl<<endl;
					}

{DIGIT}*(\.)*{DIGIT}*[Ee]({DIGIT}*(\.)+{DIGIT}*)+	|
{DIGIT}+\.					{
						error_count++;
						logout<<"Error at line no "<<line_count<<": Ill formed number "<<yytext<<endl<<endl;
					}
{DIGIT}+{LETTER}+			|
{DIGIT}+[\@#$(_{}:?\\]+	{
						error_count++;
						logout<<"Error at line no "<<line_count<<": Invalid prefix on ID or invalid suffix on Number "<<yytext<<endl<<endl;
					}

\'{LETTER}({WHITESPACE}*{LETTER}+{SYMBOL}*)+\'	|
\'{LETTER}({WHITESPACE}+{LETTER}*{SYMBOL}*)+\'	|	
\'{LETTER}({WHITESPACE}*{LETTER}*{SYMBOL}+)+\'	{
						error_count++;
						logout<<"Error at line no "<<line_count<<": Multi character constant error "<<yytext<<endl<<endl;
					}
\'({LETTER}*{SYMBOL}*{WHITESPACE}*{DIGIT}*)*{NEWLINE}	{
						error_count++;
						string x = string(strdup(yytext));
						removeCharacter(x, '\n');
						logout<<"Error at line no "<<line_count<<": Unterminated character "<<x<<endl<<endl;
						line_count++;
					}

\'\\\'({LETTER}*{SYMBOL}*{WHITESPACE}*{DIGIT}*)*{NEWLINE}					{
						error_count++;
						logout<<"Error at line no "<<line_count<<": Unterminated character "<<yytext<<endl<<endl;
						line_count++;
					}
					
\'\'					{
						error_count++;
						logout<<"Error at line no "<<line_count<<": Empty character constant error "<<yytext<<endl<<endl;
					}
					
.					{
						error_count++;
						logout<<"Error at line no "<<line_count<<": Unrecognized Character "<<yytext<<endl<<endl;	
					}		
					

%%

char modifyChar(string &s)
{
	char ch;
	if(s[0] == '\\')
	{
		switch(s[1]){
			case 't':
				ch = '\t';
				break;
			case 'a':
				ch = '\a';
				break;
			case 'f':
				ch = '\f';
				break;
			case 'n':
				ch = '\n';
				break;
			case 'b':
				ch = '\b';
				break;
			case 'v':
				ch = '\v';
				break;
//			case '0':
//				ch = '\0';
//				break;
			case 'r':
				ch = '\r';
				break;
			case '\'':
				ch = '\'';
				break;
			case '\"':
				ch = '\"';
				break;
			case '\?':
				ch = '\?';
				break;
			case '\\':
				ch = '\\';
				break;
			default:
				break;
		}		
	}
	else
		ch = s[0];
	return ch;
}

//void newLineIncrease(string &str)
//{
//    for (int i = 0; i < str.size(); i++)
//    {
//        if (str[i] ==  '\n')
//       		line_count++;
//    }
//}

void removeCharacter(string &str, char a)
{
	str.erase(std::remove(str.begin(), str.end(), a), str.end());
}

void modifyString(string &s)
{
	string x ="";
	for(int i=0; i<s.size()-1; i++)
	{
		if(s[i] == '\\')
		{
		switch(s[i+1]){
			case 't':
				s[i] = ' ';
				s[i+1] = '\t';
				break;
			case 'a':
				s[i] = ' ';
				s[i+1] = '\a';
				break;
			case 'f':
				s[i] = ' ';
				s[i+1] = '\f';
				break;
			case 'n':
				s[i] = ' ';
				s[i+1] = '\n';
				break;
			case 'b':
				s[i] = ' ';
				s[i+1] = '\b';
				break;
			case 'v':
				s[i] = ' ';
				s[i+1] = '\v';
				break;
//			case '0':
//				ch = '\0';
//				break;
			case 'r':
				s[i] = ' ';
				s[i+1] = '\r';
				break;
			case '\'':
				s[i] = ' ';
				s[i+1] = '\'';
				break;
			case '\"':
				s[i] = ' ';
				s[i+1] = '\"';
				break;
			case '\?':
				s[i] = ' ';
				s[i+1] = '\?';
				break;
			case '\\':
				s[i] = ' ';
				s[i+1] = '\\';
				break;
			case '\n':
				s[i] = ' ';
				s[i+1] = ' ';
			default:
				break;
			}
		}
	}	
}

int main(int argc,char *argv[]){
	
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	logout.open("1705108_log.txt");
	tokenout.open("1705108_token.txt");

	yyin= fin;
	yylex();
	fclose(yyin);
	
	st.printAllScopeTable(logout);
	
	logout<<"Total Lines: "<<line_count<<endl;
	logout<<"Total Errors: "<<error_count<<endl;
	
	logout.close();
	tokenout.close();
	
	return 0;
}
