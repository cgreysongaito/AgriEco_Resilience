using SymPy

@vars I
@vars yₘ I₀ p c

#Type III
f(I) = yₘ * (I^2) / (I₀ + (I^2))
SymPy.simplify(diff(f(I),I))

g(I) = 2 * I * yₘ * I₀ / (( I₀ + (I^2) )^2)
SymPy.simplify(diff(g(I),I))

SymPy.solve((c/p)*((I₀+(C^2))^2)-(2*C*y*I₀), C)




# Monod Type II version
@vars C
@vars y I₀ c p

diff(sqrt(C), C)

f(C) = y * C / (I₀ + C)
g(y) = (p * I₀) / (y * (I₀ - sqrt((p * y * I₀)/c)))
s(I₀) = (p * I₀) / (y * (I₀ - sqrt((p * y * I₀)/c)))
SymPy.simplify(diff(g(y),y))
SymPy.simplify(diff(s(I₀),I₀))

SymPy.simplify(diff(f(C),C))

SymPy.simplify((-c * ((sqrt((p * y * I₀)/c))-I₀)) / ((y * ((sqrt((p * y * I₀)/c))-I₀)) / (I₀ + ((sqrt((p * y * I₀)/c))-I₀)) )^2)
