%{
#include<stdio.h>
#include<string.h>
#include<stdlib.h>
#include<ctype.h>
#include "data_types.h"
extern FILE* yyin;
extern char* yytext;

int q;
char type[10];
char messages[1000][1000];
int message_line = 0;

void* temp_vector[100000];
int temp_vector_size;

%}
%union { 
      struct symbol_var { 
	      char *str_val; 
            char *type;
            char *evaluated_str_val; 
            int num_val;
            void * linked_symbol;
	} nd_obj;

      struct evaluation_node {
            char *str_val;
            char *type;
      } eval_node;
} 

%{
int add_with_value(char c, char* type, char* id, struct evaluation_node variable);
int add_with_values(char c, char* type, char* id, struct symbol_var variable);
int add_func_with_parameters(char c, char* type, char* id);
int add(char c, char* type, char* id);
int search(char *, char);
const char* get_type(char *);
const char* get_value(char *);
const char* get_value_from_vector(char *, int);
%}

%token<nd_obj> CONST ID TIP BGIN END ASSIGN NR NR_F END_CLASS START_FUNCTION END_FUNCTION COMPARATORS START_IF START_WHILE START_FOR START_CLASS START_PROGRAM END_PROGRAM END_IF END_FOR END_WHILE TYPEOF EVAL ARITHMETIC_OPERATORS
%type<nd_obj> function_call variable multiple_values vectorizable_value 
%type<eval_node> expression_element expression
%left '+'
%left '*'
%left '-'
%left '/'

%start progr



%%
progr: program_structure { if(has_semantic_analysis_errors) { printf("Eroare de compilare...\n"); } else { printf("\n\nProgram corect sintactic\n\n"); } }
     ;

program_structure : declaratii_globale declaratii_functii declaratii_clase program
                    ;

/* -------------------------------- */

/* global variables */

declaratii_globale : declaratie_globala ';'
                    | declaratii_globale declaratie_globala ';'
                    |
                    ;

declaratie_globala : TIP ID { add('V', $1.str_val, $2.str_val); }
                    | ID ID  /* TODO valideaza prin tabela de simboluri pentru tipuri de date custom */
                    | CONST TIP ID ASSIGN expression { add_with_value('C', $2.str_val, $3.str_val, $5);}
                    | TIP ID ASSIGN expression { add_with_value('V', $1.str_val, $2.str_val, $4); }
                    | TIP ID ASSIGN '[' multiple_values ']' { 
                        if($5.linked_symbol)
                        {
                              if(strcmp($1.str_val, "int[]") == 0 || strcmp($1.str_val, "float[]") == 0 || strcmp($1.str_val, "bool[]") == 0) { 
                                    add_with_values('V', $1.str_val, $2.str_val, $5);
                              } else { 
                                    has_semantic_analysis_errors = 1; 
                                    printf("Initialization not valid on line %d with type %s\n", yylineno, $1.str_val);
                              }
                        } else {
                              add_with_values('V', $1.str_val, $2.str_val, $5);
                        }
                     } 
                    |
                    ;

multiple_values : vectorizable_value { $$=$1; }
                  | vectorizable_value ',' multiple_values {$$ = $1; $$.linked_symbol = &$3; }
                  ;  

vectorizable_value : NR { $$ = $1; }
                  | NR_F { $$ = $1; }

multiple_ids : ID
             | ID ',' multiple_ids 
             ;      

/* end global variables */

/* -------------------------------- */

/* functions declaration */

declaratii_functii : declaratie_functie
                    | declaratii_functii declaratie_functie
                    |
                    ;

declaratie_functie : START_FUNCTION TIP ID '(' ')' ':' execution_block_logic END_FUNCTION { add('F', $2.str_val, $3.str_val); }
                    | START_FUNCTION TIP ID '(' lista_param ')' ':'execution_block_logic END_FUNCTION { add_func_with_parameters('F', $2.str_val, $3.str_val); }
                    | START_FUNCTION TIP ID '(' ')' ':' END_FUNCTION { add('F', $2.str_val, $3.str_val); }
                    | START_FUNCTION TIP ID '(' lista_param ')' ':' END_FUNCTION { add_func_with_parameters('F', $2.str_val, $3.str_val); }
                    ;

lista_param : function_param
            | function_param ',' lista_param
            ;
            
function_param : TIP ID { 
      temp_function_definition_table[temp_function_definition_cnt].type = strdup($1.str_val);
      temp_function_definition_table[temp_function_definition_cnt].id = strdup($2.str_val);
      temp_function_definition_cnt++;
}; 

/* end functions declaration */

/* -------------------------------- */

/* custom data types declaration */

declaratii_clase : declaratie_clasa 
                    | declaratii_clase declaratie_clasa
                    |
                    ;

