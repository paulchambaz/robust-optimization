# projet q121

from gurobipy import *

nbvar = 10

colonnes = range(nbvar)

s1 = [70, 18, 16, 14, 12, 10, 8, 6, 4, 2]
s2 = [2, 4, 6, 8, 10, 12, 14, 16, 18, 70]

m = Model("projet_q12")
x = []
for i in colonnes:
    x.append(m.addVar(vtype=GRB.INTEGER, lb=0, name="x%d" % (i + 1)))
m.update()
obj = LinExpr()
obj = 0
for j in colonnes:
    obj += s1[j] * x[j]
print(obj)
m.setObjective(obj, GRB.MAXIMIZE)

for i in range(nbvar):
    m.addConstr(x[i] <= 1, "Contrainte%d")

m.optimize()
print("")
print("Solution optimale")
for j in colonnes:
    print("x%d" % (j + 1), "=", x[j].x)
print("")
print("Valeur de la fonction objectif :", m.objVal)
z1 = 0
for i in range(nbvar):
    z1 += s1[i] * x[i].x
print("Valeur de z1 :", z1)
