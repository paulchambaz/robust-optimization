#import "template.typ": *
#import "@preview/cetz:0.3.1": canvas, draw

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

Considérons l'ensemble de $p = 10$ projets, caractérisés comme suit par des coût ($c$) et deux variables d'utilités ($s^1$ et $s^2$) :
$
c = (60, 10, 15, 20, 25, 20, 5, 15, 20, 60) \
s^1 = (70, 18, 16, 14, 12, 10, 8, 6, 4, 2) \
s^2 = (2, 4, 6, 8, 10, 12, 14, 16, 18, 70)
$

Dans ce contexte, une solution réalisable est caractérisée par un vecteur $x in {0,1}^p$ satisfaisant la contrainte budgétaire $sum_(j=1)^p c_j x_j <= B$ avec $B = 100$. Pour toute solutoin $x$, on note $z(x) = (z_1(x), z_2(x))$ son vecteur image où l'utilité dans chaque scénario est donnée par :
$
cases(
  z_1(x) = sum_(j=1)^p s^1_j x_j \
  z_2(x) = sum_(j=1)^p s^2_j x_j
)
$

Le problème d'optimisation initial s'écrit alors :
$
max_(x in X) g(x) = max_(x in X) min{z_1(x), z_2(x)}
$

où $X$ représente l'ensemble des solutions réalisables défini par :
$
X = {x in {0,1}^p : sum_(j=1)^p c_j x_j <= B}
$

Pour obtenir un programme linéraire en variables mixtes, nous introduisons une variable $alpha$ représentant le minimum des utilités. Le problème se reformule alors :
$
max alpha \
cases(
  alpha <= sum_(j=1)^p s^1_j x_j \
  alpha <= sum_(j=1)^p s^2_j x_j \
  sum_(j=1)^p c_j x_j <= 100 \
  x_j in {0,1} quad forall j in {1,...,p} \
  alpha in RR
)
$

L'implémentation de ce programme linéaire a été réalisée en Python à l'aide de la librairie `pulp` et du solveur `gurobi` (voir le fichier `src/q11.py`). La résolution nous fournit les résultats suivants.

La solution optimale $x^*$ est un vecteur binaire où seuls les projets 2, 3, 4, 7, 8 et 9 sont sélectionnés, ce qui s'écrit :

#figure[
  Vecteur $x^* : (0, 1, 1, 1, 0, 0, 1, 1, 1, 0)$ \
  Coût total : $85K €$ \
  Valeur image : $z(x^*) = (66, 66)$ \
  Valeur optimale : $g(x^*) = 66$
]

Il est intéressant de noter que cette solution atteint exactement la même utilité dans les deux scénarios ($z_1(x^*) = z_2(x^*) = 66$), ce qui suggère un bon équilibre entre les deux scénarios.

Il est intéressant de noter que l'utilisation d'autres solveurs nous conduit à une solution alternative :

#figure[
  Vecteur $x^* : (0, 0, 1, 1, 1, 1, 1, 1, 0, 0)$ \
  Coût total : $100K €$ \
  Valeur image : $z(x^*) = (66, 66)$ \
  Valeur optimale : $g(x^*) = 66$
]

Bien que ces deux solutions soient équivalentes du point de vue de notre critère maxmin, atteignant la même valeur optimale $g(x^*) = 66$, elles diffèrent par leur efficience économique. En effet, la seconde solution mobilise l'intégralité du budget pour atteindre le même niveau d'utilité que la première qui n'en utilise que 85%. La minimisation des coûts n'étant pas un objectif de notre programme linéaire, ces deux solutions sont mathématiquement équivalentes, bien que la première apparaisse plus avantageuse d'un point de vue pratique.

=== 1.2
Dans cette partie, nous traitons la linéarisation du critère minmax regret, qui est très similaire au problème précédent mais avec une approche différente de l'évaluation des solutions. En effet, plutôt que de considérer directement les utilités dans chaque scénario, nous nous intéressons maintenant au "regret" - c'est-à-dire à la différence entre l'utilité obtenue et la meilleure utilité possible dans chaque scénario.

Reprenons les données de la partie 1.1 avec les mêmes vecteurs de coûts et d'utilités.

