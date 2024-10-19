import pulp  # type: ignore

prob = pulp.LpProblem("LinearizedProblem", pulp.LpMaximize)

x = pulp.LpVariable("x", lowBound=0, cat="Integer")
y = pulp.LpVariable("y", lowBound=0, cat="Integer")
z = pulp.LpVariable("z", cat="Binary")

M = 1000
epsilon = 0.1

prob += x + y, "Objective"

prob += pulp.lpSum(x + y) <= 10, "Constraint1"
prob += pulp.lpSum(x - y + M * z) >= epsilon, "DiffLow"
prob += pulp.lpSum(y - x + M * (1 - z)) >= epsilon, "DiffHigh"

prob.solve(pulp.GLPK())

# Print results
print(f"Status: {pulp.LpStatus[prob.status]}")
print(f"x = {x.varValue}")
print(f"y = {y.varValue}")
print(f"z = {z.varValue}")
print(f"Objective function value: {pulp.value(prob.objective)}")
