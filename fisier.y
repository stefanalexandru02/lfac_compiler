%{
#include <stdio.h>
extern FILE* yyin;
extern char* yytext;
extern int yylineno;
%}
%token CONST ID TIP BGIN END ASSIGN NR END_CLASS START_FUNCTION END_FUNCTION COMPARATORS START_IF START_WHILE START_FOR START_CLASS START_PROGRAM END_PROGRAM END_IF END_FOR END_WHILE
%left '+'
%left '*'
%left '-'
%left '/'

%start progr



%%
progr: program_structure {printf("program corect sintactic\n");}
     ;

program_structure : declaratii_globale declaratii_functii declaratii_clase program
                    ;

/* -------------------------------- */

/* global variables */

declaratii_globale : declaratie_globala ';'
                    | declaratii_globale declaratie_globala ';'
                    |
                    ;
declaratie_globala : TIP ID
                    | ID ID  /* valideaza prin tabela de simboluri pentru tipuri de date custom */
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

declaratie_functie : START_FUNCTION TIP ID '(' ')' ':' END_FUNCTION
                    | START_FUNCTION TIP ID '(' lista_param ')' ':' END_FUNCTION
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

function_call : variable '(' ')'
               | variable '(' lista_apel ')'
               ;

lista_apel : expression_element
           | lista_apel ',' expression_element
           ;

assign_statement : variable ASSIGN expression ';' {printf("%d \n", $3);}
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
          | expression_element '+' expression_element {$$=$1+$3;  }
          | expression_element '-' expression_element {$$=$1-$3;  }
          | expression_element '*' expression_element {$$=$1*$3;  }
          | expression_element '/' expression_element {$$=$1/$3;  }
          | '(' expression ')' '+' '(' expression ')' {$$=$2+$6;  }
          | '(' expression ')' '-' '(' expression ')' {$$=$2-$6;  }
          | '(' expression ')' '*' '(' expression ')' {$$=$2*$6;  }
          | '(' expression ')' '/' '(' expression ')' {$$=$2/$6;  }
          | '(' expression ')' '+' expression_element {$$=$2+$5;  }
          | '(' expression ')' '-' expression_element {$$=$2-$5;  }
          | '(' expression ')' '*' expression_element {$$=$2*$5;  }
          | '(' expression ')' '/' expression_element {$$=$2/$5;  }
          | expression_element '+' '(' expression ')' {$$=$1+$4;  }
          | expression_element '-' '(' expression ')' {$$=$1-$4;  }
          | expression_element '*' '(' expression ')' {$$=$1*$4;  }
          | expression_element '/' '(' expression ')' {$$=$1/$4;  }
          | expression '+' expression {$$=$1+$3;  }
          | expression '-' expression {$$=$1-$3;  }
          | expression '*' expression {$$=$1*$3;  }
          | expression '/' expression {$$=$1/$3;  }
          | '(' expression ')' {$$=$2;}
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
} 