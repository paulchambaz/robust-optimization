#import "@preview/cetz:0.3.1": canvas, draw
#import "@preview/cetz-plot:0.1.0": plot, chart
#import "@preview/statastic:1.0.0"

// #set text(size: 11pt, font: "New Computer Modern")
#set text(size: 11pt)

#set page(
  numbering: "1",
  margin: (x: 2cm, y: 3cm),
  header: [
    #set text(weight: 400, size: 10pt)
    #stack(dir: ttb, 
      stack(dir: ltr,
        [ Modélisation, optimisation, graphes, programmation linéaire ],
        h(1fr),
        [ Paul Chambaz & Zélie van der Meer ],
      ),
      v(.1cm),
      line(length: 100%, stroke: .4pt)
    )
  ],
  footer: [
    #set text(weight: 400, size: 10pt)
    #stack(dir: ltr,
        [ Sorbonne Université ],
        h(1fr),
        [ #context {
            counter(page).display("1")
        } ],
        h(1fr),
        [ Master #smallcaps[Ai2d] & #smallcaps[Sar] M1 -- 2024 ],
    )
  ],
)

#set par(justify: true)

#show heading.where(
  level: 2
): it => block(width: 100%)[
  #v(0.2cm)
  #set align(center)
  #set text(13pt, weight: 500)
  #smallcaps(it.body)
]

#show heading.where(
  level: 3
): it => text(
  size: 11pt,
  weight: "regular",
  style: "italic",
  it.body + [.],
)

#let plot-performance(
  data,
  caption: none,
  x-label: none,
  y-label: none,
  log-scale: false,
  show-quartiles: false,
  show-line: false,
) = {
  figure(
    caption: caption,
    canvas({
      let x_values = data.map(((x, _)) => x)
      let y_values = data.map(((_, y)) => y)

      let x_min = calc.min(..x_values)
      let x_max = calc.max(..x_values)
      let y_min = calc.min(..y_values)
      let y_max = calc.max(..y_values)

      let f1(x) = calc.sin(x)

      plot.plot(
        size: (5, 5),
        x-min: x_min,
        x-max: x_max,
        y-min: y_min,
        y-max: y_max,
        {
          plot.add(
            f1,
            domain: (x_min, x_max),
            style: (stroke: black)
          )
        }
      )
    })
  )
}

// #let sample-data = parse-performance-data("your_data.csv")
#let sample-data = (
  (10, 0.001),
  (10, 0.0012),
  (10, 0.0009),
  (100, 0.1),
  (100, 0.11),
  (100, 0.09),
  (1000, 10),
  (1000, 11),
  (1000, 9),
  (10000, 1000),
  (10000, 1100),
  (10000, 900)
)

#align(center)[
  #v(.5cm)
  #rect(inset: .4cm, stroke: .4pt)[
    = Projet #smallcaps[Mogpl] \ Optimisation robuste dans l'incertain total
  ]
  #v(1cm)
]


#show: rest => columns(2, rest)

== Partie 1

=== 1.1
#lorem(120)

#plot-performance(
  sample-data,
  caption: [ Performance Analysis ],
  x-label: [ Instance size ],
  y-label: [ Execution time (ms) ],
  log-scale: false,
  show-quartiles: false,
  show-line: false,
)

=== 1.2
#lorem(100)

=== 1.3
#lorem(130)

=== 1.4
#lorem(110)

== Partie 2

=== 2.1
#lorem(120)

=== 2.2
#lorem(110)

=== 2.3
#lorem(150)

=== 2.4
#lorem(130)

=== 2.5
#lorem(140)

=== 2.6
#lorem(160)

== Partie 3

=== 3.1
#lorem(120)

=== 3.2
#lorem(130)

=== 3.3
#lorem(110)

=== 3.4
#lorem(100)
