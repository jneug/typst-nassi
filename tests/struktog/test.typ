#import "../../src/nassi.typ"

#set page(width: 20cm, height: auto, margin: 1cm)

#let _struktog-files = (
  // "struktog_1.json",
  // "struktog_forloop.json",
  // "struktog_switch.json",
  "struktog_full.json",
)



#for file in _struktog-files {
  nassi.struktog(json(file))

  pagebreak(weak: true)
}
