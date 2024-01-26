module Check

import AST;
import Resolve;
import Message;

data Type
  = tint()
  | tbool()
  | tstr()
  | tunknown()
  ;

// the type environment consisting of defined questions in the form 
alias TEnv = rel[loc def, str name, str label, Type \type];

TEnv collect(AForm f) {
  TEnv tenv = {};

  for (/question(AId x, str label, AType t) := f) {
    tenv += { <x.src, x.name, label, Atype2Type(t)> };
  }

  for (/computedQuestion(AId x, str label, AType t, _) := f) {
    tenv += { <x.src, x.name, label, Atype2Type(t)> };
  }

  return tenv; 
}

// Note: Kind of cursed, but I don't know how else to convert AType to Type.
// And I didn't want to use AType in the type environment.
Type Atype2Type(AType t) {
  switch (t) {
    case tint():
      return tint();
    case tbool():
      return tbool();
    case tstr():
      return tstr();
  }
  
  return tunknown();
}

set[Message] check(AForm f, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};

  // check for duplicate names and labels
  msgs += { m | /AQuestion q <- f, m <- check(q, tenv, useDef) };
  msgs += { m | /AComputedQuestion cq <- f, m <- check(cq, tenv, useDef) };
  msgs += { m | /AIfThen ifThen <- f, m <- check(ifThen, tenv, useDef) };
  msgs += { m | /AIfThenElse ifThenElse <- f, m <- check(ifThenElse, tenv, useDef) };
  
  // check expressions
  // Note: Not deep matching for Exprs, because I think that will check the same thing twice.
  msgs += { m | /AComputedQuestion cq <- f, m <- check(cq.expression, tenv, useDef) };
  msgs += { m | /AIfThen ifThen <- f, m <- check(ifThen.condition, tenv, useDef) };
  msgs += { m | /AIfThenElse ifThenElse <- f, m <- check(ifThenElse.condition, tenv, useDef) };

  return msgs;
}
set[Message] check(AQuestion q1, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};

  // Doing it in one loop, because I think it's nicer.
  for (<def, name, label, t> <- tenv) {
    // Check for duplicate labels
    if (label == q1.label && def != q1.variable.src) {
      msgs += { warning("Duplicate label <q1.label>", q1.src) };
    }

    // Check for duplicate names with differing types
    if (name == q1.variable.name && def != q1.variable.src && t != Atype2Type(q1.\type)) {
      msgs += { error("Duplicate name <q1.variable.name>", q1.variable.src) };
    }
  }

  return msgs; 
}

set[Message] check(AComputedQuestion q1, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};


  for (<def, name, label, t> <- tenv) {
    // Check for duplicate labels
    if (label == q1.label && def != q1.variable.src) {
      msgs += { warning("Duplicate label <q1.label>", q1.src) };
    }

    // Check for duplicate names with differing types
    if (name == q1.variable.name && def != q1.variable.src && t != Atype2Type(q1.\type)) {
      msgs += { error("Duplicate name <q1.variable.name>", q1.variable.src) };
    }
  }

  // Check that the expression is of the same type as the question
  Type expressionType = typeOf(q1.expression, tenv, useDef);
  if (Atype2Type(q1.\type) != expressionType) {
    msgs += { error("Type error: type <expressionType> can not be assigned to question of type <Atype2Type(q1.\type)>", q1.src) };
  }

  return msgs; 
}

set[Message] check(AIfThen ifThen, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};

  // Check that the condition is of type bool
  Type conditionType = typeOf(ifThen.condition, tenv, useDef);
  if (conditionType != tbool()) {
    msgs += { error("Type error: condition must be of type bool, but is of type <conditionType>", ifThen.src) };
  }

  return msgs; 
}

set[Message] check(AIfThenElse ifThenElse, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};

  // Check that the condition is of type bool
  Type conditionType = typeOf(ifThenElse.condition, tenv, useDef);
  if (conditionType != tbool()) {
    msgs += { error("Type error: condition must be of type bool, but is of type <conditionType>", ifThenElse.src) };
  }

  return msgs; 
}

// Helper function for checking binary operators in the function below.
set[Message] binaryOpCheck(AExpr e, Type \type, str opStr, TEnv tenv, UseDef useDef) {
  Type t = typeOf(e, tenv, useDef);
  if (t != \type) {
    return { error("Type error: type can not be used with operator <opStr>", e.src) };
  }
  return {};
}

