B0 = 0.1
k_10 = 0.018377505387559667
k_20 = 0.01013198112809354
T_a1 = 3000.
T_a2 = 1500.

k1(T) = k_10 * exp(-T / T_a1)
k2(T) = k_20 * exp(-T / T_a2)
A(T) = k2(T) * B0 / (k1(T) + k2(T))

set dummy T
set grid
set xlabel "Temperature (K)"
set ylabel "Equilibrium concentration (mol)"

set term svg
set output "ChemicalReactionEquilibriumConcentration.svg"

plot [273.15:1200] A(T) t ""

