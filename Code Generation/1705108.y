%{
#include<bits/stdc++.h>
#define bucket_size 30
#include "1705108_SymbolTable.h"

using namespace std;

ofstream logFile;
ofstream errorFile;

ofstream code;										// file for code generation
ofstream optimized_code;										// file for optimized code generation

int yyparse(void);
int yylex(void);
extern FILE *yyin;

int line_count = 1;
int error_count = 0;

int labelCount = 0;									// how many labels
int tempCount = 0;									// how many temp registers
int scopeCount = 0;									// how many scopes 			// for assembly variable declarations

bool is_main = false;

SymbolTable st(bucket_size);

string type, id_name;								// for functions/variable
string return_type, func_name;						// for functions

string assembly_code = "";							// final assembly code

struct variable
{
	string var_type;
	string var_name;
	int var_size;									// for array
};

struct parameter
{
	string param_type;
	string param_name;
}; 

vector<variable>variable_list;							// container for variable
vector<parameter>param_list;							// container for function parameter
vector<string>arg_list;									// container for arguments

//**asm**//
vector<string>data_list;								// container for data segment declaration
vector<string>tempArgAddress;							// container for temporary argument addresses for function calls
vector<string>argumentAddressList;						// container for assembly variables under a function
vector<string>asmVariables;								// container for all the assembly variables declared




//-----helper functions--------//

bool searchParamList(string name)						// searching for redundancy in parameter list
{
	for(int i=0; i<param_list.size(); i++)
	{
		if(param_list[i].param_name == name)
			return true;
	}
}

char *newLabel()										// for adding a new Label
{
	char *lb= new char[4];
	strcpy(lb,"L");
	char b[3];
	sprintf(b,"%d", labelCount);
	labelCount++;
	strcat(lb,b);
	return lb;
}

char *newTemp()											// for adding a new temp register
{
	char *t= new char[4];
	strcpy(t,"t");
	char b[3];
	sprintf(b,"%d", tempCount);
	tempCount++;
	strcat(t,b);
	return t;
}

string makeAsmVariable(string name)
{									
	return (name + to_string(scopeCount));				// concatenating the scope number
}

string makeAsmVariableDeclaration(string name, int size)
{
	name = makeAsmVariable(name);

	if(size == -1)										// not an array, just a variable
	{								
		name += " dw ?";								// assembly variable declaration 		(e.g.) -> 	"a1 dw ?"
	}
	else 												// array
	{
		name += " dw ";
		name += to_string(size);
		name += " DUP(?)";								// assembly array declaration 		(e.g.) -> 	"a1 dw 3 DUP(?)"							
	}
	return name;
}


void yyerror(char *s)
{
	cout<<"Error at line "<<line_count<<": "<<s<<endl<<endl;
	error_count++;
	
	return;
}


%}



// --------- DEFINITION section ----------------//

%union{
	SymbolInfo* si;
}

%token IF ELSE FOR WHILE MAIN
%token <si> ID CONST_INT CONST_FLOAT SEMICOLON
%token LPAREN RPAREN COMMA LCURL RCURL LTHIRD RTHIRD RETURN PRINTLN
%token <si> INT FLOAT VOID 
%token ASSIGNOP NOT INCOP DECOP
%token <si> ADDOP MULOP RELOP LOGICOP

%type <si> declaration_list var_declaration type_specifier statement statements program parameter_list func_declaration 
%type <si> variable factor unary_expression term simple_expression rel_expression logic_expression expression
%type <si> unit compound_statement func_definition expression_statement argument_list arguments id start

//%left 
//%right

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE 


%%

//-------------- RULES section -------------//

start : program
	{
		cout<<"Line "<<line_count<<": start : program"<<endl<<endl;

		if(!error_count)
		{
			string label1 = newLabel();
			string label2 = newLabel();
			// string exitLabel = newLabel();

			assembly_code += ".MODEL small\n";
			assembly_code += ".STACK 100H\n";
			assembly_code += ".DATA\n";

			for(int i=0; i<data_list.size(); i++)								// data segment
			{
				assembly_code += (string)data_list[i] + "\n";
			}
			assembly_code += "ret_temp dw ?\n";
			assembly_code += "\n";

			assembly_code += ".CODE\n";
			// assembly_code += "PRINTLN PROC\n\n";								// print procedure
			// assembly_code += "push ax\n";
			// assembly_code += "push bx\n";
			// assembly_code += "push cx\n";
			// assembly_code += "push dx\n";

			// assembly_code += "mov cx, 0\n";
			// assembly_code += "mov dx, 0\n";

			// assembly_code += (label1 + ":\n\n");
			// assembly_code += "cmp ax, 0\n";
			// assembly_code += ("je " + label2 + "\n\n");
			// assembly_code += "mov bx, 10\n";
			// assembly_code += "div bx\n\n";
			// assembly_code += "push dx\n";
			// assembly_code += "inc cx\n\n";
			// assembly_code += "xor dx, dx\n";
			// assembly_code += ("jmp " + label1 + "\n\n");
			// assembly_code += (label2 + ":\n\n");
			// assembly_code += "cmp cx, 0\n";
			// assembly_code += "je " + exitLabel + "\n\n";
			// assembly_code += "pop dx\n";
			// assembly_code += "add dx, 48\n\n";
			// assembly_code += "mov ah, 2\n";
			// assembly_code += "int 21h\n\n";
			// assembly_code += "dec cx\n";
			// assembly_code += ("jmp " + label2 + "\n\n");
			// assembly_code += (exitLabel + ":\n");

			// assembly_code += "pop dx\n";
			// assembly_code += "pop cx\n";
			// assembly_code += "pop bx\n";
			// assembly_code += "pop ax\n";
			// assembly_code += "ret\n";
			// assembly_code += "PRINTLN ENDP\n\n";

			assembly_code += "PRINTLN PROC\n\n";
			assembly_code += "\tpush ax\n";
			assembly_code += "\tpush bx\n";
			assembly_code += "\tpush cx\n";
			assembly_code += "\tpush dx\n";

			assembly_code += "\tmov bx, 10\n";
			assembly_code += "\tmov cx, 0\n";
			assembly_code += (label1 + ":\n");
			assembly_code += "\tmov dx, 0\n";
			assembly_code += "\tdiv bx\n";
			assembly_code += "\tpush dx\n";
			assembly_code += "\tinc cx\n";
			assembly_code += "\tcmp ax, 0\n";
			assembly_code += ("\tjne " + label1 + "\n");
			assembly_code += (label2 + ":\n");
			assembly_code += "\tmov ah, 2\n";
			assembly_code += "\tpop dx\n";
			assembly_code += "\tadd dl, '0'\n";
			assembly_code += "\tint 21h\n";
			assembly_code += "\tdec cx\n";
			assembly_code += "\tcmp cx, 0\n";
			assembly_code += ("\tjne " + label2 + "\n");
			assembly_code += "\tmov dl, 0Ah\n";
			assembly_code += "\tint 21h\n";
			assembly_code += "\tmov dl, 0Dh\n";
			assembly_code += "\tint 21h\n";

			assembly_code += "\tpop dx\n";
			assembly_code += "\tpop cx\n";
			assembly_code += "\tpop bx\n";
			assembly_code += "\tpop ax\n";
			assembly_code += "\tret\n";
			assembly_code += "PRINTLN ENDP\n\n";

			assembly_code += $1->getCode();										// code segment
			assembly_code += "END MAIN\n";										// end segment

			code<<assembly_code;												//writing to assembly code file
		}	
	}
	;

program : program unit {
			$$ = new SymbolInfo(($1->getName() + "\n" + $2->getName()), "NON_TERMINAL");
			cout<<"Line "<<line_count<<": program : program unit"<<endl<<endl;	
			cout<<$1->getName()<<"\n"<<$2->getName()<<endl<<endl;

			//*asm**//
			$$->appendCode($1->getCode());
			$$->appendCode($2->getCode());
			}
			
	| unit	{
			cout<<"Line "<<line_count<<": program : unit"<<endl<<endl;	
			cout<<$1->getName()<<endl<<endl;
		}
	;
	
unit : var_declaration	{

			cout<<"Line "<<line_count<<": unit : var_declaration"<<endl<<endl;	
			cout<<$1->getName()<<endl<<endl;
		}
    	| func_declaration	{

			cout<<"Line "<<line_count<<": unit : func_declaration"<<endl<<endl;	
			cout<<$1->getName()<<endl<<endl;
		}
	| func_definition	{

			cout<<"Line "<<line_count<<": unit : func_definition"<<endl<<endl;	
			cout<<$1->getName()<<endl<<endl;
		}
     ;
     
func_declaration : type_specifier id update_func_info LPAREN parameter_list RPAREN insert_func_dec_info SEMICOLON	{
		
			$$ = new SymbolInfo(($1->getName() + " " + $2->getName() + "(" + $5->getName() + ");"), "NON_TERMINAL");
			cout<<"Line "<<line_count<<": func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON"<<endl<<endl;
			cout<<$1->getName()<<" "<<$2->getName()<<"("<<$5->getName()<<");"<<endl<<endl;
			
//			func_info.push_back(make_pair($1->getName(), $2->getName()));
		}
		
		| type_specifier id update_func_info LPAREN RPAREN insert_func_dec_info SEMICOLON	{
		
			$$ = new SymbolInfo(($1->getName() + " " + $2->getName() + "();"), "NON_TERMINAL");
			cout<<"Line "<<line_count<<": func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON"<<endl<<endl;
			cout<<$1->getName()<<" "<<$2->getName()<<"();"<<endl<<endl;
			
//			func_info.push_back(make_pair($1->getName(), $2->getName()));
		}
		;

		 
