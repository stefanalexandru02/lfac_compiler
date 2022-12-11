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
"if" { return IF_STATEMENT; }
"while" { return WHILE_STATEMENT; }
"for" { return FOR_STATEMENT; }
"endfunction" {return END_FUNCTION;}
"function" {return START_FUNCTION;}
[_a-zA-Z][_a-zA-Z0-9]* {return ID;}
#[_a-zA-Z][_a-zA-Z0-9]* {return CLASS_DEFINE;}
"=" {return ASSIGN;}
"<"|"<="|"=="|">"|">="|"!=" { return OPERATORS; }
[0-9]+ {return NR;}
[ \t] ;
\n {yylineno++;}
. {return yytext[0];}

 