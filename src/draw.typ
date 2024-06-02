#import "@preview/cetz:0.2.2" as cetz: draw

#let typst-measure = measure
#import cetz.util: measure, resolve-number

#import "elements.typ": TYPES, empty

#let calc-height( ctx, elements ) = {
  let height = 0

  if elements != none {
    let (min-y, max-y) = elements.fold(
      (none, none),
      (x, f) => f(ctx).drawables.fold(
        x,
        ((y1, y2), d) => if "pos" in d and "height" in d {
          if y1 == none {
            (d.pos.at(1) - d.height/2, d.pos.at(1) + d.height/2)
          } else {
            (
              calc.min(y1, d.pos.at(1) - d.height/2),
              calc.max(y2, d.pos.at(1) + d.height/2)
            )
          }
        } else {
          (y1, y2)
        }
      )
    )

    height = max-y - min-y
  }

  return height
}

#let rebalance-heights(elements, height-growth, y:auto) = {
  // Count elements that can have a dynamic height
  let dynamic = 0
  for e in elements {
    if e.type in (TYPES.PROCESS, TYPES.CALL, TYPES.EMPTY) {
      dynamic += 1
    }
  }

  // Adjust height and position of elements
  if y == auto {
    y = elements.first().pos.at(1)
  }

  if dynamic > 0 {
    let growth = height-growth / dynamic
    for (i, e) in elements.enumerate() {
      e.pos.at(1) = y

      if e.type in (TYPES.PROCESS, TYPES.CALL, TYPES.EMPTY) {
        e.height += growth
        //e.grow += growth

        elements.at(i) = e
      }

      y -= e.height + e.grow
    }
  } else {
    let growth = height-growth / elements.len()
    for (i, e) in elements.enumerate() {
      e.grow += growth
      e.pos.at(1) = y

      if e.type in (TYPES.LOOP, TYPES.FUNCTION) {
        e.elements = rebalance-heights(e.elements, growth, y: e.pos.at(1) - e.height)
      } else if e.type == TYPES.BRANCH {
        e.left = rebalance-heights(e.left, growth, y: e.pos.at(1) - e.height)
        e.right = rebalance-heights(e.right, growth, y: e.pos.at(1) - e.height)
      }

      elements.at(i) = e
      y -= e.height + e.grow
    }
  }
  return elements
}

#let layout-elements(ctx, (x, y), width, inset, elements) = {
  let elems = ()

  for element in elements {
    element.pos = (x, y)
    element.width = width
    element.inset = if element.inset == auto {
      inset
    } else {
      resolve-number(ctx, element.inset)
    }
    element.height = if element.height == auto {
      measure(ctx, block(width:width * ctx.length, element.text)).at(1) + 2*element.inset
    } else {
      element.height
    }

    if element.type in (TYPES.LOOP, TYPES.FUNCTION) {
      if element.elements == none or element.elements == () {
        element.elements = empty()
      }

      element.elements = layout-elements(ctx, (x + 2*element.inset, y - element.height), width - 2*element.inset, inset, () + element.elements)
      element.grow = element.elements.fold(0, (h, e) => h + e.height + e.grow)

      if element.type == TYPES.FUNCTION {
        element.grow += 2*element.inset
      }
    } else if element.type == TYPES.BRANCH {
      if element.left == none or element.left == () {
        element.left = empty()
      }
      element.left = layout-elements(ctx, (x, y - element.height), width*element.column-split, inset, () + element.left)

      if element.right == none or element.right == () {
        element.right = empty()
      }
      element.right = layout-elements(ctx, (x + width*element.column-split, y - element.height), width*(1 - element.column-split), inset, () + element.right)

      let (height-left, height-right) = (
        element.left.fold(0, (h, e) => h + e.height + e.grow),
        element.right.fold(0, (h, e) => h + e.height + e.grow)
      )

      if height-left < height-right {
        element.left = rebalance-heights(
          element.left, (height-right - height-left)
        )
      } else if height-right < height-left {
        element.right = rebalance-heights(
          element.right, (height-left - height-right)
        )
      }

      element.grow = calc.max(height-left, height-right)
    }

    elems.push(element)

    y -= element.height + element.grow
  }

  return elems
}