declaratie_clasa : START_CLASS ID ':' declaratii_globale declaratii_functii END_CLASS
               | START_CLASS ID ':' declaratii_globale END_CLASS
               | START_CLASS ID ':' declaratii_functii END_CLASS
               ;

/* end custom data types declaration */

/* -------------------------------- */

/* main */

program: START_PROGRAM execution_block END_PROGRAM
          ;

execution_block : execution_block execution_block_logic
               | execution_block_logic
               |
               ;

execution_block_logic : function_call ';'
                    | assign_statement
                    | control_statement
                    | declaratie_globala ';'
                    ;

function_call : variable '(' ')' { 
                  if(search($1.str_val, 'F') != -1) { 
                        has_semantic_analysis_errors = 1; printf("Function undefined on line %d\n", yylineno);  
                  }
                  else {
                        int found_cnt = 0, found_at = 0;
                        for(int i=0; i<function_definition_table_count;i++)
                        {
                            if(strcmp($1.str_val,function_definition_symbol_table[i].function_id) == 0 )
                            {
                              found_cnt++;
                              found_at=i;
                            }  
                        }
                        if(found_cnt != 1)
                        {
                              has_semantic_analysis_errors = 1; printf("Function does not match symbol definition on line %d\n", yylineno);  
                        } else if(function_definition_symbol_table[found_at].id[0] != '-')
                        {
                              has_semantic_analysis_errors = 1; printf("Function does not match symbol definition on line %d\n", yylineno); 
                        }
                  } }
               | variable '(' lista_apel ')' {
                        if(search($1.str_val, 'F') != -1) { 
                              has_semantic_analysis_errors = 1; printf("Function undefined on line %d\n", yylineno);  
                        }
                        else 
                        {
                              int j=0;
                              for(int i=0; i<function_definition_table_count; ++i)
                              {
                                    if(strcmp($1.str_val,function_definition_symbol_table[i].function_id) == 0 )
                                    {
                                          if(strcmp(function_definition_symbol_table[i].type, temp_function_call_table[j].type) != 0)
                                          {
                                                has_semantic_analysis_errors = 1; printf("Function does not match symbol definition on line %d\n", yylineno); 
                                          }
                                          j++;
                                    }
                              }
                              if(j != temp_function_call_cnt)
                              {
                                    has_semantic_analysis_errors = 1; printf("Function does not match symbol definition on line %d\n", yylineno); 
                              }
                        }
                        temp_function_call_cnt = 0;
                  }
               | TYPEOF '(' expression ')' { 
                  sprintf(messages[message_line++], "TypeOf on line %d responded with %s\n", yylineno, $3.type);
                  } 
               | EVAL '(' expression ')' { 
                  sprintf(messages[message_line++], "Eval on line %d responded with %s\n", yylineno, $3.str_val);
                  } 
               ;

lista_apel : expression_element { 
                  temp_function_call_table[temp_function_call_cnt].type = strdup($1.type); 
                  temp_function_call_table[temp_function_call_cnt++].id = strdup($1.str_val); 
            }
           | expression_element ',' lista_apel { 
                  temp_function_call_table[temp_function_call_cnt].type = strdup($1.type); 
                  temp_function_call_table[temp_function_call_cnt++].id = strdup($1.str_val); 
            }
           ;

assign_statement : variable ASSIGN expression ';' { 
                        if(search($1.str_val, 0) != -1)
                        {
                              has_semantic_analysis_errors = 1; printf("Variable does not match symbol definition on line %d\n", yylineno); 
                        }
                        validateAbstractExpressionTypes(get_type($1.str_val), $3.type); 
                  }
                 ;

control_statement : if_statement
                    | while_statement
                    | for_statement
                    ;

/* end main */

/* -------------------------------- */

/* control statements */

if_statement : START_IF boolean_expression ')' '{' execution_block END_IF
             ;

while_statement : START_WHILE boolean_expression ')' '{' execution_block END_WHILE
                ;

for_statement : START_FOR assign_statement boolean_expression ';' assign_statement ')' '{' execution_block END_FOR
               ;

/* end control statements */

/* -------------------------------- */

/* expression */

boolean_expression : expression COMPARATORS expression
                    ;

