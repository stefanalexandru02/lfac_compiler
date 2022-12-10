%{
#include <stdio.h>
#include "y.tab.h"
%}
%option noyywrap
%%
"int"|"float"|"char"|"string"|"bool"|"int[]"|"float[]"|"char[]"|"string[]"|"bool[]" {return TIP;}
"begin" {return BGIN;}
"end" {return END;}
"endclass" {return END_CLASS;}
"endfunction" {return END_FUNCTION;}
$[_a-zA-Z][_a-zA-Z0-9]* {return FUNCTION_DEFINE;}
[_a-zA-Z][_a-zA-Z0-9]* {return ID;}
#[_a-zA-Z][_a-zA-Z0-9]* {return CLASS_DEFINE;}
"=" {return ASSIGN;}
[0-9]+ {return NR;}
[ \t] ;
\n {yylineno++;}
. {return yytext[0];}

 