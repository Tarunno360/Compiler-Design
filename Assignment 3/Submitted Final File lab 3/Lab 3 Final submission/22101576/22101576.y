%{

#include "symbol_table.h"

#define YYSTYPE symbol_info*

extern FILE *yyin;
int yyparse(void);
int yylex(void);
extern YYSTYPE yylval;

// create your symbol table here.
int parameter_count_var =0;
int lines=1;
std::ofstream outlog;
std::ofstream outerror;

int error_count = 0;
int warning_count = 0;
string current_function_name = "";  


SymbolTable n_symbol_table(10, &outlog);
vector<symbol_info *> params ;


string get_expression_type(symbol_info *expr);

bool is_variable_declared(string name);

symbol_info* lookup_symbol(string name);

bool is_numeric(string s);

bool is_float_literal(string s);

void yyerror(char *s)
{
	outlog<<"At line "<<lines<<" "<<s<<endl<<endl;
    // you may need to reinitialize variables if you find an error
}

// Helper functions
bool is_numeric(string s) {
	if (s.empty()) return false;
	for (char c : s) {
		if (!isdigit(c)) return false;
	}
	return true;
}

bool is_float_literal(string s) {
	if (s.empty()) return false;
	bool has_dot = false;
	for (size_t i = 0; i < s.length(); i++) {
		if (s[i] == '.') {
			if (has_dot) return false;
			has_dot = true;
		} else if (s[i] == 'e' || s[i] == 'E') {
			return true;
		} else if (!isdigit(s[i])) {
			return false;
		}
	}
	return has_dot;
}

symbol_info* lookup_symbol(string name) {
	symbol_info* temp_sym = new symbol_info(name, "temp");
	return n_symbol_table.lookup(temp_sym);
}

string get_expression_type(symbol_info *expr) {
	if (!expr) return "error";
	
	string name = expr->getname();
	
	// Check if it's a numeric constant
	if (is_numeric(name)) return "int";
	if (is_float_literal(name)) return "float";
	
	// Check if it's a function call - format: name(...)
	if (name.find("(") != string::npos && name.find(")") != string::npos) {
		size_t paren_pos = name.find("(");
		string func_name = name.substr(0, paren_pos);
		symbol_info* func_sym = lookup_symbol(func_name);
		if (func_sym && func_sym->get_symbol_type() == "Function Definition") {
			return func_sym->get_return_type();
		}
		return "error";
	}
	
	// Checking if it's an array access - format: name[...]
	if (name.find("[") != string::npos) {
		size_t bracket_pos = name.find("[");
		string var_name = name.substr(0, bracket_pos);
		symbol_info* var_sym = lookup_symbol(var_name);
		if (var_sym) {
			return var_sym->get_return_type();
		}
		return "error";
	}
	
	// Checking if it's a variable
	symbol_info* var_sym = lookup_symbol(name);
	if (var_sym && var_sym->get_symbol_type() != "Function Definition") {
		return var_sym->get_return_type();
	}
	
	// For complex expressions
	return "unknown";
}

%}

%token IF ELSE FOR WHILE DO BREAK INT CHAR FLOAT DOUBLE VOID RETURN SWITCH CASE DEFAULT CONTINUE PRINTLN ADDOP MULOP INCOP DECOP RELOP ASSIGNOP LOGICOP NOT LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON CONST_INT CONST_FLOAT ID

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%



start : program
	{
		outlog<<"At line no: "<<lines<<" start : program "<<endl<<endl;
		outlog<<"Symbol Table"<<endl<<endl;
		
		// Print your whole symbol table here
		n_symbol_table.print_all_scopes();
		
	}
	;

program : program unit
	{
		outlog<<"At line no: "<<lines<<" program : program unit "<<endl<<endl;
		outlog<<$1->getname()+"\n"+$2->getname()<<endl<<endl;
		
		$$ = new symbol_info($1->getname()+"\n"+$2->getname(),"program");
	}
	| unit
	{
		outlog<<"At line no: "<<lines<<" program : unit "<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
		
		$$ = new symbol_info($1->getname(),"program");
	}
	;

unit : var_declaration
	 {
		outlog<<"At line no: "<<lines<<" unit : var_declaration "<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
		
		$$ = new symbol_info($1->getname(),"unit");
	 }
     | func_definition
     {
		outlog<<"At line no: "<<lines<<" unit : func_definition "<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
		
		$$ = new symbol_info($1->getname(),"unit");
	 }
     ;

