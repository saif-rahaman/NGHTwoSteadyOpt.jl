
function update_solution_fields_in_ref(ss::SteadyOptimizer, var::Dict{Symbol,Any})
    
    sol = Dict{Symbol,Any}()

    ref = ss.ref
    nominal_values = ss.nominal_values

    sol[:pressure] = Dict()
    sol[:node_concentration] = Dict()
    sol[:injection_flows] = Dict()
    sol[:withdrawal_flows] = Dict()
    sol[:withdrawal_heat_content] = Dict()
    sol[:pipe_flows] = Dict()
    sol[:compressor_flows] = Dict()
    sol[:pipe_concentration] = Dict()
    sol[:compressor_concentration] = Dict()
    sol[:compressor_ratio] = Dict()

    for (i,_) in ref[:node]
        sol[:pressure][i] = sqrt(JuMP.value(var[:Π][i])) * nominal_values[:pressure]
        sol[:node_concentration][i] = JuMP.value(var[:η][i])
    end

    for (i,_) in ref[:dispatchable_receipt]
        sol[:injection_flows][i] = JuMP.value(var[:qs][i]) * nominal_values[:mass_flow]
    end

    for (i,_) in ref[:dispatchable_delivery]
        sol[:withdrawal_flows][i] = JuMP.value(var[:qw][i]) * nominal_values[:mass_flow]
        sol[:withdrawal_heat_content][i] = JuMP.value(var[:g][i]) * nominal_values[:mass_flow]
    end

    for (i,_) in ref[:pipe]
        sol[:pipe_flows][i] = JuMP.value(var[:f_pipe][i]) * nominal_values[:mass_flow]
        sol[:pipe_concentration][i] = JuMP.value(var[:γ_pipe][i])
    end

    for (i,compressor) in ref[:compressor]
        sol[:compressor_flows][i] = JuMP.value(var[:f_comp][i]) * nominal_values[:mass_flow]
        sol[:compressor_concentration][i] = JuMP.value(var[:γ_comp][i])
        sol[:compressor_ratio][i] = sqrt((JuMP.value(var[:Π][compressor["to_node"]])/JuMP.value(var[:Π][compressor["fr_node"]])))
    end

    return sol

end

