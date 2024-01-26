module AST

/*
 * Define Abstract Syntax for QL
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
  = question(AId variable, str label, AType \type)
  ;

data AComputedQuestion(loc src = |tmp:///|)
  = computedQuestion(AId variable, str label, AType \type, AExpr expression)
  ;

data AIfThen(loc src = |tmp:///|)
  = ifThen(AExpr condition, ABlock thenBlock)
  ;

data AIfThenElse(loc src = |tmp:///|)
  = ifThenElse(AExpr condition, ABlock thenBlock, ABlock elseBlock)
  ;

// TODO: map operators to lists (???)
data AExpr(loc src = |tmp:///|)
  = ref(AId id)
  | \int(int \intval)
  | \str(str \strval)
  | \bool(bool \boolval)
  | par(AExpr expr)
  | neg(AExpr expr)
  | mul(AExpr left, AExpr right)
  | div(AExpr left, AExpr right)
  | add(AExpr left, AExpr right)
  | sub(AExpr left, AExpr right)
  | lt(AExpr left, AExpr right)
  | le(AExpr left, AExpr right)
  | gt(AExpr left, AExpr right)
  | ge(AExpr left, AExpr right)
  | equal(AExpr left, AExpr right)
  | ne(AExpr left, AExpr right)
  | and(AExpr left, AExpr right)
  | or(AExpr left, AExpr right)
  ;

data AId(loc src = |tmp:///|)
  = id(str name);

data AType(loc src = |tmp:///|)
  = tint()
  | tbool()
  | tstr()
  | tunknown()
  ;
