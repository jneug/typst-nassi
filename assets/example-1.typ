#import "../src/nassi.typ"

#set page(width: auto, height:auto, margin: 5mm)

#nassi.diagram(width:12cm, ```
function ggt(a, b)
  while a > 0 and b > 0
    if a > b
      a <- a - b
    else
      b <- b - a
    endif
  endwhile
  if b == 0
    return a
  else
    return b
  endif
endfunction
```)
