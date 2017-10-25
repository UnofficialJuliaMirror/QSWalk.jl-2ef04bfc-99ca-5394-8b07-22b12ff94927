# ------------------------------------------------------------------------------
# Imports
# ------------------------------------------------------------------------------

using QSWalk

#
using PyPlot # for plot
using LightGraphs # for PathGraph

# Dimension of the system
dim = 51

# Initial position on the line
s0 = Int((dim+1)/2)

# Adjency matrix for the line
adjmtx = adjacency_matrix(PathGraph(dim))
# this is equvalent to 
#adjmtx = spdiagm((ones(dim-1), ones(dim-1)), (-1, 1))
##

# ------------------------------------------------------------------------------
# Case 1: classical Lindbladian
# ------------------------------------------------------------------------------
ham = adjmtx
lin = classical_lindblad_operators(adjmtx)
evo = global_operator(ham, lin)
init = proj(s0, dim)
time_step = 1.0
time_points = collect(0:10)*time_step
##

# Versions using sparse evolution
@time evolve(evo, full(init), time_step)
@time res = evolve(evo, init, time_step)
plot(diag(res)
# Versions using dense evolution
#@time evolve(full(evo), full(init), time_step)
#@time evolve(full(evo), init, time_step)

#evolve_operator(full(evo), time_step)
##
# ------------------------------------------------------------------------------
# Case 2: stochastic case with moralization
# ------------------------------------------------------------------------------

ham = adjmt
lin = [adjmtx]
omg = 0.5

evo = global_operator(ham, lin, omg)

init = proj(s0, dim)
time_point = 1.
##

@time evolve(evo, init, time_point)

@time evolve(full(evo), init, time_point)

##

# ------------------------------------------------------------------------------
# Case 3: stochastic case with demoralization procedure
# ------------------------------------------------------------------------------

lin, vset = nonmoralizing_lindbladian(adjmtx)
ham = (x-> if x!=0 1 else 0 end).(lin) # makes 0-1 matrix
ham_local = local_hamiltonian(vset)

omg = 0.5
evo = global_operator(ham, [lin], ham_local, omg)
init = init_nonmoralized([vset[s0]], vset)

time_point = 1.
##
result = evolve(evo, init, time_point)
distribution = measurement_nonmoralized(result, vset)
plot(distribution)

##