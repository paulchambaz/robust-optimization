# question 2.2 - paul chambaz & zelie van der meer - 2024

import pulp as pl  # type:ignore

if __name__ == "__main__":
    z = [2, 9, 6, 8, 5, 4]
    n = len(z)

    L = []

    for k in range(1, n + 1):
        prob = pl.LpProblem(f"dual_L{k}", pl.LpMaximize)

        r_k = pl.LpVariable(f"r_{k}", lowBound=None)
        b_ik = [pl.LpVariable(f"b_{i}{k}", lowBound=0) for i in range(n)]

        prob += k * r_k - pl.lpSum(b_ik)

        for i in range(n):
            prob += r_k - b_ik[i] <= z[i]

        prob.solve(pl.GUROBI_CMD(msg=0))

        L_k = int(pl.value(prob.objective))

        print(pl.value(r_k))
        print([pl.value(b_ik[i]) for i in range(n)])

        L.append(L_k)

    print(f"L(z) = {L}")
    print(z)
