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
 * Import functions
 */
#import "lib/func.typ": *

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
) = style(styles => {
  /*
   * Useful booleans
   */
  let titled = (title != "")
  let boxed = title-style.at("boxed", default: false)

  /*
   * Useful sizes and alignements
   */
  let title-size = measure(title, styles)
  let title-block-size = title-size.height + showy-inset(top, showy-section-inset("title", frame)) + showy-inset(bottom, showy-section-inset("title", frame))
  let boxed-align = title-style.at("boxed-align", default: left)
  
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
    /* Since we cannot modify a exxtern variable from style(), 
       define a local variable for shadow values, called d-shadow */
    let d-shadow = shadow
    
    if type(shadow.at("offset", default: 4pt)) != "dictionary" {
      d-shadow.offset = (
        x: shadow.at("offset", default: 4pt),
        y: shadow.at("offset", default: 4pt)
      )
    }
    shadowwrap = (sbox) => {
      let sbox-size = measure(sbox, styles)

      /* If it has a boxed title, leave some space to avoid collisions
         with other elements next to the showybox*/
      if titled and boxed {
        v(title-block-size - .5em)
      }
      
      block(
        breakable: breakable,
        radius: frame.at("radius", default: 5pt),
        fill:   shadow.at("color", default: luma(128)),
        spacing: 0pt,
        outset: (
          left: -d-shadow.offset.x,
          right: d-shadow.offset.x,
          bottom: d-shadow.offset.y,
          top: -d-shadow.offset.y 
        ),
        /* If it have a boxed title, substract some space to
           avoid the shadow to be body + title height, and only
           body height */
        if titled and boxed {
          v(-(title-block-size - .5em))
          sbox
        } else {
          sbox
        }
      )
    }
  }
  
  let showyblock = {

    if titled and boxed{
      v(title-block-size -.5em)
    }

    block(
      width: width,
      fill: frame.at("body-color", default: white),
      radius: frame.at("radius", default: 5pt),
      inset: 0pt,
      spacing: 0pt,
      breakable: breakable,
      stroke: showy-stroke(frame)
    )[
      /*
       * Title of the showybox
       */
      #if titled and not boxed {
        showy-title(frame, title-style, title)
      } else if titled and boxed {        
        // Leave some space for putting a boxed title
        v(1em)
        place(
          top + boxed-align,
          dy: -(title-block-size - 1em),
          dx: if boxed-align == left {
            1em
          } else if boxed-align == right {
            -1em
          } else {
            0pt
          },
          showy-title(frame, title-style, title)
        )
      }
      
      /*
       * Body of the showybox
       */
      #block(
        width: 100%,
        spacing: 0pt,
        inset:  showy-section-inset("body", frame),
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
          inset: showy-section-inset("footer", frame),
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
  }

  alignwrap(
    shadowwrap(showyblock)
  )
})