func_definition : type_specifier id update_func_info LPAREN parameter_list RPAREN insert_func_def_info compound_statement	{

			$$ = new SymbolInfo(($1->getName() + " " + $2->getName() + "(" + $5->getName() + ")" + $8->getName()), "NON_TERMINAL");
			cout<<"Line "<<line_count<<": func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement"<<endl<<endl;	
			cout<<$1->getName()<<" "<<$2->getName()<<"("<<$5->getName()<<")"<<$8->getName()<<endl<<endl;

			//**asm**//
			$$->appendCode($2->getName() + "_proc PROC\n");			// making function name // e.g. f_proc
			$$->appendCode("\tpush ax\n");
			$$->appendCode("\tpush bx\n");
			$$->appendCode("\tpush cx\n");
			$$->appendCode("\tpush dx\n");
			$$->appendCode("\tpush di\n\n");
			$$->appendCode($8->getCode());
			$$->appendCode($2->getName() + "_proc ENDP\t");
			$$->appendCode("\t; line no. " + to_string(line_count) + "\n\n");
		}
		
		| type_specifier id update_func_info LPAREN RPAREN insert_func_def_info compound_statement		{

			$$ = new SymbolInfo(($1->getName() + " " + $2->getName() + "(" + ")" + $7->getName()), "NON_TERMINAL");
			cout<<"Line "<<line_count<<": func_definition : type_specifier ID LPAREN RPAREN compound_statement"<<endl<<endl;	
			cout<<$1->getName()<<" "<<$2->getName()<<"("<<")"<<$7->getName()<<endl<<endl; 

			//**asm**//
			if($2->getName() == "main")									// if main function
			{
				$$->appendCode("\tMAIN PROC\n");
				$$->appendCode("\t; DATA SEGMENT INITIALIZATION\n\n");
				$$->appendCode("\tmov ax, @DATA\n");
				$$->appendCode("\tmov ds, ax\n\n");						// data segment init part

				$$->appendCode($7->getCode() + "\n");					// main code part

				$$->appendCode("\t; DOS EXIT\n");
				$$->appendCode("\tmov ah, 4CH\n");
				$$->appendCode("\tint 21H\n");							// dos exit 

				$$->appendCode("\tMAIN ENDP\n");
			}
			else  														// not main function
			{
				$$->appendCode($2->getName() + "_proc PROC\n");			// making function name // e.g. f_proc
				$$->appendCode("\tpush ax\n");
				$$->appendCode("\tpush bx\n");
				$$->appendCode("\tpush cx\n");
				$$->appendCode("\tpush dx\n");
				$$->appendCode("\tpush di\n\n");
				$$->appendCode($7->getCode());
				$$->appendCode($2->getName() + "_proc ENDP\t");
				$$->appendCode("\t; line no. " + to_string(line_count) + "\n\n");
			}
		}
 		;
 		
update_func_info	: 	{	
					func_name = id_name;
					return_type = type;					
				};

insert_func_def_info 	: 	{ 										
					SymbolInfo* temp = st.Lookup(func_name);								// searching in all the scopes
					
					if(temp == NULL)														// no id with the same name found
					{
						SymbolInfo* si  = new SymbolInfo(func_name, "ID");
						si->setTypeSpecifier(return_type);
						si->setSize(-2);													// -2 for function definition
						
						for(int i=0; i<param_list.size(); i++)								// adding parameters
						{
							si->addParameter(param_list[i].param_type, param_list[i].param_name);
						}

						// cout<<argumentAddressList.size()<<endl;
						for(int i=0; i<argumentAddressList.size(); i++)
						{
							si->pushFuncArgsAddress(argumentAddressList[i]);
						}						
						// cout<<si->getName()<<" "<<si->getFuncArgsAddressSize()<<endl;
						st.Insert(*si);

						//NOTICE//
						if(func_name == "main")												// this is used to remove asm code
							is_main = true;													// of "return 0" from main
					}
					
					else if(temp->getSize() == -3)											// function declared before
					{
						if(return_type != temp->getTypeSpecifier())							// return types don't match
						{
							cout<<"Error at line "<<line_count<<": Return type mismatch with function declaration in function "<<func_name<<endl<<endl;
							errorFile<<"Error at line "<<line_count<<": Return type mismatch with function declaration in function "<<func_name<<endl<<endl;
							error_count++;
						}
						
						else if(param_list.size() != temp->getParamListSize())				// parameter list sizes don't match
						{
							cout<<"Error at line "<<line_count<<": Total number of arguments mismatch with declaration in function "<<func_name<<endl<<endl;
							errorFile<<"Error at line "<<line_count<<": Total number of arguments mismatch with declaration in function "<<func_name<<endl<<endl;
							error_count++;
						}
						
						else																// return type and sizes match
						{
							int i = 0;
							
							for(i=0; i<param_list.size(); i++)								// checking whether all the param type matches
							{
								if(param_list[i].param_type != temp->getParameter(i).param_type)	// if one doesn't match
								{
									cout<<"Error at line "<<line_count<<": inconsistent function definition with its declaration for "<<func_name<<endl<<endl;
									errorFile<<"Error at line "<<line_count<<": inconsistent function definition with its declaration for "<<func_name<<endl<<endl;
									error_count++;
									break;
								}
							}
							
							if(i == param_list.size())										// all the param types matched
							{
								temp->setSize(-2);											// function is defined now
							}
						}
					}
					
					else																	// id with same name found
					{
						cout<<"Error at line "<<line_count<<": Multiple declaration of "<<func_name<<endl<<endl;
						errorFile<<"Error at line "<<line_count<<": Multiple declaration of "<<func_name<<endl<<endl;
						error_count++;
					}
				};
				
insert_func_dec_info 	: 	{ 	
					SymbolInfo* temp = st.Lookup(func_name);				// searching for the func_name
					
					if(temp == NULL)							// no id is declared before with the same name
					{
						SymbolInfo* si  = new SymbolInfo(func_name, "ID");
						si->setTypeSpecifier(return_type);
						si->setSize(-3);						// -3 for function declared
						
						for(int i=0; i<param_list.size(); i++)				// adding parameters
						{
							si->addParameter(param_list[i].param_type, param_list[i].param_name);
						}

						for(int i=0; i<argumentAddressList.size(); i++)
						{
							si->pushFuncArgsAddress(argumentAddressList[i]);
						}	
							
						st.Insert(*si);							// inserting function info
						
						param_list.clear();						// emptying the container
						argumentAddressList.clear();
					}
					else									// some other id with the same name is found
					{
						cout<<"Error at line "<<line_count<<": Multiple declaration of "<<func_name<<endl<<endl;
						errorFile<<"Error at line "<<line_count<<": Multiple declaration of "<<func_name<<endl<<endl;
						error_count++;
					}
				};


parameter_list  : parameter_list COMMA type_specifier id	{
		
			$$ = new SymbolInfo(($1->getName() + ", " + $3->getName() + " " + $4->getName()), "NON_TERMINAL");
 			cout<<"Line "<<line_count<<": parameter_list : parameter_list COMMA type_specifier ID"<<endl<<endl;	
 			
 			if(searchParamList($4->getName()))					// checking multiple declaration of parameters
 			{
 				cout<<"Error at line "<<line_count<<": Multiple declaration of "<<$4->getName()<<" in parameter"<<endl<<endl;
				errorFile<<"Error at line "<<line_count<<": Multiple declaration of "<<$4->getName()<<" in parameter"<<endl<<endl;
				error_count++;
 			}
 			else
 			{
 				param_list.push_back({$3->getName(), $4->getName()});
 				argumentAddressList.push_back(($4->getName() + to_string(scopeCount+1)));		// NOTICE
 			}
 				
 			cout<<$1->getName()<<", "<<$3->getName()<<" "<<$4->getName()<<endl<<endl;
		}
		
		| parameter_list COMMA type_specifier	{
		
			$$ = new SymbolInfo(($1->getName() + ", " + $3->getName()), "NON_TERMINAL");
 			cout<<"Line "<<line_count<<": parameter_list : parameter_list COMMA type_specifier"<<endl<<endl;	
 			cout<<$1->getName()<<", "<<$3->getName()<<endl<<endl;
 			
 			param_list.push_back({$3->getName(), ""});	
		}
		
 		| type_specifier id	{
 			
 			$$ = new SymbolInfo(($1->getName() + " " + $2->getName()), "NON_TERMINAL");
 			cout<<"Line "<<line_count<<": parameter_list  : type_specifier ID"<<endl<<endl;	
 			cout<<$1->getName()<<" "<<$2->getName()<<endl<<endl;
 			
 			param_list.push_back({$1->getName(), $2->getName()});
 			argumentAddressList.push_back(($2->getName() + to_string(scopeCount+1)));		// NOTICE
 		}
 		
		| type_specifier	{
		
			cout<<"Line "<<line_count<<": parameter_list : type_specifier"<<endl<<endl;	
			cout<<$1->getName()<<endl<<endl;
			
			param_list.push_back({$1->getName(), ""});
		}
 		;

 		
