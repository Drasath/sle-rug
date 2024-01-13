module AST

/*
 * Define Abstract Syntax for QL
 *
 * - complete the following data types
 * - make sure there is an almost one-to-one correspondence with the grammar
 */

data AForm(loc src = |tmp:///|)
  = form(str name, ABlock block)
  ;

data ABlock(loc src = |tmp:///|)
  = block(list[AStatement] statements)
  ;

data AStatement(loc src = |tmp:///|)
  = sQuestion(AQuestion question)
  | sComputedQuestion(AComputedQuestion computedQuestion)
  // | IfThen(AIfThen ifThen)
  // | IfThenElse(AIfThenElse ifThenElse)
  ;

data AQuestion(loc src = |tmp:///|)
  = question(AId variable, AType \type)
  ;

data AComputedQuestion(loc src = |tmp:///|)
  = computedQuestion(AId variable, AType \type, AExpr computation)
  ;

data AIfThen(loc src = |tmp:///|)
  = ifThen(AExpr guard, ABlock block)
  ;

data AIfThenElse(loc src = |tmp:///|)
  = ifThenElse(AExpr guard, ABlock ifBlock, ABlock elseBlock)
  ;

data AExpr(loc src = |tmp:///|)
  = ref(AId id)
  ;

data AId(loc src = |tmp:///|)
  = id(str name);

data AType(loc src = |tmp:///|)
  = \type(str a);