#let draw-elements( ctx, layout, stroke:1pt+black, theme:(:), labels:() ) = {
  for element in layout {
    let (x,y) = element.pos

    if element.type == TYPES.EMPTY {
      draw.rect(
        (x,y), (x + element.width, y - element.height - element.grow),
        stroke:stroke,
        fill: theme.at("empty", default:rgb("#fffff3"))
      )
      draw.content(
        (x + element.width*.5, y - element.height*.5),
        element.text,
        anchor: "center"
      )
    } else if element.type == TYPES.PROCESS {
      draw.rect(
        (x,y), (x + element.width, y - element.height - element.grow),
        stroke:stroke,
        fill: theme.at("process", default:rgb("#fceece"))
      )
      draw.content(
        (x + element.inset, y - element.height*.5),
        element.text,
        anchor: "west"
      )
    } else if element.type == TYPES.CALL {
      draw.rect(
        (x,y), (x + element.width, y - element.height - element.grow),
        stroke:stroke,
        fill: theme.at("call", default:rgb("#fceece")).darken(5%)
      )
      draw.rect(
        (x + element.inset*.5,y), (x + element.width - element.inset*.5, y - element.height - element.grow),
        stroke:stroke,
        fill: theme.at("call", default:rgb("#fceece"))
      )
      draw.content(
        (x + element.inset, y - element.height*.5),
        element.text,
        anchor: "west"
      )
    } else if element.type == TYPES.LOOP {
      draw.rect(
        (x,y), (x + element.width, y - element.height - element.grow),
        stroke:stroke,
        fill: theme.at("loop", default:rgb("#dcefe7"))
      )
      draw.content(
        (x + element.inset, y - element.height*.5),
        element.text,
        anchor: "west"
      )

      draw-elements(ctx, element.elements, stroke:stroke, theme:theme)
    } else if element.type == TYPES.FUNCTION {
      draw.rect(
        (x,y), (x + element.width, y - element.height - element.grow),
        stroke:stroke,
        fill: theme.at("function", default:rgb("#ffffff"))
      )
      draw.content(
        (x + element.inset, y - element.height*.5),
        strong(element.text),
        anchor: "west"
      )

      draw-elements(ctx, element.elements, stroke:stroke, theme:theme)
    } else if element.type == TYPES.BRANCH {
      draw.rect(
        (x,y), (x + element.width, y - element.height - element.grow),
        fill: theme.at("branch", default:rgb("#fadad0")),
        stroke: stroke
      )

      let content-width = measure(ctx, element.text).at(0) + 2*element.inset
      draw.content(
        //(x + (.2 + element.column-split*.6)*element.width, y - element.inset),
        (x + element.column-split*element.width + (.5 - element.column-split)*content-width, y - element.inset),
        element.text,
        anchor: "north"
      )

      draw.line(
        (x, y),
        (x + element.width*element.column-split, y - element.height),
        (x + element.width, y),
        stroke:stroke
      )

      draw.content(
        (x + element.inset*.5, y - element.height + element.inset*.5),
        text(.66em,
            element.labels.at(0, default:labels.at(0, default:"true"))
        ),
        anchor: "south-west"
      )
      draw.content(
        (x + element.width - element.inset*.5, y - element.height + element.inset*.5),
        text(.66em,
          element.labels.at(1, default:labels.at(1, default:"false"))
        ),
        anchor: "south-east"
      )

      draw-elements(ctx, element.left, stroke:stroke, theme:theme)
      draw-elements(ctx, element.right, stroke:stroke, theme:theme)
    }
  }
}
