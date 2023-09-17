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

/*
 * Function: showybox()
 *
 * Description: Creates a showybox
 *
 * Parameters:
 * - title: Title of the showybox
 * - footer: Footer of the showybox
 * - frame:
 *   + title-color: Color used as background color where the title goes
 *   + body-color: Color used as background color where the body goes
 *   + footer-color: Color used as background color where the footer goes
 *   + border-color: Color used for the showybox's border
 *   + inset: Inset for the title, body, and footer, if title-inset, body-inset, footer-inset aren't given
 *   + radius: Showybox's radius
 *   + thickness: Border width of the showybox
 *   + dash: Showybox's border style
 * - title-style:
 *   + color: Text color
 *   + weight: Text weight
 *   + align: Text align
 *   + boxed: Whether the title's block should be apart or not
 *   + boxed-align: Alignement of the boxed title
 *   + sep-thickness: Title's separator thickness
 * - body-styles:
 *   + color: Text color
 *   + align: Text align
 * - footer-style:
 *   + color: Text color
 *   + weight: Text weight
 *   + align: Text align
 *   + sep-thickness: Footer's separator thickness
 * - sep:
 *   + width: Separator's width
 *   + dash: Separator's style (as a 'line' dash style)
 *   + gutter: Separator's gutter space
 * - shadow:
 *   + color: Shadow color
 *   + offset: How much to offset the shadow in x and y direction either as a length or a dictionary with keys `x` and `y`
 * - width: Showybox's width
 * - align: Alignement of the showybox inside its container
 * - breakable: Whether the showybox can break if it reaches the end of its container
 * - spacing: Space above and below the showybox
 * - above: Space above the showybox
 * - below: Space below the showybox
 * - body: The content of the showybox
 */
 #let showybox(
  frame: (
    title-color: black,
    body-color: white,
    border-color: black,
    footer-color: luma(220),
    inset: (x: 1em, y: .65em),
    radius: 5pt,
    thickness: 1pt,
    dash: "solid"
  ),
  title-style: (
    color: white,
    weight: "bold",
    align: left,
    boxed: false,
    sep-thickness: 1pt
  ),
  boxed-style: (
    anchor: (
      y: horizon,
      x: left,
    ),
    offset: 0pt // Only in x direction
  ),
  body-style: (
    color: black,
    align: left
  ),
  footer-style: (
    color: luma(85),
    weight: "regular",
    align: left,
    sep-thickness: 1pt,
  ),
  sep: (
    width: 1pt,
    dash: "solid",
    gutter: 0.65em
  ),
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
      weight: title-style.at("weight", default: "bold"),
      align: title-style.at("align", default: left),
      boxed: title-style.at("boxed", default: false),
      sep-thickness: title-style.at("sept-thickness", default: 1pt)
    ),
    boxed-style: (
      anchor: (
        y: boxed-style.at("anchor", default: (:)).at("y", default: horizon),
        x: boxed-style.at("anchor", default: (:)).at("x", default: left),
      ),
      offset: boxed-style.at("offset", default: 0pt),
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
    }
  )
  // Add title, body and footer inset (if present)
  for section-inset in ("title-inset", "body-inset", "footer-inset") {
    let value = frame.at(section-inset, default: none)
    if value != none {
      props.frame.insert(section-inset, value)
    }
  }


  /*
   * Useful sizes and alignements
   */
  let title-size = measure(title, styles)
  let title-block-height = title-size.height + showy-value-in-direction(top, showy-section-inset("title", props.frame), 0pt) + showy-value-in-direction(bottom, showy-section-inset("title", props.frame), 0pt)

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
   * Optionally create one or two wrapper
   * functions to add a shadow.
   */
  let shadowwrap = (sbox) => sbox
  let boxedtitleshadowwrap = (tbox) => tbox
  if props.shadow != none {
    shadowwrap = (sbox) => {

      /* If it has a boxed title, leave some space to avoid collisions
         with other elements next to the showybox*/
      if title != "" and props.title-style.boxed {
        if props.boxed-style.anchor.y == top {
          v(title-block-height)
        } else if props.boxed-style.anchor.y == horizon{
          v(title-block-height - 10pt)
        } // Otherwise, no space is needed

      }

      block(
        breakable: breakable,
        radius: props.frame.radius,
        fill: props.shadow.color,
        spacing: 0pt,
        outset: (
          left: -props.shadow.offset.x,
          right: props.shadow.offset.x,
          bottom: props.shadow.offset.y,
          top: -props.shadow.offset.y
        ),
        /* If it have a boxed title, substract some space to
           avoid the shadow to be body + title height, and only
           body height */
        if title != "" and props.title-style.boxed {
          if props.boxed-style.anchor.y == top {
            v(-title-block-height)
          } else if props.boxed-style.anchor.y == horizon {
            v(-title-block-height + 10pt)
          } // Otherwise do nothing

          sbox
        } else {
          sbox
        }
      )
    }

    if title != "" and props.title-style.boxed and props.boxed-style.anchor.y != bottom {
      /* Due to some uncontrolable spaces between blocks, there's the need
         of adding an offset to `bottom-outset` to avoid an unwanted space
         between the boxed-title shadow and the body. Hopefully in the
         future a more pure-mathematically formula will be found. At the
         moment, this 'trick' solves all cases where a showybox title has
         only one line of heights */
      let bottom-outset = if props.boxed-style.anchor.y == horizon {
        10pt + props.frame.thickness/2 - .15pt
      } else {
        props.frame.thickness/2 - .15pt
      }

      boxedtitleshadowwrap = (tbox) => block(
        breakable: breakable,
        radius: (
          top-left: showy-value-in-direction("top-left", props.boxed-style.radius, 5pt),
          top-right: showy-value-in-direction("top-right", props.boxed-style.radius, 5pt)
        ),
        fill: props.shadow.color,
        spacing: 0pt,
        outset: (
          left: -props.shadow.offset.x,
          right: props.shadow.offset.x,
          top: -props.shadow.offset.y,
          bottom: -bottom-outset
        ),
        tbox
      )
    }
  }

  let showyblock = {

    if title != "" and props.title-style.boxed {
      if props.boxed-style.anchor.y == top {
      v(title-block-height)
      } else if props.boxed-style.anchor.y == horizon {
        v(title-block-height - 10pt)
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
        if props.boxed-style.anchor.y == bottom {
          block(
            width: 100%,
            spacing: 0pt,
            align(
              props.boxed-style.anchor.x,
              showy-title(props, title)
            )
          )
        } else {
          if props.boxed-style.anchor.y == horizon {
            // Leave some space for putting a horizon-boxed title
            v(10pt)
          }
          place(
            top + props.boxed-style.anchor.x,
            dy: if props.boxed-style.anchor.y == top {
              -title-block-height
            } else if props.boxed-style.anchor.y == horizon {
              -title-block-height + 10pt
            },
            dx: props.boxed-style.offset,
            boxedtitleshadowwrap(showy-title(props, title))
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
  }

  alignwrap(
    shadowwrap(showyblock)
  )
})