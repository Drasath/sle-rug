module Transform

import Syntax;
import Resolve;
import AST;
import ParseTree; // used to get src location of Ids

/* 
 * Transforming QL forms
 */
 
 
/* Normalization:
 *  wrt to the semantics of QL the following
 *     q0: "" int; 
 *     if (a) { 
 *        if (b) { 
 *          q1: "" int; 
 *        } 
 *        q2: "" int; 
 *      }
 *
 *  is equivalent to
 *     if (true) q0: "" int;
 *     if (true && a && b) q1: "" int;
 *     if (true && a) q2: "" int;
 *
 * Write a transformation that performs this flattening transformation.
 *
 */

AForm flatten(AForm f) {
  AExpr conditions = \bool(true);

  // First pass, change all conditions  
  f = top-down visit(f) {
    case AIfThen ifStatement => {
      conditions = and(conditions, ifStatement.condition);
      ifStatement.condition = conditions;
      ifStatement;
    }
  }

  f.block.statements = [statement(ifThen(\bool(true), block(f.block.statements)))];

  // Second pass, move all if statements to the top
  list[AStatement] newStatements = [];

  f = visit(f) {
    case statement(AIfThen ifStatement) => {
      newStatements += statement(ifStatement);
      statement(block([])); // Don't know how to remove a node so replace with empty block
    }
  }

  // Add to root block, in reverse order (we want the previous visit to be bottom-up)
  f.block.statements += reverse(newStatements); // reverse to somewhat preserve order

  return f;
}

/* Rename refactoring:
 *
 * Write a refactoring transformation that consistently renames all occurrences of the same name.
 * Use the results of name resolution to find the equivalence class of a name.
 *
 */
 
start[Form] rename(start[Form] f, loc useOrDef, str newName, UseDef useDef) {
  // for each location find in def/use find in form and rename

  // Get defs (can be multiple)
  set[loc] defs = useDef[useOrDef];

  // Get all uses
  set[loc] uses = {use | <use, def> <- useDef, def <- defs};

  f = visit (f) {
    case (Id) x => {
      if (x.src in defs || x.src in uses) {
        x = parse(#Id, newName);
      } else {
        x;
      }
    }
  }

  return f; 
} 
