
/*
 * ShowyBox - A package for Typst
 * Pablo González Calderón and Showybox Contributors (c) 2023
 *
 * Main Contributors:
 * - Jonas Neugebauer (<https://github.com/jneug>)
 *
 * showy.typ -- The package's main file containing the
 * public and (more) useful functions
 *
 * This file is under the MIT license. For more
 * information see LICENSE on the package's main folder.
 */

/*
 * Function: showy-inset()
 *
 * Description: Helper function to get inset in a specific direction
 *
 * Parameters:
 * + direction
 * + value
 */
#let showy-inset( direction, value ) = {
  direction = repr(direction)   // allows use of alignment values
  if type(value) == "dictionary" {
    if direction in value {
      value.at(direction)
    } else if direction in ("left", "right") and "x" in value {
      value.x
    } else if direction in ("top", "bottom") and "y" in value {
      value.y
    } else  if "rest" in value {
      value.rest
    } else {
      0pt
    }
  } else if value == none {
    0pt
  } else {
    value
  }
}
/*
 * Function: showy-line()
 *
 * Description: Creates a modified `#line()` function
 * to draw a separator line with start and end points
 * adjusted to insets.
 *
 * Parameters:
 * + frame: The dictionary with frame settings
 */
#let showy-line( frame ) = {
  let inset = frame.at("body-inset", default: frame.at("inset", default:(x:1em, y:0.65em)))
  let inset = (
    left: showy-inset(left, inset),
    right: showy-inset(right, inset)
  )
  let (start, end) = (0%, 0%)

  // For relative insets the original width needs to be calculated
  if type(inset.left) == "ratio" and type(inset.right) == "ratio" {
    let full = 100% / (1 - float(inset.right) - float(inset.left))
    start = -inset.left * full
    end = full + start
  } else if type(inset.left) == "ratio" {
    let full = (100% + inset.right) / (1 - float(inset.left))
    (start, end) = (-inset.left * full, 100% + inset.right)
  } else if type(inset.right) == "ratio" {
    let full = (100% + inset.left) / (1 - float(inset.right))
    (start, end) = (-inset.left, full - inset.left)
  } else {
    (start, end) = (-inset.left, 100% + inset.right)
  }

  line.with(
    start: (start, 0%),
    end: (end, 0%)
  )
}
/*
 * Function: showy-stroke()
 *
 * Description: Creates a stroke or set of strokes
 * to use as borders.
 *
 * Parameters:
 * + frame: The dictionary with frame settings
 */
#let showy-stroke( frame, ..overrides ) = {
  let (paint, dash, width) = (
    frame.at("border-color", default: black),
    frame.at("dash", default: "solid"),
    frame.at("thickness", default: 1pt)
  )

  let strokes = (:)
  if type(width) != "dictionary" { // Set all borders at once
    for side in ("top", "bottom", "left", "right") {
      strokes.insert(side, (paint: paint, dash: dash, thickness: width))
    }
  } else { // Set each border individually
    for pair in width {
      strokes.insert(
        pair.first(), // key
        (paint: paint, dash: dash, thickness: pair.last())
      )
    }
  }
  for pair in overrides.named() {
    strokes.insert(
      pair.first(),
      (paint: paint, dash: dash, thickness: pair.last())
    )
  }
  return strokes
}

/*
 * Function: showy-title()
 *
 * Description: Sets the title's block properties
 * depending if it's `boxed` or not
 *
 * Parameters:
 * + frame: The dictionary with frame settings
 * + title-styles: The dictionary with title styles
 */
#let showy-title( frame, title-style ) = {
  /*
   * Porperties independent of `boxed`
   */
  let props = (
    spacing: 0pt,
    fill: frame.at("title-color", default: black)
  )

  if "title-inset" in frame {
    props.insert("inset", frame.title-inset)
  } else {
    props.insert("inset", frame.at("inset", default:(x:1em, y:0.65em)))
  }

  /*
   * Porperties dependent of `boxed`
   */
  if title-style.at("boxed", default: false) == true {
    props = props + (
      width: auto,
      radius: frame.at("radius", default: 5pt),
      stroke: showy-stroke(frame),
    )
    
  } else {
    props = props + (
      width: 100%,
      radius: (top: frame.at("radius", default: 5pt)),
      stroke: showy-stroke(frame, bottom: 1pt)
    )
  }

  return props
}

