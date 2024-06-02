#import "../src/nassi.typ"

#set page(width: auto, height:auto, margin: 5mm)

#nassi.diagram(width:12cm,
  colors: nassi.themes.greyscale,
  ```
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
)
