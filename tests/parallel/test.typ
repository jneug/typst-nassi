#import "../../src/nassi.typ"

#set page(width: 20cm, height: auto, margin: 1cm)

#nassi.diagram({
  nassi.elements.parallel(
    {
      nassi.elements.process("pressBrakes()")
      nassi.elements.assign("Ignission", "off")
    },
    {
      nassi.elements.assign("Ignission", "on")
    },
    {
      nassi.elements.process("accelerate()")
    },
    { },
  )

  // nassi.elements.process("accelerate()")
})

#pagebreak()

#nassi.diagram({
  nassi.elements.switch(
    "trafficLight",
    (
      red: {
        nassi.elements.process("pressBrakes()")
        nassi.elements.assign("Ignission", "off")
      },
      yellow: {
        nassi.elements.assign("Ignission", "on")
      },
      green: {
        nassi.elements.process("accelerate()")
      },
      default: { },
    ),
    labels: ("A", "B", "C"),
    fill: red,
    height: 1.5,
  )
  nassi.elements.process("accelerate()")
})

#pagebreak()

#nassi.diagram({
  nassi.elements.switch(
    "trafficLight",
    (
      red: {
        nassi.elements.process("pressBrakes()")
        nassi.elements.assign("Ignission", "off")
        nassi.elements.assign("Ignission", "off")
        nassi.elements.assign("Ignission", "off")
        nassi.elements.assign("Ignission", "off")
      },
      default: {
        nassi.elements.switch(
          "trafficJam",
          (
            yes: {
              nassi.elements.process("pressBrakes()")
              nassi.elements.assign("Ignission", "off")
            },
            no: {
              nassi.elements.assign("Ignission", "on")
            },
          ),
        )
      },
    ),
  )
  nassi.elements.process("accelerate()")
})
