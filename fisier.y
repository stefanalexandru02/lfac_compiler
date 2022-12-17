%{
#include<stdio.h>
#include<string.h>
#include<stdlib.h>
#include<ctype.h>
extern FILE* yyin;
extern char* yytext;
extern int yylineno;

struct dataType {
        char * id_name;
        char * data_type;
        char * type;
        int line_no;
        void * value;
} symbol_table[4000];

struct function_signature_parameter { 
      int function_id;
      int parameter_order;
      char * id_name;
      char * type;
} function_definition_symbol_table[4000];

int count=0;
int q;
char type[10];

void* temp_vector[100000];
int temp_vector_size;

int has_semantic_analysis_errors = 0;

%}
%union { struct symbol_var { 
			char *str_val; 
                  int num_val;
                  void * linked_symbol;
		} nd_obj;
	} 

%{
int add_with_value(char c, char* type, char* id, struct symbol_var variable);
int add(char c, char* type, char* id);
int search(char *, char);
const char* get_type(char *);
%}

%token<nd_obj> CONST ID TIP BGIN END ASSIGN NR NR_F END_CLASS START_FUNCTION END_FUNCTION COMPARATORS START_IF START_WHILE START_FOR START_CLASS START_PROGRAM END_PROGRAM END_IF END_FOR END_WHILE TYPEOF
%type<nd_obj> expression_element expression function_call variable multiple_values vectorizable_value
%left '+'
%left '*'
%left '-'
%left '/'

%start progr



%%
progr: program_structure { if(has_semantic_analysis_errors) { printf("Eroare de compilare...\n"); } else { printf("Program corect sintactic\n"); } }
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
                                    add_with_value('V', $1.str_val, $2.str_val, $5);
                              } else { 
                                    has_semantic_analysis_errors = 1; 
                                    printf("Initialization not valid on line %d with type %s\n", yylineno, $1.str_val);
                              }
                        } else {
                              add_with_value('V', $1.str_val, $2.str_val, $5);
                        }
                     } 
                    |
                    ;

multiple_values : vectorizable_value {$$=$1; }
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
                    | START_FUNCTION TIP ID '(' lista_param ')' ':'execution_block_logic END_FUNCTION { add('F', $2.str_val, $3.str_val); }
                    |START_FUNCTION TIP ID '(' ')' ':' END_FUNCTION { add('F', $2.str_val, $3.str_val); }
                    | START_FUNCTION TIP ID '(' lista_param ')' ':' END_FUNCTION { add('F', $2.str_val, $3.str_val); }
                    ;

lista_param : param
            | lista_param ','  param 
            ;
            
param : TIP ID
      ; 

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

function_call : variable '(' ')' { if(search($1.str_val, 'F') != -1) { has_semantic_analysis_errors = 1; printf("Function undefined on line %d\n", yylineno); } }
               | variable '(' lista_apel ')'
               | TYPEOF '(' ID ')' { printf("TypeOf(%s) = %s\n", $3.str_val, get_type($3.str_val)); }
               | TYPEOF '(' expression ')' { printf("Called typeof on expression\n"); }
               ;

lista_apel : expression_element 
           | lista_apel ',' expression_element
           ;

assign_statement : variable ASSIGN expression ';'
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
          | expression_element '+' expression_element {$$.num_val=$1.num_val+$3.num_val;  }
          | expression_element '-' expression_element {$$.num_val=$1.num_val-$3.num_val;  }
          | expression_element '*' expression_element {$$.num_val=$1.num_val*$3.num_val;  }
          | expression_element '/' expression_element {$$.num_val=$1.num_val/$3.num_val;  }
          | '(' expression ')' '+' '(' expression ')' {$$.num_val=$2.num_val+$6.num_val;  }
          | '(' expression ')' '-' '(' expression ')' {$$.num_val=$2.num_val-$6.num_val;  }
          | '(' expression ')' '*' '(' expression ')' {$$.num_val=$2.num_val*$6.num_val;  }
          | '(' expression ')' '/' '(' expression ')' {$$.num_val=$2.num_val/$6.num_val;  }
          | '(' expression ')' '+' expression_element {$$.num_val=$2.num_val+$5.num_val;  }
          | '(' expression ')' '-' expression_element {$$.num_val=$2.num_val-$5.num_val;  }
          | '(' expression ')' '*' expression_element {$$.num_val=$2.num_val*$5.num_val;  }
          | '(' expression ')' '/' expression_element {$$.num_val=$2.num_val/$5.num_val;  }
          | expression_element '+' '(' expression ')' {$$.num_val=$1.num_val+$4.num_val;  }
          | expression_element '-' '(' expression ')' {$$.num_val=$1.num_val-$4.num_val;  }
          | expression_element '*' '(' expression ')' {$$.num_val=$1.num_val*$4.num_val;  }
          | expression_element '/' '(' expression ')' {$$.num_val=$1.num_val/$4.num_val;  }
          | expression '+' expression {$$.num_val=$1.num_val+$3.num_val;  }
          | expression '-' expression {$$.num_val=$1.num_val-$3.num_val;  }
          | expression '*' expression {$$.num_val=$1.num_val*$3.num_val;  }
          | expression '/' expression {$$.num_val=$1.num_val/$3.num_val;  }
          | '(' expression ')' {$$.num_val=$2.num_val;}
          ;

