#import "../src/nassi.typ"

#set page(width: 22cm, height:auto, margin: 1cm)

#nassi.diagram(width:12, {
  import nassi.elements: *

  function("nassiTest(Tree b)", {
    process("n <- 1")
    process("n += 1")
    loop("n > 0", {
      process("n -= 1")
      branch("n is even", {
        branch("xxx", {

        }, {

        })
      }, {
        loop("n > 0", {
          call("print 'Foo'")
          call("print 'Foo'")
        })
      })
    })
    branch("n is odd", center:.3, {
      loop("n > 0", {
        process("n -= 1")
      })
    }, {
      loop("n > 0", {
        process("n -= 1")
        call("print 'Foo'")
        call("print 'Foo'")
        call("print 'Foo'")
      })
    },
    labels:("Ja", "Nein"))
  })
  process("XXXX")
})

#nassi.diagram(width:20cm, ```
n := 1
n += 1
while n > 0
  n -= 1
endwhile
```)

#show: nassi.shneiderman(
  font:"Comic Neue",
  fontsize:14pt,
  colors:nassi.themes.greyscale,
  labels:("Wahr", "Falsch"),
  inset: .5em,
  stroke: 2pt+red
)

```nassi
function a(b)
  n := 1
  n += 1
  while n > 0
    n -= 1
    |other process|
    if n == 0
      n := 10
    else
      n := -10
    endif
  endwhile
endfunction
```

#nassi.diagram({
  import nassi.elements-de: *

  anweisung("a <- b")
  zuweisung("a", "b")
  zuweisung("a", "b", symbol:":=")
})
