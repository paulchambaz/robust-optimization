# question 2.5 - paul chambaz & zelie van der meer - 2024

import pulp as pl  # type:ignore


def minowa_regret_project_selection(
    n: int, p: int, costs: list[int], utilities: list[list[int]], B: int, w: list[int]
) -> tuple[str, list[int], int, list[int]]:
    """
    Implements the OWA minimization criterion for regret in project selection under uncertainty

    # Params

    * `n`: Number of scenarios to consider
    * `p`: Number of projects to select from
    * `costs`: List of project costs
    * `utilities`: Matrix of utilities for each project under each scenario
    * `B`: Total budget constraint
    * `w`: OWA weight vector in decreasing order
    """
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
    b = [[pl.LpVariable(f"b_{i}_{k}", lowBound=0) for i in range(n)] for k in range(n)]

    prob += pl.lpSum(
        w_prime[k] * ((k + 1) * r[k] + pl.lpSum(b[i][k] for i in range(n)))
        for k in range(n)
    )

    for k in range(n):
        for i in range(n):
            prob += r[k] + b[i][k] >= optimals[i] - pl.lpSum(
                utilities[i][j] * x[j] for j in range(p)
            )

    prob += pl.lpSum(costs[j] * x[j] for j in range(p)) <= B

    prob.solve(pl.GUROBI_CMD(msg=0))

    status = pl.LpStatus[prob.status]
    solution = [int(pl.value(x[j])) for j in range(p)]
    optimal = int(pl.value(prob.objective))

    return status, solution, optimal, optimals


if __name__ == "__main__":
    costs = [60, 10, 15, 20, 25, 20, 5, 15, 20, 60]
    utilities = [
        [70, 18, 16, 14, 12, 10, 8, 6, 4, 2],
        [2, 4, 6, 8, 10, 12, 14, 16, 18, 70],
    ]
    B = 100
    w = [2, 1]
    n = len(utilities)
    p = len(costs)

    status, solution, optimal, optimals = minowa_regret_project_selection(
        n, p, costs, utilities, B, w
    )

    selected_projects = [j + 1 for j in range(p) if solution[j] == 1]
    z = [
        optimals[i] - sum(utilities[i][j] * solution[j] for j in range(p))
        for i in range(n)
    ]
    total_cost = sum(costs[j] * solution[j] for j in range(p))

    print(f"Status: {status}")
    print(f"Vector x*: {solution}")
    print(f"Selected projects: {selected_projects}")
    print(f"Total cost: {total_cost}")
    print(f"Vector z(x*) = {tuple(z)}")
    print(f"Optimal value g(x*): {optimal}")
    print(f"Optimals: {optimals}")
