#import "template.typ": *

#show: report.with(
  title: [ Projet #smallcaps[Mogpl] \ Optimisation robuste dans l'incertain total ],
  course: [ Modélisation, optimisation, graphes, programmation linéaire ],
  authors: ("Paul Chambaz", "Zélie van der Meer"),
  university: [ Sorbonne Université ],
  reference: [ Master #smallcaps[Ai2d] & #smallcaps[Sar] M1 -- 2024 ],
)

== Partie 1

=== 1.1
#lorem(120)

// #plot-performance(
//   load-performance-data("data/linear.csv"),
//   caption: [ Analyse de performance ],
//   x-label: [ Taille d'instance ],
//   y-label: [ Temps d'exécution (ms) ],
//   show-regression: true,
// )

// #plot-performance(
//   load-performance-data("data/exponential.csv"),
//   caption: [ Analyse de performance ],
//   x-label: [ Taille d'instance ],
//   y-label: [ Temps d'exécution (ms) ],
// )

#plot-performance(
  load-performance-data("data/exponential.csv"),
  caption: [ Analyse de performance \ (échelle : $log(x)$) ],
  x-label: [ Taille d'instance ],
  y-label: [ Temps d'exécution (ms) ],
  show-regression: true,
  scaler: (x) => calc.log(x),
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