compound_statement : LCURL {										// enter new scope while encountering "{"
			
			st.EnterScope();
			scopeCount++;											// increasing the scope count

			for(int i=0; i<param_list.size(); i++)
			{
				SymbolInfo* si = new SymbolInfo(param_list[i].param_name, "ID");
				si->setTypeSpecifier(param_list[i].param_type);

				//**asm**//
				si->setAddress(makeAsmVariable(param_list[i].param_name));				// updating the corresponding assembly variable
				st.Insert(*si);															// inserting variable in SymbolTable

				data_list.push_back(makeAsmVariableDeclaration(param_list[i].param_name, -1));
				asmVariables.push_back(makeAsmVariable(param_list[i].param_name));		// pushing the variable in assembly var list
			}
			param_list.clear();
			argumentAddressList.clear();
			
		} statements RCURL	{

			$$ = new SymbolInfo(("{\n" + $3->getName() + "\n}"), "NON_TERMINAL");
			cout<<"Line "<<line_count<<": compound_statement : LCURL statements RCURL"<<endl<<endl;	
			cout<<"{\n"<<$3->getName()<<"\n}"<<endl<<endl;
			
			st.printAllScopeTable(logFile);
			st.ExitScope();

			//***asm***//
			$$->appendCode($3->getCode());
			$$->setAddress($3->getAddress());			
		}
		
 		    | LCURL {										// enter new scope while encountering "{"
			
			st.EnterScope();
			scopeCount++;									// increasing the scope count

			for(int i=0; i<param_list.size(); i++)
			{
				SymbolInfo* si = new SymbolInfo(param_list[i].param_name, "ID");
				si->setTypeSpecifier(param_list[i].param_type);
				
				//**asm**//
				si->setAddress(makeAsmVariable(param_list[i].param_name));				// updating the corresponding assembly variable
				st.Insert(*si);															// inserting variable in SymbolTable

				data_list.push_back(makeAsmVariableDeclaration(param_list[i].param_name, -1));
				asmVariables.push_back(makeAsmVariable(param_list[i].param_name));		// pushing the variable in assembly var list
			}
					
			param_list.clear();
			argumentAddressList.clear();
			
		} RCURL	{

			$$ = new SymbolInfo(((string)"{\n" + (string)"\n}"), "NON_TERMINAL");
			cout<<"Line "<<line_count<<": compound_statement : LCURL RCURL"<<endl<<endl;	
			cout<<"{\n"<<"\n}"<<endl<<endl;
			
			st.printAllScopeTable(logFile);
			st.ExitScope();
		}
 		;
 		    
var_declaration : type_specifier declaration_list SEMICOLON	{

				$$ = new SymbolInfo(($1->getName() + " " + $2->getName() + ";"), "NON_TERMINAL");
				cout<<"Line "<<line_count<<": var_declaration : type_specifier declaration_list SEMICOLON"<<endl<<endl;
				
				if($1->getName() == "void")								// e.g.		void x, y, z;
				{
					cout<<"Error at line "<<line_count<<": Variable type cannot be void"<<endl<<endl;
					errorFile<<"Error at line "<<line_count<<": Variable type cannot be void"<<endl<<endl;
					error_count++;
				}
				else
				{
					for(int i=0; i<variable_list.size(); i++)
					{
						SymbolInfo* si = new SymbolInfo(variable_list[i].var_name, "ID");
						si->setTypeSpecifier($1->getName());						// setting the variable type
						si->setSize(variable_list[i].var_size);

						//**asm**//
						si->setAddress(makeAsmVariable(variable_list[i].var_name));			// updating the corresponding assembly variable
						st.Insert(*si);															// inserting variable in SymbolTable

						data_list.push_back(makeAsmVariableDeclaration(variable_list[i].var_name, variable_list[i].var_size));
					}
				}
				cout<<$1->getName()<<" "<<$2->getName()<<";"<<endl<<endl;
				
//				st.printAllScopeTable(logFile);
				variable_list.clear();							// emptying the variable_list container after inserting
			}
 		 ;
 		 
type_specifier	: INT	{	$$ = new SymbolInfo($1->getName(), "NON_TERMINAL");
				cout<<"Line "<<line_count<<": type_specifier : INT"<<endl<<endl;	
				cout<<"int"<<endl<<endl;		
				
				type = "int";
			}
				
 		| FLOAT	{	$$ = new SymbolInfo($1->getName(), "NON_TERMINAL");
				cout<<"Line "<<line_count<<": type_specifier : FLOAT"<<endl<<endl;	
				cout<<"float"<<endl<<endl;
				
				type = "float";		
			}
				
 		| VOID	{	$$ = new SymbolInfo($1->getName(), "NON_TERMINAL");
				cout<<"Line "<<line_count<<": type_specifier : VOID"<<endl<<endl;	
				cout<<"void"<<endl<<endl;		
				
				type = "void";	
			}
		;
 		
declaration_list : declaration_list COMMA id	{

			SymbolInfo* temp = st.LookupHere($3->getName());				// searching for id in the current ScopeTable
			
			if(temp!=NULL)													// found in the SymbolTable
			{
				cout<<"Error at line "<<line_count<<": Multiple declaration of "<<$1->getName()<<endl<<endl;
				errorFile<<"Error at line "<<line_count<<": Multiple declaration of "<<$1->getName()<<endl<<endl;
				error_count++;
			}
			
			else			
				variable_list.push_back({"int", $3->getName(), -1});			// default var_type "int", var_size -1
			
			$$ = new SymbolInfo(($1->getName() + ", " + $3->getName()), "NON_TERMINAL");
			cout<<"Line "<<line_count<<": declaration_list : declaration_list COMMA ID"<<endl<<endl;
			cout<<$1->getName()<<", "<<$3->getName()<<endl<<endl;
		}
		
 		  | declaration_list COMMA id LTHIRD CONST_INT RTHIRD	{				// array
 		  	
 		  	SymbolInfo* temp = st.LookupHere($3->getName());					// searching for id in the current ScopeTable
			
			if(temp != NULL)													// found in the SymbolTable
			{
				cout<<"Error at line "<<line_count<<": Multiple declaration of "<<$3->getName()<<endl<<endl;
				errorFile<<"Error at line "<<line_count<<": Multiple declaration of "<<$3->getName()<<endl<<endl;
				error_count++;
			}
 		  	else
 		  		variable_list.push_back({"int", $3->getName(), stoi($5->getName())});	// default var_type "int", array size taken from $5
 		  	
 		  	$$ = new SymbolInfo(($1->getName() + ", " + $3->getName() + "[" + $5->getName() + "]"), "NON_TERMINAL");
 		  	cout<<"Line "<<line_count<<": declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD"<<endl<<endl;
 		  	cout<<$1->getName()<<", "<<$3->getName()<<"[" + $5->getName()<<"]"<<endl<<endl;
 		  	
 		  	
 		}
 		
 		  | id	{										// single identifier... 		e.g. (int) a
 		  
			SymbolInfo* temp = st.LookupHere($1->getName());				// searching it in the current ScopeTable
			
			if(temp != NULL)								// found in the SymbolTable
			{
				cout<<"Error at line "<<line_count<<": Multiple declaration of "<<$1->getName()<<endl<<endl;
				errorFile<<"Error at line "<<line_count<<": Multiple declaration of "<<$1->getName()<<endl<<endl;
				error_count++;
			}
			
			else
				variable_list.push_back({"int", $1->getName(), -1});			// default var_type "int", var_size -1
				
			cout<<"Line "<<line_count<<": declaration_list : ID"<<endl<<endl;	
			cout<<$1->getName()<<endl<<endl;
		}
		
 		  | id LTHIRD CONST_INT RTHIRD	{							// array  		e.g. (int) a[7]
 		  	
 		  	SymbolInfo* temp = st.LookupHere($1->getName());
			
			if(temp!=NULL)									// found in the SymbolTable
			{
				cout<<"Error at line "<<line_count<<": Multiple declaration of "<<$1->getName()<<endl<<endl;
				errorFile<<"Error at line "<<line_count<<": Multiple declaration of "<<$1->getName()<<endl<<endl;
				error_count++;
			}
			else
 		  		variable_list.push_back({"int", $1->getName(), stoi($3->getName())});	// default var_type "int", array size taken from $3
 		  	
 		  	$$ = new SymbolInfo(($1->getName() + "[" + $3->getName() + "]"), "NON_TERMINAL");
 		  	cout<<"Line "<<line_count<<": declaration_list : ID LTHIRD CONST_INT RTHIRD"<<endl<<endl;
 		  	cout<<$1->getName()<<"[" + $3->getName()<<"]"<<endl<<endl;
 		}
 		  ;
 		  
id	:	ID {
			$$ = new SymbolInfo($1->getName(), "NON_TERMINAL");
			id_name = $1->getName();
		}
	;

 		  
statements : statement	{

			cout<<"Line "<<line_count<<": statements : statement"<<endl<<endl;	
			cout<<$1->getName()<<endl<<endl;
		}
		
	   | statements statement	{

			$$ = new SymbolInfo(($1->getName() + "\n" + $2->getName()), "NON_TERMINAL");
			cout<<"Line "<<line_count<<": statements : statements statement"<<endl<<endl;	
			cout<<$1->getName()<<"\n"<<$2->getName()<<endl<<endl;

			//**asm**//
			$$->appendCode($1->getCode());
			$$->appendCode($2->getCode());
		}
	   ;
	   