expression : expression_element {$$=$1;}
            | expression_element ARITHMETIC_OPERATORS expression_element { 
                  validateAbstractExpressionTypes($1.type, $3.type); $$.type = $1.type; 
                  $$.str_val = calculateAbstractExpressionStrValue($$.type, $2.str_val[0], $1.str_val, $3.str_val); 
            }
            | '(' expression ')' ARITHMETIC_OPERATORS '(' expression ')' {
                  validateAbstractExpressionTypes($2.type, $6.type); $$.type = $2.type; 
                  $$.str_val = calculateAbstractExpressionStrValue($$.type, $4.str_val[0], $2.str_val, $6.str_val); 
            }
            | '(' expression ')' ARITHMETIC_OPERATORS expression_element {
                  validateAbstractExpressionTypes($2.type, $5.type); $$.type = $2.type; 
                  $$.str_val = calculateAbstractExpressionStrValue($$.type, $4.str_val[0], $2.str_val, $5.str_val); 
            }
            | expression_element ARITHMETIC_OPERATORS '(' expression ')' {
                  validateAbstractExpressionTypes($1.type, $4.type); $$.type = $1.type; 
                  $$.str_val = calculateAbstractExpressionStrValue($$.type, $2.str_val[0], $1.str_val, $4.str_val); 
            }
            | expression ARITHMETIC_OPERATORS expression {
                  validateAbstractExpressionTypes($1.type, $3.type); $$.type = $1.type; 
                  $$.str_val = calculateAbstractExpressionStrValue($$.type, $2.str_val[0], $1.str_val, $3.str_val); 
            }
            | '(' expression ')' {
                  $$.type=$2.type;
                  $$.str_val = $2.str_val;
            }
          ;

expression_element :  NR { $$.str_val=$1.str_val; $$.type=strdup("int"); }
                    | NR_F { $$.str_val = $1.str_val; $$.type=strdup("float"); }
                    | variable { $$.type=$1.type;  $$.str_val = $1.evaluated_str_val; }
                    | function_call
                    ;

variable: ID { $$.evaluated_str_val = get_value($$.str_val); $$.type = strdup(get_type($$.str_val)); }
      | ID '[' NR ']' { 
            $$.type = strdup(get_type($$.str_val)); 
            $$.type[strlen($$.type)-2] = '\0';
            $$.evaluated_str_val = strdup(get_value_from_vector($$.str_val, atoi($3.str_val))); 
      }
      | ID '.' ID
      ;

/* end expression */

/* -------------------------------- */

%%
int yyerror(char * s){
printf("eroare: %s la linia:%d\n",s,yylineno);
}

int main(int argc, char** argv){
      yyin=fopen(argv[1],"r");
      yyparse();
      if(has_semantic_analysis_errors) { return; }

      print_symbol_table();
      print_function_symbol_table();

      for(int i=0; i<message_line; ++i) printf("%s", messages[i]);

      printf("\n");
} 

int search(char *type, char c) {
	int i;
	for(i=count-1; i>=0; i--) {
		if(strcmp(symbol_table[i].id_name, type)==0) {
                  if(c == 0)
                  {
                        return -1;
                        break;
                  }
                  else {
                        if(c == 'F' && strcmp(symbol_table[i].type, "Function") == 0)
                        {
                              return -1;
                        }
                  }
		}
	}
	return 0;
}

const char* get_type(char *id) {
	int i;
	for(i=count-1; i>=0; i--) {
		if(strcmp(symbol_table[i].id_name, id)==0) {
                  return symbol_table[i].data_type;
		}
	}
	return "char[]";
}

const char* get_value(char *id) {
      int i;
	for(i=count-1; i>=0; i--) {
		if(strcmp(symbol_table[i].id_name, id)==0) {
                  return symbol_table[i].value;
		}
	}
	return id;
}

const char* get_value_from_vector(char *id, int index)
{
      int i;
	for(i=count-1; i>=0; i--) {
		if(strcmp(symbol_table[i].id_name, id)==0) {
                  char buff[1000] = {0};
                  strcpy(buff, symbol_table[i].value);
                  char *p = strtok(buff, ",");                  
                  while(p) {
                        if(index == 0)
                        {
                              char *result = strdup(p);
                              return result;
                        }
                        index--;
                        p = strtok(NULL, ",");
                  }
		}
	}
	return "N/A";
}

int add(char c, char* type, char* id) {
      q=search(id, 0);
      if(!q) {
            if(c == 'K') {
			symbol_table[count].id_name=strdup(id);
			symbol_table[count].data_type=strdup("N/A");
			symbol_table[count].line_no=yylineno;
			symbol_table[count].type=strdup("Keyword\t");
			count++;
		}
		else if(c == 'V') {
			symbol_table[count].id_name=strdup(id);
			symbol_table[count].data_type=strdup(type);
			symbol_table[count].line_no=yylineno;
			symbol_table[count].type=strdup("Variable");
			count++;
		}
		else if(c == 'C') {
			symbol_table[count].id_name=strdup(id);
			symbol_table[count].data_type=strdup(type);
			symbol_table[count].line_no=yylineno;
			symbol_table[count].type=strdup("Constant");
			count++;
		}
		else if(c == 'F') {
			symbol_table[count].id_name=strdup(id);
			symbol_table[count].data_type=strdup(type);
			symbol_table[count].line_no=yylineno;
			symbol_table[count].type=strdup("Function");

                  function_definition_symbol_table[function_definition_table_count].function_id = symbol_table[count].id_name;
                  function_definition_symbol_table[function_definition_table_count].function_type = symbol_table[count].data_type;
                  function_definition_symbol_table[function_definition_table_count].id = strdup("-");
                  function_definition_symbol_table[function_definition_table_count].type = strdup("-");

                  function_definition_table_count++;

			count++;
		}
	}
      else {
            printf("Symbol %s on line %d is already defined\n",id, yylineno);
            has_semantic_analysis_errors = 1;
      }
}

