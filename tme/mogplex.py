from pulp import GLPK, LpMaximize, LpProblem, LpVariable, lpSum  # type:ignore

# Problem parameters
nbcont = 4
nbvar = 2

# Range of constraints and variables
lignes = range(nbcont)
colonnes = range(nbvar)

# Constraint matrix
a = [[1, 0], [0, 1], [1, 2], [2, 1]]

# Right-hand side values
b = [8, 6, 15, 18]

# Objective function coefficients
c = [4, 10]

# Create the model
m = LpProblem("mogplex", LpMaximize)

# Create decision variables
x = [LpVariable(f"x{i+1}", lowBound=0, cat="Continuous") for i in colonnes]

# Set objective function
m += lpSum(c[j] * x[j] for j in colonnes)

# Add constraints
for i in lignes:
    m += lpSum(a[i][j] * x[j] for j in colonnes) <= b[i], f"Constraint{i}"

# Solve the problem using GLPK
m.solve(GLPK())

# Print results
print("\nSolution optimale:")
for j in colonnes:
    print(f"x{j+1} = {x[j].value()}")

print(f"\nValeur de la fonction objectif : {m.objective.value()}")
