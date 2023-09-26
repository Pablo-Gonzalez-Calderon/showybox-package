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
#import "lib/sections.typ": *
#import "lib/shadows.typ": *
#import "lib/state.typ": *

/*
 * Function: showybox()
 *
 * Description: Creates a showybox
 *
 */
 #let showybox(
  frame: (:),
  title-style: (:),
  boxed-style: (:),
  body-style: (:),
  footer-style: (:),
  sep: (:),
  shadow: none,
  width: 100%,
  breakable: false,
  /* align: none, / collides with align-function */
  /* spacing, above, and below are by default what's set for all `block`s */
  title: "",
  footer: "",
  ..body
) = style(styles => {
  /*
   * Complete and store all the dictionary-like-properties inside a
   * single dictionary. This will improve readability and avoids to
   * constantly have a default option while accessing
   */
  let props = (
    frame: (
      title-color: frame.at("title-color", default: black),
      body-color: frame.at("body-color", default: white),
      border-color: frame.at("border-color", default: black),
      footer-color: frame.at("footer-color", default: luma(220)),
      inset: frame.at("inset", default: (x: 1em, y: .65em)),
      radius: frame.at("radius", default: 5pt),
      thickness: frame.at("thickness", default: 1pt),
      dash: frame.at("dash", default: "solid"),
    ),
    title-style: (
      color: title-style.at("color", default: white),
      weight: title-style.at("weight", default: "regular"),
      align: title-style.at("align", default: left),
      boxed: title-style.at("boxed", default: false),
      sep-thickness: title-style.at("sept-thickness", default: 1pt)
    ),
    boxed-style: (
      anchor: (
        y: boxed-style.at("anchor", default: (:)).at("y", default: horizon),
        x: boxed-style.at("anchor", default: (:)).at("x", default: left),
      ),
      offset: if type(boxed-style.at("offset", default: 0pt)) != dictionary {
        (
          x: boxed-style.at("offset", default: 0pt),
          y: boxed-style.at("offset", default: 0pt),
        )
      } else {
        (
          x: boxed-style.at("offset").at("x", default: 0pt),
          y: boxed-style.at("offset").at("y", default: 0pt)
        )
      },
      radius: boxed-style.at("radius", default: 5pt)
    ),
    body-style: (
      color: body-style.at("color", default: black),
      align: body-style.at("align", default: left)
    ),
    footer-style: (
      color: footer-style.at("color", default: luma(85)),
      weight: footer-style.at("weight", default: "regular"),
      align: footer-style.at("align", default: left),
      sep-thickness: footer-style.at("sep-thickness", default: 1pt),
    ),
    sep: (
      width: sep.at("width", default: 1pt),
      dash: sep.at("dash", default: "solid"),
      gutter: sep.at("gutter", default: 0.65em)
    ),
    shadow: if shadow != none {
      if type(shadow.at("offset", default: 4pt)) != dictionary {
        (
          offset: (
            x: shadow.at("offset", default: 4pt),
            y: shadow.at("offset", default: 4pt),
          ),
          color: shadow.at("color", default: luma(128))
        )
      } else {
        (
          offset: (
            x: shadow.at("offset").at("x", default: 4pt),
            y: shadow.at("offset").at("y", default: 4pt),
          ),
          color: shadow.at("color", default: luma(128))
        )
      }
    } else {
      none
    },
    breakable: breakable,
    title: title
  )
  // Add title, body and footer inset (if present)
  for section-inset in ("title-inset", "body-inset", "footer-inset") {
    let value = frame.at(section-inset, default: none)
    if value != none {
      props.frame.insert(section-inset, value)
    }
  }

  _showy-id.step()

  /*
   * Get title height and store it in the state. This pre-renders
   * the title inside a container similar to the "final" one,
   * depending if it's container's width is given as a ratio type
   * or a length type.
   */
  locate(loc => {
    let my-id = _showy-id.at(loc)
    let my-state = _showy-state(my-id.first())

    if type(width) == ratio {
      layout(size => {
        // Get full container's width in a length type
        let container-width = size.width * width

        let pre-rendered = block(
          spacing: 0pt,
          width: container-width,
          fill: yellow,
          inset: (x: 1em),
          showy-title(props, title)
        )

        place(
          top,
          hide(pre-rendered)
        )

        let rendered-size = measure(pre-rendered, styles)

        // Store the height in the state
        my-state.update(rendered-size.height)

      })
    } else {
      // Pre-rendering "normally" will be effective
      let pre-rendered = block(
        spacing: 0pt,
        width: width,
        fill: yellow,
        inset: (x: 1em),
        showy-title(props, title)
      )

      place(
        top,
        hide(pre-rendered)
      )

      let rendered-size = measure(pre-rendered, styles)

      // Store the height in the state
      my-state.update(rendered-size.height)
    }
  })

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

  let showyblock = locate(loc => {
    let my-id = _showy-id.at(loc)
    let my-state = _showy-state(my-id.first())

    if title != "" and props.title-style.boxed {
      if props.boxed-style.anchor.y == bottom {
        v(my-state.at(loc))
      } else if props.boxed-style.anchor.y == horizon {
        v(my-state.at(loc)/2)
      } // Otherwise don't add extra space
    }

    block(
      width: width,
      fill: props.frame.body-color,
      radius: props.frame.radius,
      inset: 0pt,
      spacing: 0pt,
      breakable: breakable,
      stroke: showy-stroke(props.frame)
    )[
      /*
       * Title of the showybox
       */
      #if title != "" and not props.title-style.boxed {
        showy-title(props, title)
      } else if title != "" and props.title-style.boxed {
        if props.boxed-style.anchor.y == top {
          block(
            width: 100%,
            spacing: 0pt,
            align(
              props.boxed-style.anchor.x,
              move(
                dx: props.boxed-style.offset.x,
                dy: props.boxed-style.offset.y,
                block(
                  spacing: 0pt,
                  inset: (x: 1em),
                  showy-title(props, title)
                )
              )
            )
          )
        } else {
          if props.boxed-style.anchor.y == horizon {
            // Leave some space for putting a horizon-boxed title
            v(my-state.at(loc)/2)
          }
          place(
            top + props.boxed-style.anchor.x,
            dx: props.boxed-style.offset.x,
            dy: props.boxed-style.offset.y + if props.boxed-style.anchor.y == bottom {
              -my-state.at(loc)
            } else if props.boxed-style.anchor.y == horizon {
              -my-state.at(loc)/2
            },
            block(
              spacing: 0pt,
              inset: (x: 1em),
              showy-boxed-title-shadow(props, showy-title(props, title))
            )
          )
        }
      }

      /*
       * Body of the showybox
       */
      #showy-body(props, ..body)

      /*
       * Footer of the showybox
       */
      #if footer != "" {
        showy-footer(props, footer)
      }
    ]
  })

  alignwrap(
    showy-shadow(props, showyblock)
  )
})