%option noyywrap
%option yylineno

%{
    #include "tokens.h"
    #include "stdlib.h"
    #include "string.h"
    #include "stdio.h"
%}

%option noyywrap
%option yylineno

%%
"-"?[0-9]+("."[0-9]+)? { yylval.float_t = atof(yytext); return FLOAT_LIT; }
"+" { return ADD; }
"=" { return '='; }
"-" { return SUB; }
"*" { return MUL; }
"/" { return DIV; }
"(" { return '('; }
")" { return ')'; }
"," { return ','; }
";" { return ';'; }
">" { return '>'; }
"<" { return '<'; }
"let" { return LET; }
"while" { return WHILE; }
"do" { return DO; }
"done" { return DONE; }
[\n] { return EOL; }
[ \t\r] { /* ignorar */ }
[A-Za-z][A-Za-z0-9_]* { yylval.id = strdup(yytext); return ID; }
. { printf("Line: %i, invalido %s\n", yylineno, yytext); }
%%