// Check operand compatibility with operators.
// Note: This can probably be optimized somehow.
set[Message] check(AExpr e, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};
  
  switch (e) {
    case ref(AId x):
      msgs += { error("Undeclared question <x.name>", x.src) | useDef[x.src] == {} };
    case neg(AExpr x):
      msgs += { error("Type error: type can not be used with unary operator !", e.src) | typeOf(x, tenv, useDef) != tbool() };
    case mul(AExpr _, AExpr _):
      msgs += binaryOpCheck(e, tint(), "*", tenv, useDef);
    case div(AExpr _, AExpr _):
      msgs += binaryOpCheck(e, tint(), "/", tenv, useDef);
    case add(AExpr _, AExpr _):
      msgs += binaryOpCheck(e, tint(), "+", tenv, useDef);
    case sub(AExpr _, AExpr _):
      msgs += binaryOpCheck(e, tint(), "-", tenv, useDef);
    case lt(AExpr _, AExpr _):
      msgs += binaryOpCheck(e, tbool(), "\<", tenv, useDef);
    case le(AExpr _, AExpr _):
      msgs += binaryOpCheck(e, tbool(), "\<=", tenv, useDef);
    case gt(AExpr _, AExpr _):
      msgs += binaryOpCheck(e, tbool(), "\>", tenv, useDef);
    case ge(AExpr _, AExpr _):
      msgs += binaryOpCheck(e, tbool(), "\>=", tenv, useDef);
    case and(AExpr _, AExpr _):
      msgs += binaryOpCheck(e, tbool(), "&&", tenv, useDef);
    case or(AExpr _, AExpr _):
      msgs += binaryOpCheck(e, tbool(), "||", tenv, useDef);
    case equal(AExpr _, AExpr _):
      msgs += binaryOpCheck(e, tbool(), "==", tenv, useDef);
    case ne(AExpr _, AExpr _):
      msgs += binaryOpCheck(e, tbool(), "!=", tenv, useDef);
  }
  
  return msgs; 
}

// Helper function for checking if types are equal in the function below.
bool areEqualTypes(AExpr lhs, AExpr rhs, TEnv tenv, UseDef useDef) {
  Type lhsType = typeOf(lhs, tenv, useDef);
  Type rhsType = typeOf(rhs, tenv, useDef);
  return lhsType == rhsType;
}

// Note: Again this can probably be optimized.
Type typeOf(AExpr e, TEnv tenv, UseDef useDef) {
  switch (e) {
    case ref(id(_, src = loc u)):  
      if (<u, loc d> <- useDef, <d, _, _, Type t> <- tenv) {
        return t;
      }
    case \int(_):
      return tint();
    case \bool(_):
      return tbool();
    case \str(_):
      return tstr();
    case neg(AExpr x):
      if (typeOf(x, tenv, useDef) == tbool()) {
        return tbool();
      }
    case mul(AExpr lhs, AExpr rhs):
      if (areEqualTypes(lhs, rhs, tenv, useDef)) {
        return typeOf(lhs, tenv, useDef);
      }
    case div(AExpr lhs, AExpr rhs):
      if (areEqualTypes(lhs, rhs, tenv, useDef)) {
        return typeOf(lhs, tenv, useDef);
      }
    case add(AExpr lhs, AExpr rhs):
      if (areEqualTypes(lhs, rhs, tenv, useDef)) {
        return typeOf(lhs, tenv, useDef);
      }
    case sub(AExpr lhs, AExpr rhs):
      if (areEqualTypes(lhs, rhs, tenv, useDef)) {
        return typeOf(lhs, tenv, useDef);
      }
    case lt(AExpr lhs, AExpr rhs):
      if (areEqualTypes(lhs, rhs, tenv, useDef)) {
        return tbool();
      }
    case le(AExpr lhs, AExpr rhs):
      if (areEqualTypes(lhs, rhs, tenv, useDef)) {
        return tbool();
      }
    case gt(AExpr lhs, AExpr rhs):
      if (areEqualTypes(lhs, rhs, tenv, useDef)) {
        return tbool();
      }
    case ge(AExpr lhs, AExpr rhs):
      if (areEqualTypes(lhs, rhs, tenv, useDef)) {
        return tbool();
      }
    case and(AExpr lhs, AExpr rhs):
      if (areEqualTypes(lhs, rhs, tenv, useDef)) {
        return tbool();
      }
    case or(AExpr lhs, AExpr rhs):
      if (areEqualTypes(lhs, rhs, tenv, useDef)) {
        return tbool();
      }
    case equal(AExpr lhs, AExpr rhs):
      if (areEqualTypes(lhs, rhs, tenv, useDef)) {
        return tbool();
      }
    case ne(AExpr lhs, AExpr rhs):
      if (areEqualTypes(lhs, rhs, tenv, useDef)) {
        return tbool();
      }
  }

  return tunknown(); 
}

/* 
 * Note: Why is this comment here? V
 *
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
 