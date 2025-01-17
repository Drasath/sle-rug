module Resolve

import AST;

/*
 * Name resolution for QL
 */ 


// modeling declaring occurrences of names
alias Def = rel[str name, loc def];

// modeling use occurrences of names
alias Use = rel[loc use, str name];

alias UseDef = rel[loc use, loc def];

// the reference graph
alias RefGraph = tuple[
  Use uses, 
  Def defs, 
  UseDef useDef
]; 

RefGraph resolve(AForm f) = <us, ds, us o ds>
  when Use us := uses(f), Def ds := defs(f);

Use uses(AForm f) {
  // get all top level statements in the form's block
  list[AStatement] ss = [s | /AStatement s <- f];

  // In QL, variables can be used in expressions, which only occur in computed questions, if-then and if-then-else conditions
  // Get all nested expressions in the expression
  list[AExpr] expr = [q.expression | s <- ss, AComputedQuestion q <- s];
  expr += [i.condition | s <- ss, AIfThen i <- s];
  expr += [i.condition | s <- ss, AIfThenElse i <- s];

  list[AId] ids = [i | e <- expr, /AId i <- e];

  return {<c.src, c.name> | c <- ids};
}

Def defs(AForm f) {
  // Get all top level statements in the form's block
  list[AStatement] ss = [s | /AStatement s <- f.block.statements];

  // In QL, variables can only be declared in questions and computed questions
  list[AId] ids = [q.variable | s <- ss, AQuestion q <- s];
  ids += [q.variable | s <- ss, AComputedQuestion q <- s];

  return {<c.name, c.src> | c <- ids};
}
