/*
 * ShowyBox - A package for Typst
 * Pablo González Calderón and Showybox Contributors (c) 2023
 *
 * lib/sections.typ -- The package's file containing all the
 * internal functions for drawing sections.
 *
 * This file is under the MIT license. For more
 * information see LICENSE on the package's main folder.
 */

#import "func.typ": *

/*
 * Function: counter-family()
 *
 * Description: Used for break-style and tracking which parts of the box need to be differently styled.
 *
 * Parameters:
 * + id: The id of the box
 */
#let counter-family(id) = {
  let parent = counter(id)
  let parent-step() = parent.step()
  let get-child() = counter(id + str(parent.get().at(0)))
  return (parent-step, get-child)
}

/*
 * Function: showy-get-title-props()
 *
 * Description: Returns the title's properties
 *
 * Parameters:
 * + sbox-props: Showybox properties
 */
#let showy-get-title-props(sbox-props) = {
  /*
   * Properties independent of `boxed`
   */
  let props = (spacing: 0pt, fill: sbox-props.frame.title-color, inset: showy-section-inset("title", sbox-props.frame))

  /*
   * Properties dependent of `boxed`
   */
  if sbox-props.title-style.boxed-style != none {
    props = (
      props + (width: auto, radius: sbox-props.title-style.boxed-style.radius, stroke: showy-stroke(sbox-props.frame))
    )
  } else {
    props = (
      props
        + (
          width: 100%,
          radius: (
            top-left: showy-value-in-direction("top-left", sbox-props.frame.radius, 5pt),
            top-right: showy-value-in-direction("top-right", sbox-props.frame.radius, 5pt),
            bottom: 0pt,
          ),
          stroke: showy-stroke(sbox-props.frame, bottom: sbox-props.title-style.sep-thickness),
        )
    )
  }
  return props
}

/*
 * Function: showy-title()
 *
 * Description: Returns the title's block
 *
 * Parameters:
 * + sbox-props: Showybox properties
 */
#let showy-title(sbox-props) = block(
  ..showy-get-title-props(sbox-props),
  align(
    sbox-props.title-style.align,
    text(sbox-props.title-style.color, weight: sbox-props.title-style.weight, sbox-props.title),
  ),
)

/*
 * Function: showy-body()
 *
 * Description: Returns the body's block
 *
 * Parameters:
 * + sbox-props: Showybox properties
 * + body: Body content
 */
