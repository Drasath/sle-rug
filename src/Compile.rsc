module Compile

import AST;
import Resolve;
import IO;
import lang::html::AST; // see standard library
import lang::html::IO;

/*
 * Implement a compiler for QL to HTML and Javascript
 *
 * - assume the form is type- and name-correct
 * - separate the compiler in two parts form2html and form2js producing 2 files
 * - use string templates to generate Javascript
 * - use the HTMLElement type and the `str writeHTMLString(HTMLElement x)` function to format to string
 * - use any client web framework (e.g. Vue, React, jQuery, whatever) you like for event handling
 * - map booleans to checkboxes, strings to textfields, ints to numeric text fields
 * - be sure to generate uneditable widgets for computed questions!
 * - if needed, use the name analysis to link uses to definitions
 */

void compile(AForm f) {
  println("Compiling form " + f.name + " to HTML and Javascript");
  writeFile(f.src[extension="js"].top, form2js(f));
  writeFile(f.src[extension="html"].top, writeHTMLString(form2html(f)));
}

HTMLElement form2html(AForm f) {
  return html([
    head([
      title([
        text(f.name)
      ])
    ]),
    body([
      h1([
        text(f.name)
      ]),
      block2html(f.block)
    ])
  ]);
}

HTMLElement block2html(ABlock b) {
  return div(
    [question2html(q) | /AQuestion q <- b.statements]
  );
}

HTMLElement question2html(AQuestion q) {
  return div([
    label([
      text(q.label)
    ]),
    input()
  ]);
}

str form2js(AForm f) {
  return `
    function ${f.name}() {
      // TODO
    }
    `;
}
