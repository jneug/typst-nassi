#import "../../src/nassi.typ"

#set page(width: 20cm, height: auto, margin: 1cm)

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
  )
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
})
