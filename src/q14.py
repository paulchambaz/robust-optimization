# question 1.4 - paul chambaz & zelie van der meer - 2024

import csv
import random
import time

from q11 import maxmin_project_selection
from q12 import minmax_regret_project_selection

if __name__ == "__main__":
    ns = [5, 10, 15, 20, 25, 30, 35, 40, 45, 50]
    ps = [10, 15, 20, 25, 30, 35, 40, 45, 50]
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