La première étape consiste à déterminer les utilités optimales $z^*_1$ et $z^*_2$ pour chaque scénario, qui sont obtenues en résolvant deux problèmes d'optimisations distincts :
$
z^*_i = max_(x in X) z_i(x) = max_(x in X) sum_(j=1)^p s_i_j x_j quad forall i in {1,2}
$

où $X$ représente toujours l'ensemble des solutions réalisables défini par :
$
X = {x in {0,1}^p : sum_(j=1)^p c_j x_j <= B}
$

Le critère minmax regret cherche alors à minimiser le regret maximum sur l'ensemble des scénarios. Pour toute solution $x$, le regret dans le scénario $i$ est donné par $r(x,s_i) = z^*_1 - z_i(x)$. Le problème se formule alors :
$
min_(x in X) g(x) = min_(x in X) max{r(x,s_1), r(x,s_2)}
$

Pour obtenir un programme linéaire en variables mixtes, nous introduisons une variables $beta$ représentant le regret maximum. Le problème se reformule alors :
$
min beta \
cases(
  beta >= z^*_1 - sum_(j=1)^p s^1_j x_j \
  beta >= z^*_2 - sum_(j=1)^p s^2_j x_j \
  sum_(j=1)^p c_j x_j <= 100 \
  x_j in {0,1} quad forall j in {1,...,p} \
  alpha in RR
)
$

L'implémentation de ce programme linéaire a été réalisée en Python (voir le fichier `src/q12.py`). La résolution nous fournit les résultats suivants.

#figure[
  Vecteur $x^* : (0, 1, 1, 0, 0, 1, 1, 1, 1, 0)$ \
  Coût total : $85K €$ \
  Regrets : $r(x^*) = (50, 48)$ \
  Valeur optimale : $g(x^*) = 50$
]

Le regret maximum est presque équilibré entre les deux scénarios (50 et 48), ce qui suggère que la solution est bien équilibrée au sens de ce nouveau critère. On note finalement que cette solution est différente de la solution proposée à la question 1.1, un nouveau critère résulte bien ici en une solution différente.

=== 1.3
On cherche à représenter l'utilité de chacune des solutions $x^*_1$, $x^*_2$, $x^*$ et $x'^*$ dans chacun des scénarios.
L'implémentation du calcul des points a été réalisée en Python (voir le fichier `src/q13.py`). On obtient les points $x^*_1 = (112, 26)$, $x^*_2 = (20, 118)$, $x^* = (66, 66)$ et $x'^* = (62, 70)$ illustrés dans le graphe suivant :

