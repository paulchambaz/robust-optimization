# question 3.2 - paul chambaz & zelie van der meer - 2024

import pulp as pl  # type:ignore


def preprocess_graph(graph):
    M = 10000
    for i in range(len(graph)):
        for j in range(len(graph)):
            if graph[i][j] == 0:
                graph[i][j] = M


def objective_function(costs, x, scenario):
    return -pl.lpSum(
        pl.lpSum(costs[scenario][i][j] * x[i][j] for j in range(p)) for i in range(p)
    )


def is_admissible(prob, source, destination, x):
    for v in range(p):
        if v != source and v != destination:
            prob += pl.lpSum(x[i][v] - x[v][i] for i in range(p)) == 0

    prob += pl.lpSum(x[source][j] for j in range(p)) == 1
    prob += pl.lpSum(x[i][destination] for i in range(p)) == 1


def path_selection(source, destination, costs, p, scenario):
    prob = pl.LpProblem(f"path_selection_{scenario}", pl.LpMaximize)
    x = [
        [pl.LpVariable(f"x_{i}_{j}", cat=pl.LpBinary) for j in range(p)]
        for i in range(p)
    ]

    prob += objective_function(costs, x, scenario)

    is_admissible(prob, source, destination, x)

    prob.solve(pl.GUROBI_CMD(msg=0))

    status = pl.LpStatus[prob.status]
    solution = [[int(pl.value(x[i][j])) for j in range(p)] for i in range(p)]
    optimal = int(pl.value(prob.objective))

    return status, solution, optimal


def maxmin_path_selection(source, destination, costs, n, p):
    for _, graph in enumerate(costs):
        preprocess_graph(graph)

    prob = pl.LpProblem("maxmin_path_selection", pl.LpMaximize)
    x = [
        [pl.LpVariable(f"x_{i}_{j}", cat=pl.LpBinary) for j in range(p)]
        for i in range(p)
    ]
    alpha = pl.LpVariable("alpha", lowBound=None)

    prob += alpha
    for scenario in range(n):
        prob += objective_function(costs, x, scenario) >= alpha

    is_admissible(prob, source, destination, x)

    prob.solve(pl.GUROBI_CMD(msg=0))

    status = pl.LpStatus[prob.status]
    solution = [[int(pl.value(x[i][j])) for j in range(p)] for i in range(p)]
    optimal = int(pl.value(prob.objective))

    return status, solution, optimal


def minmax_regret_path_selection(source, destination, costs, n, p):
    for _, graph in enumerate(costs):
        preprocess_graph(graph)

    optimals = []
    for s in range(n):
        _, _, optimal = path_selection(source, destination, costs, p, s)
        optimals.append(optimal)

    prob = pl.LpProblem("minmax_regret_path_selection", pl.LpMinimize)
    x = [
        [pl.LpVariable(f"x_{i}_{j}", cat=pl.LpBinary) for j in range(p)]
        for i in range(p)
    ]
    beta = pl.LpVariable("beta", lowBound=None)

    prob += beta
    for scenario in range(n):
        prob += optimals[scenario] - objective_function(costs, x, scenario) <= beta

    is_admissible(prob, source, destination, x)

    prob.solve(pl.GUROBI_CMD(msg=0))

    status = pl.LpStatus[prob.status]
    solution = [[int(pl.value(x[i][j])) for j in range(p)] for i in range(p)]
    optimal = int(pl.value(prob.objective))

    return status, solution, optimal, optimals


def maxowa_path_selection(source, destination, costs, n, p, w):
    for _, graph in enumerate(costs):
        preprocess_graph(graph)

    w_prime = [w[k] - w[k + 1] for k in range(len(w) - 1)] + [w[-1]]

    prob = pl.LpProblem("maxowa_path_selection", pl.LpMaximize)

    x = [
        [pl.LpVariable(f"x_{i}_{j}", cat=pl.LpBinary) for j in range(p)]
        for i in range(p)
    ]
    r = [pl.LpVariable(f"r_{k}", lowBound=None) for k in range(n)]
    b = [[pl.LpVariable(f"b_{s}_{k}", lowBound=0) for s in range(n)] for k in range(n)]

    prob += pl.lpSum(
        w_prime[k] * ((k + 1) * r[k] - pl.lpSum(b[s][k] for s in range(n)))
        for k in range(n)
    )

    for k in range(n):
        for s in range(n):
            prob += r[k] - b[s][k] <= objective_function(costs, x, s)

    is_admissible(prob, source, destination, x)

    prob.solve(pl.GUROBI_CMD(msg=0))

    status = pl.LpStatus[prob.status]
    solution = [[int(pl.value(x[i][j])) for j in range(p)] for i in range(p)]
    optimal = int(pl.value(prob.objective))

    return status, solution, optimal


