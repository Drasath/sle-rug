module Check

import AST;
import Resolve;
import Message; // see standard library

data Type
  = tint()
  | tbool()
  | tstr()
  | tunknown()
  ;

// the type environment consisting of defined questions in the form 
alias TEnv = rel[loc def, str name, str label, Type \type];

// To avoid recursively traversing the form, use the `visit` construct
// or deep match (e.g., `for (/question(...) := f) {...}` ) 
TEnv collect(AForm f) {
  TEnv tenv = {};
  for (/question(AId x, str label, AType t) := f) {
    tenv += { <x.src, x.name, label, tint()> };
  }

  return tenv; 
}

set[Message] check(AForm f, TEnv tenv, UseDef useDef) {
  // set[Message] msgs = { m | /AQuestion q <- f, m <- check(q, tenv, useDef) };
  // msgs += { m | /AComputedQuestion cq <- f, m <- check(cq, tenv, useDef) };
  return { error("Bla bla bal", f.src) };
}

// - produce an error if there are declared questions with the same name but different types.
// - duplicate labels should trigger a warning 
// - the declared type computed questions should match the type of the expression.
set[Message] check(AQuestion q1, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};

  // check for duplicate labels
  msgs += { error("Duplicate label <q1.label>", q1.src) };

  return msgs; 
}

set[Message] check(AComputedQuestion q1, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};

  // check for duplicate labels
  msgs += { error("Duplicate label <q1.label>", q1.src) };
  msgs += check(q1.expression, tenv, useDef);

  return msgs; 
}

// Check operand compatibility with operators.
// E.g. for an addition node add(lhs, rhs), 
//   the requirement is that typeOf(lhs) == typeOf(rhs) == tint()
set[Message] check(AExpr e, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};
  
  switch (e) {
    case ref(AId x):
      msgs += { error("Undeclared question", x.src) | useDef[x.src] == {} };
    case binaryOp(AExpr lhs, AExpr rhs, _):
      {
        msgs += check(lhs, tenv, useDef);
        msgs += check(rhs, tenv, useDef);
        if (typeOf(lhs, tenv, useDef) == typeOf(rhs, tenv, useDef)) {
          msgs += { error("Type error", e.src) };
        }
      }

    // etc.
  }
  
  return msgs; 
}

Type typeOf(AExpr e, TEnv tenv, UseDef useDef) {
  switch (e) {
    case ref(id(_, src = loc u)):  
      if (<u, loc d> <- useDef, <d, x, _, Type t> <- tenv) {
        return t;
      }
    case \int(_):
      return tint();
    case \bool(_):
      return tbool();
    case \str(_):
      return tstr();
    case unaryOp(AExpr e, _):
      return typeOf(e, tenv, useDef);
    case binaryOp(AExpr lhs, AExpr rhs, _):
      {
        if (typeOf(lhs, tenv, useDef) == typeOf(rhs, tenv, useDef)) {
          return typeOf(lhs, tenv, useDef);
        }
      }
  }

  return tunknown(); 
}

/* 
 * Pattern-based dispatch style:
 * 
 * Type typeOf(ref(id(_, src = loc u)), TEnv tenv, UseDef useDef) = t
 *   when <u, loc d> <- useDef, <d, x, _, Type t> <- tenv
 *
 * ... etc.
 * 
 * default Type typeOf(AExpr _, TEnv _, UseDef _) = tunknown();
 *
 */
 
 

