# question 2.4 - paul chambaz & zelie van der meer - 2024

import pulp as pl  # type:ignore


def maxowa_project_selection(n, p, costs, utilities, B, w):
    w_prime = [w[k] - w[k + 1] for k in range(len(w) - 1)] + [w[-1]]

    prob = pl.LpProblem("maxowa_project_selection", pl.LpMaximize)

    x = [pl.LpVariable(f"x_{j}", cat=pl.LpBinary) for j in range(p)]
    r = [pl.LpVariable(f"r_{k}", lowBound=None) for k in range(n)]
    b = [[pl.LpVariable(f"b_{i}_{k}", lowBound=0) for i in range(n)] for k in range(n)]

    prob += pl.lpSum(
        w_prime[k] * ((k + 1) * r[k] - pl.lpSum(b[i][k] for i in range(n)))
        for k in range(n)
    )

    for k in range(n):
        for i in range(n):
            prob += r[k] - b[i][k] <= pl.lpSum(utilities[i][j] * x[j] for j in range(p))

    prob += pl.lpSum(costs[j] * x[j] for j in range(p)) <= B

    prob.solve(pl.GUROBI_CMD(msg=0))

    status = pl.LpStatus[prob.status]
    solution = [int(pl.value(x[j])) for j in range(p)]
    optimal = int(pl.value(prob.objective))

    return status, solution, optimal


costs = [60, 10, 15, 20, 25, 20, 5, 15, 20, 60]
utilities = [
    [70, 18, 16, 14, 12, 10, 8, 6, 4, 2],
    [2, 4, 6, 8, 10, 12, 14, 16, 18, 70],
]
B = 100
w = [2, 1]
n = len(utilities)
p = len(costs)


status, solution, optimal = maxowa_project_selection(n, p, costs, utilities, B, w)

selected_projects = [j + 1 for j in range(p) if solution[j] == 1]
z = [sum(utilities[i][j] * solution[j] for j in range(p)) for i in range(n)]
total_cost = sum(costs[j] * solution[j] for j in range(p))

print(f"Status: {optimal}")
print(f"Vector x*: {solution}")
print(f"Selected projects: {selected_projects}")
print(f"Total cost: {total_cost}")
print(f"Vector z(x*): = {tuple(z)}")
print(f"Optimal value g(x*): {optimal}")
