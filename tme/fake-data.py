import os

import numpy as np


def generate_performance_data(
    path, n_start, n_end, n_step, measurements_per_n, time_function, noise_function
):
    os.makedirs(os.path.dirname(os.path.abspath(path)), exist_ok=True)
    with open(path, "w") as f:
        f.write("instance_size,execution_time\n")
        for n in range(n_start, n_end + n_step, n_step):
            base_time = int(time_function(n))
            for _ in range(measurements_per_n):
                noise = int(noise_function(base_time))
                time = max(1, base_time + noise)  # Minimum 1ms
                f.write(f"{n},{time}\n")


if __name__ == "__main__":
    linear_time = lambda n: n * 0.1  # 0.1ms per element
    linear_noise = lambda t: np.random.normal(0, 0.1 * t)
    generate_performance_data(
        "paper/data/linear.csv",
        n_start=1000,
        n_end=10000,
        n_step=1000,
        measurements_per_n=10,
        time_function=linear_time,
        noise_function=linear_noise,
    )

    exp_time = lambda n: 10 * (2 ** (n / 10))
    exp_noise = lambda t: np.random.normal(0, 0.2 * t)
    generate_performance_data(
        "paper/data/exponential.csv",
        n_start=10,
        n_end=100,
        n_step=10,
        measurements_per_n=10,
        time_function=exp_time,
        noise_function=exp_noise,
    )
