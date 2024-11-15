#import "@preview/cetz:0.3.1": canvas, draw
#import "@preview/statastic:1.0.0": arrayLinearRegression

#let report(
  title: none,
  course: none,
  authors: (),
  university: none,
  reference: none,
  doc
) = {
  set text(size: 11pt, lang: "fr", font: "New Computer Modern")
  // #set text(size: 11pt, lang: "fr")

  set page(
    numbering: "1",
    margin: (x: 2cm, y: 3cm),
    header: [
      #set text(weight: 400, size: 10pt)
      #stack(dir: ttb, 
        stack(dir: ltr,
          course,
          h(1fr),
          [ #authors.join(" ", last: " & ") ],
        ),
        v(.1cm),
        line(length: 100%, stroke: .4pt)
      )
    ],
    footer: [
      #set text(weight: 400, size: 10pt)
      #stack(dir: ltr,
          university,
          h(1fr),
          [ #context { counter(page).display("1") } ],
          h(1fr),
          reference,
      )
    ],
  )

  set par(justify: true)

  show heading.where(
    level: 2
  ): it => block(width: 100%)[
    #v(0.2cm)
    #set align(center)
    #set text(13pt, weight: 500)
    #smallcaps(it.body)
    #v(0.2cm)
  ]

  show heading.where(
    level: 3
  ): it => text(
    size: 11pt,
    weight: "regular",
    style: "italic",
    it.body + [.],
  )

  align(center)[
    #v(.5cm)
    #rect(inset: .4cm, stroke: .4pt)[
      = #title
    ]
    #v(1cm)
  ]

  show: rest => columns(2, rest)

  doc
}

#let map(val, from_min, from_max, to_min, to_max) = {
  to_min + ((val - from_min) / (from_max - from_min)) * (to_max - to_min)
}

#let inv-value(funct, target-value, epsilon: 0.00001) = {
  if calc.abs(funct(target-value) - target-value) < epsilon {
    return target-value
  }
  
  let low = 0
  let high = target-value * 2
  
  while funct(high) < target-value {
    high = high * 2
  }
  
  for _ in range(50) {
    let mid = (low + high) / 2
    let mid-value = funct(mid)
    
    if calc.abs(mid-value - target-value) < epsilon {
      return mid
    }
    
    if mid-value < target-value {
      low = mid
    } else {
      high = mid
    }
  }
  
  return (low + high) / 2
}

#let plot-performance(
  data,
  caption: none,
  x-label: none,
  y-label: none,
  scaler: (x) => x,
  show-quartiles: false,
  show-regression: false,
  dimension: 6,
  ticks: 9,
) = {
  figure(
    caption: caption,
    canvas({
      import draw: *

      let copy-data = data.map(el => { el })
      let data = data.map(((x, y)) => {
        (x, scaler(y))
      })

      let x-values = data.map(((x, _)) => x)
      let y-values = data.map(((_, y)) => y)
      let x-min = calc.min(..x-values)
      let x-max = calc.max(..x-values)
      let y-min = calc.min(..y-values)
      let y-max = calc.max(..y-values)

      let reg = arrayLinearRegression(x-values, y-values)
      let slope = reg.at("slope")
      let intercept = reg.at("intercept")
      let r-squared = reg.at("r_squared")

      set-style(
        stroke: 0.4pt,
        mark: (fill: black),
        content: (padding: 1pt),
      )

      line((0, 0), (dimension * 1.05, 0), mark: (end: "stealth"), name: "x")

      line((0, 0), (0, dimension * 1.05), mark: (end: "stealth"), name: "y")

      grid(
        (0, 0),
        (dimension, dimension),
        step: dimension/ticks,
        stroke: gray + 0.2pt
      )

      for i in range(0, ticks + 1) {
        let x = i * dimension/ticks
        let tick-value = calc.round(x-min + (x-max - x-min) * (i/ticks))
        line((x, 0), (x, -0.1))
        content(
          (x, -0.2),
          angle: 45deg,
          anchor: "north",
          text(size: 0.7em)[#tick-value]
        )
      }

      for i in range(0, ticks + 1) {
        let y = i * dimension/ticks

        let transformed-value = y-min + (y-max - y-min) * (i/ticks)
        let original-value = inv-value(scaler, transformed-value)
        let scaled-value = calc.round(original-value)

        line((0, y), (-0.1, y))
        content(
          (-0.2, y),
          anchor: "east",
          text(size: 0.7em)[#scaled-value]
        )
      }

      for point in data {
        let x = map(point.at(0), x-min, x-max, 0, dimension)
        let y = map(point.at(1), y-min, y-max, 0, dimension)
        circle((x, y), stroke: none, fill: black, radius: .5pt)
      }

      if show-regression {
        let start-x = 0
        let end-x = dimension
        let start-y = map(slope * x-min + intercept, y-min, y-max, 0, dimension)
        let end-y = map(slope * x-max + intercept, y-min, y-max, 0, dimension)
        line(
          (start-x, start-y),
          (end-x, end-y),
          stroke: red + .5pt
        )
      }


      content(
        (dimension/2, -0.8),
        anchor: "north",
        text(size: .8em)[ #x-label ]
      )
      content(
        (-0.8, dimension/2),
        angle: 90deg,
        anchor: "south",
        padding: 5pt,
        text(size: .8em)[ #y-label ]
      )
    })
  )
}

#let load-performance-data(path) = {
  let data = csv(path)
  
  let rows = data.slice(1)
  
  let converted-data = rows.map(row => {
    let size = float(row.at(0))
    let time = float(row.at(1))
    (size, time)
  })
  
  converted-data.map(((size, time)) => (size, time))
}