func_definition : type_specifier ID LPAREN 
		{
		current_function_name = $2->getname();  // Set function name EARLY
		}
		parameter_list RPAREN
		{
		$2->set_symbol_type("Function Definition");
		$2->set_return_type($1->getname());
		stringstream ss($5->getname());
		string token;
		while (getline(ss, token, ',')) {
        	$2->add_parameter_type(token);
    	} 
		
		// Check for multiple function declarations
		if (!n_symbol_table.insert($2)) {
			outerror<<"At line no: "<<lines<<" Multiple declaration of function "<<$2->getname()<<endl;
			outlog<<"At line no: "<<lines<<" Multiple declaration of function "<<$2->getname()<<endl;
			error_count++;
		}
		}
		compound_statement
		{	
			outlog<<"At line no: "<<lines<<" func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement "<<endl<<endl;
			if ($1 && $2 && $5 && $7) {
				outlog<<$1->getname()<<" "<<$2->getname()<<"("+$5->getname()+")\n"<<$7->getname()<<endl<<endl;
				
				$$ = new symbol_info($1->getname()+" "+$2->getname()+"("+$5->getname()+")\n"+$7->getname(),"func_def");
			} else {
				$$ = new symbol_info("error","func_def");
			}
			current_function_name = "";  // Clear
			
			// The function definition is complete.
            // You can now insert necessary information about the function into the symbol table
            // However, note that the scope of the function and the scope of the compound statement are different.
		}
		| type_specifier ID LPAREN RPAREN 
		{
		current_function_name = $2->getname();  // Track function name
		$2->set_symbol_type("Function Definition");
		$2->set_return_type($1->getname());
		
		// Check for multiple function declarations
		if (!n_symbol_table.insert($2)) {
			outerror<<"At line no: "<<lines<<" Multiple declaration of function "<<$2->getname()<<endl;
			outlog<<"At line no: "<<lines<<" Multiple declaration of function "<<$2->getname()<<endl;
			error_count++;
		}
		}
		compound_statement
		{
			
			outlog<<"At line no: "<<lines<<" func_definition : type_specifier ID LPAREN RPAREN compound_statement "<<endl<<endl;
			outlog<<$1->getname()<<" "<<$2->getname()<<"()\n"<<$6->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname()+" "+$2->getname()+"()\n"+$6->getname(),"func_def");	
			current_function_name = "";  // Clear
			
			// The function definition is complete.
            // You can now insert necessary information about the function into the symbol table
            // However, note that the scope of the function and the scope of the compound statement are different.
		}
 		;

parameter_list : parameter_list COMMA type_specifier ID
		{
			outlog<<"At line no: "<<lines<<" parameter_list : parameter_list COMMA type_specifier ID "<<endl<<endl;
			outlog<<$1->getname()<<","<<$3->getname()<<" "<<$4->getname()<<endl<<endl;
					
			$$ = new symbol_info($1->getname()+","+$3->getname()+" "+$4->getname(),"param_list");
			$4->set_symbol_type("Variable");
			$4->set_return_type($3->getname());
			
			// Check for duplicate parameter names
			for (auto p : params) {
				if (p->getname() == $4->getname()) {
					outerror<<"At line no: "<<lines<<" Multiple declaration of variable "<<$4->getname()<<" in parameter of "<<current_function_name<<endl;
					outlog<<"At line no: "<<lines<<" Multiple declaration of variable "<<$4->getname()<<" in parameter of "<<current_function_name<<endl;
					error_count++;
					break;
				}
			}
			params.push_back($4);
			parameter_count_var++;
            // store the necessary information about the function parameters
            // They will be needed when you want to enter the function into the symbol table
		}
		| parameter_list COMMA type_specifier
		{
			outlog<<"At line no: "<<lines<<" parameter_list : parameter_list COMMA type_specifier "<<endl<<endl;
			outlog<<$1->getname()<<","<<$3->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname()+","+$3->getname(),"param_list");
			
            // store the necessary information about the function parameters
            // They will be needed when you want to enter the function into the symbol table
		}
 		| type_specifier ID
 		{
			outlog<<"At line no: "<<lines<<" parameter_list : type_specifier ID "<<endl<<endl;
			outlog<<$1->getname()<<" "<<$2->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname()+" "+$2->getname(),"param_list");
			$2->set_symbol_type("Variable");
			$2->set_return_type($1->getname());
			params.push_back($2);
			parameter_count_var++;
            // store the necessary information about the function parameters
            // They will be needed when you want to enter the function into the symbol table
		}
		| type_specifier
		{
			outlog<<"At line no: "<<lines<<" parameter_list : type_specifier "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname(),"param_list");
			
            // store the necessary information about the function parameters
            // They will be needed when you want to enter the function into the symbol table
		}
 		;

