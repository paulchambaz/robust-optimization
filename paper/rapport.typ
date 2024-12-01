#import "template.typ": *
#import "@preview/cetz:0.3.1": canvas, draw

#show: report.with(
  title: [ Projet #smallcaps[Mogpl] \ Optimisation robuste dans l'incertain total ],
  course: [ Modélisation, optimisation, graphes, programmation linéaire ],
  authors: ("Paul Chambaz", "Zélie van der Meer"),
  university: [ Sorbonne Université ],
  reference: [ Master #smallcaps[Ai2d] & #smallcaps[Sar] M1 -- 2024 ],
)

== Partie 1

=== 1.1
On traite la linéarisation du critère maximin dans le contexte de la sélection de projets sous incertitude. On cherche la solution dont l'évaluation dans le pire scénario est la meilleure possible.

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
s.c. cases(
  alpha <= sum_(j=1)^p s^1_j x_j \
  alpha <= sum_(j=1)^p s^2_j x_j \
  sum_(j=1)^p c_j x_j <= B
) \
x_j in {0,1} quad forall j in {1,...,p}, alpha in RR
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
z^*_i = max_(x in X) z_i(x) = max_(x in X) sum_(j=1)^p s_j^i x_j quad forall i in {1,2}
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
s.c. cases(
  beta >= z^*_1 - sum_(j=1)^p s^1_j x_j \
  beta >= z^*_2 - sum_(j=1)^p s^2_j x_j \
  sum_(j=1)^p c_j x_j <= B
) \
x_j in {0,1} quad forall j in {1,...,p}, beta in RR
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

Alors, on aurait obtenue une solution sur le segment. Cependant, graphiquement, on peut voir que nos deux solutions $x^*$ et $x'^*$ ne sont pas sur ce segment. Les critère maxmin et minmax regret sont donc bien différents et représentent une nouvelle façon d'envisager le problème.

=== 1.4
On s'intéresse maintenant à l'évolution des temps de résolution des deux critères (maxmin et minmax regret) en fonction du nombre de scénarios ($n={5, 10, 15, ..., 50}$) et du nombre de projets ($p={10, 15, 20, ..., 50}$). Pour évaluer systématiquement leurs performances respectives, nous générons pour chaque couple $(n,p)$ un ensemble de 50 instances aléatoires. Les coûts et utilités de chaque instance sont tirés uniformément dans l'intervalle $[1, 100]$, avec un budget fixé à $50%$ de la somme totale des coûts des projets. Cette approche nous permet d'obtenir une distribution stastistiquement significative des temps de résolution pour différentes tailles de problèmes.

L'implémentation de ce programme linéaire a été réalisée en Python à l'aide de la librairie `pulp` et du solveur `gurobi` (voir le fichier `src/q14.py`). La résolution nous fournit les résultats suivants.

#let data-q14 = csv("data/q14.csv", row-type: dictionary)
#let data-maxmin-project = data-q14.map(element => {
  (
    scenario: int(element.at("n_scenarios")),
    project: int(element.at("n_projects")),
    value: float(element.at("maxmin_time")),
  )
})
#let data-minmax-regret-project = data-q14.map(element => {
  (
    scenario: int(element.at("n_scenarios")),
    project: int(element.at("n_projects")),
    value: float(element.at("minmax_regret_time")),
  )
})

L'analyse des temps de résolution révèle un comportement différent entre l'augmentation du nombre de scénarios et celle du nombre de projets. la croissance linéaire observée avec le nombre de scénarios s'explique par la structure même des programmes linéaires : chaque nouveau scénario ajoute simplement un nouvel ensemble de contraintes linéaires au problème, sans modifier la nature combinatoire du problème sous-jacent.

#figure(caption: [ Maxmin par scénarios ])[
  #plot-performance-scenario(data-maxmin-project)
]

