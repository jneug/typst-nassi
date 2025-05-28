#import "../../src/nassi.typ"

#set page(width: auto, height: auto, margin: 1cm)

#nassi.diagram(
  width: 12cm,
  {
    import nassi.elements: *

    branch(
      "branch 1",
      {
        process("Statement 1")
        process("Statement 2")
      },
      {
        process("Should grow")
      },
    )
  },
)
