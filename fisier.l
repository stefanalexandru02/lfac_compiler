%{
#include <stdio.h>
#include "y.tab.h"
%}
%option noyywrap
%%
"int"|"float"|"char"|"string"|"bool"|"int[]"|"float[]"|"char[]"|"string[]"|"bool[]" {return TIP;}
"begin" {return BGIN;}
"end" {return END;}
"start_program" { return START_PROGRAM;}
"end_program" { return END_PROGRAM;}
"endclass" {return END_CLASS;}
"if" { return IF_STATEMENT; }
"while" { return WHILE_STATEMENT; }
"for" { return FOR_STATEMENT; }
"endfunction" {return END_FUNCTION;}
"function" {return START_FUNCTION;}
"class" {return START_CLASS; }
[_a-zA-Z][_a-zA-Z0-9]* {return ID;}
"=" {return ASSIGN;}
"<"|"<="|"=="|">"|">="|"!=" { return OPERATORS; }
[0-9]+ {return NR;}
[ \t] ;
\n {yylineno++;}
. {return yytext[0];}

 