#figure(caption: [ Minmax regret par scénarios ])[
  #plot-performance-scenario(data-minmax-regret-project)
]

En revance, l'ajout de nouveaux projets impacte directement la complexité combinatoire du problème. Le problème de sélection de projets sous contrainte budgétaire est une variante du problème du sac à dos, connu pour être NP-complet. Chaque nouveau projet double potentiellement l'espace des solutions à explorer, ce qui explique la croissance exponentielle observée des temps de calcul. En effet, avec $p$ projets, l'espace des solutions possibles est de taille $2^p$, et même les algorithmes les plus sophistiqués ne peuvent échapper à cette complexité fondamentale dans les pires cas.

Finalement, cette analyse suggère qu'il est relativement peu coûteux d'envisager de nombreux scénarios différents, tandis que l'ajout de nouveux projets complexifie rapidement le problème. Cette propriété est particulièrement intéressante dans un contexte d'optimisation robuste, où l'on cherche à se prémunir contre différents scénarios possibles : on peut explorer un large éventail de futurs possibles sans que cela n'impacte drastiquement la complexité de résolution du problème.

#figure(caption: [ Maxmin par projets ])[
  #plot-performance-project(data-maxmin-project)
]

#figure(caption: [ Minmax regret par projets ])[
  #plot-performance-project(data-minmax-regret-project)
]

== Partie 2

=== 2.1
Soit le vecteur $L(z)$ défini pour tout $z in RR^n$ comme $(L_1(z), ..., L_n(z))$ où chaque composante $L_k (z) = sum_(i=1)^k z_(\(i\))$. Pour tout vecteur $z$, nous notons $z_(\(i\))$ la i-ème composante du vecteur $z$ trié par ordre croissant, représentant ainsi la i-ème plus faible valeur de $z$. D'où $L_k (z)$ représente la somme des k-ème plus faible utilités obtenues dans le problème initial.

On considère maintenant le programme linéaire suivant.

$
min sum_(i=1)^n a_(i k) z_i \
s.c. cases(
  sum_(i=1)^n a_(i k) = k
) \
a_(i k) in {0, 1} quad forall i in {1,...,n}
$

On cherche à trouver la solution de ce programme linéaire.

On a introduit pour représenter ce programme une nouvelle variable $a_(i k)$, une variable binaire avec la seule contrainte que la somme de ces variables doit être égale à $k$. Comem $a_(i k)$ est une variable binaire, la somme du $min$ revient à sommer des termes $z_i$ en les prenant si $a_(i k) = 1$ et en ne les prenant pas s $a_(i k) = 0$. On cherche ensuite à minimiser cette valeur.

On va maintenant montrer ce pourquoi $a_k = (a_(1 k), ..., a_(n k))$ de valeur $L_k (z)$ est la solution optimale de notre programme linéaire. Tout d'abord, montrons que $a_k$ est bien une solution réalisable.

$L_k (z)$ est une somme de exactement $k$ $z_i$, ils sont simplement triés par ordre croissant. On peut donc bien voir $L_k (z) = a_(i k) z_i$. Cela veut simplement dire que $a_(i k) = 1$ si $z_i$ fait parti des $k$ plus petites valeurs de $z$ et $a_(i k) = 0$ sinon. D'où  $sum_(i=1)^n a_(i k) = k$, la solution $a_k$ est bien une résolution réalisable.

Supposons maintenant par l'absurde qu'il existe $a'_k$ une solution optimale, donc de valeur inférieure à $L_k (z)$. On note $I$ l'ensemble des indices $i$ tels que $a'_(i k) = 1$ et $J$ l'ensemble des indices des $k$ plus petites composantes de $z$.
Si $I eq.not J$, et comme $|I| = |J|$, alors il existe $i_1 in I \\ J$ et $i_2 in J \\ I$.
On construit alors une nouvelle solution $a''_k$, tel que $a''_(i_1 k) = 0$ et $a''_(i_2 k) = 1$ et $a''_(i k) = a'_(i k)$ pour toutes les autres valeurs de $i$. Cette solution est toujours réalisable, et de plus, par définition de $j$, $z_(i_2) < z_(i_1)$, donc $sum_(i in J) a''_(i k) z_i < sum_(i in I) a'_(i k) z_i$. On a donc trouvé une solution avec une valeur inférieure à celle de $a'_k$, donc $a'_k$ n'est pas la solution optimale, ce qui est une contradiction.

