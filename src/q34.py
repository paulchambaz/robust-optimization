# question 3.4 - paul chambaz & zelie van der meer - 2024

import csv
import random
import time

from q33 import (
    maxmin_path_selection,
    maxowa_path_selection,
    minmax_regret_path_selection,
    minowa_regret_path_selection,
)

ns = [2, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50]
ps = [10, 15, 20, 40, 80, 120, 160, 200, 240]
num_repetitions = 50

with open("paper/data/q34.csv", "w", newline="") as csvfile:
    fieldnames = [
        "n_scenarios",
        "n_nodes",
        "repetition",
        "maxmin_time",
        "minmax_regret_time",
        "maxowa_time",
        "minowa_regret_time",
    ]
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
    writer.writeheader()

    for n in ns:
        for p in ps:
            print(f"\nRunning experiments for {n} scenarios, {p} nodes")

            for rep in range(num_repetitions):
                costs = [[[0 for j in range(p)] for i in range(p)] for s in range(n)]

                coords = [(i, j) for j in range(p) for i in range(p) if i != j]
                random.shuffle(coords)

                percent_arc = random.randint(
                    int(0.30 * len(coords)), int(0.50 * len(coords))
                )

                coords = coords[:percent_arc]

                for i, j in coords:
                    for s in range(n):
                        costs[s][i][j] = random.randint(1, 100)

                nodes = [i for i in range(p)]
                random.shuffle(nodes)
                source, destination = nodes[:2]

                w = sorted([random.randint(0, n) for i in range(n)], reverse=True)

                start_time = time.time()
                maxmin_path_selection(source, destination, costs, n, p)
                maxmin_time = time.time() - start_time

                start_time = time.time()
                minmax_regret_path_selection(source, destination, costs, n, p)
                minmax_regret_time = time.time() - start_time

                start_time = time.time()
                maxowa_path_selection(source, destination, costs, n, p, w)
                maxowa_time = time.time() - start_time

                start_time = time.time()
                minowa_regret_path_selection(source, destination, costs, n, p, w)
                minowa_regret_time = time.time() - start_time

                print(f"  Repetition {rep + 1}/{num_repetitions}:")
                print(f"    Maxmin time: {maxmin_time:.3f}s")
                print(f"    Minmax regret time: {minmax_regret_time:.3f}s")
                print(f"    Maxowa time: {maxowa_time:.3f}s")
                print(f"    Minowa regret time: {minowa_regret_time:.3f}s")

                writer.writerow(
                    {
                        "n_scenarios": n,
                        "n_nodes": p,
                        "repetition": rep + 1,
                        "maxmin_time": maxmin_time,
                        "minmax_regret_time": minmax_regret_time,
                        "maxowa_time": maxowa_time,
                        "minowa_regret_time": minowa_regret_time,
                    }
                )
