module Transform

import Syntax;
import Resolve;
import AST;
import IO;

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
  // for each if statement in form, find all nested if statements and flatten
  // ?

  // TODO: actually flatten the if statements, right now it just adds true to the condition
  f = visit(f) {
    case ifThen(cond, block) => ifThen(and(\bool(true), cond), block)
    case ifThenElse(cond, block1, block2) => ifThenElse(and(\bool(true), cond), block1, block2)
  };

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

  // Get def
  set[loc] def = useDef[useOrDef];
  // Get all uses
  
  
  println(def);

  // TODO: rename all occurrences, not all ids
  f = visit (f) {
    case (Expr) `<Id x>` => (Expr) `<Id newName>`
  }

  return f; 
} 
