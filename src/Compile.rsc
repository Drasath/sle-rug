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
      ]),
      style([
        text("body { font-family: sans-serif; font-size: 1.2em; width: 80%; margin: auto; user-select: none; }"),
        text("label { display: block; }"),
        text("div { padding: 1em; }"),
        text("div div { margin-left: 1em; }"),
        text("div:nth-child(even) { background-color: #eef; }"),
        text("input[type=text] { width: 100%; }"),
        text("input[type=number] { width: 100%; }"),
        text("input[type=checkbox] { width: 100%; }"),
        text("input[readonly] { background-color: #eee; }")
      ])
    ]),
    body([
      script([], src="https://unpkg.com/vue@3/dist/vue.global.js"),
      h1([
        text(f.name)
      ]),
      block2html(f.block),
      script([], src="tax.js")
    ])
  ]);
}

HTMLElement block2html(ABlock b) {
  return div([statement2html(s) | s <- b.statements]);
}

HTMLElement statement2html(AStatement s) {
  switch (s) {
    case /AIfThen ifThen : return ifthen2html(ifThen);
    case /AIfThenElse ifThenElse : return ifthenelse2html(ifThenElse);
    case /ABlock b : return block2html(b);
    case /AQuestion q : return question2html(q);
    case /AComputedQuestion cq : return computedquestion2html(cq);
    default : return text("<s>");
  }
}

HTMLElement ifthen2html(AIfThen ifThen) {
  return div([
    block2html(ifThen.thenBlock)
  ], \name="if");
}

HTMLElement ifthenelse2html(AIfThenElse ifThenElse) {
  return div([
    block2html(ifThenElse.thenBlock),
    block2html(ifThenElse.elseBlock)
  ], \name="if-else");
}

HTMLElement question2html(AQuestion q) {
  str qtype = "text";
  switch(q.\type.a) {
    case "boolean" : qtype = "checkbox";
    case "integer" : qtype = "number";
    default : qtype = "text";
  }
  return div([
    label([
      text(q.label)
    ], \for=q.variable.name),
    input(\type=qtype, \name=q.variable.name, \id=q.variable.name)
  ]);
}

HTMLElement computedquestion2html(AComputedQuestion cq) {
  str qtype = "text";
  return div([
    label([
      text(cq.label)
    ]),
    input(readonly="true", \type=qtype)
  ]);
}

str form2js(AForm f) {
  return "var app = Vue.createApp({
      data() {
        return {
        }
      }
    }).mount(\'#app\');
    ";
}
