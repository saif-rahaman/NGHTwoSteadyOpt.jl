######################################Node Variables########################################

"Square Pressure Variable"
function variable_pressure_sqr!(model,ref,var)

    Π = 
        var[:Π] = JuMP.@variable
        (model, 
        [i in keys(ref[:node])],
        lower_bound = (ref[:node][i]["p_min"])^2,
        upper_bound = (ref[:node][i]["p_max"])^2,
        base_name = "node_pressure_square"
        )

    return
end

"H2-conc in node"
function variable_node_conc!(model,ref,var)

    η = 
        var[:η] = JuMP.@variable
        (model, 
        [i in keys(ref[:node])],
        lower_bound = ref[:node][i]["conc_min"],
        upper_bound = ref[:node][i]["conc_max"],
        base_name = "node_H2-conc"
        )

    return
end

"supply/injection flow rate"
function variable_production_mass_flow!(model,ref,var)

    qs = 
        var[:qs] = JuMP.@variable
        (model, 
        [i in keys(ref[:dispatchable_receipt])],
        lower_bound = ref[:dispatchable_receipt][i]["injection_min"],
        upper_bound = ref[:dispatchable_receipt][i]["injection_max"],
        base_name = "supply"
        )

    return
end

"demand/withdrawal flow rate"
function variable_load_mass_flow!(model,ref,var)

    qw = 
        var[:qs] = JuMP.@variable
        (model, 
        [i in keys(ref[:dispatchable_delivery])],
        lower_bound = ref[:dispatchable_delivery][i]["withdrawal_min"],
        upper_bound = ref[:dispatchable_delivery][i]["withdrawal_max"],
        base_name = "demand"
        )

    return
end

######################################Edge Variables########################################

"mass flow in pipes"
function variable_pipe_mass_flow!(model,ref,var)

    f_pipe = 
        var[:f_pipe] = JuMP.@variable
        (model, 
        [i in keys(ref[:pipe])],
        lower_bound = ref[:pipe][i]["flow_min"],
        upper_bound = ref[:pipe][i]["flow_max"],
        base_name = "pipe_flow"
        )

    return
end

"mass flow in compressors"
function variable_compressor_mass_flow!(model,ref,var)

    f_comp = 
        var[:f_comp] = JuMP.@variable
        (model, 
        [i in keys(ref[:compressor])],
        lower_bound = ref[:compressor][i]["flow_min"],
        upper_bound = ref[:compressor][i]["flow_max"],
        base_name = "compressor_flow"
        )

    return
end

"H2-conc in pipe"
function variable_pipe_conc!(model,ref,var)

    γ_pipe = 
        var[:γ_pipe] = JuMP.@variable
        (model, 
        [i in keys(ref[:pipe])],
        lower_bound = ref[:pipe][i]["conc_min"],
        upper_bound = ref[:pipe][i]["conc_max"],
        base_name = "pipe_H2-conc"
        )

    return
end

"H2-conc in compressor"
function variable_compressor_conc!(model,ref,var)

    γ_comp = 
        var[:γ_comp] = JuMP.@variable
        (model, 
        [i in keys(ref[:compressor])],
        lower_bound = ref[:compressor][i]["conc_min"],
        upper_bound = ref[:compressor][i]["conc_max"],
        base_name = "compressor_H2-conc"
        )

    return
end

# "Compressor Ratio"
# function variable_compressor_ratio_sqr(model,ref)

#     ω = 
#         var[:ω] = JuMP.@variable
#         (model, 
#         [i in keys(ref[:compressor])],
#         lower_bound = ref[:compressor][i]["c_ratio_min"]^2,
#         upper_bound = ref[:compressor][i]["c_ratio_max"]^2,
#         base_name = "compressor_ratio_sqr"
#         )

#     return
# end

"Building variables"
function build_variables!(model,ref)

    var = Dict()

    ####Defining and adding the Variables####
    
    variable_pressure_sqr!(model, ref, var)
    variable_node_conc!(model, ref, var)
    variable_production_mass_flow!(model, ref, var)
    variable_load_mass_flow!(model, ref, var)

    variable_pipe_mass_flow!(model, ref, var)
    variable_compressor_mass_flow!(model, ref, var)
    variable_pipe_conc!(model, ref, var)
    variable_compressor_conc!(model, ref, var)

    return model, var

end

