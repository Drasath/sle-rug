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
  = statement(AQuestion question)
  | statement(AComputedQuestion computedQuestion)
  | statement(AIfThen ifThen)
  | statement(AIfThenElse ifThenElse)
  | statement(ABlock block)
  ;

data AQuestion(loc src = |tmp:///|)
  = question(AId variable, AType \type)
  ;

data AComputedQuestion(loc src = |tmp:///|)
  = computedQuestion(AId variable, AType \type, AExpr expression)
  ;

data AIfThen(loc src = |tmp:///|)
  = ifThen(AExpr condition, ABlock thenBlock)
  ;

data AIfThenElse(loc src = |tmp:///|)
  = ifThenElse(AExpr condition, ABlock thenBlock, ABlock elseBlock)
  ;

data AExpr(loc src = |tmp:///|)
  = ref(AId id)
  //| \bool(Bool \value)
  ;

data AId(loc src = |tmp:///|)
  = id(str name);

data AType(loc src = |tmp:///|)
  = \type(str a);
