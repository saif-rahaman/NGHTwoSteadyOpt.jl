include("./src/NGHTwoSteadyOpt.jl")

file = "./data/GasLib-40/"
ss = initialize_optimizer(file, initial_guess_filename="");

type = "nlp_eq"
solver_options = Dict()
#solver_options["outlev"] = 6
#solver_options["algorithm"] = 1

solver_options["print_level"] = 5
solver_options["linear_solver"] = "ma57"
#solver_options["max_iter"] = 10000
# #solver_options["NonConvex"] = 2

report = run_optimizer(ss, type, solver_options);

results_file = file * "results.json"

open(results_file, "w") do f 
    JSON.print(f, report.sol, 2)
end
