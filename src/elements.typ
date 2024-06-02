
#let TYPES = (
  EMPTY: 0,
  PROCESS: 1,
  BRANCH: 2,
  SWITCH: 3,
  LOOP: 4,
  LOOP_2: 5,
  PARALLEL: 6,
  FUNCTION: 7,
  CALL: 8
)

#let empty( height: auto ) = (
  (
    type: TYPES.EMPTY,
    text: sym.emptyset,
    height: height
  ),
)

#let process( text, height: auto ) = (
  (
    type: TYPES.PROCESS,
    text: text,
    height: height
  ),
)

#let assign( var, expression, height: auto, symbol:sym.arrow.l ) = (
  (
    type: TYPES.PROCESS,
    text: var + " " + symbol + " " + expression,
    height: height
  ),
)

#let loop( text, elements, height: auto ) = (
  (
    type: TYPES.LOOP,
    text: text,
    elements: elements,
    height: height
  ),
)

#let branch( text, left, right, height: auto, center:.5, labels:(), text-shift:.0 ) = (
  (
    type: TYPES.BRANCH,
    text: text,
    left: left,
    right: right,
    height: height,
    center: center,
    labels: labels,
    text-shift: text-shift
  ),
)

#let switch( text, ..branches, height: auto ) = (
  (
    type: TYPES.SWITCH,
    text: text,
    branches: branches,
    height: height
  ),
)

#let parallel( text, ..branches, height: auto ) = (
  (
    type: TYPES.PARALLEL,
    text: text,
    branches: branches,
    height: height
  ),
)

#let function( text, elements, height: auto ) = (
  (
    type: TYPES.FUNCTION,
    text: text,
    elements: elements,
    height: height
  ),
)

#let call( text, height: auto ) = (
  (
    type: TYPES.CALL,
    text: text,
    height: height
  ),
)
