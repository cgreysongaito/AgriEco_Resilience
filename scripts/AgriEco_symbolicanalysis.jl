using SymPy

@vars I
@vars yₘ y₀ p c

#Type III
f(I) = yₘ * (I^2) / (y₀ + (I^2))
SymPy.simplify(diff(f(I),I))

g(I) = 2 * I * yₘ * y₀ / (( y₀ + (I^2) )^2)
SymPy.simplify(diff(g(I),I))

SymPy.solve((c/p)*((y₀+(C^2))^2)-(2*C*y*y₀), C)




# Monod Type II version
@vars C
@vars y y₀ c p

diff(sqrt(C), C)

f(C) = y * C / (y₀ + C)
g(y) = (p * y₀) / (y * (y₀ - sqrt((p * y * y₀)/c)))
s(y₀) = (p * y₀) / (y * (y₀ - sqrt((p * y * y₀)/c)))
SymPy.simplify(diff(g(y),y))
SymPy.simplify(diff(s(y₀),y₀))

SymPy.simplify(diff(f(C),C))

SymPy.simplify((-c * ((sqrt((p * y * y₀)/c))-y₀)) / ((y * ((sqrt((p * y * y₀)/c))-y₀)) / (y₀ + ((sqrt((p * y * y₀)/c))-y₀)) )^2)
