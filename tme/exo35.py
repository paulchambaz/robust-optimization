import pulp  # type: ignore

m = pulp.LpProblem("branch and bound", pulp.LpMinimize)

# x = [pulp.LpVariable(f"x{i+1}", lowBound=0, cat="Continuous") for i in range(3)]
x = [pulp.LpVariable(f"x{i+1}", lowBound=0, cat="Integer") for i in range(3)]

m += pulp.lpSum(7 * x[0] + 3 * x[1] + 4 * x[2])

m += pulp.lpSum(1 * x[0] + 2 * x[1] + 3 * x[2]) >= 8, "Constraint0"
m += pulp.lpSum(3 * x[0] + 1 * x[1] + 1 * x[2]) >= 5, "Constraint1"

m.solve(pulp.GLPK())

print("\nSolution optimale:")
for i, val in enumerate(x):
    print(f"x{i+1} = {val.value()}")

print(f"\nValeur de la fonction objectif : {m.objective.value()}")


m = pulp.LpProblem("branch and bound dual", pulp.LpMaximize)

# y = [pulp.LpVariable(f"y{i+1}", lowBound=0, cat="Continuous") for i in range(2)]
y = [pulp.LpVariable(f"y{i+1}", lowBound=0, cat="Integer") for i in range(2)]

m += pulp.lpSum(8 * y[0] + 5 * y[1])

m += pulp.lpSum(1 * y[0] + 3 * y[1]) <= 7, "Constraint0"
m += pulp.lpSum(2 * y[0] + 1 * y[1]) <= 3, "Constraint1"
m += pulp.lpSum(3 * y[0] + 1 * y[1]) <= 4, "Constraint2"

m.solve(pulp.GLPK())

print("\nSolution optimale:")
for i, val in enumerate(y):
    print(f"y{i+1} = {val.value()}")

print(f"\nValeur de la fonction objectif : {m.objective.value()}")