compound_statement : LCURL
{
	n_symbol_table.enter_scope();
	
} statements RCURL
			{ 
 		    	outlog<<"At line no: "<<lines<<" compound_statement : LCURL statements RCURL "<<endl<<endl;
				if ($3) {
					outlog<<"{\n"+$3->getname()+"\n}"<<endl<<endl;
					
					$$ = new symbol_info("{\n"+$3->getname()+"\n}","comp_stmnt");
				} else {
					$$ = new symbol_info("{\n}","comp_stmnt");
				}
					if (parameter_count_var>0){
							for (auto param: params){
							n_symbol_table.insert(param);
						}
						parameter_count_var = 0;
						params.clear();
						}
					n_symbol_table.print_all_scopes();
					n_symbol_table.exit_scope();
                // The compound statement is complete.
                // Print the symbol table here and exit the scope
                // Note that function parameters should be in the current scope
 		    }
 		    | LCURL RCURL
 		    { 
 		    	outlog<<"At line no: "<<lines<<" compound_statement : LCURL RCURL "<<endl<<endl;
				outlog<<"{\n}"<<endl<<endl;
				
				$$ = new symbol_info("{\n}","comp_stmnt");
				
				// The compound statement is complete.
                // Print the symbol table here and exit the scope
 		    }
 		    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON
		 {
			outlog<<"At line no: "<<lines<<" var_declaration : type_specifier declaration_list SEMICOLON "<<endl<<endl;
			outlog<<$1->getname()<<" "<<$2->getname()<<";"<<endl<<endl;
			
			$$ = new symbol_info($1->getname()+" "+$2->getname()+";","var_dec");
			
			// Check if type is void
			if ($1->getname() == "void") {
				outerror<<"At line no: "<<lines<<" variable type can not be void "<<endl;
				outlog<<"At line no: "<<lines<<" variable type can not be void "<<endl;
				error_count++;
			}
			
			stringstream ss_var($2->getname());
			string token_var;
			while (getline(ss_var, token_var, ',')) {
				symbol_info *func = new symbol_info(token_var, "ID");

				size_t index_lthird = token_var.find("[");
				size_t index_rthird = token_var.find("]");
				if (index_lthird != string::npos) {
					func->set_name(token_var.substr(0, index_lthird));
					func->set_symbol_type("Array");
					func->set_return_type($1->getname());

					string s = token_var.substr(index_lthird + 1, index_rthird - index_lthird - 1);
					func->set_size(stoi(s));
				} else {
					func->set_symbol_type("Variable");
					func->set_return_type($1->getname());
				}

				if (!n_symbol_table.insert(func)) {
					outerror<<"At line no: "<<lines<<" Multiple declaration of variable "<<func->getname()<<endl;
					outlog<<"At line no: "<<lines<<" Multiple declaration of variable "<<func->getname()<<endl;
					error_count++;
				}
    		}
			// Insert necessary information about the variables in the symbol table
		 }
 		 ;

type_specifier : INT
		{
			outlog<<"At line no: "<<lines<<" type_specifier : INT "<<endl<<endl;
			outlog<<"int"<<endl<<endl;
			
			$$ = new symbol_info("int","type");
	    }
 		| FLOAT
 		{
			outlog<<"At line no: "<<lines<<" type_specifier : FLOAT "<<endl<<endl;
			outlog<<"float"<<endl<<endl;
			
			$$ = new symbol_info("float","type");
	    }
 		| VOID
 		{
			outlog<<"At line no: "<<lines<<" type_specifier : VOID "<<endl<<endl;
			outlog<<"void"<<endl<<endl;
			
			$$ = new symbol_info("void","type");
	    }
 		;

