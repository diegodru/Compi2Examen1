#include "ast.h"
#include <iostream>

extern int yylineno;

typedef list<Statement *> StatementList;

void VarExpr::evaluate_semantic(){
  if(variables.find(id) != variables.end()){
    fprintf(stderr, "Ya se ha declarado la variable con id %s\n", id.c_str());
    exit(1);
  }
  variables.emplace(id, value);
  printf("Variable %s declarada\n", id.c_str());
}

void Method::evaluate_semantic(){
  if(methods.find(id) != methods.end()){
    fprintf(stderr, "Ya se ha declarado el metodo con id %s\n", id.c_str());
    exit(1);
  }
  list<string>::iterator it = params->begin();
  while(it != params->end()){
    if(variables.find(*it) != variables.end()){
      fprintf(stderr, "Ya se ha declarado la variable con id %s\n", (*it).c_str());
      exit(1);
    }
    variables.emplace(*it, 0);
    it++;
  }
  methods.emplace(id, this);
  printf("Metodo %s delcarado\n", id.c_str());
}

float Method::evaluate() const{
  if(params->size() != arguments->size()){
    fprintf(stderr, "Line %i, Error: se esperaban %lu argumentos peros solo se encontraron %lu en el metodo %s\n", yylineno, params->size(), arguments->size(), id.c_str());
    exit(1);
  }
  list<Statement *>::iterator it = statements->begin();
  list<string>::iterator param_it = params->begin();
  list<Expr *>::iterator arg_it = arguments->begin();
  while(param_it != params->end()){
    variables[*param_it] = (*arg_it)->evaluate();
    param_it++;
    arg_it++;
  }
  while(it != statements->end()){
    printf("%f\n", (*it)->evaluate());
    it++;
  }
  return 0;
}

float BinaryExpr::evaluate() const{
  float result = 0;
  switch(op){
    case '+':
      result = left->evaluate() + right->evaluate();
      break;
    case '-':
      result = left->evaluate() - right->evaluate();
      break;
    case '*':
      result = left->evaluate() * right->evaluate();
      break;
    case '/':
      result = left->evaluate() / right->evaluate();
      break;
    case '<':
      result = left->evaluate() < right->evaluate();
      break;
    case '>':
      result = left->evaluate() > right->evaluate();
      break;
  }
  return result;
}
float While::evaluate() const{
  while((int)expr->evaluate()){
    list<Statement *>::iterator it = statements->begin();
    while(it != statements->end()){
      (*it)->evaluate();
      it++;
    }
  }
  return 0;
}

float Assign::evaluate() const{
  printf("%s = %f\n", id.c_str(), expr->evaluate());
  variables.at(id) = expr->evaluate();
  return expr->evaluate();

}

float NumExpr::evaluate() const{
  return number;
}

float VarExpr::evaluate() const{
  auto var = variables.find(id);
  if(var == variables.end()){
    fprintf(stderr, "No se ha declarado la variable con id %s\n", id.c_str());
    exit(1);
  }
  return var->second;
}

Method *test::MethodEvaluate(string id, list<Expr *> *arglist){
  //std::cout << methods.find("f")->second << '\n';
  methods.find(id)->second->arguments = arglist;
  methods.find(id)->second->evaluate();
  return methods.find(id)->second;
}