#let showy-body(sbox-props, ..body) = {
  let (parent-step, get-child) = counter-family("split-box-unique-counter-string")
  parent-step() // Place the parent counter once.
  // Keep track of a bunch of common variables that get re-used.
  // showy-borders is the strokes, because we need to turn parts of
  // it on and off for different sections of the box.
  let showy-borders = showy-stroke(sbox-props.frame)
  let body-borders = showy-borders
  body-borders.top = none
  body-borders.bottom = none
  // showy-inset is the insets, broken out into "top", "right", "bottom", "left" for the same reaon.
  let showy-inset = showy-section-inset("body", sbox-props.frame)
  // We need each corner's radius separately.
  let tl-radius = if type(sbox-props.frame.radius) == dictionary {
    calc.max(sbox-props.frame.radius.at("top-left", default: 0pt), sbox-props.frame.radius.at("top", default: 0pt))
  } else {
    sbox-props.frame.radius
  }
  let tr-radius = if type(sbox-props.frame.radius) == dictionary {
    calc.max(sbox-props.frame.radius.at("top-right", default: 0pt), sbox-props.frame.radius.at("top", default: 0pt))
  } else {
    sbox-props.frame.radius
  }
  // And the max of the top radius, but if we have a non-floating title it's 0.
  let top-radius = if (sbox-props.has_title) { 0pt } else {
    calc.max(tl-radius, tr-radius)
  }
  // The bottom corner's radii
  let bl-radius = if type(sbox-props.frame.radius) == dictionary {
    calc.max(
      sbox-props.frame.radius.at("bottom-left", default: 0pt),
      sbox-props.frame.radius.at("bottom", default: 0pt),
    )
  } else {
    sbox-props.frame.radius
  }
  let br-radius = if type(sbox-props.frame.radius) == dictionary {
    calc.max(
      sbox-props.frame.radius.at("bottom-right", default: 0pt),
      sbox-props.frame.radius.at("bottom", default: 0pt),
    )
  } else {
    sbox-props.frame.radius
  }
  // Similarly, if we have a footer we don't round the corners betweent the body and the footer.
  let bottom-radius = if (sbox-props.has_footer) { 0pt } else { calc.max(bl-radius, br-radius) }
  //These are how much you have to shift the contents to make them line up with the inset and the radius.
  //
  let tshift = (
    if type(showy-inset) == dictionary {
      showy-inset.at("top", default: showy-inset.at("y", default: showy-inset.at("rest", default: 0em)))
    } else { showy-inset }
      - top-radius
  )
  let bshift = (
    if type(showy-inset) == dictionary {
      showy-inset.at("bottom", default: showy-inset.at("y", default: showy-inset.at("rest", default: 0em)))
    } else { showy-inset }
      - bottom-radius
  )
  //No bottom-stroke for top-caps.
  let top-borders = showy-borders
  top-borders.bottom = none
  let default-header = block(
    stroke: top-borders,
    fill: sbox-props.frame.body-color,
    radius: (top-left: tl-radius, top-right: tr-radius, rest: 0pt),
    width: 100%,
    height: top-radius,
  )
  // No top-stroke for bottom-caps.
  let bottom-borders = showy-borders
  bottom-borders.top = none
  let default-footer = block(
    stroke: bottom-borders,
    //Radius is replaced with just the bottom radii
    radius: (bottom-left: bl-radius, bottom-right: br-radius, rest: 0pt),
    width: 100%,
    height: bottom-radius,
  )
  // Keep track of each time the header is placed on a page.
  // Then check if we're at the first placement (for header) or the last (footer)
  // If not, we'll use the 'between' forms of the  border lines.
  // Create the content of the cell to go at the top of the break. In the header.
  let cell-above = context {
    //So, get where we are, and increment the counter
    let header-count = get-child()
    header-count.step()
    let h = if sbox-props.frame.break-style.upper-break == none {
      // If it's not the first header and no styling, then
      // just the block with no space for the title.
      default-header
      v(tshift)
    } else {
      // If not the first header and we have styling, use the styling.
      // Add the cap, then the appropriate amount of inset.
      set par(spacing: 0pt, leading: 0pt)
      box(width: 100%, stroke: body-borders, fill: sbox-props.frame.body-color, height: showy-inset.top)
      v(-showy-inset.top)
      box(sbox-props.frame.break-style.upper-break)
      v(showy-inset.top)
    }

    //If this is the only header, do nothing
    if header-count.final() != (1,) {
      // If this is the first header...
      if header-count.get() == (0,) {
        //Hide an invisible copy so it's consistent height
        hide(h)
      } else {
        //Else display it
        h
      }
    } else { }
  }

  let cell-below = context {
    //So, get where we are, but do not increment the counter.
    let header-count = get-child()
    //If this is after the last header, it's the last column. Or if there's no special styling.
    let f = if header-count.get() == header-count.final() or sbox-props.frame.break-style.lower-break == none {
      default-footer
    } else {
      // If not the last header and we have styling, use the styling.
      // Add the appropriate amount of inset, then the cap.
      box(sbox-props.frame.break-style.lower-break)
    }

    //Footers can be displayed whenever it's more than one column and it's not the last.
    if header-count.final() != (1,) and header-count.get() != header-count.final() {
      f
    } else { }
  }
  //Disable the insets, because they're included.
  showy-inset.top = 0pt
  showy-inset.bottom = 0pt
  //So we have to use a grid (or table). The header and footer cells
  // give us the element that shows up at the start and end of every column.
  // A single column, with the obvous width.
  grid(
    columns: if sbox-props.shadow == none {
      sbox-props.width
    } else {
      100%
    },
    //And the header
    grid.header(grid.cell(cell-above)),
    //So, the first column gets a different-sized header, because of titles, and that was
    // screwing up the heights of everything after.  But we can just make that
    // a traditional cell, and have it splat over the top of an invisible copy of the header
    grid.cell(
      breakable: false,
      [
        #v(-measure(cell-above).height)
        // If there's a floating title, make space for it.
        #v(sbox-props.at("float-title-height", default: 0pt))
        #block(
          stroke: top-borders,
          fill: sbox-props.frame.body-color,
          radius: (top-left: tl-radius, top-right: tr-radius, rest: 0pt),
          width: 100%,
          height: top-radius + sbox-props.at("float-title-height", default: 0pt),
        )
        //Insert the title.
        #sbox-props.at("float-title", default: none)
      ],
    ),
    //Then the body cell
    grid.cell(
      breakable: sbox-props.breakable,
      fill: sbox-props.frame.body-color,
      stroke: body-borders,
      inset: showy-inset,
    )[
      //Take care of the inset+radius, shifting into the header-cap
      #v(tshift)
      //No change here.
      #align(
        sbox-props.body-style.align,
        text(
          sbox-props.body-style.color,
          body
            .pos()
            .map(block.with(spacing: 0pt, width: 100%, breakable: sbox-props.breakable))
            .join(
              block(
                spacing: sbox-props.sep.gutter,
                align(
                  left, // Avoid alignment errors
                  showy-line(sbox-props.frame)(
                    stroke: (
                      paint: sbox-props.frame.border-color,
                      dash: sbox-props.sep.dash,
                      thickness: sbox-props.sep.thickness,
                    ),
                  ),
                ),
              ),
            ),
        ),
      )
      //Take care of the inset+radius, shifting into the footer-cap
      #v(bshift)
    ],
    // Similarly the basic end-cap can just be another cell at the end,
    // which prevents all the layout convergence problems.
    grid.cell(fill: sbox-props.frame.body-color, default-footer),
    //And the footer cell.  Note that the fill happens here, not in cell-below
    // because cell-below comes after the content, which would put the fill over the text.
    // But the grid.cell doesn't, I guess?
    grid.footer(grid.cell(fill: sbox-props.frame.body-color, cell-below)),
  )
}

/*
 * Function: showy-footer()
 *
 * Description: Returns the footer's block
 *
 * Parameters:
 * + sbox-props: Showybox properties
 * + body: Body content
 */
#let showy-footer(sbox-props, footer) = block(
  width: 100%,
  spacing: 0pt,
  inset: showy-section-inset("footer", sbox-props.frame),
  fill: sbox-props.frame.footer-color,
  stroke: showy-stroke(sbox-props.frame, top: sbox-props.footer-style.sep-thickness),
  radius: (
    bottom-left: showy-value-in-direction("bottom-left", sbox-props.frame.radius, 5pt),
    bottom-right: showy-value-in-direction("bottom-right", sbox-props.frame.radius, 5pt),
    top: 0pt,
  ),
  align(
    sbox-props.footer-style.align,
    text(sbox-props.footer-style.color, weight: sbox-props.footer-style.weight, footer),
  ),
)