Par conséquent, $L_k (z)$ est bien la solution optimale de notre programme linéaire.

=== 2.2
On part du programme linéaire relaxé:

$
min sum_(i=1)^n a_(i k) z_i \
s.c. cases(
  sum_(i=1)^n a_(i k) = k \
  a_(i k) <= 1 quad forall i in {1, ..., n}
) \
a_(i k) >= 0 quad forall i in {1, ..., n}
$

Pour construire le dual, on suit la méthode standard. Les contraintes du primal deviennent des variables dans le dual, les variables du primal deviennent des contraintes dans le dual et le sens de l'optimisation s'inverse. D'où le programme dual $D_k$ suivant :

$
max k r_k - sum_(i=1)^n b_(i k) \
s.c. cases(
  r_k - b_(i k) <= z_i quad forall i in {1, ..., n}
) \
b_(i k) >= 0 quad forall i in {1, ..., n}, r_k in RR
$

Soit $z = (2, 9, 6, 8, 5, 4)$, on cherche désormais à calculer la valeur de $L(z)$. On peut le faire de deux façons différentes, tout d'abord, en triant à la main le vecteur $z$, pour obtenir $z' = (2, 4, 5, 6, 8, 9)$ et calculant le vecteur cumulé, ce qui correspond à $L(z)$.

$
L_1 (z) = 2 \
L_2 (z) = 2 + 4 = 6 \
L_3 (z) = 6 + 5 = 11 \
L_4 (z) = 11 + 6 = 17 \
L_5 (z) = 17 + 8 = 25 \
L_6 (z) = 25 + 9 = 34 \
$

Ce qui nous permet de conclure :

$
L(z) = (2, 6, 11, 17, 25, 34)
$