declaration_list : declaration_list COMMA ID
		  {
 		  	outlog<<"At line no: "<<lines<<" declaration_list : declaration_list COMMA ID "<<endl<<endl;
 		  	outlog<<$1->getname()+","<<$3->getname()<<endl<<endl;

            // you may need to store the variable names to insert them in symbol table here or later
			$$ = new symbol_info($1->getname()+","+$3->getname(),"declaration_list");
			
 		  }
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD //array after some declaration
 		  {
 		  	outlog<<"At line no: "<<lines<<" declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD "<<endl<<endl;
 		  	outlog<<$1->getname()+","<<$3->getname()<<"["<<$5->getname()<<"]"<<endl<<endl;
			$$ = new symbol_info($1->getname()+","+$3->getname()+"["+$5->getname()+"]","declaration_list");
            // you may need to store the variable names to insert them in symbol table here or later
 		  }
 		  |ID
 		  {
 		  	outlog<<"At line no: "<<lines<<" declaration_list : ID "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;

			$$ = new symbol_info($1->getname(),"declaration_list");
            // you may need to store the variable names to insert them in symbol table here or later
			
 		  }
 		  | ID LTHIRD CONST_INT RTHIRD //array
 		  {
 		  	outlog<<"At line no: "<<lines<<" declaration_list : ID LTHIRD CONST_INT RTHIRD "<<endl<<endl;
			outlog<<$1->getname()<<"["<<$3->getname()<<"]"<<endl<<endl;
			$$ = new symbol_info($1->getname()+"["+$3->getname()+"]","declaration_list");
            // you may need to store the variable names to insert them in symbol table here or later
            
 		  }
 		  ;
 		  

statements : statement
	   {
	    	outlog<<"At line no: "<<lines<<" statements : statement "<<endl<<endl;
			if ($1) {
				outlog<<$1->getname()<<endl<<endl;
				$$ = new symbol_info($1->getname(),"stmnts");
			} else {
				$$ = new symbol_info("","stmnts");
			}
	   }
	   | statements statement
	   {
	    	outlog<<"At line no: "<<lines<<" statements : statements statement "<<endl<<endl;
			if ($1 && $2) {
				outlog<<$1->getname()<<"\n"<<$2->getname()<<endl<<endl;
				$$ = new symbol_info($1->getname()+"\n"+$2->getname(),"stmnts");
			} else if ($1) {
				$$ = new symbol_info($1->getname(),"stmnts");
			} else if ($2) {
				$$ = new symbol_info($2->getname(),"stmnts");
			} else {
				$$ = new symbol_info("","stmnts");
			}
	   }
	   ;
	   
statement : var_declaration
	  {
	    	outlog<<"At line no: "<<lines<<" statement : var_declaration "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname(),"stmnt");
	  }
	  | func_definition
	  {
	  		outlog<<"At line no: "<<lines<<" statement : func_definition "<<endl<<endl;
            outlog<<$1->getname()<<endl<<endl;

            $$ = new symbol_info($1->getname(),"stmnt");
	  		
	  }
	  | expression_statement
	  {
	    	outlog<<"At line no: "<<lines<<" statement : expression_statement "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname(),"stmnt");
	  }
	  | compound_statement
	  {
	    	outlog<<"At line no: "<<lines<<" statement : compound_statement "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname(),"stmnt");
	  }
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement
	  {
	    	outlog<<"At line no: "<<lines<<" statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement "<<endl<<endl;
			outlog<<"for("<<$3->getname()<<$4->getname()<<$5->getname()<<")\n"<<$7->getname()<<endl<<endl;
			
			$$ = new symbol_info("for("+$3->getname()+$4->getname()+$5->getname()+")\n"+$7->getname(),"stmnt");
	  }
	  | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE
	  {
	    	outlog<<"At line no: "<<lines<<" statement : IF LPAREN expression RPAREN statement "<<endl<<endl;
			outlog<<"if("<<$3->getname()<<")\n"<<$5->getname()<<endl<<endl;
			
			$$ = new symbol_info("if("+$3->getname()+")\n"+$5->getname(),"stmnt");
	  }
	  | IF LPAREN expression RPAREN statement ELSE statement
	  {
	    	outlog<<"At line no: "<<lines<<" statement : IF LPAREN expression RPAREN statement ELSE statement "<<endl<<endl;
			outlog<<"if("<<$3->getname()<<")\n"<<$5->getname()<<"\nelse\n"<<$7->getname()<<endl<<endl;
			
			$$ = new symbol_info("if("+$3->getname()+")\n"+$5->getname()+"\nelse\n"+$7->getname(),"stmnt");
	  }
	  | WHILE LPAREN expression RPAREN statement
	  {
	    	outlog<<"At line no: "<<lines<<" statement : WHILE LPAREN expression RPAREN statement "<<endl<<endl;
			outlog<<"while("<<$3->getname()<<")\n"<<$5->getname()<<endl<<endl;
			
			$$ = new symbol_info("while("+$3->getname()+")\n"+$5->getname(),"stmnt");
	  }
	  | PRINTLN LPAREN ID RPAREN SEMICOLON
	  {
	    	outlog<<"At line no: "<<lines<<" statement : PRINTLN LPAREN ID RPAREN SEMICOLON "<<endl<<endl;
			outlog<<"printf("<<$3->getname()<<");"<<endl<<endl; 
			
			// Check if variable is declared
			symbol_info* var_sym = lookup_symbol($3->getname());
			if (!var_sym) {
				outerror<<"At line no: "<<lines<<" Undeclared variable "<<$3->getname()<<endl;
				outlog<<"At line no: "<<lines<<" Undeclared variable "<<$3->getname()<<endl;
				error_count++;
			}
			
			$$ = new symbol_info("printf("+$3->getname()+");","stmnt");
	  }
	  | RETURN expression SEMICOLON
	  {
	    	outlog<<"At line no: "<<lines<<" statement : RETURN expression SEMICOLON "<<endl<<endl;
			outlog<<"return "<<$2->getname()<<";"<<endl<<endl;
			
			$$ = new symbol_info("return "+$2->getname()+";","stmnt");
	  }
	  ;
	  
