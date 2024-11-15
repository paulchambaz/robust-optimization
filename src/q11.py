# question 1.1 - paul chambaz & zelie van der meer - 2024

import pulp as pl  # type:ignore

n = 10
B = 100
costs = [60, 10, 15, 20, 25, 20, 5, 15, 20, 60]
utilities_s1 = [70, 18, 16, 14, 12, 10, 8, 6, 4, 2]
utilities_s2 = [2, 4, 6, 8, 10, 12, 14, 16, 18, 70]

prob = pl.LpProblem("maximin_project_selection", pl.LpMaximize)
x = [pl.LpVariable(f"x_{j}", cat=pl.LpBinary) for j in range(n)]
alpha = pl.LpVariable("alpha", lowBound=None)

prob += alpha
prob += pl.lpSum(utilities_s1[j] * x[j] for j in range(n)) >= alpha
prob += pl.lpSum(utilities_s2[j] * x[j] for j in range(n)) >= alpha
prob += pl.lpSum(costs[j] * x[j] for j in range(n)) <= B

# prob.solve(pl.GLPK())
prob.solve(pl.GUROBI_CMD())

solution = [int(pl.value(x[j])) for j in range(n)]
selected_projects = [j + 1 for j in range(n) if solution[j] == 1]
optimal_alpha = int(pl.value(alpha))

z1 = sum(utilities_s1[j] * solution[j] for j in range(n))
z2 = sum(utilities_s2[j] * solution[j] for j in range(n))
total_cost = sum(costs[j] * solution[j] for j in range(n))

print(f"Status: {pl.LpStatus[prob.status]}")
print(f"Vector x*: {solution}")
print(f"Selected projects: {selected_projects}")
print(f"Total cost: {total_cost}")
print(f"Vector z(x*) = ({z1}, {z2})")
print(f"Optimal value g(x*) = {optimal_alpha}")