#figure(caption: [ Représentation des différentes solutions dans chaque scénarios ])[
  #canvas(length: 5cm, {
    import draw: *

    set-style(
      mark: (fill: black),
    )

    let scalar_to_screen(x) = (x / 120)
    let vec_to_screen(x, y) = (scalar_to_screen(x), scalar_to_screen(y))

    grid(vec_to_screen(0, 0), vec_to_screen(130, 130), step: scalar_to_screen(10), stroke: gray + 0.2pt)

    line(vec_to_screen(0, 0), vec_to_screen(130, 0), mark: (end: "stealth"), stroke: 0.5pt)
    line(vec_to_screen(0, 0), vec_to_screen(0, 130), mark: (end: "stealth"), stroke: 0.5pt)
    for i in range(0, 130, step: 10) {
      let x = vec_to_screen(i, 0)
      let y = vec_to_screen(0, i)

      line((scalar_to_screen(i), 0), (scalar_to_screen(i), -0.02), stroke: 0.5pt)
      line((0, scalar_to_screen(i)), (-0.02, scalar_to_screen(i)), stroke: 0.5pt)
      content(
        (scalar_to_screen(i), -0.05),
        angle: 45deg,
        anchor: "north",
        text(size: 0.7em)[#i]
      )
      content(
        (-0.04, scalar_to_screen(i)),
        anchor: "east",
        text(size: 0.7em)[#i]
      )
    }

    circle(vec_to_screen(112, 26), radius: 1.5pt, stroke: none, fill: red, name: "z(x1*)")
    circle(vec_to_screen(20, 118), radius: 1.5pt, stroke: none, fill: red, name: "z(x2*)")
    circle(vec_to_screen(66, 66), radius: 1.5pt, stroke: none, fill: red, name: "z(x*)")
    circle(vec_to_screen(62, 70), radius: 1.5pt, stroke: none, fill: red, name: "z(x'*)")

    line("z(x1*)", "z(x2*)", stroke: .5pt)
    content("z(x1*)", anchor: "north", padding: .02, text()[ $z(x_1^*)$ ])
    content("z(x2*)", anchor: "west", padding: .02, text()[ $z(x_2^*)$ ])
    content("z(x*)", anchor: "north", padding: .02, text()[ $z(x^*)$ ])
    content("z(x'*)", anchor: "east", padding: .02, text()[ $z(x'^*)$ ])

    content(vec_to_screen(130, 0), anchor: "west", padding: .02, text()[ $z_1(x)$ ])
    content(vec_to_screen(0, 130), anchor: "south", padding: .02, text()[ $z_2(x)$ ])
  })
]

Le segment ici représenté illustre le fait que ces nouveaux critères ne sont pas une simple pondération des solutions $x^*_1$ et $x^*_2$. En effet, si on avait introduit une nouvelle variable $lambda in [0,1]$ et que l'on avait calculé par simple pondération des deux solutions une nouvelle solution en faisant :
$
(1 - lambda) x^*_1 + lambda x^*_2
$

Alors, on aurait obtenue une solution sur le segment. Cependant, graphiquement, on peut voir que nos deux solutions $x^*$ et $x'^*$ ne sont pas sur ce segment. Le critère maxmin et minmax regret sont donc bien différent et représente une nouvelle façon d'envisager le problème.

=== 1.4
On s'intéresse maintenant à l'évolution des temps de résolution des deux critères (maxmin et minmax regret) en fonction du nombre de scénarios ($n={5, 10, 15, ..., 50}$) et du nombre de projets ($p={10, 15, 20, ..., 50}$). Pour évaluer systématiquement leurs performances respectives, nous générons pour chaque couple $(n,p)$ un ensemble de 50 instances aléatoires. Les coûts et utilités de chaque instance sont tirés uniformément dans l'intervalle $[1, 100]$, avec un budget fixé à $50%$ de la somme totale des coûts des projets. Cette approche nous permet d'obtenir une distribution stastistiquement significative des temps de résolution pour différentes tailles de problèmes.

L'implémentation de ce programme linéaire a été réalisée en Python à l'aide de la librairie `pulp` et du solveur `gurobi` (voir le fichier `src/q14.py`). La résolution nous fournit les résultats suivants.

#figure(caption: [ Temps de résolution par nombre de projets ])[
  #image("data/figure_1.png")
]

#figure(caption: [ Temps de résolution par nombre de scénarios ])[
  #image("data/figure_2.png")
]

L'analyse des temps de résolution révèle un comportement différent entre l'augmentation du nombre de scénarios et celle du nombre de projets. la croissance linéaire observée avec le nombre de scénarios s'explique par la structure même des programmes linéaires : chaque nouveau scénario ajoute simplement un nouvel ensemble de contraintes linéaires au problème, sans modifier la nature combinatoire du problème sous-jacent.

En revance, l'ajout de nouveaux projets impacte directement la complexité combinatoire du problème. Le problème de sélection de projets sous contrainte budgétaire est une variante du problème du sac à dos, connu pour être NP-complet. Chaque nouveau projet double potentiellement l'espace des solutions à explorer, ce qui explique la croissance exponentielle observée des temps de calcul. En effet, avec $p$ projets, l'espace des solutions possibles est de taille $2^p$, et même les algorithmes les plus sophistiqués ne peuvent échapper à cette complexité fondamentale dans les pires cas.

Finalement, cette analyse suggère qu'il est relativement peu coûteux d'envisager de nombreux scénarios différents, tandis que l'ajout de nouveux projets complexifie rapidement le problème. Cette propriété est particulièrement intéressante dans un contexte d'optimisation robuste, où l'on cherche à se prémunir contre différents scénarios possibles : on peut explorer un large éventail de futurs possibles sans que cela n'impacte drastiquement la complexité de résolution du problème.

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
