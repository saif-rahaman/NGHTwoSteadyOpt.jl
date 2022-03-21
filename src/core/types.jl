struct SteadyOptimizer
    data::Dict{String,Any}
    ref::Dict{Symbol,Any}
    sol::Dict{String,Any}
    nominal_values::Dict{Symbol,Any}
    params::Dict{Symbol,Any}
    initial_guess::Dict{Symbol,Any}
    boundary_conditions::Dict{Symbol,Any}
    pu_eos_coeffs::Function
    pu_pressure_to_pu_density::Function
    pu_density_to_pu_pressure::Function
end

ref(ss::SteadyOptimizer) = ss.ref
ref(ss::SteadyOptimizer, key::Symbol) = ss.ref[key]
ref(ss::SteadyOptimizer, key::Symbol, id::Int64) = ss.ref[key][id]
ref(ss::SteadyOptimizer, key::Symbol, id::Int64, field) = ss.ref[key][id][field]

params(ss::SteadyOptimizer) = ss.params
params(ss::SteadyOptimizer, key::Symbol) = ss.params[key]

nominal_values(ss::SteadyOptimizer) = ss.nominal_values
nominal_values(ss::SteadyOptimizer, key::Symbol) = ss.nominal_values[key]

initial_pipe_mass_flow(ss::SteadyOptimizer, id::Int64) = 
    ss.initial_guess[:pipe][id]

initial_compressor_flow(ss::SteadyOptimizer, id::Int64) = 
    ss.initial_guess[:compressor][id]

initial_nodal_pressure(ss::SteadyOptimizer, id::Int64) = 
    ss.initial_guess[:node][id]

get_eos_coeffs(ss::SteadyOptimizer) = ss.pu_eos_coeffs(nominal_values(ss), params(ss))
get_pressure(ss::SteadyOptimizer, density, gamma) = 
    ss.pu_density_to_pu_pressure(density, gamma, nominal_values(ss), params(ss))
get_density(ss::SteadyOptimizer, pressure, gamma) = 
    ss.pu_pressure_to_pu_density(pressure, gamma, nominal_values(ss), params(ss))


TOL = 1.0e-5

function get_nodal_control_type(ss::SteadyOptimizer, id::Int64)::CONTROL_TYPE 
    (!haskey(ss.boundary_conditions[:node], id)) && (return flow_control)
    return ss.boundary_conditions[:node][id]["control_type"]
end 

function get_slack_control(ss::SteadyOptimizer, id::Int64)::Tuple{Float64,Float64}
    (ref(ss, :node, id, "is_slack") == 0) && 
        (@error "node $id is non-slack")
    return ss.boundary_conditions[:node][id]["val"]
end 

function get_non_slack_control(ss::SteadyOptimizer, id::Int64)::Tuple{Float64,Float64,Float64}
    (!haskey(ss.boundary_conditions[:node], id)) && (return (NaN, 0.0, NaN))
    return ss.boundary_conditions[:node][id]["val"]
end 

function get_nodal_control(ss::SteadyOptimizer,
    id::Int64)::Union{Tuple{Float64,Float64}, Tuple{Float64,Float64,Float64}}
    (ref(ss, :node, id, "is_slack") == 0) && (return get_slack_control(ss, id))
    return get_non_slack_control(ss, id)
end

get_compressor_control_type(ss::SteadyOptimizer, id::Int64)::CONTROL_TYPE = 
    CONTROL_TYPE(ss.boundary_conditions[:compressor][id]["control_type"])


get_compressor_control(ss::SteadyOptimizer, id::Int64)::Float64 = 
    ss.boundary_conditions[:compressor][id]["val"]

@enum CONTROL_TYPE begin
    unknown_control = 0
    c_ratio_control = 1
    pressure_control = 2
    flow_control = 3
end

"""
Equation ordering helper functions:
        1. full nodal balance at nodes
        2. hydrogen nodal balance at the nodes 
        3. slack pressure fixing at the nodes 
        4. steady physics for pipes 
        5. concentration definition for pipes 
        6. boost ratio for compressors 
        7. concentration definition for compressors 
"""
# function get_nodal_eqn_id(ss::SteadyOptimizer, key::Symbol, id::Int64)::Int64 
#     (key == :full_nodal_balance) && (return ref(ss, :node, id, "dof_pressure"))
#     (key == :hydrogen_nodal_balance) && (return ref(ss, :node, id, "dof_concentration"))
#     if key == :slack_pressure
#         (ref(ss, :node, id, "is_slack") == 0) && (@error "$id is not a slack node")
#     end 
#     return ref(ss, :node, id, "dof_slack_injection")
# end 

# function get_pipe_eqn_id(ss::SteadyOptimizer, key::Symbol, id::Int64)::Int64
#     (key == :physics) && (return ref(ss, :pipe, id, "dof_flow"))
#     return ref(ss, :pipe, id, "dof_concentration")
# end 

# function get_compressor_eqn_id(ss::SteadyOptimizer, key::Symbol, id::Int64)::Int64
#     (key == :physics) && (return ref(ss, :compressor, id, "dof_flow"))
#     return ref(ss, :compressor, id, "dof_concentration")
# end 


@enum SOLVER_STATUS begin 
    successfull = 0 
    nl_solve_failure = 1 
    compressor_flow_infeasibility = 2
    slack_pressure_infeasibility = 3
end

struct SolverReturn 
    status::SOLVER_STATUS
    iterations::Int 
    residual_norm::Float64 
    time::Float64 
    solution::Vector{Float64}
    negative_flow_in_compressors::Vector{Int64}
    negative_potential_in_nodes::Vector{Int64}
end 
