
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
  let inset = frame.at("lower-inset", default: frame.at("inset", default:(x:1em, y:0.65em)))
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
 * Function: showybox()
 *
 * Description: Creates a showybox
 *
 * Parameters:
 * - frame:
 *   + upper-color: Color used as background color where the title goes
 *   + lower-color: Color used as background color where the body goes
 *   + border-color: Color used for the showybox's border
 *   + radius: Showybox's radius
 *   + width: Border width of the showybox
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
    upper-color: black,
    lower-color: white,
    border-color: black,
    inset: (x:1em, y:.65em),
    radius: 5pt,
    width: 1pt,
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

  ..body
) = {
  /*
   *  Alignment wrapper
   */
  let alignprops = (:)
  for prop in ("spacing", "above", "blow") {
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
  let showyblock = block(
    width: width,
    fill: frame.at("lower-color", default: white),
    radius: frame.at("radius", default: 5pt),
    inset: 0pt,
    breakable: breakable,
    stroke: if type(frame.at("width", default: 1pt)) != "dictionary" { // Set all borders at once
      (
        paint: frame.at("border-color", default: black),
        dash: frame.at("dash", default: "solid"),
        thickness: frame.at("width", default: 1pt)
      )
    } else { // Set each border individually
      let prop = (:)
      for pair in frame.at("width") {
        prop.insert(
          pair.at(0), // key
          (
            paint: frame.at("border-color", default: black),
            dash: frame.at("dash", default: "solid"),
            thickness: pair.at(1)
          )
        )
      }
      prop
    }
  )[
    /*
     * Title of the showybox. We'll check if it is
     * empty. If so, skip its drawing and only put
     * the body
     */
    #if title != "" {
      block(
        inset: if "upper-inset" in frame {
          frame.upper-inset
        } else {
          frame.at("inset", default:(x:1em, y:0.65em))
        },
        width: 100%,
        spacing: 0pt,
        fill: frame.at("upper-color", default: black),
        stroke: if type(frame.at("width", default: 1pt)) != "dictionary" { // Set all borders at once
          (
            paint: frame.at("border-color", default: black),
            dash: frame.at("dash", default: "solid"),
            thickness: frame.at("width", default: 1pt)
          )
        } else { // Set each border individually
          let prop = (:)
          for pair in frame.at("width") {
            prop.insert(
              pair.at(0), // key
              (
                paint: frame.at("border-color", default: black),
                dash: frame.at("dash", default: "solid"),
                thickness: pair.at(1)
              )
            )
          }
          // Allways set bottom border to 1pt for title
          prop.insert(
            "bottom",
            (
              paint: frame.at("border-color", default: black),
                dash: frame.at("dash", default: "solid"),
                thickness: 1pt
            )
          )
          prop
        },
        radius: (top: frame.at("radius", default: 5pt)))[
          #align(
            title-style.at("align", default: left),
            text(
              title-style.at("color", default: white),
              weight: title-style.at("weight", default: "bold"),
              title
            )
          )
      ]
    }

    /*
     * Body of the showybox
     */
    #block(
      width: 100%,
      spacing: 0pt,
      inset:  if "lower-inset" in frame {
        frame.lower-inset
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
                    thickness: sep.at("width", default: 1pt)
                  )
                )
              ))
            )
        )
      )
    )
  ]

  alignwrap(
    shadowwrap(showyblock)
  )
}