On peut aussi écrire un programme linéaire pour résoudre le même dual, ce qui a été réalisé en Python (voir le fichier `src/q22.py`. La résolution nous fournit les résolutats suivants.

$
L(z) = (2, 6, 11, 17, 25, 34)
$

Les deux façon de calculer la valeur de $L(z)$ renvoie bien exactement les mêmes résultats, comme on attendu.

=== 2.3
On cherche à montrer le résultat suivant.

$
g = sum_(k=1)^n w'_k L_k (z) \
= sum_(k=1)^(n-1) (w_k - w_(k+1)) L_k (z) + w_n L_n (z) \
= sum_(k=1)^(n-1) w_k L_k (z) - sum_(k=1)^(n-1) w_(k+1) L_k (z) + w_n L_n (z) \

= [w_1 L_1 (z) + w_2 L_2 (z) + ... + w_(n-1) L_(n-1) (z)] \
- [w_2 L_1 (z) + ... + w_(n-1) L_(n-2) (z) + w_(n) L_(n-1) (z)] \
+ w_n L_n (z) \

= w_1 L_1 (z) + w_2 (L_2 (z) - L_1 (z)) + ... + w_(n-1) \
(L_(n-1) (z) - L_(n-2) (z)) + w_n (L_n (z) - L_(n-1) (z))
$

Avant de continuer le calcul de cette somme, on remarque que :

$
L_1 (z) = sum_(i=1)^1 z_(\(i\)) = z_(\(1\))
$

On s'intéresse aussi aux termes récurrents, ce qui nous permet d'observer que :

$
L_k (z) - L_(k-1) (z) \
= sum_(i=1)^k z_(\(i\)) - sum_(i=1)^(k-1) z_(\(i\)) \
= sum_(i=1)^(k-1) z_(\(i\)) + z_(\(k\)) - sum_(i=1)^(k-1) z_(\(i\)) \
= z_(\(k\))
$


D'où, si on reprend le calcul de $g$ :

$
g = w_1 z_(\(1\)) + w_2 z_(\(2\)) + ... + w_(n-1) z_(\(n-1\)) + w_(n) z_(\(n\)) \
= sum_(i=1)^n w_i z_(\(i\))
$

Ceci montre bien que:

$
g(x) = sum_(i=1)^n w_i z_(\(i\)) (x) = sum_(k=1)^n w'_k L_k (z(x))
$

=== 2.4
On va désormais passer de la formulation du dual à une formulation finale. On sait que $g(x) = sum_(i=1)^n w'_k L_k (z(x))$ et que $L_k (z(x)) = max k r_k - sum_(i=1)^n b_(i k)$ s.c. On va donc pouvoir combiner ces deux résultats pour arriver à un programme linéaire.

$
g(x) = sum_(k=1)^n w'_k L_k (z(x)) = sum_(k=1)^n w'_k max k r_k - sum_(i=1)^n b_(i k)
$

Comme les poids $w'_k$ sont positifs, on peut fusionner les max :

$
max g(x) = max sum_(k=1)^n w'_k (k r_k - sum_(i=1)^n b_(i k))
$

On obtient donc le programme linéaire suivant :

$
max sum_(k=1)^n w'_k (k r_k - sum_(i=1)^n b_(i k)) \
s.c. cases(
  r_k - b_(i k) <= sum_(j=1)^p s_j^i x_j quad forall i in {1, ..., n} \
  sum_(j=1)^p c_j x_j <= B
) \
b_(i k) >= 0 quad forall i,k in {1, ..., n} \
r_k in RR quad forall k in {1, ..., n} \
x_j in {0, 1} quad forall j in {1, ..., p}
$


L'implémentation de ce programme linéaire a été réalisé en Python (voir le fichier `src/q24.py`). La résolution nous fournit les résultats suivants.

#figure[
Vecteur $x^*$: $(0, 1, 1, 1, 0, 0, 1, 1, 1, 0)$ \
Coût total: $85K €$ \
Valeur image: $z(x*) = (66, 66)$ \
Valeur optimale: $g(x^*) = 198$ \
]

Cette solution est identique dans notre exemple à la solution obtenue durant la partie 1.1, ce qui n'est pas surprenant car les deux critères favorisent les solutions équilibrées. On peut tout de même faire varier les valeurs des poids et observer de nouvelles solutions, ce qui démontre bien l'utilité et le développement d'un tel critère : il permet à l'utilisateur d'adapter ses perceptions par rapport à ce qu'il anticipe pour avoir un résultat plus conforme à ses attentes. On note aussi que mettre les poids à $w = (1, 0)$ correspond à ne considérer que le pire des deux scénarios et revient bien au maxmin, on observe bien ce résultat en testant le programme linéaire.

=== 2.5
Pour le minOWA des regrets, on suit une approche similaire mais avec des modifications importantes. Comme pour le maxOWA, on commence par définir:

$
g(x) = sum_(i=1)^n w_i r(x, s_(\(i\)))
$

où $r(x, s_(\(i\)))$ représente le i-ème plus grand regret (en ordre décroissant). On peut définir :

$
L'_k (r) = sum_(i=1)^k r_(\(n-i+1\))
$

qui représente la somme des k plus grands regrets. Cette fonction peut être obtenu comme solution du programme linéaire suivant :

$
L'_k (r) = max sum_(i=1)^n a_(i k) (z_i^* - z_i) \
s.c. cases(
  sum_(i=1)^n a_(i k) = k \
  a_(i k) <= 1 quad forall i in {1, ..., n}
) \
a_(i k) >= 0 quad forall i in {1, ..., n}
$