/*
 * Function: showybox()
 *
 * Description: Creates a showybox
 *
 * Parameters:
 * - frame:
 *   + title-color: Color used as background color where the title goes
 *   + body-color: Color used as background color where the body goes
 *   + border-color: Color used for the showybox's border
 *   + radius: Showybox's radius
 *   + thickness: Border width of the showybox
 *   + dash: Showybox's border style
 * - title-style:
 *   + color: Text color
 *   + weight: Text weight
 *   + align: Text align
 * - body-styles:
 *   + color: Text color
 *   + align: Text align
 * - sep:
 *   + width: Separator's width
 *   + dash: Separator's style (as a 'line' dash style)
 */
 #let showybox(
  frame: (
    title-color: black,
    body-color: white,
    border-color: black,
    footer-color: luma(220),
    inset: (x:1em, y:.65em),
    radius: 5pt,
    thickness: 1pt,
    dash: "solid"
  ),
  title-style: (
    color: white,
    weight: "bold",
    align: left
  ),
  body-style: (
    color: black,
    align: left
  ),
  footer-style: (
    color: luma(85),
    weight: "regular",
    align: left
  ),
  sep: (
    width: 1pt,
    dash: "solid",
    gutter: 0.65em
  ),
  shadow: none,

  width: 100%,
  breakable: false,
  // align: none, // collides with align-function

  title: "",
  footer: "",

  ..body
) = {
  /*
   *  Alignment wrapper
   */
  let alignprops = (:)
  for prop in ("spacing", "above", "below") {
    if prop in body.named() {
      alignprops.insert(prop, body.named().at(prop))
    }
  }
  let alignwrap( content ) = block(
    ..alignprops,
    width: 100%,
    if "align" in body.named() and body.named().align != none {
      align(body.named().align, content)
    } else {
      content
    }
  )

  /*
   * Optionally create a wrapper
   * function to add a shadow.
   */
  let shadowwrap = (sbox) => sbox
  if shadow != none {
    if type(shadow.at("offset", default: 4pt)) != "dictionary" {
      shadow.offset = (
        x: shadow.at("offset", default: 4pt),
        y: shadow.at("offset", default: 4pt)
      )
    }
    shadowwrap = (sbox) => block(
      breakable: breakable,
      radius: frame.at("radius", default: 5pt),
      fill:   shadow.at("color", default: luma(128)),
      outset: (
        top: -shadow.offset.y,
        left: -shadow.offset.x,
        right: shadow.offset.x,
        bottom: shadow.offset.y
      ),
      sbox
    )
  }

  let adjust-boxed-title = (tbox) => tbox
  if title-style.at("boxed", default: false) == true {
    adjust-boxed-title = (tbox) => block(
      spacing: 0pt,
      width: 100%,
      if title-style.at("boxed-align", default: left) == left {
        move(
          dx: 1em,
        align(title-style.at("boxed-align", default: left), tbox)
        )
      } else {
        align(title-style.at("boxed-align"), tbox)
      }
    )
  }
  
  let showyblock = style(styles => {
    let title-size = measure(title, styles)
    
    block(
      width: width,
      fill: frame.at("body-color", default: white),
      radius: frame.at("radius", default: 5pt),
      inset: 0pt,
      outset: if title-style.at("boxed", default: false) == true {
        // For calculating mid line position use either body-inset or inset
        if "body-inset" in frame {
          (top: -(title-size.height/2 + showy-inset(top, frame.body-inset)))
        } else {
          (top: -(title-size.height/2 + showy-inset(top, frame.at("inset", default: (x:1em, y: 0.65em)))))
        }
      } else {
        0pt
      },
      breakable: breakable,
      stroke: showy-stroke(frame)
    )[
      /*
       * Title of the showybox. We'll check if it is
       * empty. If so, skip its drawing and only put
       * the body
       */
      #if title != "" {
        adjust-boxed-title(
          block(..showy-title(frame, title-style))[
            #align(
              title-style.at("align", default: left),
              text(
                title-style.at("color", default: white),
                weight: title-style.at("weight", default: "bold"),
                title
              )
            )
          ]
        )
      }
    
      /*
       * Body of the showybox
       */
      #block(
        width: 100%,
        spacing: 0pt,
        inset:  if "body-inset" in frame {
          frame.body-inset
        } else {
          frame.at("inset", default:(x:1em, y:0.65em))
        },
        align(
          body-style.at("align", default: left),
          text(
            body-style.at("color", default: black),
            body.pos()
              .map(block.with(spacing:0pt))
              .join(block(spacing: sep.at("gutter", default: .65em),
                align(left, // Avoid alignment errors
                  showy-line(frame)(
                    stroke: (
                      paint: frame.at("border-color", default: black),
                      dash: sep.at("dash", default: "solid"),
                      thickness: sep.at("thickness", default: 1pt)
                    )
                  )
                ))
              )
          )
        )
      )
    
      /*
       * Footer of the showybox
       */
      #if footer != "" {
        block(
          inset: if "footer-inset" in frame {
            frame.footer-inset
          } else {
            frame.at("inset", default:(x:1em, y:0.65em))
          },
          width: 100%,
          spacing: 0pt,
          fill: frame.at("footer-color", default: luma(220)),
          stroke: showy-stroke(frame, top:1pt),
          radius: (bottom: frame.at("radius", default: 5pt)))[
            #align(
              footer-style.at("align", default: left),
              text(
                footer-style.at("color", default: luma(85)),
                weight: footer-style.at("weight", default: "regular"),
                footer
              )
            )
        ]
      }
    ]
  })

  alignwrap(
    shadowwrap(showyblock)
  )
}
