%code requires{
    #include "ast.h"
}

%{
    #include "ast.h"
    #include <cstdio>
    #include <string>
    #include <iostream>
    using namespace std;
    int yylex();
    extern char *yytext;
    extern int yylineno;
    void yyerror(const char * s){
        fprintf(stderr, "Line: %d, error: %s: %s\n", yylineno, s, yytext);
    }

    #define YYERROR_VERBOSE 1
%}

%union{
  float float_t;
  char *id;
  Expr *expr_t;
  Statement *statement_t;
  list<Statement *> *statement_list;
  list<Expr *> *argument_list;
  list<string> *parameter_list;
  Method *method_t;
  Assign *ass_t;
}

%token<float_t> FLOAT_LIT
%token<id> ID
%token EOL
%token ADD SUB MUL DIV IF THEN ENDIF WHILE DO DONE ELSE LET

%type<expr_t> expr factor term relational_expr while_expr
%type<statement_t>  statement while_statement 
%type<statement_list> statements
%type<argument_list> argument_list
%type<parameter_list> params
%type<method_t> method_definition method_call
%type<ass_t> assign_stmt

%%
start: start declaration EOL
     | start expr EOL { printf("%f\n", $2->evaluate()); }
     | start method_call EOL
     | start while_statement EOL { $2->evaluate(); }
     | start EOL
     | 
     ;

while_statement: WHILE '(' while_expr ')' DO statements DONE {
                  $$ = new While(); ((While *)$$)->expr = $3; ((While *)$$)->statements = $6; 
               }
               ;

while_expr: relational_expr
          | expr

relational_expr: expr '<' expr { $$ = new BinaryExpr(); auto bin = (BinaryExpr *)$$; bin->left = $1; bin->op = '<'; bin->right = $3; }
               | expr '>' expr { $$ = new BinaryExpr(); auto bin = (BinaryExpr *)$$; bin->left = $1; bin->op = '>'; bin->right = $3; }

declaration: method_definition
           | variable_definition
           ;

statement: expr { $$ = (Statement *)$1; }
         | method_call { $$ = (Statement *)$1; }
         | while_statement { $$ = (Statement *)$1; }
         | assign_stmt { $$ = (Statement *) $1; }
         ; 

assign_stmt: ID '=' expr {
             auto ass = new Assign();
             ((Assign *) ass)->id = $1;
             ((Assign *) ass)->expr = $3;
             $$ = ass;
           }

statements: statement {  $$ = new list<Statement *>(); $$->push_back($1); }
          | statements ';' statement { $$ = $1; $$->push_back($3); }
          | statements ';' { $$ = $1; }
          ;

argument_list: expr { $$ = new list<Expr *>(); $$->push_back($1); }
             | argument_list ',' expr { $$ = $1; $$->push_back($3); }
             ;

variable_definition: LET ID '=' expr {
                    auto var = new VarExpr();
                    var->id = $2;
                    var->value = $4->evaluate();
                    var->evaluate_semantic();
                   }
                   ;

method_call: ID '(' argument_list ')' { 
             auto t = new test();
             $$ = t->MethodEvaluate($1, $3);
           }
           ;

method_definition: LET ID '(' params ')' '=' statements {
                   $$ = new Method($2, $7, $4); 
                   $$->evaluate_semantic();
                 }
                 ;

params: ID { $$ = new list<string>(); $$->push_back($1); }
      | params ',' ID { $$ = $1; $$->push_back($3); }
      ;

expr: factor 
    | factor ADD expr { $$ = new BinaryExpr(); auto bin = (BinaryExpr *)$$; bin->left = $1; bin->op = '+'; bin->right = $3; }
    | factor SUB expr { $$ = new BinaryExpr(); auto bin = (BinaryExpr *)$$; bin->left = $1; bin->op = '-'; bin->right = $3; }
    ;

factor: term
      | term MUL factor { $$ = new BinaryExpr(); auto bin = (BinaryExpr *)$$; bin->left = $1; bin->op = '*'; bin->right = $3; }
      | term DIV factor { $$ = new BinaryExpr(); auto bin = (BinaryExpr *)$$; bin->left = $1; bin->op = '/'; bin->right = $3; }
      ;

term: FLOAT_LIT  { $$ = new NumExpr(); ((NumExpr *)$$)->number = $1; }
    | ID { 
      auto var_expr = new VarExpr();
      var_expr->id = $1;
      $$ = var_expr;
    }
    ;

%%

