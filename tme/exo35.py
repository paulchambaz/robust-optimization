import pulp  # type: ignore

colonnes = range(3)

m = pulp.LpProblem("branch and bound", pulp.LpMinimize)

x = [pulp.LpVariable(f"x{i+1}", lowBound=0, cat="Continuous") for i in colonnes]

m += pulp.lpSum(7 * x[0] + 3 * x[1] + 4 * x[2])

m += pulp.lpSum(1 * x[0] + 2 * x[1] + 3 * x[2]) >= 8, "Constraint0"
m += pulp.lpSum(3 * x[0] + 1 * x[1] + 1 * x[2]) >= 5, "Constraint1"
m += pulp.lpSum(x[1]) <= 3, "Constraint2"
m += pulp.lpSum(x[0]) >= 1, "Constraint3"

m.solve(pulp.GLPK())

print("\nSolution optimale:")
for j in range(3):
    print(f"x{j+1} = {x[j].value()}")

print(f"\nValeur de la fonction objectif : {m.objective.value()}")


# solution optimale: x* = (0, 5, 0)