int add_with_value(char c, char* type, char* id, struct evaluation_node variable) {
      int was_created = add(c, type, id);
      if(was_created)
      {
            if(strcmp(type, "int") == 0)
            {
                  symbol_table[count-1].value = variable.str_val;
            }
            else if(strcmp(type, "float") == 0)
            {
                  symbol_table[count-1].value = variable.str_val; 
            }
            else if(strcmp(type, "char") == 0)
            {
                  if(strlen(variable.str_val) != 1)
                  {
                        printf("%s is not a valid char on line %d\n", variable.str_val, yylineno);
                        has_semantic_analysis_errors = 1;
                        return 0;
                  }
                  symbol_table[count-1].value = variable.str_val[0];
            }
            else if(strcmp(type, "char[]") == 0)
            {
                  symbol_table[count-1].value = variable.str_val;
            }
            else if(strcmp(type, "bool") == 0)
            {
                  if(strlen(variable.str_val)!=1 || (variable.str_val[0]!='0' && variable.str_val[0]!='1'))
                  {
                        printf("%s is not a valid bool on line %d\n", variable.str_val, yylineno);
                        has_semantic_analysis_errors = 1;
                        return 0;
                  }
                  symbol_table[count-1].value = variable.str_val;
            }
            
      }
}

int add_with_values(char c, char* type, char* id, struct symbol_var variable) {
      int was_created = add(c, type, id);
      if(was_created)
      {
            if(strcmp(type, "char[]") == 0)
            {
                  symbol_table[count-1].value = variable.str_val;
            }
            else if(strcmp(type, "int[]") == 0 || strcmp(type, "float[]") == 0 || strcmp(type, "bool[]") == 0)
            {
                  int isBool = strcmp(type, "bool[]") == 0;
                  char serialized[10000] = {0};
                  strcpy(serialized, "");
                  int values_cnt = 1;
                  if(isBool)
                  {
                        if(strlen(variable.str_val)!=1 || (variable.str_val[0]!='0' && variable.str_val[0]!='1'))
                        {
                              printf("%s is not a valid bool on line %d\n", variable.str_val, yylineno);
                              has_semantic_analysis_errors = 1;
                              return 0;
                        }
                  }
                  strcat(serialized, variable.str_val);
                  strcat(serialized, ",");
                  void *p = variable.linked_symbol;            
                  while(p)
                  {
                        if(isBool)
                        {
                              if(strlen(((struct symbol_var*)p)->str_val)!=1 || (((struct symbol_var*)p)->str_val[0]!='0' && ((struct symbol_var*)p)->str_val[0]!='1'))
                              {
                                    printf("%s is not a valid bool on line %d\n", ((struct symbol_var*)p)->str_val, yylineno);
                                    has_semantic_analysis_errors = 1;
                                    return 0;
                              }
                        }

                        strcat(serialized, ((struct symbol_var*)p)->str_val);
                        strcat(serialized, ",");


                        p = ((struct symbol_var*)p)->linked_symbol;
                        values_cnt++;
                  }

                  symbol_table[count-1].value = (char*)malloc(sizeof(char) * strlen(serialized));
                  strcpy(symbol_table[count-1].value, serialized);
            }            
      }
}

int add_func_with_parameters(char c, char* type, char* id)
{
      q=search(id, 0);
      if(!q)
      {
            symbol_table[count].id_name=strdup(id);
		symbol_table[count].data_type=strdup(type);
		symbol_table[count].line_no=yylineno;
            symbol_table[count].type=strdup("Function");
            count++;

            for(int i = 0; i < temp_function_definition_cnt; i++)
            {
                  function_definition_symbol_table[function_definition_table_count].function_id = strdup(id);
                  function_definition_symbol_table[function_definition_table_count].function_type = strdup(type);
                  function_definition_symbol_table[function_definition_table_count].id = strdup(temp_function_definition_table[i].id);
                  function_definition_symbol_table[function_definition_table_count].type = strdup(temp_function_definition_table[i].type);

                  function_definition_table_count++;
            }
            temp_function_definition_cnt = 0;
      }
}