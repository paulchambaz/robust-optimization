# question 1.2 - paul chambaz & zelie van der meer - 2024

import pulp as pl  # type:ignore

n = 2
p = 10
B = 100
costs = [60, 10, 15, 20, 25, 20, 5, 15, 20, 60]
utilities = [
    [70, 18, 16, 14, 12, 10, 8, 6, 4, 2],
    [2, 4, 6, 8, 10, 12, 14, 16, 18, 70],
]

optimals = []
for i in range(n):
    prob = pl.LpProblem("optimal_scenario_1", pl.LpMaximize)
    x = [pl.LpVariable(f"x_{j}", cat=pl.LpBinary) for j in range(p)]

    prob += pl.lpSum(utilities[i][j] * x[j] for j in range(p))
    prob += pl.lpSum(costs[j] * x[j] for j in range(p)) <= B

    prob.solve(pl.GUROBI_CMD(msg=0))

    optimal = sum(utilities[i][j] * int(pl.value(x[j])) for j in range(p))

    optimals.append(optimal)

prob = pl.LpProblem("minmax_regret_project_selection", pl.LpMinimize)
x = [pl.LpVariable(f"x_{j}", cat=pl.LpBinary) for j in range(p)]
beta = pl.LpVariable("beta", lowBound=None)

prob += beta
for i in range(n):
    prob += optimals[i] - pl.lpSum(utilities[i][j] * x[j] for j in range(p)) <= beta
prob += pl.lpSum(costs[j] * x[j] for j in range(p)) <= B

prob.solve(pl.GUROBI_CMD(msg=0))

solution = [int(pl.value(x[j])) for j in range(p)]
selected_projects = [j + 1 for j in range(p) if solution[j] == 1]
optimal_beta = int(pl.value(beta))

z1 = optimals[0] - sum(utilities[0][j] * solution[j] for j in range(p))
z2 = optimals[1] - sum(utilities[1][j] * solution[j] for j in range(p))
total_cost = sum(costs[j] * solution[j] for j in range(p))

print(f"Status: {pl.LpStatus[prob.status]}")
print(f"Vector x*: {solution}")
print(f"Selected projects: {selected_projects}")
print(f"Total cost: {total_cost}")
print(f"Vector z(x*) = ({z1}, {z2})")
print(f"Optimal value g(x*) = {optimal_beta}")
print(f"Optimals s1*, s2* = ({optimals[0]}, {optimals[1]})")
