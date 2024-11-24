# question 1.1 - paul chambaz & zelie van der meer - 2024

import pulp as pl  # type:ignore


def maxmin_project_selection(n, p, costs, utilities, B):
    prob = pl.LpProblem("maxmin_project_selection", pl.LpMaximize)
    x = [pl.LpVariable(f"x_{j}", cat=pl.LpBinary) for j in range(p)]
    alpha = pl.LpVariable("alpha", lowBound=None)

    prob += alpha
    for i in range(n):
        prob += pl.lpSum(utilities[i][j] * x[j] for j in range(p)) >= alpha
    prob += pl.lpSum(costs[j] * x[j] for j in range(p)) <= B

    prob.solve(pl.GUROBI_CMD(msg=0))

    status = pl.LpStatus[prob.status]
    solution = [int(pl.value(x[j])) for j in range(p)]
    optimal = int(pl.value(prob.objective))

    return status, solution, optimal


B = 100
costs = [60, 10, 15, 20, 25, 20, 5, 15, 20, 60]
utilities = [
    [70, 18, 16, 14, 12, 10, 8, 6, 4, 2],
    [2, 4, 6, 8, 10, 12, 14, 16, 18, 70],
]
n = len(utilities)
p = len(costs)

status, solution, optimal = maxmin_project_selection(n, p, costs, utilities, B)

selected_projects = [j + 1 for j in range(p) if solution[j] == 1]
z = [sum(utilities[i][j] * solution[j] for j in range(p)) for i in range(n)]
total_cost = sum(costs[j] * solution[j] for j in range(p))

print(f"Status: {status}")
print(f"Vector x*: {solution}")
print(f"Selected projects: {selected_projects}")
print(f"Total cost: {total_cost}")
print(f"Vector z(x*) = {tuple(z)}")
print(f"Optimal value g(x*) = {optimal}")