expression_statement : SEMICOLON
			{
				outlog<<"At line no: "<<lines<<" expression_statement : SEMICOLON "<<endl<<endl;
				outlog<<";"<<endl<<endl;
				
				$$ = new symbol_info(";","expr_stmt");
	        }			
			| expression SEMICOLON 
			{
				outlog<<"At line no: "<<lines<<" expression_statement : expression SEMICOLON "<<endl<<endl;
				outlog<<$1->getname()<<";"<<endl<<endl;
				
				$$ = new symbol_info($1->getname()+";","expr_stmt");
	        }
			;
	  
variable : ID 	
      {
	    outlog<<"At line no: "<<lines<<" variable : ID "<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
		
		// Check if variable is an array - if so, report error
		symbol_info* var_sym = lookup_symbol($1->getname());
		if (var_sym && var_sym->get_symbol_type() == "Array") {
			outerror<<"At line no: "<<lines<<" variable is of array type : "<<$1->getname()<<endl;
			outlog<<"At line no: "<<lines<<" variable is of array type : "<<$1->getname()<<endl;
			error_count++;
		}
		
		$$ = new symbol_info($1->getname(),"varbl");
		if (var_sym) {
			$$->set_return_type(var_sym->get_return_type());
			$$->set_symbol_type(var_sym->get_symbol_type());
		}
		
	 }	
	 | ID LTHIRD expression RTHIRD 
	 {
	 	outlog<<"At line no: "<<lines<<" variable : ID LTHIRD expression RTHIRD "<<endl<<endl;
		outlog<<$1->getname()<<"["<<$3->getname()<<"]"<<endl<<endl;
		
		// Check if variable is declared
		symbol_info* var_sym = lookup_symbol($1->getname());
		if (!var_sym) {
			outerror<<"At line no: "<<lines<<" Undeclared variable "<<$1->getname()<<endl;
			outlog<<"At line no: "<<lines<<" Undeclared variable "<<$1->getname()<<endl;
			error_count++;
		} else if (var_sym->get_symbol_type() != "Array") {
			outerror<<"At line no: "<<lines<<" variable is not of array type : "<<$1->getname()<<endl;
			outlog<<"At line no: "<<lines<<" variable is not of array type : "<<$1->getname()<<endl;
			error_count++;
		}
		
		// Check if array index is integer
		string index_type = get_expression_type($3);
		if (index_type == "float") {
			outerror<<"At line no: "<<lines<<" array index is not of integer type : "<<$1->getname()<<endl;
			outlog<<"At line no: "<<lines<<" array index is not of integer type : "<<$1->getname()<<endl;
			error_count++;
		}
		
		$$ = new symbol_info($1->getname()+"["+$3->getname()+"]","varbl");
		if (var_sym) {
			$$->set_return_type(var_sym->get_return_type());
			$$->set_symbol_type("Array");
		}
	 }
	 ;
	 