statement : var_declaration	{

			cout<<"Line "<<line_count<<": statement : var_declaration"<<endl<<endl;	
			cout<<$1->getName()<<endl<<endl;
		}
		
	  | expression_statement	{
	  
			cout<<"Line "<<line_count<<": statement : expression_statement"<<endl<<endl;	
			cout<<$1->getName()<<endl<<endl;
		}
		
	  | compound_statement		{
	  
			cout<<"Line "<<line_count<<": statement : compound_statement"<<endl<<endl;	
			cout<<$1->getName()<<endl<<endl;
		}
		
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement	{
	  
	  		$$ = new SymbolInfo(("for(" + $3->getName() + $4->getName() + $5->getName() + ")" + $7->getName()), "NON_TERMINAL");
			cout<<"Line "<<line_count<<": statement : FOR LPAREN expression_statement expression_statement expression RPAREN 			statement"<<endl<<endl;	
			cout<<"for("<<$3->getName()<<$4->getName()<<$5->getName()<<")"<<$7->getName()<<endl<<endl;

			//**asm**//
			if($3->getName() != ";" && $4->getName() != ";")					// if not "for( ; ; )"
			{
				string label1 = newLabel();
                string label2 = newLabel();

                $$->appendCode($3->getCode());									// code for "i = 0"
                $$->appendCode("\t\n");
                $$->appendCode(label1 + ":\n");									// L1:
                $$->appendCode($4->getCode());									// code for "i < 10"
                $$->appendCode("\t\n");
                $$->appendCode("\tmov ax," + $4->getAddress() + "\n");			// mov ax, t3 (address of i < 10)
                $$->appendCode("\tcmp ax, 0\n");									// cmp ax, 0
                $$->appendCode("\tje " + label2 + "\n");							// je L2
                $$->appendCode("\t\n");
                $$->appendCode($7->getCode());									// code for block inside for loop
                $$->appendCode("\t\n");
                $$->appendCode($5->getCode());									// i++
                $$->appendCode("\tjmp " + label1 + "\n");							// jmp L1
                $$->appendCode(label2 + ":\t");									// L2:
                $$->appendCode("\t; line no. " + to_string(line_count) + "\n\n");
			}
		}
		
	  | IF LPAREN expression RPAREN statement	%prec LOWER_THAN_ELSE	{
	  
	  		$$ = new SymbolInfo(("if(" + $3->getName() + ")" + $5->getName()), "NON_TERMINAL");
			cout<<"Line "<<line_count<<": statement : IF LPAREN expression RPAREN statement"<<endl<<endl;	
			cout<<"if("<<$3->getName()<<")"<<$5->getName()<<endl<<endl;

			//**asm**//
			string label = newLabel();

			$$->appendCode($3->getCode());										// code of condition
			$$->appendCode("\tmov ax, " + $3->getAddress() + "\n");				// mov ax, t0  (computed value of condition)	
			$$->appendCode("\tcmp ax, 0\n");										// cmp ax, 0
			$$->appendCode("\tje " + label + "\n");								// je L
			$$->appendCode($5->getCode());										// code of statement
			$$->appendCode(label + ":\t");										// L:
			$$->appendCode("\t; line no. " + to_string(line_count) + "\n\n");
		}
		
	  | IF LPAREN expression RPAREN statement ELSE statement	{
	  
	  		$$ = new SymbolInfo(("if(" + $3->getName() + ")" + $5->getName() + "\nelse\n" + $7->getName()), "NON_TERMINAL");
			cout<<"Line "<<line_count<<": statement : IF LPAREN expression RPAREN statement ELSE statement"<<endl<<endl;	
			cout<<"if("<<$3->getName()<<")"<<$5->getName()<<"\nelse\n"<<$7->getName()<<endl<<endl;

			//**asm**//
			string label1 = newLabel();
			string label2 = newLabel();

			$$->appendCode($3->getCode());
			$$->appendCode("\tmov ax, " + $3->getAddress() + "\n");				// mov ax, t0
			$$->appendCode("\tcmp ax, 0\n");										// cmp ax, 0
			$$->appendCode("\tje " + label1 + "\n");								// je L1:
			$$->appendCode($5->getCode());										// code
			$$->appendCode("\tjmp " + label2 + "\n");								// jmp L2:
			$$->appendCode(label1 + ":\n");										// L1:
			$$->appendCode($7->getCode());										// code
			$$->appendCode(label2 + ":\t");										// L2:
			$$->appendCode("\t; line no." + to_string(line_count) + "\n\n");
		}
		
	  | WHILE LPAREN expression RPAREN statement	{
	  
	  		$$ = new SymbolInfo(("while(" + $3->getName() + ")" + $5->getName()), "NON_TERMINAL");
			cout<<"Line "<<line_count<<": statement : WHILE LPAREN expression RPAREN statement"<<endl<<endl;	
			cout<<"while("<<$3->getName()<<")"<<$5->getName()<<endl<<endl;

			//**asm**//
			string label1 = newLabel();
           	string label2 = newLabel();

        	$$->appendCode(label1 + ":\n");									// L1:
        	$$->appendCode($3->getCode());									// code for "i < 10"
        	$$->appendCode("\tmov ax," + $3->getAddress() + "\n");			// mov ax, t3 (address of i < 10)
        	$$->appendCode("\tcmp ax, 0\n");									// cmp ax, 0
        	$$->appendCode("\tje " + label2 + "\n");							// je L2
        	$$->appendCode("\t\n");
        	$$->appendCode($5->getCode());									// code for block inside while loop
         	$$->appendCode("\tjmp " + label1 + "\n");							// jmp L1
          	$$->appendCode(label2 + ":\t");									// L2:
          	$$->appendCode("\t; line no. " + to_string(line_count) + "\n\n");
		}
		
	  | PRINTLN LPAREN id RPAREN SEMICOLON		{
	  
	  		$$ = new SymbolInfo(("printf(" + $3->getName() + ");" + "\n"), "NON_TERMINAL");
			cout<<"Line "<<line_count<<": statement : PRINTLN LPAREN ID RPAREN SEMICOLON"<<endl<<endl;
			
			SymbolInfo * temp = st.LookupHere($3->getName());
			
			if(temp == NULL)
			{
				cout<<"Error at line "<<line_count<<": Undeclared variable "<<$3->getName()<<endl<<endl;
				errorFile<<"Error at line "<<line_count<<": Undeclared variable "<<$3->getName()<<endl<<endl;
				error_count++;
			}
			else
			{
				//**asm**//
				$$->appendCode("\tpush ax\n");									// push ax
				$$->appendCode("\tmov ax, " + temp->getAddress() + "\n");			// mov ax, a1
				$$->appendCode("\tcall PRINTLN\n");								// call PRINTLN
				$$->appendCode("\tpop ax\t");										// pop ax
				$$->appendCode("\t; line no. " + to_string(line_count));
				$$->appendCode("\t\n\n");
			}

			cout<<"printf("<<$3->getName()<<");"<<"\n"<<endl<<endl;

		}
		
	  | RETURN expression SEMICOLON		{
	  
	  		$$ = new SymbolInfo(("return " + $2->getName() + ";"), "NON_TERMINAL");
			cout<<"Line "<<line_count<<": statement : RETURN expression SEMICOLON"<<endl<<endl;	
			cout<<"return "<<$2->getName()<<";"<<endl<<endl;

			//**asm**//
			if(!is_main)
			{
				$$->appendCode($2->getCode());
				$$->appendCode("\tmov ax, " + $2->getAddress() + "\n");
				$$->appendCode("\tmov ret_temp, ax\n");
				$$->appendCode("\tpop di\n");
				$$->appendCode("\tpop dx\n");
				$$->appendCode("\tpop cx\n");
				$$->appendCode("\tpop bx\n");
				$$->appendCode("\tpop ax\n");
				$$->appendCode("\tret\t");
				$$->appendCode("\t; line no. " + to_string(line_count) + "\n\n");
			}
			else
				$$->appendCode($2->getCode());
		}
	  ;
	  
expression_statement 	: SEMICOLON	{

			$$ = new SymbolInfo(";", "SEMICOLON");
			cout<<"Line "<<line_count<<": expression_statement : SEMICOLON"<<endl<<endl;	
			cout<<";"<<endl<<endl;
		}		
			| expression SEMICOLON 		{

			$$ = new SymbolInfo(($1->getName() + ";"), "NON_TERMINAL");
			cout<<"Line "<<line_count<<": expression_statement : expression SEMICOLON"<<endl<<endl;	
			cout<<$1->getName()<<";"<<endl<<endl;

			//**asm**//
			$$->appendCode($1->getCode());
			$$->setAddress($1->getAddress());
		}
			;
	  
