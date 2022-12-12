%{
#include<stdio.h>
#include<string.h>
#include<stdlib.h>
#include<ctype.h>
extern FILE* yyin;
extern char* yytext;
extern int yylineno;

void add(char c, char* type, char* id);
int search(char *, char);

struct dataType {
        char * id_name;
        char * data_type;
        char * type;
        int line_no;
} symbol_table[4000];

int count=0;
int q;
char type[10];

int has_semantic_analysis_errors = 0;

%}
%union { struct var_name { 
			char *str_val; 
                  int num_val;
		} nd_obj;
	} 

%token<nd_obj> CONST ID TIP BGIN END ASSIGN NR END_CLASS START_FUNCTION END_FUNCTION COMPARATORS START_IF START_WHILE START_FOR START_CLASS START_PROGRAM END_PROGRAM END_IF END_FOR END_WHILE
%type<nd_obj> expression_element expression function_call variable
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
                    | TIP multiple_ids
                    | 
                    ;
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

declaratie_functie : START_FUNCTION TIP ID '(' ')' ':' END_FUNCTION { add('F', $2.str_val, $3.str_val); }
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

expression : expression_element {$$.num_val=$1.num_val;}
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
                    | NR {$$=$1; }
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
	printf("\nSYMBOL   DATATYPE   TYPE   LINE NUMBER \n");
	printf("_______________________________________\n\n");
	int i=0;
	for(i=0; i<count; i++) {
		printf("%s\t%s\t%s\t%d\t\n", symbol_table[i].id_name, symbol_table[i].data_type, symbol_table[i].type, symbol_table[i].line_no);
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

void add(char c, char* type, char* id) {
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
			symbol_table[count].data_type=strdup("CONST");
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
}