expression : logic_expression
	   {
	    	outlog<<"At line no: "<<lines<<" expression : logic_expression "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname(),"expr");
			$$->set_return_type(get_expression_type($1));
	   }
	   | variable ASSIGNOP logic_expression 	
	   {
	    	outlog<<"At line no: "<<lines<<" expression : variable ASSIGNOP logic_expression "<<endl<<endl;
			outlog<<$1->getname()<<"="<<$3->getname()<<endl<<endl;

			// Check if left-hand variable is declared
			string var_name = $1->getname();
			size_t bracket_pos = var_name.find("[");
			if (bracket_pos == string::npos) {  // Simple variable, not array
				symbol_info* var_sym = lookup_symbol(var_name);
				if (!var_sym) {
					outerror<<"At line no: "<<lines<<" Undeclared variable "<<var_name<<endl;
					outlog<<"At line no: "<<lines<<" Undeclared variable "<<var_name<<endl;
					error_count++;
				}
			}
			
			// Type checking for assignment
			string left_type = $1->get_return_type();
			string right_type = get_expression_type($3);
			
			// Check if right side is void
			if (right_type == "void") {
				outerror<<"At line no: "<<lines<<" operation on void type "<<endl;
				outlog<<"At line no: "<<lines<<" operation on void type "<<endl;
				error_count++;
			}
			
			// If right side is float and left is int, generate warning
			if (right_type == "float" && left_type == "int") {
				outerror<<"At line no: "<<lines<<" Warning: Assignment of float value into variable of integer type "<<endl;
				outlog<<"At line no: "<<lines<<" Warning: Assignment of float value into variable of integer type "<<endl;
				warning_count++;
			}
			
			$$ = new symbol_info($1->getname()+"="+$3->getname(),"expr");
			$$->set_return_type(left_type);
	   }
	   ;
			
logic_expression : rel_expression
	     {
	    	outlog<<"At line no: "<<lines<<" logic_expression : rel_expression "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname(),"lgc_expr");
			$$->set_return_type(get_expression_type($1));
	     }	
		 | rel_expression LOGICOP rel_expression 
		 {
	    	outlog<<"At line no: "<<lines<<" logic_expression : rel_expression LOGICOP rel_expression "<<endl<<endl;
			outlog<<$1->getname()<<$2->getname()<<$3->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname()+$2->getname()+$3->getname(),"lgc_expr");
			$$->set_return_type("int");  // Result of LOGICOP is integer
	     }	
		 ;
			
rel_expression	: simple_expression
		{
	    	outlog<<"At line no: "<<lines<<" rel_expression : simple_expression "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname(),"rel_expr");
			$$->set_return_type(get_expression_type($1));
	    }
		| simple_expression RELOP simple_expression
		{
	    	outlog<<"At line no: "<<lines<<" rel_expression : simple_expression RELOP simple_expression "<<endl<<endl;
			outlog<<$1->getname()<<$2->getname()<<$3->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname()+$2->getname()+$3->getname(),"rel_expr");
			$$->set_return_type("int");  // Result of RELOP is integer
	    }
		;
				
simple_expression : term
          {
	    	outlog<<"At line no: "<<lines<<" simple_expression : term "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname(),"simp_expr");
			$$->set_return_type(get_expression_type($1));
			
	      }
		  | simple_expression ADDOP term 
		  {
	    	outlog<<"At line no: "<<lines<<" simple_expression : simple_expression ADDOP term "<<endl<<endl;
			outlog<<$1->getname()<<$2->getname()<<$3->getname()<<endl<<endl;
			
			// Type inference for addition - if either is float, result is float
			string left_type = get_expression_type($1);
			string right_type = get_expression_type($3);
			
			// Check for operation on void type
			if (left_type == "void" || right_type == "void") {
				outerror<<"At line no: "<<lines<<" operation on void type "<<endl;
				outlog<<"At line no: "<<lines<<" operation on void type "<<endl;
				error_count++;
			}
			
			$$ = new symbol_info($1->getname()+$2->getname()+$3->getname(),"simp_expr");
			if (left_type == "float" || right_type == "float") {
				$$->set_return_type("float");
			} else {
				$$->set_return_type("int");
			}
	      }
		  ;
					
term :	unary_expression //term can be void because of un_expr->factor
     {
	    	outlog<<"At line no: "<<lines<<" term : unary_expression "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname(),"term");
			$$->set_return_type(get_expression_type($1));
			
	 }
     |  term MULOP unary_expression
     {
	    	outlog<<"At line no: "<<lines<<" term : term MULOP unary_expression "<<endl<<endl;
			outlog<<$1->getname()<<$2->getname()<<$3->getname()<<endl<<endl;
			
			string op = $2->getname();
			string left_type = get_expression_type($1);
			string right_type = get_expression_type($3);
			
			// Check for operation on void type
			if (left_type == "void" || right_type == "void") {
				outerror<<"At line no: "<<lines<<" operation on void type "<<endl;
				outlog<<"At line no: "<<lines<<" operation on void type "<<endl;
				error_count++;
			}
			
			// Check for modulus operator
			if (op == "%") {
				// Check if both operands are integers
				if (left_type == "float" || right_type == "float") {
					outerror<<"At line no: "<<lines<<" Modulus operator on non integer type "<<endl;
					outlog<<"At line no: "<<lines<<" Modulus operator on non integer type "<<endl;
					error_count++;
				}
				
				// Check if right operand is 0
				string right_name = $3->getname();
				if (is_numeric(right_name) && stoi(right_name) == 0) {
					outerror<<"At line no: "<<lines<<" Modulus by 0 "<<endl;
					outlog<<"At line no: "<<lines<<" Modulus by 0 "<<endl;
					error_count++;
				}
			}
			
			// Check for division by 0
			if (op == "/") {
				string right_name = $3->getname();
				if (is_numeric(right_name) && stoi(right_name) == 0) {
					outerror<<"At line no: "<<lines<<" Division by 0 "<<endl;
					outlog<<"At line no: "<<lines<<" Division by 0 "<<endl;
					error_count++;
				}
			}
			
			$$ = new symbol_info($1->getname()+$2->getname()+$3->getname(),"term");
			// Type inference for multiplication - if either is float, result is float
			if (left_type == "float" || right_type == "float") {
				$$->set_return_type("float");
			} else {
				$$->set_return_type("int");
			}
			
	 }
     ;

