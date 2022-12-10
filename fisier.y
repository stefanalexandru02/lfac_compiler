%{
#include <stdio.h>
extern FILE* yyin;
extern char* yytext;
extern int yylineno;
%}
%token ID TIP BGIN END ASSIGN NR CLASS_DEFINE END_CLASS FUNCTION_DEFINE END_FUNCTION OPERATORS IF_STATEMENT WHILE_STATEMENT FOR_STATEMENT
%start progr
%%
progr: declaratii bloc {printf("program corect sintactic\n");}
     ;

declaratii :  declaratie ';'
	   | declaratii declaratie ';'
        | clasa ';'
        | declaratii clasa ';'
        | clasa declaratii ';'
        | functie ';'
        | declaratii functie ';'
        | functie declaratii ';'
	   ;
declaratii_clasa_intern :  declaratie ';'
                        | declaratii_clasa_intern declaratie ';'
                        | functie ';'
                        | declaratii functie ';'
                        | functie declaratii ';'
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
           | CLASS_DEFINE ID 
           | CLASS_DEFINE ID '(' lista_param ')'
           | CLASS_DEFINE ID '(' ')'
           | CLASS_DEFINE multiple_ids
           ;
multiple_ids : ID 
             | ID ',' multiple_ids 
             ;

lista_param : param
            | lista_param ','  param 
            ;
            
param : TIP ID
      ; 


functie : FUNCTION_DEFINE '(' ')' declaratii_functie_intern END_FUNCTION
        | FUNCTION_DEFINE '(' lista_param ')' declaratii_functie_intern END_FUNCTION
        ;

clasa : CLASS_DEFINE declaratii_clasa_intern END_CLASS
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