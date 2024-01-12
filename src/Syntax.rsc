module Syntax

extend lang::std::Layout;
extend lang::std::Id;

/*
 * Concrete syntax of QL
 */
keyword Keywords = "true" | "false";

start syntax Form = "form" Id name Block;

syntax Block = "{" Statement* statements "}"; 
syntax Statement = Question | ComputedQuestion | IfThen | IfThenElse;
syntax Question = Str Id ":" Type;
syntax ComputedQuestion = Str Id ":" Type "=" Expr;
//  | "{" Question* questions "}" // ?
syntax IfThen = "if" "(" Expr ")" Block;
syntax IfThenElse = "if" "(" Expr ")" Block "else" Block;

syntax Expr 
  = Id \ Keywords
  | Int
  | Str
  | Bool
  | left ( "+" Expr // TODO: Fix ambiguity with Id
         | "-" Expr // TODO: Fix ambiguity with Id
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
  ;
  
syntax Type = "boolean" | "integer";

lexical Str = [\"] ![\"]* [\"]; 

lexical Int = "-"? [0-9]*; // TODO: Fix ambiguity "-" with Id

lexical Bool = "true" | "false";