variable : id 	{
			cout<<"Line "<<line_count<<": variable : ID"<<endl<<endl;
			
			SymbolInfo* temp = st.Lookup($1->getName());					// searching it in the SymbolTable		
			
			if(temp == NULL)												// if not declared previously
			{
				cout<<"Error at line "<<line_count<<": Undeclared variable "<<$1->getName()<<endl<<endl;
				errorFile<<"Error at line "<<line_count<<": Undeclared variable "<<$1->getName()<<endl<<endl;
				error_count++;
				
//				$$->setTypeSpecifier("default");					// default type specifier = default -> when error
				$$->setTypeSpecifier("int");						// default type specifier = int -> when error
			}
			
			else if(temp->getSize() > 0)							//  {id} is an array
			{
				//cout<<temp->getSize()<<endl;
				cout<<"Error at line "<<line_count<<": Type mismatch, "<<$1->getName()<<" is an array"<<endl<<endl;
				errorFile<<"Error at line "<<line_count<<": Type mismatch, "<<$1->getName()<<" is an array"<<endl<<endl;
				error_count++;
				
				$$->setTypeSpecifier(temp->getTypeSpecifier());				
//				$$->setTypeSpecifier("int");						// default type specifier = int -> when error
			}
			
			else
			{					
				$$->setTypeSpecifier(temp->getTypeSpecifier());				// setting the type specifier
				$$->setSize(temp->getSize());

				//**asm**//
				$$->setAddress(temp->getAddress());						// setting up the assembly code symbol				
			}	
			cout<<$1->getName()<<endl<<endl;
		}	
		
	 | id LTHIRD expression RTHIRD {								// array index
	 		
	 		$$ = new SymbolInfo(($1->getName() + "[" + $3->getName() + "]"), "NON_TERMINAL");
			cout<<"Line "<<line_count<<": variable : ID LTHIRD expression RTHIRD"<<endl<<endl;
			
			SymbolInfo* temp = st.Lookup($1->getName());					// searching in all the ScopeTables
			
			if(temp == NULL)								// if not declared previously
			{
				cout<<"Error at line "<<line_count<<": Undeclared variable"<<$1->getName()<<endl<<endl;
				errorFile<<"Error at line "<<line_count<<": Undeclared variable"<<$1->getName()<<endl<<endl;
				error_count++;
				
//				$$->setTypeSpecifier("default");					// default type specifier = default -> when error
				$$->setTypeSpecifier("int");						// default type specifier = int -> when error
			}

			else												// declared previously
			{
				if(temp->getSize() < 0)							// not an array
				{
					cout<<"Error at line "<<line_count<<": "<<$1->getName()<<" is not an array"<<endl<<endl;
					errorFile<<"Error at line "<<line_count<<": "<<$1->getName()<<" is not an array"<<endl<<endl;
					error_count++;
					
//					$$->setTypeSpecifier("default");				// default type specifier = default -> when error
					$$->setTypeSpecifier("int");					// default type specifier = int -> when error
				}
			
				else if($3->getTypeSpecifier() != "int")				// index is not an integer
				{
					cout<<"Error at line "<<line_count<<": Expression inside third brackets not an integer"<<endl<<endl;
					errorFile<<"Error at line "<<line_count<<": Expression inside third brackets not an integer"<<endl<<endl;
					error_count++;
					
//					$$->setTypeSpecifier("default");				// default type specifier = default -> when error
					$$->setTypeSpecifier("int");					// default type specifier = int -> when error
				}
				else
				{
					$$->setTypeSpecifier(temp->getTypeSpecifier());			// setting the type specifier
					$$->setSize(temp->getSize());

					//**asm**//
					$$->appendCode($3->getCode());
					$$->appendCode("\tmov di, " + $3->getAddress() + "\n");					// mov di, 2 
					$$->appendCode("\tadd di, di\t");											// add di, di
					$$->appendCode("\t; line no. " + to_string(line_count) + "\n");
					$$->setAddress(temp->getAddress());						// setting up the assembly code symbol	
				}
			
			}
			
			cout<<$1->getName()<<"["<<$3->getName()<<"]"<<endl<<endl;
		}
	 ;
	 
expression : logic_expression		{

			cout<<"Line "<<line_count<<": expression : logic_expression "<<endl<<endl;	
			cout<<$1->getName()<<endl<<endl;
			
//			$$->setTypeSpecifier($1->getTypeSpecifier());
			type = $1->getTypeSpecifier();
		}
		
	   | variable ASSIGNOP logic_expression		{
			
			$$ = new SymbolInfo(($1->getName() + "=" + $3->getName()), "NON_TERMINAL");
			cout<<"Line "<<line_count<<": expression : variable ASSIGNOP logic_expression "<<endl<<endl;

			if($3->getTypeSpecifier() == "void")						// e.g.	(int) x = foo();	where foo() is void
			{
				cout<<"Error at line "<<line_count<<": Void function used in expression"<<endl<<endl;
				errorFile<<"Error at line "<<line_count<<": Void function used in expression"<<endl<<endl;
				error_count++;
				
				$$->setTypeSpecifier("int");						// default type specifier -> int
			}
			
			else if($1->getTypeSpecifier() != $3->getTypeSpecifier())			// if the type specfiers don't match
			{
				if($1->getTypeSpecifier() == "float" && $3->getTypeSpecifier() == "int")			
				{
					$$->setTypeSpecifier("float");					// if one is float and the other is int, result is float
				}
				
				else
				{
					cout<<"Error at line "<<line_count<<": Type Mismatch"<<endl<<endl;
					errorFile<<"Error at line "<<line_count<<": Type Mismatch"<<endl<<endl;
					error_count++;
						
	//				$$->setTypeSpecifier("default");				// default when error
					$$->setTypeSpecifier("int");					// default type specifier = int -> when error
				}
			}
			else 													// no errors
			{
				$$->setTypeSpecifier($1->getTypeSpecifier());	

				//**asm**//
				if($1->getSize() < 0 && $3->getSize() < 0)							// both are variable
				{
					$$->appendCode($1->getCode());
					$$->appendCode($3->getCode());
					$$->appendCode("\tmov ax, " + $3->getAddress() + "\n");			// e.g. mov ax, 2
					$$->appendCode("\tmov " + $1->getAddress() + ", ax \t"); 			// e.g. mov a_1, ax
					$$->appendCode("\t; line no. " + to_string(line_count));
					$$->appendCode("\t\n\n");
					
					$$->setAddress($1->getAddress());
				}
				else if($1->getSize() > 0 && $3->getSize() < 0) 					// $1 is array  // e.g. c[1] = 2
				{
					$$->appendCode($1->getCode());
					$$->appendCode($3->getCode());
					$$->appendCode("\tmov ax, " + $3->getAddress() + "\n");			// mov ax, 2
					$$->appendCode("\tmov " + $1->getAddress() + "[di], ax\t");		// mov c1[di], ax
					$$->appendCode("\t; line no. " + to_string(line_count));
					$$->appendCode("\t\n\n");
					
					$$->setAddress($1->getAddress());
				}
				else if($1->getSize() < 0 && $3->getSize() > 0)						// $3 is array // e.g. a = c[2]
				{
					$$->appendCode($1->getCode());
					$$->appendCode($3->getCode());
					$$->appendCode("\tmov ax, " + $3->getAddress() + "[di]\n");		// mov ax, c1[di]
					$$->appendCode("\tmov " + $1->getAddress() + ", ax\t");			// mov a1, ax
					$$->appendCode("\t; line no. " + to_string(line_count));
					$$->appendCode("\t\n\n");
					
					$$->setAddress($1->getAddress());
				}
				else  																// both are array // e.g. a[2] = c[3]
				{
					string temp = newTemp();
					data_list.push_back(temp + " dw ?");							// Pushing the new temp variable in data segment

					$$->appendCode($3->getCode());									// mov di, 0; add di, di
					$$->appendCode("\tmov ax, " + $3->getAddress() + "[di]\n");		// mov ax, c1[di]
					$$->appendCode("\tmov " + temp + ", ax\n");						// mov t6, ax
					$$->appendCode($1->getCode());									// mov di, 1; add di, di
					$$->appendCode("\tmov ax, " + temp + "\n");						// mov ax, t6
					$$->appendCode("\tmov " + $1->getAddress() + ", ax\t");			// mov a1[di], ax
					$$->appendCode("\t; line no. " + to_string(line_count) + "\n\n");

					$$->setAddress($1->getAddress());
				}
			}
			cout<<$1->getName()<<" = "<<$3->getName()<<endl<<endl;	
		}	 
	   ;
			