def minowa_regret_path_selection(source, destination, costs, n, p, w):
    for _, graph in enumerate(costs):
        preprocess_graph(graph)

    w_prime = [w[k] - w[k + 1] for k in range(len(w) - 1)] + [w[-1]]

    optimals = []
    for s in range(n):
        _, _, optimal = path_selection(source, destination, costs, p, s)
        optimals.append(optimal)

    prob = pl.LpProblem("minowa_regret_path_selection", pl.LpMinimize)

    x = [
        [pl.LpVariable(f"x_{i}_{j}", cat=pl.LpBinary) for j in range(p)]
        for i in range(p)
    ]
    r = [pl.LpVariable(f"r_{k}", lowBound=None) for k in range(n)]
    b = [[pl.LpVariable(f"b_{s}_{k}", lowBound=0) for s in range(n)] for k in range(n)]

    prob += pl.lpSum(
        w_prime[k] * ((k + 1) * r[k] + pl.lpSum(b[s][k] for s in range(n)))
        for k in range(n)
    )

    for k in range(n):
        for s in range(n):
            prob += r[k] + b[s][k] >= optimals[s] - objective_function(costs, x, s)

    is_admissible(prob, source, destination, x)

    prob.solve(pl.GUROBI_CMD(msg=0))

    status = pl.LpStatus[prob.status]
    solution = [[int(pl.value(x[i][j])) for j in range(p)] for i in range(p)]
    optimal = int(pl.value(prob.objective))

    return status, solution, optimal, optimals


costs = [
    [
        [0, 4, 5, 0, 0, 0],
        [0, 0, 2, 1, 2, 7],
        [0, 0, 0, 5, 2, 0],
        [0, 0, 0, 0, 0, 3],
        [0, 0, 0, 0, 0, 5],
        [0, 0, 0, 0, 0, 0],
    ],
    [
        [0, 3, 1, 0, 0, 0],
        [0, 0, 1, 4, 2, 5],
        [0, 0, 0, 1, 7, 0],
        [0, 0, 0, 0, 0, 2],
        [0, 0, 0, 0, 0, 2],
        [0, 0, 0, 0, 0, 0],
    ],
]

n = len(costs)
p = len(costs[0])
status, solution, optimal = maxmin_path_selection(0, p - 1, costs, n, p)

selected_arcs = [
    (chr(ord("a") + i), chr(ord("a") + j))
    for j in range(p)
    for i in range(p)
    if solution[i][j] == 1
]
z = [
    -sum(costs[s][i][j] * solution[i][j] for j in range(p) for i in range(p))
    for s in range(n)
]

print("Left graph")
print("\nMaxmin")
print(f"Status: {status}")
print(f"Vector x*: {solution}")
print(f"Selected arcs: {selected_arcs}")
print(f"Vector z(x*) = {tuple(z)}")
print(f"Optimal value g(x*): {optimal}")

status, solution, optimal, optimals = minmax_regret_path_selection(
    0, p - 1, costs, n, p
)

selected_arcs = [
    (chr(ord("a") + i), chr(ord("a") + j))
    for j in range(p)
    for i in range(p)
    if solution[i][j] == 1
]
z = [
    optimals[s]
    + sum(costs[s][i][j] * solution[i][j] for j in range(p) for i in range(p))
    for s in range(n)
]

print("\nMinmax regret")
print(f"Status: {status}")
print(f"Vector x*: {solution}")
print(f"Selected arcs: {selected_arcs}")
print(f"Vector z(x*) = {tuple(z)}")
print(f"Optimal value g(x*): {optimal}")
print(f"Optimals s* = {tuple(optimals)}")

w = [2, 1]

status, solution, optimal = maxowa_path_selection(0, p - 1, costs, n, p, w)

selected_arcs = [
    (chr(ord("a") + i), chr(ord("a") + j))
    for j in range(p)
    for i in range(p)
    if solution[i][j] == 1
]
z = [
    -sum(costs[s][i][j] * solution[i][j] for j in range(p) for i in range(p))
    for s in range(n)
]

print("\nMaxowa")
print(f"Status: {status}")
print(f"Vector x*: {solution}")
print(f"Selected arcs: {selected_arcs}")
print(f"Vector z(x*) = {tuple(z)}")
print(f"Optimal value g(x*): {optimal}")

status, solution, optimal, optimals = minowa_regret_path_selection(
    0, p - 1, costs, n, p, w
)

selected_arcs = [
    (chr(ord("a") + i), chr(ord("a") + j))
    for j in range(p)
    for i in range(p)
    if solution[i][j] == 1
]
z = [
    optimals[s]
    + sum(costs[s][i][j] * solution[i][j] for j in range(p) for i in range(p))
    for s in range(n)
]

print("\nMinowa regret")
print(f"Status: {status}")
print(f"Vector x*: {solution}")
print(f"Selected arcs: {selected_arcs}")
print(f"Vector z(x*) = {tuple(z)}")
print(f"Optimal value g(x*): {optimal}")
print(f"Optimals s* = {tuple(optimals)}")