Le dual de ce programme est :

$
min k r_k + sum_(i=1)^n b_(i k) \
s.c. cases(
  r_k + b_(i k) >= z_i^* - z_i
) \
b_(i k) >= 0 quad forall i,k in {1, ..., n}, \
r_k in RR quad forall k in {1, ..., n}
$

Par un raisonnement similaire à celui de la question 2.4, on obtient le programme linéaire final :

$
min sum_(k=1)^n w'_k (k r_k + sum_(i=1)^n b_(i k)) \
s.c. cases(
  r_k + b_(i k) >= z_i^* - sum_(j=1)^p s_j^i x_j quad forall i in {1, ..., n} \
  sum_(j=1)^p c_j x_j <= B
) \
b_(i k) >= 0 quad forall i,k in {1, ..., n} \
r_k in RR quad forall k in {1, ..., n} \
x_j in {0, 1} quad forall j in {1, ..., p}
$

L'implémentation de ce programm linéaire a été réalisée en Python (voir le fichier `src/q25.py`). La résolution nous fournit les résultats suivants.

#figure[
Vecteur $x^*$: $(0, 1, 1, 0, 0, 1, 1, 1, 1, 0)$ \
Coût total: $85K €$ \
Valeur image: $z(x*) = (50, 48)$ \
Valeur optimale: $g(x^*) = 148$ \
]

On note que cette solution est une fois encore la même que celle obtenue dans la partie 1.2. On peut, de la même façon qu'en 2.4, faire varier les poids pour obtenir de nouvelles solutions. Finalement, on note que prendre les poids $w = (1, 0)$ revient à faire exactement le minmax regret de la question 1.2.

=== 2.6
On s'intéresse maintenant à l'évolution des temps de résolution des deux critères (maxOWA et minOWA regret) en fonction du nombre de scénarios ($n={5, 10, 15, ..., 50}$) et du nombre de projets ($p={10, 15, 20, ..., 50}$). Pour évaluer systématiquement leurs performances respectives, nous générons pour chaque couple $(n,p)$ un ensemble de 50 instances aléatoires. Les coûts et utilités de chaque instance sont tirés uniformément dans l'intervalle $[1, 100]$, avec un budget fixé à $50%$ de la somme totale des coûts des projets.
Les poids sont choisis dans l'intervalle $[1, n]$ puis trié pour pouvoir respecter la conditions de poids décroissants.
Cette approche nous permet d'obtenir une distribution stastistiquement significative des temps de résolution pour différentes tailles de problèmes.

L'implémentation de ce programme linéaire a été réalisée en Python(voir le fichier `src/q26.py`). La résolution nous fournit les résultats suivants.

#let data-q26 = csv("data/q26.csv", row-type: dictionary)
#let data-maxowa-project = data-q26.map(element => {
  (
    scenario: int(element.at("n_scenarios")),
    project: int(element.at("n_projects")),
    value: float(element.at("maxowa_time")),
  )
})
#let data-minowa-regret-project = data-q26.map(element => {
  (
    scenario: int(element.at("n_scenarios")),
    project: int(element.at("n_projects")),
    value: float(element.at("minowa_regret_time")),
  )
})

#figure(caption: [ MaxOWA par scénarios ])[
  #plot-performance-scenario(data-maxowa-project)
]

#figure(caption: [ MinOWA regret par scénarios ])[
  #plot-performance-scenario(data-minowa-regret-project)
]

#figure(caption: [ MaxOWA par projets ])[
  #plot-performance-project(data-maxowa-project)
]

#figure(caption: [ MinOWA regret par projets ])[
  #plot-performance-project(data-minowa-regret-project)
]

== Partie 3

=== 3.1
On cherche à représenter le problème comme un problème linéaire.

On déduit que la fonction objective que l'on va minimiser est la longeur du chemin.