logic_expression : rel_expression 	{								

			cout<<"Line "<<line_count<<": logic_expression : rel_expression "<<endl<<endl;	
			cout<<$1->getName()<<endl<<endl;
		}
		
		| rel_expression LOGICOP rel_expression		{					
			
			$$ = new SymbolInfo(($1->getName() + $2->getName() + $3->getName()), "NON_TERMINAL");
			cout<<"Line "<<line_count<<": logic_expression : rel_expression LOGICOP rel_expression "<<endl<<endl;	
			cout<<$1->getName()<<$2->getName()<<$3->getName()<<endl<<endl;
			
			if($1->getTypeSpecifier() == "void" || $3->getTypeSpecifier() == "void")	// e.g.	foo()||x;	where foo() is void
			{
				cout<<"Error at line "<<line_count<<": Void function used in expression"<<endl<<endl;
				errorFile<<"Error at line "<<line_count<<": Void function used in expression"<<endl<<endl;
				error_count++;						
			}
			
			$$->setTypeSpecifier("int");

			//**asm**//
			string label1 = newLabel();
			string label2 = newLabel();
			string temp = newTemp();
			data_list.push_back(temp + " dw ?");							// Pushing the new temp variable in data segment
			$$->setAddress(temp);

			if($2->getName() == "&&")
			{
				$$->appendCode($1->getCode());
				$$->appendCode($3->getCode());
				$$->appendCode("\tcmp " + $1->getAddress() + ", 0\n");				// cmp a1, 0
				$$->appendCode("\tje " + label1 + "\n");								// je L1
				$$->appendCode("\tcmp " + $3->getAddress() + ", 0\n");				// cmp b1, 0
				$$->appendCode("\tje " + label1 + "\n");								// je L1
				$$->appendCode("\tmov " + temp + ", 1\n");							// mov t1, 1
				$$->appendCode("\tjmp " + label2 + "\n");								// jmp L2
				$$->appendCode(label1 + ":\n");										// L1 :
				$$->appendCode("\tmov " + temp + ", 0\n");							// mov t1, 0
				$$->appendCode(label2 + ":\t");										// L2 :
				$$->appendCode("\t; line no. " + to_string(line_count) + "\n\n");
			}
			else if($2->getName() == "||")
			{
				$$->appendCode($1->getCode());
				$$->appendCode($3->getCode());
				$$->appendCode("\tcmp " + $1->getAddress() + ", 1\n");				// cmp a1, 1
				$$->appendCode("\tje " + label1 + "\n");								// je L1
				$$->appendCode("\tcmp " + $3->getAddress() + ", 1\n");				// cmp b1, 1
				$$->appendCode("\tje " + label1 + "\n");								// je L1
				$$->appendCode("\tmov " + temp + ", 0\n");							// mov t1, 0
				$$->appendCode("\tjmp " + label2 + "\n");								// jmp L2
				$$->appendCode(label1 + ":\n");										// L1 :
				$$->appendCode("\tmov " + temp + ", 1\n");							// mov t1, 1
				$$->appendCode(label2 + ":\t");										// L2 :
				$$->appendCode("\t; line no. " + to_string(line_count) + "\n\n");
			}
		}	
		 ;
			
rel_expression	: simple_expression 	{								

			cout<<"Line "<<line_count<<": rel_expression : simple_expression "<<endl<<endl;	
			cout<<$1->getName()<<endl<<endl;
		}
		
		| simple_expression RELOP simple_expression	{					

			$$ = new SymbolInfo(($1->getName() + $2->getName() + $3->getName()), "NON_TERMINAL");
			cout<<"Line "<<line_count<<": rel_expression : simple_expression RELOP simple_expression "<<endl<<endl;	
			cout<<$1->getName()<<$2->getName()<<$3->getName()<<endl<<endl;
			
			if($1->getTypeSpecifier() == "void" || $3->getTypeSpecifier() == "void")	// e.g.	foo() < x;	where foo() is void
			{
				cout<<"Error at line "<<line_count<<": Void function used in expression"<<endl<<endl;
				errorFile<<"Error at line "<<line_count<<": Void function used in expression"<<endl<<endl;
				error_count++;
			}
			
			$$->setTypeSpecifier("int");							// default type	-> int

			string label1 = newLabel();
			string label2 = newLabel();
			string temp = newTemp();
			data_list.push_back(temp + " dw ?");

			//**asm**//
			if($2->getName() == "<")
			{
				$$->appendCode("\tmov ax, " + $1->getAddress() + "\n");				// mov ax, 2
				$$->appendCode("\tcmp ax, " + $3->getAddress() + "\n");				// cmp ax, 5
				$$->appendCode("\tjge " + label1 + "\n");								// jge L0
				$$->appendCode("\tmov " + temp + ", 1\n");							// mov t3, 1
				$$->appendCode("\tjmp " + label2 + "\n");								// jmp L1
				$$->appendCode(label1 + ": \n");									// L0:
				$$->appendCode("\tmov " + temp + ", 0\n");							// mov t3, 0
				$$->appendCode(label2 + ": \t");									// L1:
				$$->appendCode("\t; line no. " + to_string(line_count) + "\n\n");
			}
			else if($2->getName() == ">")
			{
				$$->appendCode("\tmov ax, " + $1->getAddress() + "\n");				// mov ax, 2
				$$->appendCode("\tcmp ax, " + $3->getAddress() + "\n");				// cmp ax, 5
				$$->appendCode("\tjle " + label1 + "\n");								// jle L0
				$$->appendCode("\tmov " + temp + ", 1\n");							// mov t3, 1
				$$->appendCode("\tjmp " + label2 + "\n");								// jmp L1
				$$->appendCode(label1 + ": \n");									// L0:
				$$->appendCode("\tmov " + temp + ", 0\n");							// mov t3, 0
				$$->appendCode(label2 + ": \t");									// L1:
				$$->appendCode("\t; line no. " + to_string(line_count) + "\n\n");
			}
			else if($2->getName() == "<=")
			{
				$$->appendCode("\tmov ax, " + $1->getAddress() + "\n");				// mov ax, 2
				$$->appendCode("\tcmp ax, " + $3->getAddress() + "\n");				// cmp ax, 5
				$$->appendCode("\tjg " + label1 + "\n");								// jg L0
				$$->appendCode("\tmov " + temp + ", 1\n");							// mov t3, 1
				$$->appendCode("\tjmp " + label2 + "\n");								// jmp L1
				$$->appendCode(label1 + ": \n");									// L0:
				$$->appendCode("\tmov " + temp + ", 0\n");							// mov t3, 0
				$$->appendCode(label2 + ": \t");									// L1:
				$$->appendCode("\t; line no. " + to_string(line_count) + "\n\n");
			}
			else if($2->getName() == ">=")
			{
				$$->appendCode("\tmov ax, " + $1->getAddress() + "\n");				// mov ax, 2
				$$->appendCode("\tcmp ax, " + $3->getAddress() + "\n");				// cmp ax, 5
				$$->appendCode("\tjl " + label1 + "\n");								// jl L0
				$$->appendCode("\tmov " + temp + ", 1\n");							// mov t3, 1
				$$->appendCode("\tjmp " + label2 + "\n");								// jmp L1
				$$->appendCode(label1 + ": \n");									// L0:
				$$->appendCode("\tmov " + temp + ", 0\n");							// mov t3, 0
				$$->appendCode(label2 + ": \t");									// L1:
				$$->appendCode("\t; line no. " + to_string(line_count) + "\n\n");
			}
			else if($2->getName() == "==")
			{
				$$->appendCode("\tmov ax, " + $1->getAddress() + "\n");				// mov ax, 2
				$$->appendCode("\tcmp ax, " + $3->getAddress() + "\n");				// cmp ax, 5
				$$->appendCode("\tjne " + label1 + "\n");								// jne L0
				$$->appendCode("\tmov " + temp + ", 1\n");							// mov t3, 1
				$$->appendCode("\tjmp " + label2 + "\n");								// jmp L1
				$$->appendCode(label1 + ": \n");									// L0:
				$$->appendCode("\tmov " + temp + ", 0\n");							// mov t3, 0
				$$->appendCode(label2 + ": \t");									// L1:
				$$->appendCode("\t; line no. " + to_string(line_count) + "\n\n");
			}
			else  		// RELOP -> !=
			{
				$$->appendCode("\tmov ax, " + $1->getAddress() + "\n");				// mov ax, 2
				$$->appendCode("\tcmp ax, " + $3->getAddress() + "\n");				// cmp ax, 5
				$$->appendCode("\tje " + label1 + "\n");								// je L0
				$$->appendCode("\tmov " + temp + ", 1\n");							// mov t3, 1
				$$->appendCode("\tjmp " + label2 + "\n");								// jmp L1
				$$->appendCode(label1 + ": \n");									// L0:
				$$->appendCode("\tmov " + temp + ", 0\n");							// mov t3, 0
				$$->appendCode(label2 + ": \t");									// L1:
				$$->appendCode("\t; line no. " + to_string(line_count) + "\n\n");
			}
			$$->setAddress(temp);
		}			
		;
				
simple_expression : term 	{

			cout<<"Line "<<line_count<<": simple_expression : term "<<endl<<endl;	
			cout<<$1->getName()<<endl<<endl;
		}
				
		  | simple_expression ADDOP term 	{						
		  
		  	$$ = new SymbolInfo(($1->getName() + $2->getName() + $3->getName()), "NON_TERMINAL");
		  	cout<<"Line "<<line_count<<": simple_expression : simple_expression ADDOP term  "<<endl<<endl;	
			cout<<$1->getName()<<$2->getName()<<$3->getName()<<endl<<endl;
			
			if($1->getTypeSpecifier() == "void" || $3->getTypeSpecifier() == "void")	// e.g.	foo() + x;	where foo() is void
			{
				cout<<"Error at line "<<line_count<<": Void function used in expression"<<endl<<endl;
				errorFile<<"Error at line "<<line_count<<": Void function used in expression"<<endl<<endl;
				error_count++;
				
				$$->setTypeSpecifier("int");						// default type	-> int				
			}
			
			if($1->getTypeSpecifier() == "float" || $3->getTypeSpecifier() == "float")	// if any of the operands are float, result is float
				$$->setTypeSpecifier("float");
			
			else
				$$->setTypeSpecifier($1->getTypeSpecifier());	

			//**asm**//
			string temp = newTemp();
			data_list.push_back(temp + " dw ?");								// Pushing the new temp variable in data segment
			$$->setAddress(temp); 

			$$->appendCode($1->getCode());
			$$->appendCode($3->getCode());
			$$->appendCode("\tmov ax, " + $1->getAddress() + "\n");				// e.g. mov ax, a1

			if($2->getName() == "+")
				$$->appendCode("\tadd ax, " + $3->getAddress() + "\n");			// e.g. add ax, b1
			else
				$$->appendCode("\tsub ax, " + $3->getAddress() + "\n");			// e.g. sub ax, b1

			$$->appendCode("\tmov " + temp + ", ax\n");							// e.b. mov t0, ax
			$$->appendCode("\t; line no. " + to_string(line_count) +"\n\n");		
		}
		;
					
