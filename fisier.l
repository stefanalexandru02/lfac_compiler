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

"function" {return START_FUNCTION;}
"end_function" {return END_FUNCTION;}

"class" {return START_CLASS; }
"end_class" {return END_CLASS;}

[_a-zA-Z][_a-zA-Z0-9]* {return ID;}
[0-9]+ {return NR;}

"if(" { return START_IF; }
"}end_if" {return END_IF; }
"while(" { return START_WHILE; }
"}end_while" {return END_WHILE; }
"for(" { return START_FOR; }
"}end_for" {return END_FOR; }

"=" {return ASSIGN;}
"<"|"<="|"=="|">"|">="|"!=" { return COMPARATORS; }
[ \t] ;
\n {yylineno++;}
. {return yytext[0];}

 