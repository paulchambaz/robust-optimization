# question 2.5 - paul chambaz & zelie van der meer - 2024

import pulp as pl  # type:ignore

n = 2
p = 10
B = 100
costs = [60, 10, 15, 20, 25, 20, 5, 15, 20, 60]
utilities = [
    [70, 18, 16, 14, 12, 10, 8, 6, 4, 2],
    [2, 4, 6, 8, 10, 12, 14, 16, 18, 70],
]
w = [2, 1]
w_prime = [w[k] - w[k + 1] for k in range(len(w) - 1)] + [w[-1]]

optimals = []
for i in range(n):
    prob = pl.LpProblem("optimal_scenario_1", pl.LpMaximize)
    x = [pl.LpVariable(f"x_{j}", cat=pl.LpBinary) for j in range(p)]
    prob += pl.lpSum(utilities[i][j] * x[j] for j in range(p))
    prob += pl.lpSum(costs[j] * x[j] for j in range(p)) <= B
    prob.solve(pl.GUROBI_CMD(msg=0))
    optimal = sum(utilities[i][j] * int(pl.value(x[j])) for j in range(p))
    optimals.append(optimal)

prob = pl.LpProblem("minowa_regret_project_selection", pl.LpMinimize)

x = [pl.LpVariable(f"x_{j}", cat=pl.LpBinary) for j in range(p)]
r = [pl.LpVariable(f"r_{k}", lowBound=None) for k in range(n)]
b = {(i, k): pl.LpVariable(f"b_{i}{k}", lowBound=0) for i in range(n) for k in range(n)}

prob += pl.lpSum(w[i] * utilities[i] for i in range(n)) - pl.lpSum(
    w_prime[k] * ((k + 1) * r[k] - pl.lpSum(b[i, k] for i in range(n)))
    for k in range(n)
)

for k in range(n):
    for i in range(n):
        prob += r[k] - b[i, k] >= utilities[i] - pl.lpSum(
            utilities[i][j] * x[j] for j in range(p)
        )

prob += pl.lpSum(costs[j] * x[j] for j in range(p)) <= B

prob.solve(pl.GUROBI_CMD(msg=0))

solution = [int(pl.value(x[j])) for j in range(p)]
selected_projects = [j + 1 for j in range(p) if solution[j] == 1]
total_cost = sum(costs[j] * solution[j] for j in range(p))
regrets = [
    optimals[i] - sum(utilities[i][j] * solution[j] for j in range(p)) for i in range(n)
]
sorted_regrets = sorted(regrets, reverse=True)
owa_value = sum(w[i] * sorted_regrets[i] for i in range(n))

print(f"Status: {pl.LpStatus[prob.status]}")
print(f"Vector x*: {solution}")
print(f"Selected projects: {selected_projects}")
print(f"Total cost: {total_cost}")
print(f"Regrets: r(x*) = {tuple(regrets)}")
print(f"OWA value of regrets: {owa_value}")
print(f"Optimals: {optimals}")