term :	unary_expression	{
			
			cout<<"Line "<<line_count<<": term : unary_expression"<<endl<<endl;	
			cout<<$1->getName()<<endl<<endl;
			
			$$->setTypeSpecifier($1->getTypeSpecifier());

			//**asm**//
			$$->setAddress($1->getAddress());
	}
	
	|  term MULOP unary_expression		{									
			
			$$ = new SymbolInfo(($1->getName() + $2->getName() + $3->getName()), "NON_TERMINAL");
			cout<<"Line "<<line_count<<": term : term MULOP unary_expression"<<endl<<endl;	
			
			if($1->getTypeSpecifier() == "void" || $3->getTypeSpecifier() == "void")		// e.g.	foo() * x;	where foo() is void
			{
				cout<<"Error at line "<<line_count<<": Void function used in expression"<<endl<<endl;
				errorFile<<"Error at line "<<line_count<<": Void function used in expression"<<endl<<endl;
				error_count++;
				
				$$->setTypeSpecifier("int");												// default type	-> int				
			}
			
			if($2->getName() == "%")														// modulus operator
			{
				if($1->getTypeSpecifier() != "int" || $3->getTypeSpecifier() != "int")		// if any of the operands are not "int"
				{
					cout<<"Error at line "<<line_count<<": Non-Integer operand on modulus operator"<<endl<<endl;
					errorFile<<"Error at line "<<line_count<<": Non-Integer operand on modulus operator"<<endl<<endl;
					error_count++;
				}
				
				if($3->getName() == "0")								// if mod by 0
				{
					cout<<"Error at line "<<line_count<<": Modulus by Zero"<<endl<<endl;
					errorFile<<"Error at line "<<line_count<<": Modulus by Zero"<<endl<<endl;
					error_count++;
				}
				else 													// no errors
				{
					//**asm**//
					string temp = newTemp();
					data_list.push_back(temp + " dw ?");				// Pushing the new temp variable in data segment
					$$->setAddress(temp);

					$$->appendCode($1->getCode());								
					$$->appendCode($3->getCode());
					$$->appendCode("\tmov ax, " + $1->getAddress() + "\n");		// mov ax, a1
					$$->appendCode("\tmov bx, " + $3->getAddress() + "\n");		// mov bx, b1
					$$->appendCode("\txor dx, dx\n");								// xor dx, dx
					$$->appendCode("\tdiv bx\n");									// div bx
					$$->appendCode("\tmov " + temp + ", dx\t");					// mov t0, dx		// REMAINDER is in dx
					$$->appendCode("\t\n\n");

					// $$->setSize(-1);									// TODO: verify 	
				}
				
				$$->setTypeSpecifier("int");							// default specifier for modulus
			}
			
			else if($2->getName() == "/")								// division operator
			{
				if($3->getName() == "0")								// if div by 0
				{
					cout<<"Error at line "<<line_count<<": Divide by Zero"<<endl<<endl;
					errorFile<<"Error at line "<<line_count<<": Divide by Zero"<<endl<<endl;
					error_count++;
					
					$$->setTypeSpecifier("int");						// default specifier for error -> int
				}
				
				else if($1->getTypeSpecifier() == "float" || $3->getTypeSpecifier() == "float")	// if any of the operands are float
					$$->setTypeSpecifier("float");												// result is float
				
				else
					$$->setTypeSpecifier($1->getTypeSpecifier());

				//**asm**//
				string temp = newTemp();
				data_list.push_back(temp + " dw ?");				// Pushing the new temp variable in data segment
				$$->setAddress(temp);

				$$->appendCode($1->getCode());
				$$->appendCode($3->getCode());
				$$->appendCode("\tmov ax, " + $1->getAddress() + "\n");		// mov ax, a1
				$$->appendCode("\tmov bx, " + $3->getAddress() + "\n");		// mov bx, b1
				$$->appendCode("\txor dx, dx\n");								// xor dx, dx
				$$->appendCode("\tdiv bx\n");									// div bx
				$$->appendCode("\tmov " + temp + ", ax\t");					// mov t0, ax		// QUOTIENT is in ax
				$$->appendCode("\t; line no. " + to_string(line_count));
				$$->appendCode("\t\n\n");
			}
			
			else																			// multiplication operator
			{
				if($1->getTypeSpecifier() == "float" || $3->getTypeSpecifier() == "float")	// if any of the operands are float
					$$->setTypeSpecifier("float");											// result is float
				
				else
					$$->setTypeSpecifier($1->getTypeSpecifier());

				//**asm**//
				string temp = newTemp();
				data_list.push_back(temp + " dw ?");								// Pushing the new temp variable in data segment
				$$->setAddress(temp);

				$$->appendCode($1->getCode());
				$$->appendCode($3->getCode());
				$$->appendCode("\tmov ax, " + $1->getAddress() + "\n");				// mov ax, 1
				$$->appendCode("\tmov bx, " + $3->getAddress() + "\n");				// mov bx, 2
				$$->appendCode("\tmul bx\n");											// mul bx
				$$->appendCode("\tmov " + temp + ", ax\t");							// mov t1, ax
				$$->appendCode("\t; line no. " + to_string(line_count) + "\n\n");
			}
			
			cout<<$1->getName()<<$2->getName()<<$3->getName()<<endl<<endl;
}
     ;

unary_expression : ADDOP unary_expression  	{							
			
			$$ = new SymbolInfo(($1->getName() + $2->getName()), "NON_TERMINAL");
			cout<<"Line "<<line_count<<": unary_expression : ADDOP unary_expression"<<endl<<endl;	
			cout<<$1->getName()<<$2->getName()<<endl<<endl;
			
			if($2->getTypeSpecifier() == "void")						
			{
				cout<<"Error at line "<<line_count<<": Void function used in expression"<<endl<<endl;
				errorFile<<"Error at line "<<line_count<<": Void function used in expression"<<endl<<endl;
				error_count++;
				
				$$->setTypeSpecifier("int");						// default type	-> int				
			}			
			else
				$$->setTypeSpecifier($2->getTypeSpecifier());
		}
				
		 | NOT unary_expression 	{							
			
			$$ = new SymbolInfo(("!" + $2->getName()), "NON_TERMINAL");
			cout<<"Line "<<line_count<<": unary_expression : NOT unary_expression"<<endl<<endl;	
			cout<<"!"<<$2->getName()<<endl<<endl;
			
			if($2->getTypeSpecifier() == "void")						
			{
				cout<<"Error at line "<<line_count<<": Void function used in expression"<<endl<<endl;
				errorFile<<"Error at line "<<line_count<<": Void function used in expression"<<endl<<endl;
				error_count++;
				
				$$->setTypeSpecifier("int");						// default type	-> int				
			}
			else
				$$->setTypeSpecifier($2->getTypeSpecifier());
		}
				
		 | factor 	{									
			cout<<"Line "<<line_count<<": unary_expression : factor"<<endl<<endl;	
			cout<<$1->getName()<<endl<<endl;

			//**asm**//
			$$->setAddress($1->getAddress());
		}
		 ;
	
