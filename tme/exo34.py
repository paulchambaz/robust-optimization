import matplotlib.pyplot as plt  # type: ignore
import numpy as np  # type: ignore
import pulp  # type: ignore


def linear_approx(xi, yi):
    if len(xi) != len(yi):
        return

    n = len(xi)

    nbcont = 2 * n
    nbvar = 2 + n

    lines = range(nbcont)
    columns = range(nbvar)

    a = []
    for i in range(n):
        constraint = []
        constraint.append(-xi[i])
        constraint.append(-1)
        for j in range(n):
            if i == j:
                constraint.append(-1)
            else:
                constraint.append(0)
        a.append(constraint)

        constraint = []
        constraint.append(xi[i])
        constraint.append(1)
        for j in range(n):
            if i == j:
                constraint.append(-1)
            else:
                constraint.append(0)
        a.append(constraint)

    b = []
    for i in range(n):
        b.append(-yi[i])
        b.append(yi[i])

    c = [0, 0]
    for i in range(n):
        c.append(1)

    m = pulp.LpProblem("Mogpl", pulp.LpMinimize)

    x = [pulp.LpVariable(f"x{i+1}", lowBound=0, cat="Continuous") for i in columns]

    m += pulp.lpSum(c[j] * x[j] for j in columns)

    for i in lines:
        m += pulp.lpSum(a[i][j] * x[j] for j in columns) <= b[i], f"Contraint{i}"

    m.solve(pulp.GUROBI_CMD())

    x1 = x[0].value()
    x2 = x[1].value()

    return x1, x2


x1 = np.array([4, 17, 37, 55, 88, 96])
y1 = np.array([11, 25, 46, 48, 65, 71])
a, b = linear_approx(x1, y1)
line1 = a * x1 + b

x2 = np.array([4, 17, 37, 55, 88, 14])
y2 = np.array([11, 25, 46, 48, 65, 97])
a, b = linear_approx(x2, y2)
line2 = a * x2 + b


plt.plot(x1, line1, "r-", label="Line 1")
plt.plot(x1, y1, "ro", label="Points 1")
plt.plot(x2, line2, "b-", label="Line 2")
plt.plot(x2, y2, "bo", label="Points 2")

plt.show()