expression_element : variable
                    | NR { $$=$1; }
                    | NR_F { $$ = $1; }
                    | function_call
                    ;

variable: ID |
          ID '.' ID;

/* end expression */

/* -------------------------------- */

%%
int yyerror(char * s){
printf("eroare: %s la linia:%d\n",s,yylineno);
}

int main(int argc, char** argv){
      yyin=fopen(argv[1],"r");
      yyparse();
      printf("\n\n");
	printf("PHASE 1: SYMBOL TABLE \n\n");
	printf("\nSYMBOL   DATATYPE   TYPE   LINE NUMBER VALUE \n");
	printf("____________________________________________\n\n");
	int i=0;
	for(i=0; i<count; i++) {
            if(symbol_table[i].value)
            {
                  if(strcmp(symbol_table[i].data_type, "int") == 0)
                  {
                        printf("%s\t%s\t%s\t%d\t%d\t\n", symbol_table[i].id_name, symbol_table[i].data_type, symbol_table[i].type, symbol_table[i].line_no, symbol_table[i].value);
                  }
                  else if(strcmp(symbol_table[i].data_type, "char") == 0)
                  {
                        printf("%s\t%s\t%s\t%d\t%c\t\n", symbol_table[i].id_name, symbol_table[i].data_type, symbol_table[i].type, symbol_table[i].line_no, symbol_table[i].value);
                  }
                  else if(strcmp(symbol_table[i].data_type, "float") == 0)
                  {
                        printf("%s\t%s\t%s\t%d\t%s\t\n", symbol_table[i].id_name, symbol_table[i].data_type, symbol_table[i].type, symbol_table[i].line_no, symbol_table[i].value);
                  }
                  else if(strcmp(symbol_table[i].data_type, "char[]") == 0 || strcmp(symbol_table[i].data_type, "bool[]") == 0)
                  {
                        printf("%s\t%s\t%s\t%d\t%s\t\n", symbol_table[i].id_name, symbol_table[i].data_type, symbol_table[i].type, symbol_table[i].line_no, symbol_table[i].value);
                  }
                  else if(strcmp(symbol_table[i].data_type, "int[]") == 0 || strcmp(symbol_table[i].data_type, "float[]") == 0)
                  {
                        printf("%s\t%s\t%s\t%d\t%s\t\n", symbol_table[i].id_name, symbol_table[i].data_type, symbol_table[i].type, symbol_table[i].line_no, symbol_table[i].value);
                  }
                  else if(strcmp(symbol_table[i].data_type, "bool") == 0)
                  {
                        printf("%s\t%s\t%s\t%d\t%s\t\n", symbol_table[i].id_name, symbol_table[i].data_type, symbol_table[i].type, symbol_table[i].line_no, symbol_table[i].value);
                  }
                  else{
                        printf("%s\t%s\t%s\t%d\t%s\t\n", symbol_table[i].id_name, symbol_table[i].data_type, symbol_table[i].type, symbol_table[i].line_no, "TYPE NOT SUPPORTED");
                  }
            }
            else{
                  printf("%s\t%s\t%s\t%d\t%s\t\n", symbol_table[i].id_name, symbol_table[i].data_type, symbol_table[i].type, symbol_table[i].line_no, "-");
            }
	}
	for(i=0;i<count;i++) {
		free(symbol_table[i].id_name);
		free(symbol_table[i].type);
	}
	printf("\n\n");
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

const char* get_type(char *type) {
	int i;
	for(i=count-1; i>=0; i--) {
		if(strcmp(symbol_table[i].id_name, type)==0) {
                  return symbol_table[i].data_type;
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
			count++;
		}
	}
      else {
            printf("Symbol %s on line %d is already defined\n",id, yylineno);
            has_semantic_analysis_errors = 1;
      }
}

int add_with_value(char c, char* type, char* id, struct symbol_var variable) {
      int was_created = add(c, type, id);
      if(was_created)
      {
            if(strcmp(type, "int") == 0)
            {
                  symbol_table[count-1].value = variable.num_val;
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