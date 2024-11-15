#import "template.typ": *

#show: report.with(
  title: [ Projet #smallcaps[Mogpl] \ Optimisation robuste dans l'incertain total ],
  course: [ Modélisation, optimisation, graphes, programmation linéaire ],
  authors: ("Paul Chambaz", "Zélie van der Meer"),
  university: [ Sorbonne Université ],
  reference: [ Master #smallcaps[Ai2d] & #smallcaps[Sar] M1 -- 2024 ],
)

// example plot
// #plot-performance(
//   load-performance-data("data/exponential.csv"),
//   caption: [ Analyse de performance \ (échelle : $log(x)$) ],
//   x-label: [ Taille d'instance ],
//   y-label: [ Temps d'exécution (ms) ],
//   show-regression: true,
//   scaler: (x) => calc.log(x),
// )

== Partie 1

=== 1.1
On traite la linéarisation du critère maximun dans le contexte de la sélection de projets sous incertitude. On cherche la solution dont l'évaluation dans le pire scénario est la meilleure possible.

Considérons l'ensemble de $n = 10$ projets, caractérisés comme suit par des coût ($c$) et deux variables d'utilités ($s^1$ et $s^2$) :
$
c = (60, 10, 15, 20, 25, 20, 5, 15, 20, 60) \
s^1 = (70, 18, 16, 14, 12, 10, 8, 6, 4, 2) \
s^2 = (2, 4, 6, 8, 10, 12, 14, 16, 18, 70)
$

Dans ce contexte, une solution réalisable est caractérisée par un vecteur $x in {0,1}^n$ satisfaisant la contrainte budgétaire $sum_(j=1)^n c_j x_j <= B$ avec $B = 100$. Pour toute solutoin $x$, on note $z(x) = (z_1(x), z_2(x))$ son vecteur image où l'utilité dans chaque scénario est donnée par :
$
cases(
  z_1(x) = sum_(j=1)^n s^1_j x_j \
  z_2(x) = sum_(j=1)^n s^2_j x_j
)
$

Le problème d'optimisation initial s'écrit alors :
$
max_(x in X) g(x) = max_(x in X) min{z_1(x), z_2(x)}
$

où $X$ représente l'ensemble des solutions réalisables défini par :
$
X = {x in {0,1}^n : sum_(j=1)^n c_j x_j <= B}
$

Pour obtenir un programme linéraire en variables mixtes, nous introduisons une variable $alpha$ représentant le minimum des utilités. Le problème se reformule alors :
$
max alpha \
cases(
  alpha <= sum_(j=1)^n s^1_j x_j \
  alpha <= sum_(j=1)^n s^2_j x_j \
  sum_(j=1)^n c_j x_j <= 100 \
  x_j in {0,1} quad forall j in {1,...,n} \
  alpha in RR
)
$

L'implémentation de ce programme linéaire a été réalisée en Python à l'aide de la librairie `pulp` et du solveur `gurobi` (voir le fichier `src/q11.py`). La résolution nous fournit les résultats suivants.

La solution optimale $x^*$ est un vecteur binaire où seuls les projets 2, 3, 4, 7, 8 et 9 sont sélectionnés, ce qui s'écrit :

$ x^* = (0, 1, 1, 1, 0, 0, 1, 1, 1, 0) $

Cette solution présente les caractéristiques suivantes :

- Coût total: $85K €$, ce qui respecte bien la contrainte budgétaire de $100K €$
- Vecteur image : $z(x^*) = (66, 66)$
- Valeur optimale : $g(x^*) = 66$

Il est intéressant de noter que cette solution atteint exactement la même utilité dans les deux scénarios ($z_1(x^*) = z_2(x^*) = 66$), ce qui suggère un bon équilibre entre les deux scénarios.

Il est intéressant de noter que l'utilisation d'autres solveurs nous conduit à une solution alternative :

- Vecteur $x^* : [0, 0, 1, 1, 1, 1, 1, 1, 0, 0]$
- Coût total : $100K €$
- Valeur image : $z(x^*) = (66, 66)$
- Valeur optimale : $g(x^*) = 66$

Bien que ces deux solutions soient équivalentes du point de vue de notre critère maximin, atteignant la même valeur optimale $g(x^*) = 66$, elles diffèrent par leur efficience économique. En effet, la seconde solution mobilise l'intégralité du budget pour atteindre le même niveau d'utilité que la première qui n'en utilise que 85%. La minimisation des coûts n'étant pas un objectif de notre programme linéaire, ces deux solutions sont mathématiquement équivalentes, bien que la première apparaisse plus avantageuse d'un point de vue pratique.

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
