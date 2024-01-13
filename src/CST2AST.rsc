module CST2AST

import Syntax;
import AST;

import ParseTree;

/*
 * - Map regular CST arguments (e.g., *, +, ?) to lists 
 *   (NB: you can iterate over * / + arguments using `<-` in comprehensions or for-loops).
 * - Map lexical nodes to Rascal primitive types (bool, int, str)
 * - See the ref example on how to obtain and propagate source locations.
 */

AForm cst2ast(start[Form] sf) {
  Form f = sf.top; // remove layout before and after form
  return form("f.name", cst2ast(f.block), src=f.src); 
}

ABlock cst2ast(Block b) {
  return block([cst2ast(statement) | statement <- b.statements ]);
}

AStatement cst2ast(Statement s) {
  switch (s) {
    case (Statement)`<Question x>`: return statement(cst2ast(x));
    case (Statement)`<ComputedQuestion x>`: return statement(cst2ast(x));
    case (Statement)`<IfThen x>`: return statement(cst2ast(x));
    case (Statement)`<IfThenElse x>`: return statement(cst2ast(x));
    case (Statement)`<Block x>`: return statement(cst2ast(x));
    default: throw "Unhandled statement: <s>";
  }
}

AQuestion cst2ast(Question q) {
  return question(id("<q.variable>"), \type("<q.\type>"));
}

AComputedQuestion cst2ast(ComputedQuestion cq) {
  return computedQuestion(id("<cq.variable>"), \type("<cq.\type>"), cst2ast(cq.expression));
}

AIfThen cst2ast(IfThen \if) {
  return ifThen(cst2ast(\if.condition), cst2ast(\if.thenBlock));
}

AIfThenElse cst2ast(IfThenElse \if) {
  return ifThenElse(cst2ast(\if.condition), cst2ast(\if.thenBlock), cst2ast(\if.elseBlock));

}

AExpr cst2ast(Expr e) {
  switch (e) {
    case (Expr)`<Id x>`: return ref(id("<x>", src=x.src), src=x.src);
    case (Expr)`<Int x>`: return ref(id("<x>", src=x.src), src=x.src);
    case (Expr)`<Str x>`: return ref(id("<x>", src=x.src), src=x.src);
    case (Expr)`<Bool x>`: return ref(id("<x>", src=x.src), src=x.src);
    
    default: throw "Unhandled expression: <e>";
  }
}

default AType cst2ast(Type t) {
  throw "Not yet implemented <t>";
  // switch(t) {
  //   case (Type) `<Bool x>`: return \type("<x>", src=x.src);
  //   case (Type) `<Int x>`: return \type("<x>", src=x.src);

  //   default: throw "Unknown Type: <t>";
  // }
}