unary_expression : ADDOP unary_expression  // un_expr can be void because of factor
		 {
	    	outlog<<"At line no: "<<lines<<" unary_expression : ADDOP unary_expression "<<endl<<endl;
			outlog<<$1->getname()<<$2->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname()+$2->getname(),"un_expr");
			$$->set_return_type(get_expression_type($2));
	     }
		 | NOT unary_expression 
		 {
	    	outlog<<"At line no: "<<lines<<" unary_expression : NOT unary_expression "<<endl<<endl;
			outlog<<"!"<<$2->getname()<<endl<<endl;
			
			$$ = new symbol_info("!"+$2->getname(),"un_expr");
			$$->set_return_type("int");  // Result of NOT is integer
	     }
		 | factor 
		 {
	    	outlog<<"At line no: "<<lines<<" unary_expression : factor "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname(),"un_expr");
			$$->set_return_type(get_expression_type($1));
	     }
		 ;
	
factor	: variable
    {
	    outlog<<"At line no: "<<lines<<" factor : variable "<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
			
		$$ = new symbol_info($1->getname(),"fctr");
		$$->set_return_type($1->get_return_type());
	}
	| ID LPAREN argument_list RPAREN
	{
	    outlog<<"At line no: "<<lines<<" factor : ID LPAREN argument_list RPAREN "<<endl<<endl;
		outlog<<$1->getname()<<"("<<$3->getname()<<")"<<endl<<endl;

		// Look up function
		symbol_info* func_sym = lookup_symbol($1->getname());
		if (!func_sym) {
			outerror<<"At line no: "<<lines<<" Undeclared function: "<<$1->getname()<<endl;
			outlog<<"At line no: "<<lines<<" Undeclared function: "<<$1->getname()<<endl;
			error_count++;
			$$ = new symbol_info($1->getname()+"("+$3->getname()+")","fctr");
			$$->set_return_type("error");
		} else if (func_sym->get_symbol_type() != "Function Definition") {
			outerror<<"At line no: "<<lines<<" A function call cannot be made with non-function type identifier "<<endl;
			outlog<<"At line no: "<<lines<<" A function call cannot be made with non-function type identifier "<<endl;
			error_count++;
			$$ = new symbol_info($1->getname()+"("+$3->getname()+")","fctr");
			$$->set_return_type("error");
		} else {
			// Check function arguments
			vector<string> params = func_sym->get_params();
			string args_str = $3->getname();
			vector<string> arg_types;
			vector<string> arg_names;
			
			// Parse arguments
			if (!args_str.empty()) {
				stringstream ss(args_str);
				string token;
				while (getline(ss, token, ',')) {
					// Trim whitespace
					token.erase(0, token.find_first_not_of(" \t\n\r\f\v"));
					token.erase(token.find_last_not_of(" \t\n\r\f\v") + 1);
					arg_types.push_back(get_expression_type(new symbol_info(token, "temp")));
					arg_names.push_back(token);
				}
			}
			
			// Check number of arguments
			if (arg_types.size() != params.size()) {
				outerror<<"At line no: "<<lines<<" Inconsistencies in number of arguments in function call: "<<$1->getname()<<endl;
				outlog<<"At line no: "<<lines<<" Inconsistencies in number of arguments in function call: "<<$1->getname()<<endl;
				error_count++;
			} else {
				// Check type of each argument
				for (size_t i = 0; i < params.size(); i++) {
					// Extract type from param string (e.g., "int a" -> "int")
					string param_type;
					stringstream ss(params[i]);
					ss >> param_type;
					
					// Check if argument is an array - if so, skip type mismatch check
					string arg_name = arg_names[i];
					// Extract variable name (without array indices)
					size_t bracket_pos = arg_name.find("[");
					if (bracket_pos != string::npos) {
						arg_name = arg_name.substr(0, bracket_pos);
					}
					
					symbol_info* arg_sym = lookup_symbol(arg_name);
					bool is_arg_array = (arg_sym && arg_sym->get_symbol_type() == "Array");
					
					if (!is_arg_array && param_type != arg_types[i] && arg_types[i] != "error") {
						outerror<<"At line no: "<<lines<<" argument "<<(i+1)<<" type mismatch in function call: "<<$1->getname()<<endl;
						outlog<<"At line no: "<<lines<<" argument "<<(i+1)<<" type mismatch in function call: "<<$1->getname()<<endl;
						error_count++;
					}
				}
			}
			
			$$ = new symbol_info($1->getname()+"("+$3->getname()+")","fctr");
			$$->set_return_type(func_sym->get_return_type());
		}
	}
	| LPAREN expression RPAREN
	{
	   	outlog<<"At line no: "<<lines<<" factor : LPAREN expression RPAREN "<<endl<<endl;
		outlog<<"("<<$2->getname()<<")"<<endl<<endl;
		
		$$ = new symbol_info("("+$2->getname()+")","fctr");
		$$->set_return_type(get_expression_type($2));
	}
	| CONST_INT 
	{
	    outlog<<"At line no: "<<lines<<" factor : CONST_INT "<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
			
		$$ = new symbol_info($1->getname(),"fctr");
		$$->set_return_type("int");
	}
	| CONST_FLOAT
	{
	    outlog<<"At line no: "<<lines<<" factor : CONST_FLOAT "<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
			
		$$ = new symbol_info($1->getname(),"fctr");
		$$->set_return_type("float");
	}
	| variable INCOP 
	{
	    outlog<<"At line no: "<<lines<<" factor : variable INCOP "<<endl<<endl;
		outlog<<$1->getname()<<"++"<<endl<<endl;
			
		$$ = new symbol_info($1->getname()+"++","fctr");
		$$->set_return_type($1->get_return_type());
	}
	| variable DECOP
	{
	    outlog<<"At line no: "<<lines<<" factor : variable DECOP "<<endl<<endl;
		outlog<<$1->getname()<<"--"<<endl<<endl;
			
		$$ = new symbol_info($1->getname()+"--","fctr");
		$$->set_return_type($1->get_return_type());
	}
	;
	
