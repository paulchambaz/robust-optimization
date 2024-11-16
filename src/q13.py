# question 1.3 - paul chambaz & zelie van der meer - 2024

n = 10
costs = [60, 10, 15, 20, 25, 20, 5, 15, 20, 60]
utilities_s1 = [70, 18, 16, 14, 12, 10, 8, 6, 4, 2]
utilities_s2 = [2, 4, 6, 8, 10, 12, 14, 16, 18, 70]

x1_star = [1, 1, 1, 0, 0, 0, 1, 0, 0, 0]
x2_star = [0, 0, 0, 0, 0, 0, 1, 1, 1, 1]
x_star = [0, 1, 1, 1, 0, 0, 1, 1, 1, 0]
x_prime_star = [0, 1, 1, 0, 0, 1, 1, 1, 1, 0]


def get_utilities(x):
    z1 = sum(utilities_s1[j] * x[j] for j in range(n))
    z2 = sum(utilities_s2[j] * x[j] for j in range(n))
    return (z1, z2)


z1_star = get_utilities(x1_star)
z2_star = get_utilities(x2_star)
z_star = get_utilities(x_star)
z_prime_star = get_utilities(x_prime_star)

print(f"z(x1*) = {z1_star}")
print(f"z(x2*) = {z2_star}")
print(f"z(x*) = {z_star}")
print(f"z(x'*) = {z_prime_star}")
