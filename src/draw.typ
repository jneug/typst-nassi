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

#let draw-elements( ctx, pos, width, inset:.5em, stroke:1pt+black, elements, colors:(:), labels:() ) = {
  let (x, y) = pos
  let inset-num = resolve-number(ctx, 2*inset)
  let width = resolve-number(ctx, width)

  let measure-height( element, width:width ) = if element.height == auto {
    measure(ctx, block(width:width * ctx.length, element.text)).at(1) + inset-num
  } else {
    element.height
  }

  if elements == () or elements == none {
    elements = empty()
  }

  for element in elements {
    let height = measure-height(element)

    if element.type == TYPES.EMPTY {
      draw.content(
        (x, y),
        (x + width, y - height),
        box(
          align(center+horizon, element.text),
          fill: colors.at("empty", default:rgb("#fffff3")),
          stroke: stroke,
          width: 100%,
          height: 100%,
          inset: inset
        )
      )
    } else if element.type == TYPES.PROCESS {
      draw.content(
        (x, y),
        (x + width, y - height),
        box(
          align(left+horizon, element.text),
          fill: colors.at("process", default:rgb("#fceece")),
          stroke: stroke,
          width: 100%,
          height: 100%,
          inset: inset
        )
      )
    } else if element.type == TYPES.CALL {
      draw.rect(
        (x, y),
        (x + width, y - height),
        fill: colors.at("call", default:rgb("#fceece")).darken(5%),
      )
      draw.content(
        (x + .5*inset-num, y),
        (x + width - .5*inset-num, y - height),
        box(
          align(left+horizon, element.text),
          fill: colors.at("call", default:rgb("#fceece")),
          stroke: stroke,
          width: 100%,
          height: 100%,
          inset: inset
        )
      )
    } else if element.type == TYPES.LOOP {
      let elems = draw-elements(ctx, (x + inset-num, y - height), width - inset-num, element.elements, colors:colors, labels:labels, inset:inset, stroke:stroke)
      let elems-height = calc-height(ctx, elems)

      draw.content(
        (x, y),
        (x + width, y - height - elems-height),
        box(
          align(left+top, element.text),
          fill: colors.at("loop", default:rgb("#dcefe7")),
          stroke: stroke,
          width: 100%,
          height: 100%,
          inset: inset
        )
      )
      elems

      y -= elems-height
    } else if element.type == TYPES.FUNCTION {
      let elems = draw-elements(ctx, (x + inset-num, y - height), width - inset-num, element.elements, colors:colors, labels:labels, inset:inset, stroke:stroke)
      let elems-height = calc-height(ctx, elems)

      draw.content(
        (x, y),
        (x + width, y - height - elems-height - inset-num),
        box(
          align(left+top, strong(element.text)),
          fill: colors.at("function", default:rgb("#ffffff")),
          stroke: stroke,
          width: 100%,
          height: 100%,
          inset: inset
        )
      )
      elems

      y -= elems-height + inset-num
    } else if element.type == TYPES.BRANCH {
      if element.height == auto {
        height += inset-num
      }

      if element.left == none or element.left == () {
        element.left = empty()
      }
      if element.right == none or element.right == () {
        element.right = empty()
      }

      let elems-left = draw-elements(ctx, (x, y - height), width*element.center, element.left, colors:colors, labels:labels, inset:inset, stroke:stroke)
      let elems-right = draw-elements(ctx, (x + width*element.center, y - height), width*(1 - element.center), element.right, colors:colors, labels:labels, inset:inset, stroke:stroke)

      let (height-left, height-right) = (
        calc-height(ctx, elems-left),
        calc-height(ctx, elems-right)
      )
      let elems-height = calc.max(
        height-left, height-right
      )

      if height-left < height-right {
        let e = element.left.pop()
        e.height = measure-height(e, width:width*element.center) + height-right - height-left
        element.left.push(e)

        elems-left = draw-elements(ctx, (x, y - height), width*element.center, element.left, colors:colors, labels:labels, inset:inset, stroke:stroke)
      } else if height-right < height-left {
        let e = element.right.pop()
        e.height = measure-height(e, width:width*(1 - element.center)) + height-left - height-right
        element.right.push(e)

        elems-right = draw-elements(ctx, (x + width*element.center, y - height), width*(1 - element.center), element.right, colors:colors, labels:labels, inset:inset, stroke:stroke)
      }

      // draw.content(
      //   (x, y),
      //   (x + width, y - height - elems-height),
      //   box(
      //     align(center+top, element.text),
      //     fill: colors.at("branch", default:rgb("#fadad0")),
      //     stroke: stroke,
      //     width: 100%,
      //     height: 100%,
      //     inset: inset
      //   )
      // )
      draw.rect(
        (x, y),
        (x + width, y - height - elems-height),
        fill: colors.at("branch", default:rgb("#fadad0")),
        stroke: stroke
      )
      draw.content(
        (x + (.2 + element.center*.6)*width + element.text-shift, y - inset-num*.5),
        element.text,
        anchor: "north"
      )

      draw.line((x, y), (x + width*element.center, y - height), (x + width, y), stroke:stroke)
      draw.content(
        (x + inset-num*.5, y - height + inset-num*.5),
        text(.66em,
            element.labels.at(0, default:labels.at(0, default:"true"))
        ),
        anchor: "south-west"
      )
      draw.content(
        (x + width - inset-num*.5, y - height + inset-num*.5),
        text(.66em,
          element.labels.at(1, default:labels.at(1, default:"false"))
        ),
        anchor: "south-east"
      )

      elems-left
      elems-right

      y -= elems-height
    }

    y -= height
  }
}
