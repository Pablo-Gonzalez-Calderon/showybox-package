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
    shadowwrap = (sbox) => style(styles => {
        let title-size = measure(title, styles)
        
        block(
          breakable: breakable,
          radius: frame.at("radius", default: 5pt),
          fill:   shadow.at("color", default: luma(128)),
          outset: (
              left: -shadow.offset.x,
              right: shadow.offset.x,
              bottom: shadow.offset.y
          ) + if title != "" and title-style.at("boxed", default: false) {
            (top: -(shadow.offset.y + title-size.height/2 + showy-inset(top, showy-section-inset("body", frame))))
          } else {
            (top: -shadow.offset.y)
          },
          sbox
        )
      })
  }

  /*
   * Optionally create two wrapper
   * function for `boxed` titles
   */
  let boxedwrap = (tbox) => tbox
  let boxedshadowwrap = (tbox) => tbox
  if title-style.at("boxed", default: false) {
    let boxed-align = title-style.at("boxed-align", default: left)
  
    // Shadow
    if shadow != none {
      boxedshadowwrap = (tbox) => style(styles => {
        let title-size = measure(title, styles)
        let bottom-outset = title-size.height/2 + showy-inset(top, showy-section-inset("body", frame)) + (frame.at("thickness", default: 1pt)/2 - 0.5pt)
        
        block(
          radius: (
            top: frame.at("radius", default: 5pt),
            bottom: 0pt
          ),
          fill:   shadow.at("color", default: luma(128)),
          outset: (
              top: -shadow.offset.y,
              left: -shadow.offset.x,
              right: shadow.offset.x,
              bottom: -bottom-outset
            ),
          tbox
        )
      })
    }

    // Alignement
    boxedwrap = (tbox) => block(
      spacing: 0pt,
      width: 100%,
      inset: if boxed-align == left {
        (left: 1em)
      } else if boxed-align == right {
        (right: 1em)
      } else {
        0pt
      },
      boxedshadowwrap(align(title-style.at("boxed-align"), tbox))
    )
  }
  
  let showyblock = style(styles => {
    let title-size = measure(title, styles)
    
    block(
      width: width,
      fill: frame.at("body-color", default: white),
      radius: frame.at("radius", default: 5pt),
      inset: 0pt,
      outset: if title-style.at("boxed", default: false) and title != "" {
        // Get mid position by substracting title's half height plus
        // body's top inset
        (top: -(title-size.height/2 + showy-inset(top, showy-section-inset("body", frame))))
      } else {
        0pt
      },
      breakable: breakable,
      stroke: showy-stroke(frame)
    )[
      /*
       * Title of the showybox
       */
      #if title != "" {
        boxedwrap(
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
  })

  alignwrap(
    shadowwrap(showyblock)
  )
}