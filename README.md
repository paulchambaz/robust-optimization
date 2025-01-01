# Robust Decision Making Under Uncertainty

A Python implementation of robust optimization algorithms including Maxmin, Minmax Regret and OWA criteria for project selection and path finding under uncertainty (Sorbonne University, MOGPL course project)

## About Robust Optimization

This project implements various robust optimization strategies for decision making under complete uncertainty:

- **Maxmin Criterion**: Optimizes the worst case scenario
- **Minmax Regret**: Minimizes the maximum regret between the chosen solution and optimal solutions
- **OWA Criteria**: Uses ordered weighted averaging to balance between optimistic and pessimistic evaluations

It addresses two main applications:

- Project selection under budget constraints
- Path finding in weighted graphs

Both problems are solved using linear programming with binary variables through PuLP and Gurobi.

## Usage

Requires Python 3.x and the following packages:

```sh
pip install pulp  # For linear programming
# Note: Also requires Gurobi license and installation
```

Run experiments:

```sh
# Project Selection
python src/q11.py  # Maxmin
python src/q12.py  # Minmax regret
python src/q24.py  # OWA

# Path Finding
python src/q32.py  # Single scenario
python src/q33.py  # Multiple criteria

# Performance Analysis
python src/q14.py  # Project selection
python src/q26.py  # OWA criteria
python src/q34.py  # Path finding
```

## Project Structure

```
src/
  q11.py       # Maxmin project selection
  q12.py       # Minmax regret project selection
  q24.py       # OWA project selection
  q32.py       # Single scenario path finding
  q33.py       # Multi-criteria path finding
  q34.py       # Performance analysis
paper/         # Typst report and figures
  data/        # Experimental results
```

## Authors

- [Paul Chambaz](https://www.linkedin.com/in/paul-chambaz-17235a158/)
- Zélie van der Meer

## License

This project is licensed under the GNU General Public License v3.0 - see the LICENSE file for details.
