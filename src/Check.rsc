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
  for (/question(AId x, str label, _) := f) {
    tenv += { <x.src, x.name, label, tbool()> };
  }

  return tenv; 
}

set[Message] check(AForm f, TEnv tenv, UseDef useDef) {
  return { m | /AQuestion q <- f, m <- check(q, tenv, useDef) };
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

// Check operand compatibility with operators.
// E.g. for an addition node add(lhs, rhs), 
//   the requirement is that typeOf(lhs) == typeOf(rhs) == tint()
set[Message] check(AExpr e, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};
  
  switch (e) {
    case ref(AId x):
      msgs += { error("Undeclared question", x.src) | useDef[x.src] == {} };
    // case add(AExpr lhs, AExpr rhs):
    //   msgs += check(lhs, tenv, useDef);
    //   msgs += check(rhs, tenv, useDef);
    //   if (typeOf(lhs) == typeOf(rhs) == tint()) {
    //     msgs += { error("Type error", e.src) };
    //   }

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
    // etc.
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
 
 