factor	: variable 	{										
				cout<<"Line "<<line_count<<": factor : variable"<<endl<<endl;	
				cout<<$1->getName()<<endl<<endl;
				
				$$->setTypeSpecifier($1->getTypeSpecifier());

				//**asm**//
				$$->setAddress($1->getAddress());
			}
			
	| id LPAREN argument_list RPAREN	{							//function call
													
			
			$$ = new SymbolInfo(($1->getName() + "(" + $3->getName() + ")"), "NON_TERMINAL");
			cout<<"Line "<<line_count<<": factor : ID LPAREN argument_list RPAREN"<<endl<<endl;	
			
			SymbolInfo* temp = st.Lookup($1->getName());					// searching for the function being called in all ScopeTables
			
			if(temp == NULL)								// no function declared before
			{
				cout<<"Error at line "<<line_count<<": Undeclared function "<<$1->getName()<<endl<<endl;
				errorFile<<"Error at line "<<line_count<<": Undeclared function "<<$1->getName()<<endl<<endl;
				error_count++;
				
				$$->setTypeSpecifier("int");						// default type specifier = int -> when error
			}
			else if(temp->getSize() != -2)							// function not defined
			{
				cout<<"Error at line "<<line_count<<": Undefined function "<<$1->getName()<<endl<<endl;
				errorFile<<"Error at line "<<line_count<<": Undefined function "<<$1->getName()<<endl<<endl;
				error_count++;
					
				$$->setTypeSpecifier("int");						// default type specifier = int -> when error
				
			}
			else													// function defined
			{
				if(temp->getParamListSize() != arg_list.size())				// if arg_list and function param_list no. don't match
				{
					cout<<"Error at line "<<line_count<<": Total number of arguments mismatch in function "<<$1->getName()<<endl<<endl;
					errorFile<<"Error at line "<<line_count<<": Total number of arguments mismatch in function "<<$1->getName()<<endl<<endl;
					error_count++;
					
					$$->setTypeSpecifier("int");							// default -> int
				}
				else														// arg_list number matches
				{
					int i = 0;
					for(i=0; i<arg_list.size(); i++)
					{
						if(arg_list[i] != temp->getParameter(i).param_type)
						{
							cout<<"Error at line "<<line_count<<": "<<i+1<<"th argument mismatch in function "<<$1->getName()<<endl<<endl;
							errorFile<<"Error at line "<<line_count<<": "<<i+1<<"th argument mismatch in function "<<$1->getName()<<endl<<endl;
							error_count++;
							break;
						}
					}
					
					if(i == arg_list.size())					// arg_list types matches
					{
						$$->setTypeSpecifier(temp->getTypeSpecifier());

						//**asm**//
						string tempVar = newTemp();
						data_list.push_back(tempVar + " dw ?");

						$$->appendCode($3->getCode());

						for(int i=0; i<tempCount-1; i++)
						{
							$$->appendCode("\tpush t" + to_string(i) + "\n");						// pushing all the previous temp registers
						}
						for(int i=0; i< asmVariables.size(); i++)
						{
							$$->appendCode("\tpush " + asmVariables[i] + "\n");					// pushing all the variables to stack
						}

						for(int i=0; i<tempArgAddress.size(); i++)
						{
							$$->appendCode("\tmov ax, " + tempArgAddress[i] + "\n");				// mov ax, a3		// a3 from main
							$$->appendCode("\tmov " + temp->getFuncArgsAddress(i) + ", ax\n");	// mov a1, ax		// a1 from callee function
						}
						$$->appendCode("\tcall " + $1->getName() + "_proc\n");					// call f_proc
						$$->appendCode("\tmov ax, ret_temp\n");									// mov ax, ret_temp
						$$->appendCode("\tmov " + tempVar + ", ax\n");							// mov t2, ax

						for(int i=asmVariables.size()-1; i>-1; i--)
						{
							$$->appendCode("\tpop " + asmVariables[i] + "\n");					// popping the asm variables
						}
						for(int i=tempCount-2; i>-1; i--)
						{
							$$->appendCode("\tpop t" + to_string(i) + "\n");						// pop all the temp registers
						}

						$$->appendCode("\t; line no. " + to_string(line_count) + "\n\n");

						$$->setAddress(tempVar);
					}
					else
					{
						$$->setTypeSpecifier("int");				// default -> int
					}
				}
			}	
				
			cout<<$1->getName()<<"("<<$3->getName()<<")"<<endl<<endl;
			arg_list.clear();
			
			tempArgAddress.clear();
			}
												
			
	| LPAREN expression RPAREN	{								
			
			$$ = new SymbolInfo(("(" + $2->getName() + ")"), "NON_TERMINAL");
			cout<<"Line "<<line_count<<": factor : LPAREN expression RPAREN"<<endl<<endl;	
			cout<<"("<<$2->getName()<<")"<<endl<<endl;
			
			$$->setTypeSpecifier($2->getTypeSpecifier());

			//**asm**//
			$$->appendCode($2->getCode());
			$$->setAddress($2->getAddress());
			}
				
	| CONST_INT 		{
			
			$$ = new SymbolInfo($1->getName(), "NON_TERMINAL");
			cout<<"Line "<<line_count<<": factor : CONST_INT"<<endl<<endl;	
			cout<<$1->getName()<<endl<<endl;
			
			$$->setTypeSpecifier("int");
			$$->setSize(-1);

			//**asm**//
			$$->setAddress($1->getName() + "d");						// setting the assembly code symbol
			}
			
	| CONST_FLOAT		{
			
			$$ = new SymbolInfo($1->getName(), "NON_TERMINAL");
			cout<<"Line "<<line_count<<": factor : CONST_FLOAT"<<endl<<endl;	
			cout<<$1->getName()<<endl<<endl;
			
			$$->setTypeSpecifier("float");
			}
			
	| variable INCOP 	{
			
			$$ = new SymbolInfo(($1->getName() + "++"), "NON_TERMINAL");
			cout<<"Line "<<line_count<<": factor : variable INCOP"<<endl<<endl;	
			cout<<$1->getName()<<"++"<<endl<<endl;
			
			$$->setTypeSpecifier($1->getTypeSpecifier());

			//**asm**//
			string temp = newTemp();
			data_list.push_back(temp + " dw ?");					// Pushing the new temp variable in data segment

			if($1->getSize() < 0)
			{
				$$->appendCode($1->getCode());
				$$->appendCode("\tmov ax, " + $1->getAddress() + "\n");		// mov ax, c1
				$$->appendCode("\tmov " + temp + ", ax\n");					// mov t5, ax
				$$->appendCode("\tinc " + $1->getAddress() + "\t");			// inc c1
			}
			else  													// array
			{
				$$->appendCode($1->getCode());
				$$->appendCode("\tmov ax, " + $1->getAddress() + "[di]\n");		// mov ax, c1[di]
				$$->appendCode("\tmov " + temp + ", ax\n");						// mov t5, ax
				$$->appendCode("\tinc " + $1->getAddress() + "[di]\t");			// inc c1[di]
			}
			$$->appendCode("\t; line no. " + to_string(line_count) + "\n\n");
			$$->setAddress(temp);
		}
			
	| variable DECOP	{
			
			$$ = new SymbolInfo(($1->getName() + "--"), "NON_TERMINAL");
			cout<<"Line "<<line_count<<": factor : variable DECOP"<<endl<<endl;	
			cout<<$1->getName()<<"--"<<endl<<endl;
			
			$$->setTypeSpecifier($1->getTypeSpecifier());

			//**asm**//
			string temp = newTemp();
			data_list.push_back(temp + " dw ?");					// Pushing the new temp variable in data segment

			if($1->getSize() < 0)
			{
				$$->appendCode($1->getCode());
				$$->appendCode("\tmov ax," + $1->getAddress() + "\n");		// mov ax, c1
				$$->appendCode("\tmov " + temp + ", ax\n");					// mov t5, ax
				$$->appendCode("\tdec " + $1->getAddress() + "\t");			// inc c1
			}
			else  													// array
			{
				$$->appendCode($1->getCode());
				$$->appendCode("\tmov ax," + $1->getAddress() + "[di]\n");		// mov ax, c1[di]
				$$->appendCode("\tmov " + temp + ", ax\n");						// mov t5, ax
				$$->appendCode("\tdec " + $1->getAddress() + "[di]\t");			// inc c1[di]
			}
			$$->appendCode("\t; line no. " + to_string(line_count) + "\n\n");
			$$->setAddress(temp);
			}
	;
	
argument_list : arguments	{
			
			cout<<"Line "<<line_count<<": argument_list : arguments"<<endl<<endl;	
			cout<<$1->getName()<<endl<<endl;
			}	
	|	/* empty string */	{
			
			cout<<"Line "<<line_count<<": argument_list : <empty>"<<endl<<endl;
			}
			  ;
	
arguments : arguments COMMA logic_expression	{
			
			$$ = new SymbolInfo(($1->getName() + ", " + $3->getName()), "NON_TERMINAL");
			cout<<"Line "<<line_count<<": arguments : arguments COMMA logic_expression"<<endl<<endl;	
			cout<<$1->getName()<<", "<<$3->getName()<<endl<<endl;
			
			if($3->getTypeSpecifier() == "void")						
			{
				cout<<"Error at line "<<line_count<<": Void function used in expression"<<endl<<endl;
				errorFile<<"Error at line "<<line_count<<": Void function used in expression"<<endl<<endl;
				error_count++;
				
//				$$->setTypeSpecifier("int");						// default type	-> int	
				arg_list.push_back("int");						// default type -> int				
			}
			else
				arg_list.push_back($3->getTypeSpecifier());

			//**asm**//
			tempArgAddress.push_back($3->getAddress());

		}
			
	      | logic_expression	{
			
			cout<<"Line "<<line_count<<": arguments : logic_expression"<<endl<<endl;	
			cout<<$1->getName()<<endl<<endl;
			
			if($1->getTypeSpecifier() == "void")						
			{
				cout<<"Error at line "<<line_count<<": Void function used in expression"<<endl<<endl;
				errorFile<<"Error at line "<<line_count<<": Void function used in expression"<<endl<<endl;
				error_count++;
				
//				$$->setTypeSpecifier("int");						// default type	-> int
				arg_list.push_back("int");						// default type -> int				
			}
			else
				arg_list.push_back($1->getTypeSpecifier());

			//**asm**//
			tempArgAddress.push_back($1->getAddress());
		}
	      ;
 

%%
int main(int argc,char *argv[])
{

	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	logFile.open("log.txt");
	errorFile.open("error.txt");
	code.open("code.asm");													// opening assembly code file
	optimized_code.open("optimized_code.asm");								// opening optimized_code file

	cout.rdbuf(logFile.rdbuf());											// redirect cout to logFile
//	tokenout.open("1705108_token.txt");

	yyin= fin;
	yyparse();
	
	st.printAllScopeTable(logFile);
	
	cout<<"Total Lines: "<<line_count<<endl;
	cout<<"Total Errors: "<<error_count<<endl;
	
	fclose(yyin);
	logFile.close();
	errorFile.close();
	code.close();	
	return 0;
}