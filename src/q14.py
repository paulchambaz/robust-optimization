# question 1.4 - paul chambaz & zelie van der meer - 2024

import csv
import random
import time
from collections import defaultdict

import matplotlib.pyplot as plt
import pulp as pl  # type:ignore

ns = [5, 10, 15, 20, 25, 30, 35, 40, 45, 50]
ps = [10, 15, 20, 25, 30, 35, 40, 45, 50]

solver = pl.GUROBI_CMD(msg=0)


def maxmin_project_selection(n, p, costs, utilities, B):
    prob = pl.LpProblem("maxmin_project_selection", pl.LpMaximize)
    x = [pl.LpVariable(f"x_{j}", cat=pl.LpBinary) for j in range(p)]
    alpha = pl.LpVariable("alpha", lowBound=None)

    prob += alpha
    for i in range(n):
        prob += pl.lpSum(utilities[i][j] * x[j] for j in range(p)) >= alpha
    prob += pl.lpSum(costs[j] * x[j] for j in range(p)) <= B

    prob.solve(solver)


def minmax_regret_project_selection(n, p, costs, utilties, B):
    optimals = []
    for i in range(n):
        prob = pl.LpProblem("optimal_scenario_1", pl.LpMaximize)
        x = [pl.LpVariable(f"x_{j}", cat=pl.LpBinary) for j in range(p)]

        prob += pl.lpSum(utilities[i][j] * x[j] for j in range(p))
        prob += pl.lpSum(costs[j] * x[j] for j in range(p)) <= B

        prob.solve(solver)

        optimal = sum(utilities[i][j] * int(pl.value(x[j])) for j in range(p))

        optimals.append(optimal)

    prob = pl.LpProblem("minmax_regret_project_selection", pl.LpMinimize)
    x = [pl.LpVariable(f"x_{j}", cat=pl.LpBinary) for j in range(p)]
    beta = pl.LpVariable("beta", lowBound=None)

    prob += beta
    for i in range(n):
        prob += optimals[i] - pl.lpSum(utilities[i][j] * x[j] for j in range(p)) <= beta
    prob += pl.lpSum(costs[j] * x[j] for j in range(p)) <= B

    prob.solve(solver)


num_repetitions = 50

with open("paper/data/q14.csv", "w", newline="") as csvfile:
    fieldnames = [
        "n_scenarios",
        "n_projects",
        "repetition",
        "maxmin_time",
        "minmax_regret_time",
    ]
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
    writer.writeheader()

    for n in ns:
        for p in ps:
            print(f"\nRunning experiments for {n} scenarios, {p} projects")

            for rep in range(num_repetitions):
                costs = [random.randint(1, 100) for j in range(p)]
                utilities = [
                    [random.randint(1, 100) for j in range(p)] for i in range(n)
                ]
                B = int(sum(costs) * 0.50)

                start_time = time.time()
                maxmin_project_selection(n, p, costs, utilities, B)
                maxmin_time = time.time() - start_time

                start_time = time.time()
                minmax_regret_project_selection(n, p, costs, utilities, B)
                minmax_regret_time = time.time() - start_time

                print(f"  Repetition {rep + 1}/{num_repetitions}:")
                print(f"    Maxmin time: {maxmin_time:.3f}s")
                print(f"    Minmax regret time: {minmax_regret_time:.3f}s")

                writer.writerow(
                    {
                        "n_scenarios": n,
                        "n_projects": p,
                        "repetition": rep + 1,
                        "maxmin_time": maxmin_time,
                        "minmax_regret_time": minmax_regret_time,
                    }
                )


# Read and organize data
data = defaultdict(lambda: defaultdict(list))
with open("paper/data/q14.csv", "r") as csvfile:
    reader = csv.DictReader(csvfile)
    for row in reader:
        n = int(row["n_scenarios"])
        p = int(row["n_projects"])
        data[(n, p)]["maxmin_time"].append(float(row["maxmin_time"]))
        data[(n, p)]["minmax_regret_time"].append(float(row["minmax_regret_time"]))

# Calculate averages
averages = {}
for (n, p), times in data.items():
    averages[(n, p)] = {
        "maxmin": sum(times["maxmin_time"]) / len(times["maxmin_time"]),
        "minmax": sum(times["minmax_regret_time"]) / len(times["minmax_regret_time"]),
    }

