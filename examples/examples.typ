#import "@preview/showybox:1.1.0": showybox

#set par(justify: true)

/*
 * Examples in Usage section
 */

// Simple showybox
#showybox(
  [Hello world!]
)

// Showybox with title
#showybox(
  frame: (
    title-color: red.darken(40%),
    body-color: red.lighten(90%),
    border-color: black,
    thickness: 2pt
  ),
  title: "Hello world! - An example",
  [
    Hello world!
  ]
)

// Showybox with two sections
#showybox(
  frame: (
    dash: "dotted",
    border-color: red.darken(40%)
  ),
  body-style: (
    align: center
  ),
  sep: (
    dash: "dashed"
  ),
  shadow: (
	offset: (x: 3pt, y: 8pt)
  ),
  [This is an important message!],
  [Be careful outside. There are dangerous bananas!]
)

/*
 * Examples in Gallery section
 */

// Boxed title with custom width
#showybox(
  title: "Strawberry taste",
  title-style: (
    boxed: true,
    boxed-align: left,
    align: center,
    weight: 900
  ),
  width: 50%,
  align: center,
  shadow: (:),
  frame: (
    border-color: red,
    title-color: red.lighten(25%),
    thickness: 3pt
  ),
  [Eating a strawberry is a unique experience. It brings you the sweetest natural flavour in the modern world straight into your mouth, and it's only 0,99 cents!]
)

// Information-box-like showybox
/* Note:
 * Image of 'ivan' extracted from https://www.pinterest.com.mx/pin/696791373597276242/
 */
#showybox(
  width: 70%,
  align: center,
  frame: (
    radius: 0pt,
    border-color: blue.darken(40%),
    thickness: (left: 3pt),
    body-color: blue.lighten(80%),
    title-color: blue.lighten(80%)
  ),
  title-style: (
    color: black,
    sep-thickness: 0pt
  ),
  title: [_*Important information!*_],
  grid(
    columns: (2.5fr, 1fr),
    column-gutter: 15pt,
    par(justify: true)[During the past years an important issue has been concerning the local police. Apparently, a racoon, named _"Comrade Ivan, the vodkaholic"_ is draining all the vodka supplies in the city. A picture of the suspect is found at right:], image("ivan.jpg")
  )
)

// Encapsulation
#showybox(
  frame: (title-color: yellow.darken(5%), body-color: yellow.lighten(90%)),
  title-style: (color: black, weight: "regular"),
  title: "Newton's Second Law",
  [
  #box(height: 6.2cm)[
    #columns(2)[
      According to ChatGPT, Newton's second law of motion is one of the fundamental principles of classical mechanics, formulated by Sir Isaac Newton. It describes the relationship between the motion of an object, the applied force on it, and its mass. The second law can be stated as follows:
  
      The acceleration of an object is directly proportional to the net force applied to it and inversely proportional to its mass. Mathematically, it can be expressed as shown in the box at the right.
      #showybox(
        frame: (
          dash: "dotted",
          body-color: yellow.lighten(90%)
        ),
        )[
        
        $ F = m dot a $
  
        Where:
        - $F$ represents the net force acting on the object,
        - $m$ represents the mass of the object, and
        - $a$ represents the acceleration produced by the applied force.
      ]
      
    _Don't forget to ask your nearest physicist if the information given by ChatGPT is right or is a consiparational theory._
      
      ]
    ]
  ]
)

// Enabling breaking
#{
  set page(paper: "a8", flipped: true)

  showybox(
    body-style: (align: center), breakable: true,
    title: [_Breaking_ news],
    [
      As you can guess, in this $space$ #box(fill: gray.lighten(80%), radius: 2pt, outset: 3pt)[`showybox()`] the option $space$#box(fill: gray.lighten(80%), radius: 2pt, outset: 3pt)[`breakable: `#text(red,`true`)] $space$would make it break into two separated boxes when the content doesn't fit in this page anymore. So, I'm going to keep typing to make this box break.
  
      As you can see, it broke!
    ]
  )
}

// Custom radius
#showybox(frame: (radius: 0pt, title-color:white), title: "Important equations for the test", title-style: (color: black, align: center),
  box(height: 2.5cm)[
    #columns(2)[
      $ integral.cont.ccw_C  F dot dif r = limits(integral.double)_S (nabla times F) dot dif S $
      
      $ F = m dot a $
      
      
      $ P V = n R T $
      #v(2.199em)

      $ frac(dif U, dif t) = sum_(k=1)^K dot(m)_k h_k + dot(Q) + dot(W) + dot(W)_s $
    ]
  ] +
  v(1.037989em)
)