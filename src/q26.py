# question 2.6 - paul chambaz & zelie van der meer - 2024

import csv
import os
import random
import time

from q24 import maxowa_project_selection
from q25 import minowa_regret_project_selection

if __name__ == "__main__":
    ns = [5, 10, 15, 20, 25, 30, 35, 40, 45, 50]
    ps = [10, 15, 20, 25, 30, 35, 40, 45, 50]
    num_repetitions = 50

    data_dir = "paper/data"
    data_file = "q26.csv"
    output_path = (
        os.path.join(data_dir, data_file) if os.path.exists(data_dir) else data_file
    )

    with open(output_path, "w", newline="") as csvfile:
        fieldnames = [
            "n_scenarios",
            "n_projects",
            "repetition",
            "maxowa_time",
            "minowa_regret_time",
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
                    w = sorted([random.randint(0, n) for i in range(n)], reverse=True)

                    start_time = time.time()
                    maxowa_project_selection(n, p, costs, utilities, B, w)
                    maxmin_time = time.time() - start_time

                    start_time = time.time()
                    minowa_regret_project_selection(n, p, costs, utilities, B, w)
                    minmax_regret_time = time.time() - start_time

                    print(f"  Repetition {rep + 1}/{num_repetitions}:")
                    print(f"    Maxowa time: {maxmin_time:.3f}s")
                    print(f"    Minowa regret time: {minmax_regret_time:.3f}s")

                    writer.writerow(
                        {
                            "n_scenarios": n,
                            "n_projects": p,
                            "repetition": rep + 1,
                            "maxowa_time": maxmin_time,
                            "minowa_regret_time": minmax_regret_time,
                        }
                    )