Il faut exprimer ce chemin de façon mathématique simple.

On propose de représenter le graphe sous la forme d'une matrice d'adjacence.

On choisi d'introduire les variables $x_(i j)$ qui représente si on prend ou non l'arc $(i, j)$ dans le chemin.

Ainsi, on peut représenter la longeur du chemin, avec $p$ le nombre de nœuds dans le graphe, dans le scénario $s$ par

$
sum_(i=0)^n sum_(j=0)^n t_(i j)^s x_(i j)
$

Cela étant dit on a encore deux problèmes à résoudre.

Tout d'abord, on est pas certain d'avoir un chemin valable, il faut, de la même façon que dans la première partie que $x in X$ avec $X$ l'ensemble des solutions admissible.

On va transformer le problème en un problème de flot.

Si on ajoute des capacités de 1 à chaque arc, alors dans un problème de flot, on ira sélectionner plusieurs chemins valables.

Dans notre cas on veut un unique chemin, donc on va ajouter que l'on veut que le flot soit de valeur 1.

On peut alors utiliser les formules des problèmes de flots pour modéliser nos contraintes.

$
sum_(i=0)^p x_(s i) = 1 \
sum_(i=0)^p x_(i t) = 1 \
sum_(i=0)^p x_(i v) - x_(v i) = 0 quad forall v eq.not s "et" v eq.not t
$

Cela nous donne le programme linéaire suivant :

$
min sum_(i=0)^n sum_(j=0)^n t_(i j)^s x_(i j) \
s.c. cases(
  sum_(i=0)^p x_(s i) = 1,
  sum_(i=0)^p x_(i t) = 1,
  sum_(i=0)^p x_(i v) - x_(v i) = 0 quad forall v eq.not s "et" v eq.not t
) \
x_(i j) in {0, 1} quad forall i, j in {1, ..., p}
$

=== 3.2
On implémente en python...

// Left graph in scenario 1
// Status: Optimal
// Vector x*: [[0, 1, 0, 0, 0, 0], [0, 0, 0, 1, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]]
// Selected arcs: [('a', 'b'), ('b', 'd'), ('d', 'f')]
// Optimal value g(x*): 8
// Left graph in scenario 2
// Status: Optimal
// Vector x*: [[0, 0, 1, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 1, 0, 0], [0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]]
// Selected arcs: [('a', 'c'), ('c', 'd'), ('d', 'f')]
// Optimal value g(x*): 4
// Left graph in scenario 1
// Status: Optimal
// Vector x*: [[0, 0, 0, 1, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 1, 0], [0, 0, 1, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0, 0]]
// Selected arcs: [('d', 'c'), ('a', 'd'), ('c', 'f'), ('f', 'g')]
// Optimal value g(x*): 5
// Left graph in scenario 2
// Status: Optimal
// Vector x*: [[0, 0, 1, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 1, 0, 0], [0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0]]
// Selected arcs: [('a', 'c'), ('c', 'e'), ('e', 'g')]
// Optimal value g(x*): 6

=== 3.3
On remarque que le problème initial, dans un scénario, de la partie 1 peut être modélisé par :

$
max z_s (x) \
s.c. cases(x in X)
$

Une fois le problème décrit comme tel, les quatres critères peuvent être écrit de la façon suivante:

La dimension du vecteur $x$ dépend du problème, dans le problème des projets, c'était un vecteur à une dimension, ici c'est deux dimensions.

#figure(caption: [Maxmin])[
  $
  max alpha \
  s.c cases(
    alpha <= z_s (x) quad forall s in {1\, ...\, n},
    x in X
  ) \
  x in {0,1} \
  alpha in RR
  $
]

#lorem(20)

#figure(caption: [Minmax regret])[
  $
  min beta \
  s.c cases(
    beta >= z_s^* - z_s (x) quad forall s in {1\, ...\, n},
    x in X
  ) \
  x in {0,1} \
  beta in RR
  $
]

