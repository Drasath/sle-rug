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
      ]),
      script([], src="https://cdnjs.cloudflare.com/ajax/libs/react/17.0.2/umd/react.development.js"),
      script([], src="https://cdnjs.cloudflare.com/ajax/libs/react-dom/17.0.2/umd/react-dom.development.js")
    ]),
    body([
      div([], \id="root"),
      script([], src="tax.js")
    ])
  ]);
}

str getInputType(AType t) {
  switch(t) {
    case tbool(): return "checkbox";
    case tint(): return "number";
    case tstr(): return "text";
  }
  return "text";
}

str question2js(AQuestion q) {
  if (q.\type == tbool()) {
    return "React.createElement(BooleanQuestion, { label: "+q.label+", variable: \""+q.variable.name+"\", handleInputChange: handleInputChange })";
  } else {
    return "React.createElement(Question, { label: "+q.label+", variable: \""+q.variable.name+"\", type:\""+getInputType(q.\type)+"\", handleInputChange: handleInputChange })";
  }
}

str computedQuestion2js(AComputedQuestion cq) {
  return "React.createElement(ComputedQuestion, { label: "+cq.label+", type:\""+getInputType(cq.\type)+"\", calculatedValue: calculatedValues[\""+cq.variable.name+"\"] })";
}

str statement2js(AStatement s) {
  switch(s) {
    case statement(AQuestion q): return question2js(q);
    case statement(AComputedQuestion cq): return computedQuestion2js(cq);
    case statement(AIfThen ifThen): return "React.createElement(IfThen, { condition: <expr2js(ifThen.condition)>, thenBlock: "+block2js(ifThen.thenBlock)+" })";
    case statement(AIfThenElse ifThenElse): return "";
    case statement(ABlock b): return block2js(b);
  }

  return "";
}

str block2js(ABlock b) {
  str result = "React.createElement(Block, {
        statements: [";
  for (s <- b.statements) {
    result += statement2js(s) + ",\n";
  }
  result += "]
      })";
  return result;
}

str form2js(AForm f) {
  return "
    function updateAll() {
      alert(\'updateAll\');
    }

    function Block({ statements }) {
      return React.createElement(\'div\', null, ...statements);
    }

    function IfThen({ condition, thenBlock }) {
      if (!condition) {
        return null;
      }
      return React.createElement(\'div\', null, thenBlock);
    }

    function Question({ label, variable, handleInputChange, type }) {
      return React.createElement(
          \'span\', null,
          React.createElement(\'label\', {
            for: label
          }, label),
          React.createElement(\'input\', {
            id: label,
            name: label,
            onInput: (e) =\> {
              handleInputChange(`${variable}`, e.target.value);
            },
            type: type
          })
        );
    }

    function BooleanQuestion({ label, variable, handleInputChange }) {
      return React.createElement(
          \'span\', null,
          React.createElement(\'label\', {
            for: label
          }, label),
          React.createElement(\'input\', {
            id: label,
            name: label,
            onInput: (e) =\> {
              handleInputChange(`${variable}`, e.target.checked);
            },
            type: \"checkbox\"
          })
        );
    }

    function ComputedQuestion({ label, calculatedValue, type }) {
      return React.createElement(
          \'span\', null,
          React.createElement(\'label\', {
            htmlFor: label
          }, label),
          React.createElement(\'input\', {
            id: label,
            name: label,
            disabled: true,
            value: calculatedValue,
            checked: calculatedValue,
            type: type
          })
        );
    }

    function App() {
      const [inputValues, setInputValues] = React.useState({
        <for (/AQuestion q <- f) {>\"<q.variable.name>\" : \'\',
        <}>
      });

      const [calculatedValues, setCalculatedValues] = React.useState({
        <for (/AComputedQuestion cq <- f) {>\"<cq.variable.name>\" : \'\',
        <}>
      });

      const handleInputChange = (variable, value) =\> {
        setInputValues((prevInputValues) =\> ({
          ...prevInputValues,
          [variable]: value,
        }));
      };

      React.useEffect(() =\> {
        setCalculatedValues((prevCalculatedValues) =\> ({
          ...prevCalculatedValues,
          <for (/AComputedQuestion cq <- f) {>
          [\"<cq.variable.name>\"]: <expr2js(cq.expression)>,
          <}>
        }));
        console.log(calculatedValues);  
      }, [inputValues]);

      return <block2js(f.block)>;
    }

    ReactDOM.render(React.createElement(App), document.getElementById(\'root\'));
    ";
}

str expr2js(AExpr e) {
  switch(e) {
    case ref(id(expr)): return "inputValues[\"<expr>\"]";
    case \int(intval): return "<intval>";
    case \bool(boolval): return "<boolval>";
    case \str(strval): return "<strval>";
    case par(expr): return "("+expr2js(expr)+")";
    case neg(expr): return "!("+expr2js(expr)+")";
    case mul(lhs, rhs): return expr2js(lhs) + " * " + expr2js(rhs);
    case div(lhs, rhs): return expr2js(lhs) + " / " + expr2js(rhs);
    case add(lhs, rhs): return expr2js(lhs) + " + " + expr2js(rhs);
    case sub(lhs, rhs): return expr2js(lhs) + " - " + expr2js(rhs);
    case lt(lhs, rhs): return expr2js(lhs) + " \< " + expr2js(rhs);
    case le(lhs, rhs): return expr2js(lhs) + " \<= " + expr2js(rhs);
    case gt(lhs, rhs): return expr2js(lhs) + " \> " + expr2js(rhs);
    case ge(lhs, rhs): return expr2js(lhs) + " \>= " + expr2js(rhs);
    case and(lhs, rhs): return expr2js(lhs) + " && " + expr2js(rhs);
    case and(lhs, rhs): return expr2js(lhs) + " || " + expr2js(rhs);
    case equal(lhs, rhs): return expr2js(lhs) + " == " + expr2js(rhs);
    case ne(lhs, rhs): return expr2js(lhs) + " != " + expr2js(rhs);
    
  }
  return "0";
}
