module Syntax

extend lang::std::Layout;
extend lang::std::Id;

/*
 * Concrete syntax of QL
 */

keyword Keywords
  = "true" | "false";

start syntax Form
  = @Foldable "form" Id name Block block;

syntax Block
  = "{" Statement* statements "}"; 

syntax Statement
  = Question question
  | ComputedQuestion computedQuestion
  | IfThen ifThen
  | IfThenElse ifThenElse
  | Block block
  ;

syntax Question
  = Str label Id variable ":" Type type;

syntax ComputedQuestion
  = Str label Id variable ":" Type type "=" Expr expression;

syntax IfThen
  = @Foldable "if" "(" Expr condition ")" Block thenBlock;

syntax IfThenElse
  = @Foldable "if" "(" Expr condition ")" Block thenBlock "else" Block elseBlock;

// TODO: Do not allow empty expressions
syntax Expr 
  = Id \ Keywords
  | Int
  | Str
  | Bool
  | "(" Expr ")"
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
  
syntax Type
  = "boolean" | "integer";

// TODO: allow use of \" in strings
lexical Str
  = [\"] ![\"]* [\"];

// TODO: allow -Int
lexical Int
  = [\-]? [0-9]+ !>> [0-9];

lexical Bool
  = "true" | "false";
