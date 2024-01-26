module Eval

import AST;
import Resolve;

/*
 * Implement big-step semantics for QL
 */
 
// NB: Eval may assume the form is type- and name-correct.


// Semantic domain for expressions (values)
data Value
  = vint(int n)
  | vbool(bool b)
  | vstr(str s)
  ;

// The value environment
alias VEnv = map[str name, Value \value];

// Modeling user input
data Input
  = input(str question, Value \value);
  
// produce an environment which for each question has a default value
// (e.g. 0 for int, "" for str etc.)
VEnv initialEnv(AForm f) {
  VEnv venv = ();

  list[AQuestion] qs = [q | /AQuestion q <- f];
  list[AComputedQuestion] cqs = [cq | /AComputedQuestion cq <- f];
    
  venv = (q.variable.name : defaultValue(q.\type) | q <- qs);
  venv += (cq.variable.name : defaultValue(cq.\type) | cq <- cqs);
  
  return venv;
}


Value defaultValue(AType t) {
  switch (t) {
    case \tint(): return vint(0);
    case \tbool(): return vbool(false);
    case \tstr(): return vstr("");
    default: throw "Unsupported type <t>";
  }
}


// Because of out-of-order use and declaration of questions
// we use the solve primitive in Rascal to find the fixpoint of venv.
VEnv eval(AForm f, Input inp, VEnv venv) {
  return solve (venv) {
    venv = evalOnce(f, inp, venv);
  }
}

VEnv evalOnce(AForm f, Input inp, VEnv venv) {
  // Update venv with user input
  for (Input i <- inp) {
    venv[i.question] = i.\value;
  }

  return eval(f.block, inp, venv); 
}

VEnv eval(ABlock b, Input inp, VEnv venv) {
  for (AStatement s <- b) {
    venv = eval(s, inp, venv);
  }
  return venv; 
}

VEnv eval(AStatement s, Input inp, VEnv venv) {
  switch(s) {
    case AComputedQuestion cq: return eval(cq, inp, venv);
    case AIfThen ifThen: return eval(ifThen, inp, venv);
    case AIfThenElse ifThenElse: return eval(ifThenElse, inp, venv);
  }

  return venv; 
}

VEnv eval(AIfThen ifThen, Input inp, VEnv venv) {
  Value v = eval(ifThen.condition, venv);
  if (v.b) {
    venv = eval(ifThen.thenBlock, inp, venv);
  }
  return venv; 
}

VEnv eval(AIfThenElse ifThenElse, Input inp, VEnv venv) {
  Value v = eval(ifThenElse.condition, venv);
  if (v.b) {
    venv = eval(ifThenElse.thenBlock, inp, venv);
  } else {
    venv = eval(ifThenElse.elseBlock, inp, venv);
  }
  return venv; 
}

VEnv eval(AComputedQuestion cq, Input inp, VEnv venv) {
  Value v = eval(cq.expression, venv);
  venv[cq.variable.name] = v;
  return venv; 
}

Value eval(AExpr e, VEnv venv) {
  switch (e) {
    case ref(id(str x)): return venv[x];
    case \int(n): return vint(n);
    case \bool(b): return vbool(b);
    case \str(s): return vstr(s);
    case neg(AExpr expr): return vbool(!eval(expr, venv).b);
    case mul(AExpr lhs, AExpr rhs): return vint(eval(lhs, venv).n * eval(rhs, venv).n);
    case div(AExpr lhs, AExpr rhs): return vint(eval(lhs, venv).n / eval(rhs, venv).n);
    case add(AExpr lhs, AExpr rhs): return vint(eval(lhs, venv).n + eval(rhs, venv).n);
    case sub(AExpr lhs, AExpr rhs): return vint(eval(lhs, venv).n - eval(rhs, venv).n);
    case lt(AExpr lhs, AExpr rhs): return vbool(eval(lhs, venv) < eval(rhs, venv));
    case le(AExpr lhs, AExpr rhs): return vbool(eval(lhs, venv) <= eval(rhs, venv));
    case gt(AExpr lhs, AExpr rhs): return vbool(eval(lhs, venv) > eval(rhs, venv));
    case ge(AExpr lhs, AExpr rhs): return vbool(eval(lhs, venv) >= eval(rhs, venv));
    case equal(AExpr lhs, AExpr rhs): return vbool(eval(lhs, venv) == eval(rhs, venv));
    case ne(AExpr lhs, AExpr rhs): return vbool(eval(lhs, venv) != eval(rhs, venv));
    case and(AExpr lhs, AExpr rhs): return vbool(eval(lhs, venv).b && eval(rhs, venv).b);
    case or(AExpr lhs, AExpr rhs): return vbool(eval(lhs, venv).b && eval(rhs, venv).b);
    
    default: throw "Unsupported expression <e>";
  }
}