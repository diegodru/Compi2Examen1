#ifndef _AST_H_
#define _AST_H_

#include <list>
#include <string>
#include <map>
#include <stdlib.h>

using namespace std;

class Statement{
  public:
    virtual float evaluate() const = 0;
};

class Expr: public Statement{
  public:
    virtual float evaluate() const = 0;
};

class BinaryExpr: public Expr{
  public:
    float evaluate() const override;
    char op;
    Expr *left, *right;
};

class NumExpr: public Expr{
  public:
    float evaluate() const override;
    float number;
};

class VarExpr: public Expr{
  public:
    float evaluate() const override;
    void evaluate_semantic();
    string id;
    float value;
};

class Method: public Statement{
  public:
    Method(string id, list<Statement *> *statements, list<string> *params){
      this->id = id;
      this->statements = statements;
      this->params = params;
    }
    string id;
    float evaluate() const override;
    void evaluate_semantic();
    list<Statement *> *statements;
    list<string> *params;
    list<Expr *> *arguments;
};

class While: public Statement{
  public:
    float evaluate() const override;
    list<Statement *> *statements;
    Expr *expr;
};

class Assign: public Statement{
  public:
    float evaluate() const override;
    string id;
    Expr *expr;
};

static map<string, float> variables = map<string, float>();
static map<string, Method *> methods = map<string, Method *>();

class test{
  public:
    static Method *MethodEvaluate(string id, list<Expr *> *arglist);
    static void UpdateVar(string id, Expr *expr);
};

#endif
