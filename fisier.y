%{
#include <stdio.h>
extern FILE* yyin;
extern char* yytext;
extern int yylineno;
%}
%token ID TIP BGIN END ASSIGN NR CLASS_DEFINE END_CLASS
%start progr
%%
progr: declaratii bloc {printf("program corect sintactic\n");}
     ;

declaratii :  declaratie ';'
	   | declaratii declaratie ';'
        | clasa ';'
        | declaratii clasa ';'
        | clasa declaratii ';'
	   ;
mini_declaratii :  declaratie ';'
	   | mini_declaratii declaratie ';'
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


clasa : CLASS_DEFINE mini_declaratii END_CLASS
      ;

/* bloc */
bloc : BGIN list END  
     ;
     
/* lista instructiuni */
list :  statement ';' 
     | list statement ';'
     ;

/* instructiune */
statement: ID ASSIGN ID
         | ID ASSIGN NR  		 
         | ID '(' lista_apel ')'
         | ID'.'ID ASSIGN ID
         | ID'.'ID ASSIGN NR  		 
         | ID'.'ID '(' lista_apel ')'
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