#lorem(20)

#figure(caption: [Maxowa])[
  $
  max sum_(k=1)^n w'_k (k r_k - sum_(s=1)^n b_(s k)) \
  s.c cases(
    r_k - b_(s k) <= z_s (x) quad forall s in {1\, ...\, n},
    x in X
  ) \
  x in {0,1} \
  b_(s k) >= 0 quad forall s,k in {1, ..., n} \
  r_k in RR quad forall k in {1, ..., n}
  $
]

#lorem(20)

#figure(caption: [Minowa regret])[
  $
  min sum_(k=1)^n w'_k (k r_k + sum_(s=1)^n b_(s k)) \
  s.c cases(
    r_k - b_(s k) >= z_s^* - z_s (x) quad forall s in {1\, ...\, n},
    x in X
  ) \
  x in {0,1} \
  b_(s k) >= 0 quad forall s,k in {1, ..., n} \
  r_k in RR quad forall k in {1, ..., n}
  $
]

#lorem(100)

$
z_s (x) = -sum_(i=0)^n sum_(j=0)^n t_(i j)^s x_(i j) \
s.c. cases(
  sum_(i=0)^p x_(s i) = 1,
  sum_(i=0)^p x_(i t) = 1,
  sum_(i=0)^p x_(i v) - x_(v i) = 0 quad forall v eq.not s "et" v eq.not t
) \
x_(i j) in {0, 1} quad forall i, j in {1, ..., p}
$

#figure(caption: [Maxmin des chemins])[
  $
  max alpha \
  s.c cases(
    alpha <= -sum_(i=0)^n sum_(j=0)^n t_(i j)^s x_(i j) quad forall s in {1\, ...\, n},
  sum_(i=0)^p x_(s i) = 1,
  sum_(i=0)^p x_(i t) = 1,
  sum_(i=0)^p x_(i v) - x_(v i) = 0 quad forall v eq.not s "et" v eq.not t
  ) \
  x_(i j) in {0, 1} quad forall i, j in {1, ..., p} \
  alpha in RR
  $
]

#lorem(20)

#figure(caption: [Minmax regret des chemins])[
  $
  min beta \
  s.c cases(
    beta >= z_s^* + sum_(i=0)^n sum_(j=0)^n t_(i j)^s x_(i j) quad forall s in {1\, ...\, n},
  sum_(i=0)^p x_(s i) = 1,
  sum_(i=0)^p x_(i t) = 1,
  sum_(i=0)^p x_(i v) - x_(v i) = 0 quad forall v eq.not s "et" v eq.not t
  ) \
  x_(i j) in {0, 1} quad forall i, j in {1, ..., p} \
  beta in RR
  $
]

#lorem(20)

#figure(caption: [Maxowa des chemins])[
  $
  max sum_(k=1)^n w'_k (k r_k - sum_(s=1)^n b_(s k)) \
  s.c cases(
    r_k - b_(s k) <= -sum_(i=0)^n sum_(j=0)^n t_(i j)^s x_(i j) quad forall s in {1\, ...\, n},
  sum_(i=0)^p x_(s i) = 1,
  sum_(i=0)^p x_(i t) = 1,
  sum_(i=0)^p x_(i v) - x_(v i) = 0 quad forall v eq.not s "et" v eq.not t
  ) \
  x_(i j) in {0, 1} quad forall i, j in {1, ..., p} \
  b_(s k) >= 0 quad forall s,k in {1, ..., n} \
  r_k in RR quad forall k in {1, ..., n}
  $
]

#lorem(20)

