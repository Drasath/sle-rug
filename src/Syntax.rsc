module Syntax

extend lang::std::Layout;
extend lang::std::Id;

/*
 * Concrete syntax of QL
 */
keyword Keywords = "true" | "false";

start syntax Form = @Foldable "form" Id name Block block;

syntax Block = "{" Statement* statements "}"; 
syntax Statement = Question question | ComputedQuestion question| IfThen | IfThenElse;
syntax Question = Str Id variable ":" Type type;
syntax ComputedQuestion = Str Id variable ":" Type type "=" Expr computation;
//  | "{" Question* questions "}" // allow blocks?
syntax IfThen = "if" "(" Expr ")" Block;
syntax IfThenElse = "if" "(" Expr ")" Block "else" Block;

syntax Expr 
  = Id \ Keywords
  | Int
  | Str
  | Bool
  | "(" Expr ")"
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
