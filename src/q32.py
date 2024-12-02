# question 3.2 - paul chambaz & zelie van der meer - 2024

import pulp as pl  # type:ignore


def path_selection(
    scenario: int, source: int, destination: int, costs: list[list[list[int]]], p: int
) -> tuple[str, list[list[int]], int]:
    """
    Finds the shortest path between two nodes in a graph under a specific scenario

    # Params

    * `scenario`: Index of the scenario to consider
    * `source`: Index of the starting node
    * `destination`: Index of the target node
    * `costs`: 3D matrix of edge costs for each scenario
    * `p`: Number of nodes in the graph
    """
    M = 10000
    for _, graph in enumerate(costs):
        for i in range(p):
            for j in range(p):
                if graph[i][j] == 0:
                    graph[i][j] = M

    prob = pl.LpProblem("path_selection", pl.LpMinimize)
    x = [
        [pl.LpVariable(f"x_{i}_{j}", cat=pl.LpBinary) for j in range(p)]
        for i in range(p)
    ]

    prob += pl.lpSum(
        pl.lpSum(costs[scenario][i][j] * x[i][j] for j in range(p)) for i in range(p)
    )
    for v in range(p):
        if v != source and v != destination:
            prob += pl.lpSum(x[i][v] - x[v][i] for i in range(p)) == 0

    prob += pl.lpSum(x[source][j] for j in range(p)) == 1
    prob += pl.lpSum(x[i][destination] for i in range(p)) == 1

    prob.solve(pl.GUROBI_CMD(msg=0))

    status = pl.LpStatus[prob.status]
    solution = [[int(pl.value(x[i][j])) for j in range(p)] for i in range(p)]
    optimal = int(pl.value(prob.objective))

    return status, solution, optimal


if __name__ == "__main__":
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

    p = len(costs[0])

    status, solution, optimal = path_selection(0, 0, p - 1, costs, p)

    selected_arcs = [
        (chr(ord("a") + i), chr(ord("a") + j))
        for j in range(p)
        for i in range(p)
        if solution[i][j] == 1
    ]

    print("Left graph in scenario 1")
    print(f"Status: {status}")
    print(f"Vector x*: {solution}")
    print(f"Selected arcs: {selected_arcs}")
    print(f"Optimal value g(x*): {optimal}")

    p = len(costs[0])

    status, solution, optimal = path_selection(1, 0, p - 1, costs, p)

    selected_arcs = [
        (chr(ord("a") + i), chr(ord("a") + j))
        for j in range(p)
        for i in range(p)
        if solution[i][j] == 1
    ]

    print("Left graph in scenario 2")
    print(f"Status: {status}")
    print(f"Vector x*: {solution}")
    print(f"Selected arcs: {selected_arcs}")
    print(f"Optimal value g(x*): {optimal}")

    costs = [
        [
            [0, 5, 10, 2, 0, 0, 0],
            [0, 0, 4, 1, 4, 0, 0],
            [0, 0, 0, 0, 3, 1, 0],
            [0, 0, 1, 0, 0, 3, 0],
            [0, 0, 0, 0, 0, 0, 1],
            [0, 0, 0, 0, 0, 0, 1],
            [0, 0, 0, 0, 0, 0, 0],
        ],
        [
            [0, 3, 4, 6, 0, 0, 0],
            [0, 0, 2, 3, 6, 0, 0],
            [0, 0, 0, 0, 1, 2, 0],
            [0, 0, 4, 0, 0, 5, 0],
            [0, 0, 0, 0, 0, 0, 1],
            [0, 0, 0, 0, 0, 0, 1],
            [0, 0, 0, 0, 0, 0, 0],
        ],
    ]

    p = len(costs[0])

    status, solution, optimal = path_selection(0, 0, p - 1, costs, p)

    selected_arcs = [
        (chr(ord("a") + i), chr(ord("a") + j))
        for j in range(p)
        for i in range(p)
        if solution[i][j] == 1
    ]

    print("Left graph in scenario 1")
    print(f"Status: {status}")
    print(f"Vector x*: {solution}")
    print(f"Selected arcs: {selected_arcs}")
    print(f"Optimal value g(x*): {optimal}")

    p = len(costs[0])

    status, solution, optimal = path_selection(1, 0, p - 1, costs, p)

    selected_arcs = [
        (chr(ord("a") + i), chr(ord("a") + j))
        for j in range(p)
        for i in range(p)
        if solution[i][j] == 1
    ]

    print("Left graph in scenario 2")
    print(f"Status: {status}")
    print(f"Vector x*: {solution}")
    print(f"Selected arcs: {selected_arcs}")
    print(f"Optimal value g(x*): {optimal}")
