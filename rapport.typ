#import "@preview/cetz:0.3.0"

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
        [ Paul Chambaz & Simon Groc ],
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
        [#counter(page).display(
          "1",
        )],
        h(1fr),
        [ Master #smallcaps[Ai2d] M1 -- 2024 ],
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
