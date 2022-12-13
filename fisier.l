%{
#include <stdio.h>
#include <string.h>
#include "y.tab.h"
%}
%option noyywrap
%%
"int"|"float"|"char"|"string"|"bool"|"int[]"|"float[]"|"char[]"|"string[]"|"bool[]" { yylval.nd_obj.str_val = strdup(yytext); return TIP; }
"const" {return CONST;}

"begin" {yylval.nd_obj.str_val = strdup(yytext);return BGIN;}
"end" {yylval.nd_obj.str_val = strdup(yytext);return END;}

"start_program" { yylval.nd_obj.str_val = strdup(yytext); return START_PROGRAM;}
"end_program" {yylval.nd_obj.str_val = strdup(yytext); return END_PROGRAM;}

"function" { yylval.nd_obj.str_val = strdup(yytext); return START_FUNCTION;}
"end_function" { yylval.nd_obj.str_val = strdup(yytext); return END_FUNCTION;}

"class" {return START_CLASS; }
"end_class" {return END_CLASS;}

[_a-zA-Z][_a-zA-Z0-9]* { yylval.nd_obj.str_val = strdup(yytext); return ID;}
[0-9]+ {yylval.nd_obj.num_val=atoi(yytext); return NR;}

"if(" { yylval.nd_obj.str_val = strdup(yytext); return START_IF; }
"}end_if" {yylval.nd_obj.str_val = strdup(yytext); return END_IF; }
"while(" {yylval.nd_obj.str_val = strdup(yytext); return START_WHILE; }
"}end_while" {yylval.nd_obj.str_val = strdup(yytext); return END_WHILE; }
"for(" {yylval.nd_obj.str_val = strdup(yytext); return START_FOR; }
"}end_for" {yylval.nd_obj.str_val = strdup(yytext); return END_FOR; }

"=" { return ASSIGN;}
"<"|"<="|"=="|">"|">="|"!=" { return COMPARATORS; }
[ \t] ;
\n {yylineno++;}
. { return yytext[0];}
 