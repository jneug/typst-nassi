#import "@preview/cetz:0.2.2"

#import "elements.typ"
#import "elements-de.typ"
#import "draw.typ" as draw: layout-elements, draw-elements

#let parse-strukt( content ) = {
  if content == none {
    return ()
  }

  let code = content.split("\n")

  let elems = ()

  let i = 0
  while i < code.len() {
    let line = code.at(i).trim()

    if line == "" {
      i += 1
      continue
    }

    if line.starts-with("if ") {
      let (left, right) = ((),())
      let left-branch = true

      i += 1
      while code.at(i).trim() not in ("endif", "end if") {
        if code.at(i).trim() == "else" {
          left-branch = false
        } else if left-branch {
          left += (code.at(i),)
        } else {
          right += (code.at(i),)
        }

        i += 1
      }

      elems += elements.branch(
        line.slice(3).trim(),
        parse-strukt(left.join("\n")),
        parse-strukt(right.join("\n")),
        column-split: if left == () { 25% } else if right == () { 75% } else { 50% }
      )
    } else if line.starts-with("while ") {
      let children = ()

      i += 1
      while code.at(i).trim() not in ("endwhile", "end while") {
        children += (code.at(i),)
        i += 1
      }

      elems += elements.loop(
        line.slice(6),
        parse-strukt(children.join("\n"))
      )
    } else if line.starts-with("function ") {
      let children = ()

      i += 1
      while code.at(i).trim() not in ("endfunction", "end function") {
        children += (code.at(i),)
        i += 1
      }

      elems += elements.function(
        line.slice(9),
        parse-strukt(children.join("\n"))
      )
    } else {
      if line.starts-with("|") and line.ends-with("|") {
        elems += elements.call(line.slice(1,-1).trim())
      } else if line.contains("<-") {
        let (a, b) = line.split("<-")
        elems += elements.assign(a.trim(), b.trim())
      } else {
        elems += elements.process(line)
      }
    }

    i += 1
  }

  return elems
}

#let themes = (
  default: (
    empty: white,
    process: white,
    call: white,
    branch: white,
    loop: white,
    switch: white,
    parallel: white,
    function: white
  ),
  nocolor: (
    empty: white,
    process: white,
    call: white,
    branch: white,
    loop: white,
    switch: white,
    parallel: white,
    function: white
  ),
  greyscale: (
    empty: luma(100%),
    process: luma(90%),
    call: luma(90%),
    branch: luma(75%),
    loop: luma(75%),
    switch: luma(50%),
    parallel: luma(75%),
    function: luma(100%)
  )
)

#let diagram(
  width: 100%,
  font: ("Verdana", "Geneva"),
  fontsize: 10pt,
  inset: .5em,
  theme: (:),
  stroke: 1pt+black,
  labels: (),
  ..cetz-args,
  elements
) = {
  if type(elements) == content and elements.func() == raw {
    elements = elements.text
  }
  if type(elements) != array {
    elements = parse-strukt(elements)
  }

  layout(size => {
    let width = width
    if type(width) == ratio {
      width *= size.width
    }

    set text(font: font, size:fontsize)
    cetz.canvas(..cetz-args, {
      cetz.draw.get-ctx(ctx => {
        let layout = layout-elements(
          ctx, (0,0),
          cetz.util.resolve-number(ctx, width),
          cetz.util.resolve-number(ctx, inset),
          elements
        )
        draw-elements(ctx, layout, stroke:stroke, theme:theme, labels:labels)
      })
    })
  })
}

#let shneiderman( ..args ) = (body) => {
  show raw.where(block:true, lang: "nassi"): diagram.with(..args)
  body
}
