%{
#include <stdio.h>
extern FILE* yyin;
extern char* yytext;
extern int yylineno;
%}
%token ID TIP BGIN END ASSIGN NR END_CLASS START_FUNCTION END_FUNCTION OPERATORS IF_STATEMENT WHILE_STATEMENT FOR_STATEMENT START_CLASS START_PROGRAM END_PROGRAM
%start progr
%%
progr: program_structure {printf("program corect sintactic\n");}
     ;

program_structure : declaratii_globale declaratii_functii declaratii_clase program
                    | declaratii_globale declaratii_clase program
                    | declaratii_globale declaratii_functii program
                    | declaratii_functii declaratii_clase program
                    | declaratii_clase program
                    | declaratii_globale program
                    | declaratii_functii program
                    | program
                    ;

/* -------------------------------- */

/* global variables */

declaratii_globale : declaratie_globala ';'
                    | declaratii_globale declaratie_globala ';'
                    ;
declaratie_globala : TIP ID
                    | TIP multiple_ids
                    ;
multiple_ids : ID 
             | ID ',' multiple_ids 
             ;

/* end global variables */

/* -------------------------------- */

/* functions declaration */

declaratii_functii : declaratie_functie
                    | declaratii_functii declaratie_functie
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
                    | declaratii_clase declaratie_clasa;

declaratie_clasa : START_CLASS ID ':' declaratii_globale declaratii_functii END_CLASS
               | START_CLASS ID ':' declaratii_globale END_CLASS
               | START_CLASS ID ':' declaratii_functii END_CLASS
               ;

/* end custom data types declaration */

/* -------------------------------- */

/* main */

program: START_PROGRAM END_PROGRAM

/* end main */

/* -------------------------------- */


declaratii :  declaratie ';'
	   | declaratii declaratie ';'
	   ;
declaratii_clasa_intern :  declaratie ';'
                        | declaratii_clasa_intern declaratie ';'
                        ;        
declaratii_functie_intern :  declaratie ';'
	                     | declaratii_functie_intern declaratie ';'
                          | list ';'
                          | declaratii_functie_intern list;
                          ;
declaratie : TIP ID 
           | TIP ID '(' lista_param ')'
           | TIP ID '(' ')'
           | TIP multiple_ids
           ;

/* bloc */
bloc : BGIN list END  
     ;
     
/* lista instructiuni */
list :  statement ';' 
     | list statement ';'
     ;

/* instructiune */
statement: assign_statement		 
         | ID '(' lista_apel ')'
         | ID'.'ID ASSIGN ID
         | ID'.'ID ASSIGN NR  		 
         | ID'.'ID '(' lista_apel ')'
         | ID'.'ID '(' ')'
         | if_statement
         | while_statement
         | for_statement
         ;
        
assign_statement : ID ASSIGN ID
                 | ID ASSIGN NR  

if_statement : IF_STATEMENT boolean_expression ':' list END
             ;
while_statement : WHILE_STATEMENT boolean_expression ':' list END
                ;
for_statement : FOR_STATEMENT assign_statement ';' boolean_expression ';' assign_statement ':' list END
              ;

boolean_expression : ID OPERATORS ID
                   | NR OPERATORS ID
                   | ID OPERATORS NR
                   | NR OPERATORS NR
                   ;

lista_apel : NR
           | lista_apel ',' NR
           ;
%%
int yyerror(char * s){
printf("eroare: %s la linia:%d\n",s,yylineno);
}

int main(int argc, char** argv){
yyin=fopen(argv[1],"r");
yyparse();
} 