ns = sorted(set(k[0] for k in averages.keys()))
ps = sorted(set(k[1] for k in averages.keys()))

# Create two figures, each with two subplots
fig1, (ax1, ax2) = plt.subplots(1, 2, figsize=(15, 6))
fig1.suptitle("Solution Times by Number of Scenarios")

# First figure: Lines for each p, x-axis is n (as before)
for p in ps:
    # Plot MaxMin data points and averages
    for n in ns:
        if (n, p) in data:
            x_jitter = [
                n + (random.random() - 0.5) * 0.5
                for _ in range(len(data[(n, p)]["maxmin_time"]))
            ]
            ax1.scatter(
                x_jitter,
                data[(n, p)]["maxmin_time"],
                alpha=0.2,
                color=f"C{ps.index(p)}",
                marker=".",
            )
    times = [averages.get((n, p), {"maxmin": 0})["maxmin"] for n in ns]
    ax1.plot(ns, times, marker="o", label=f"p={p}", linewidth=2)

    # Plot MinMax Regret data points and averages
    for n in ns:
        if (n, p) in data:
            x_jitter = [
                n + (random.random() - 0.5) * 0.5
                for _ in range(len(data[(n, p)]["minmax_regret_time"]))
            ]
            ax2.scatter(
                x_jitter,
                data[(n, p)]["minmax_regret_time"],
                alpha=0.2,
                color=f"C{ps.index(p)}",
                marker=".",
            )
    times = [averages.get((n, p), {"minmax": 0})["minmax"] for n in ns]
    ax2.plot(ns, times, marker="o", label=f"p={p}", linewidth=2)

ax1.set_title("MaxMin Solution Times")
ax1.set_xlabel("Number of Scenarios")
ax1.set_ylabel("Time (seconds)")
ax1.legend(title="Projects", bbox_to_anchor=(1.05, 1), loc="upper left")
ax1.grid(True)

ax2.set_title("MinMax Regret Solution Times")
ax2.set_xlabel("Number of Scenarios")
ax2.set_ylabel("Time (seconds)")
ax2.legend(title="Projects", bbox_to_anchor=(1.05, 1), loc="upper left")
ax2.grid(True)

plt.tight_layout()

# Second figure: Lines for each n, x-axis is p
fig2, (ax3, ax4) = plt.subplots(1, 2, figsize=(15, 6))
fig2.suptitle("Solution Times by Number of Projects")

# Plot with p on x-axis, separate line for each n
for n in ns:
    # Plot MaxMin data points and averages
    for p in ps:
        if (n, p) in data:
            x_jitter = [
                p + (random.random() - 0.5) * 0.5
                for _ in range(len(data[(n, p)]["maxmin_time"]))
            ]
            ax3.scatter(
                x_jitter,
                data[(n, p)]["maxmin_time"],
                alpha=0.2,
                color=f"C{ns.index(n)}",
                marker=".",
            )
    times = [averages.get((n, p), {"maxmin": 0})["maxmin"] for p in ps]
    ax3.plot(ps, times, marker="o", label=f"n={n}", linewidth=2)

    # Plot MinMax Regret data points and averages
    for p in ps:
        if (n, p) in data:
            x_jitter = [
                p + (random.random() - 0.5) * 0.5
                for _ in range(len(data[(n, p)]["minmax_regret_time"]))
            ]
            ax4.scatter(
                x_jitter,
                data[(n, p)]["minmax_regret_time"],
                alpha=0.2,
                color=f"C{ns.index(n)}",
                marker=".",
            )
    times = [averages.get((n, p), {"minmax": 0})["minmax"] for p in ps]
    ax4.plot(ps, times, marker="o", label=f"n={n}", linewidth=2)

ax3.set_title("MaxMin Solution Times")
ax3.set_xlabel("Number of Projects")
ax3.set_ylabel("Time (seconds)")
ax3.legend(title="Scenarios", bbox_to_anchor=(1.05, 1), loc="upper left")
ax3.grid(True)

ax4.set_title("MinMax Regret Solution Times")
ax4.set_xlabel("Number of Projects")
ax4.set_ylabel("Time (seconds)")
ax4.legend(title="Scenarios", bbox_to_anchor=(1.05, 1), loc="upper left")
ax4.grid(True)

plt.tight_layout()
plt.show()
