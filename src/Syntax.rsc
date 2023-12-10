module Syntax

extend lang::std::Layout;
extend lang::std::Id;

/*
 * Concrete syntax of QL
 */

start syntax Form 
  = "form" Id name "{" Question* questions "}"; 

// TODO: question, computed question, block, if-then-else, if-then
syntax Question
  = Str Id ":" Type
  | Str Id ":" Type "=" Expr
  | "{" Question* questions "}" // ?
  | "if" "(" Id ")" "{" Question* questions "}"
  | "if" "(" Id ")" "{" Question* questions "}" "else" "{" Question* questions "}"
  ;

// TODO: +, -, *, /, &&, ||, !, >, <, <=, >=, ==, !=, literals (bool, int, str)
// Think about disambiguation using priorities and associativity
// and use C/Java style precedence rules (look it up on the internet)
keyword Keywords = "true" | "false";

syntax Expr 
  = Id \ Keywords
  | left ( "+" Expr
         | "-" Expr 
         )
  | right "!" Expr
  > left ( Expr "*" Expr
         | Expr "/" Expr
         )
  > left ( Expr "+" Expr
         | Expr "-" Expr
         )
  > left ( Expr "\<" Expr
         | Expr "\<=" Expr
         | Expr "\>" Expr
         | Expr "\>=" Expr
         )
  > left ( Expr "==" Expr
         | Expr "!=" Expr
         )
  > left Expr "&&" Expr
  > left Expr "||" Expr
  ; // TODO: literals
  
syntax Type = "boolean" | "integer";

lexical Str = [\"] ![\"]* [\"]; // slightly simplified

lexical Int = "-"? [0-9]*;

lexical Bool = "true" | "false";