#figure(caption: [Minowa regret des chemins])[
  $
  min sum_(k=1)^n w'_k (k r_k + sum_(s=1)^n b_(s k)) \
  s.c cases(
    r_k - b_(s k) >= z_s^* + sum_(i=0)^n sum_(j=0)^n t_(i j)^s x_(i j) quad forall s in {1\, ...\, n},
  sum_(i=0)^p x_(s i) = 1,
  sum_(i=0)^p x_(i t) = 1,
  sum_(i=0)^p x_(i v) - x_(v i) = 0 quad forall v eq.not s "et" v eq.not t
  ) \
  x_(i j) in {0, 1} quad forall i, j in {1, ..., p} \
  b_(s k) >= 0 quad forall s,k in {1, ..., n} \
  r_k in RR quad forall k in {1, ..., n}
  $
]

// Left graph
//
// Maxmin
// Status: Optimal
// Vector x*: [[0, 1, 0, 0, 0, 0], [0, 0, 0, 1, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]]
// Selected arcs: [('a', 'b'), ('b', 'd'), ('d', 'f')]
// Vector z(x*) = (-8, -9)
// Optimal value g(x*): -9
//
// Minmax regret
// Status: Optimal
// Vector x*: [[0, 1, 0, 0, 0, 0], [0, 0, 0, 0, 1, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0]]
// Selected arcs: [('a', 'b'), ('b', 'e'), ('e', 'f')]
// Vector z(x*) = (3, 3)
// Optimal value g(x*): 3
// Optimals s* = (-8, -4)
//
// Maxowa
// Status: Optimal
// Vector x*: [[0, 1, 0, 0, 0, 0], [0, 0, 0, 1, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]]
// Selected arcs: [('a', 'b'), ('b', 'd'), ('d', 'f')]
// Vector z(x*) = (-8, -9)
// Optimal value g(x*): -26
//
// Minowa regret
// Status: Optimal
// Vector x*: [[0, 1, 0, 0, 0, 0], [0, 0, 0, 0, 1, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0]]
// Selected arcs: [('a', 'b'), ('b', 'e'), ('e', 'f')]
// Vector z(x*) = (3, 3)
// Optimal value g(x*): 9
// Optimals s* = (-8, -4)

=== 3.4

#let data-q34 = csv("data/q34.csv", row-type: dictionary)

#let data-maxmin-path = data-q34.map(element => {
  (
    scenario: int(element.at("n_scenarios")),
    project: int(element.at("n_nodes")),
    value: float(element.at("maxmin_time")),
  )
})
#let data-minmax-regret-path = data-q34.map(element => {
  (
    scenario: int(element.at("n_scenarios")),
    project: int(element.at("n_nodes")),
    value: float(element.at("minmax_regret_time")),
  )
})

#let data-maxowa-path = data-q34.map(element => {
  (
    scenario: int(element.at("n_scenarios")),
    project: int(element.at("n_nodes")),
    value: float(element.at("maxowa_time")),
  )
})
#let data-minowa-regret-path = data-q34.map(element => {
  (
    scenario: int(element.at("n_scenarios")),
    project: int(element.at("n_nodes")),
    value: float(element.at("minowa_regret_time")),
  )
})

#figure(caption: [ Maxmin par scénarios ])[
  #plot-performance-scenario(data-maxmin-path)
]

#figure(caption: [ Minmax regret par scénarios ])[
  #plot-performance-scenario(data-minmax-regret-path)
]

#figure(caption: [ MaxOWA par scénarios ])[
  #plot-performance-scenario(data-maxowa-path)
]

#figure(caption: [ MinOWA regret par scénarios ])[
  #plot-performance-scenario(data-minowa-regret-path)
]

#figure(caption: [ Maxmin par nœuds ])[
  #plot-performance-project(data-maxmin-path)
]

#figure(caption: [ Minmax regret par nœuds ])[
  #plot-performance-project(data-minmax-regret-path)
]

#figure(caption: [ MaxOWA par nœuds ])[
  #plot-performance-project(data-maxowa-path)
]

#figure(caption: [ MinOWA regret par nœuds ])[
  #plot-performance-project(data-minowa-regret-path)
]