argument_list : arguments
			  {
					outlog<<"At line no: "<<lines<<" argument_list : arguments "<<endl<<endl;
					outlog<<$1->getname()<<endl<<endl;
						
					$$ = new symbol_info($1->getname(),"arg_list");
			  }
			  |
			  {
					outlog<<"At line no: "<<lines<<" argument_list :  "<<endl<<endl;
					outlog<<""<<endl<<endl;
						
					$$ = new symbol_info("","arg_list");
			  }
			  ;
	
arguments : arguments COMMA logic_expression
		  {
				outlog<<"At line no: "<<lines<<" arguments : arguments COMMA logic_expression "<<endl<<endl;
				outlog<<$1->getname()<<","<<$3->getname()<<endl<<endl;
						
				$$ = new symbol_info($1->getname()+","+$3->getname(),"arg");
		  }
	      | logic_expression
	      {
				outlog<<"At line no: "<<lines<<" arguments : logic_expression "<<endl<<endl;
				outlog<<$1->getname()<<endl<<endl;
						
				$$ = new symbol_info($1->getname(),"arg");
		  }
	      ;
 

%%

int main(int argc, char *argv[])
{
	if(argc != 2) 
	{
		cout<<"Please input file name"<<endl;
		return 0;
	}
	yyin = fopen(argv[1], "r");
	outlog.open("log.txt", ios::trunc);
	outerror.open("error.txt", ios::trunc);
	
	if(yyin == NULL)
	{
		cout<<"Couldn't open file"<<endl;
		return 0;
	}
	// Enter the global or the first scope here
	n_symbol_table.enter_scope();

	yyparse();
	
	outlog<<endl<<"Total lines: "<<lines<<endl;
	outlog<<"Total errors: "<<(error_count + warning_count)<<endl;
	
	outerror<<endl<<"Total errors: "<<(error_count + warning_count)<<endl;
	
	outlog.close();
	outerror.close();
	
	fclose(yyin);
	
	return 0;
}