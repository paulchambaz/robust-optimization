import pulp  # type: ignore

# Create the linear programming problem
prob = pulp.LpProblem("sudoku", pulp.LpMinimize)

# Create a 2D list of pulp variables
cells = [
    [
        pulp.LpVariable(f"x{i}{j}", lowBound=1, upBound=4, cat="Integer")
        for j in range(4)
    ]
    for i in range(4)
]

prob += pulp.lpSum(
    cells[0][0]
    + cells[1][1]
    + cells[2][2]
    + cells[3][3]
    + cells[0][3]
    + cells[1][2]
    + cells[2][1]
    + cells[3][0]
)


# Constants
M = 1000
epsilon = 0.1

for i in range(4):
    for j in range(4):
        for k in range(j + 1, 4):
            # we linearize the problem using a diff value
            z = pulp.LpVariable(f"diff{i}{j}{i}{k}", cat="Binary")
            prob += (
                pulp.lpSum(cells[i][j] - cells[i][k] + M * z) >= epsilon,
                f"diff_low_{i}{j}{i}{k}",
            )
            prob += (
                pulp.lpSum(cells[i][k] - cells[i][j] + M * (1 - z)) >= epsilon,
                f"diff_high_{i}{j}{i}{k}",
            )

for i in range(4):
    for j in range(4):
        for k in range(j + 1, 4):
            # we linearize the problem using a diff value
            z = pulp.LpVariable(f"diff{j}{i}{k}{i}", cat="Binary")
            prob += (
                pulp.lpSum(cells[j][i] - cells[k][i] + M * z) >= epsilon,
                f"diff_low_{j}{i}{k}{i}",
            )
            prob += (
                pulp.lpSum(cells[k][i] - cells[j][i] + M * (1 - z)) >= epsilon,
                f"diff_high_{j}{i}{k}{i}",
            )

# Add given values
prob += cells[0][1] == 2, "Given1"
prob += cells[0][3] == 4, "Given2"
prob += cells[1][0] == 3, "Given3"
prob += cells[2][2] == 4, "Given4"

prob += cells[1][2] == 2, "Given5"

# Solve the problem
prob.solve(pulp.GLPK())

# Print the solution
print("\nSolution:")
for i in range(4):
    for j in range(4):
        print(cells[i][j].value(), end=" ")
    print()

print("\nStatus:", pulp.LpStatus[prob.status])
print(f"\nValeur de la fonction objectif : {prob.objective.value()}")
