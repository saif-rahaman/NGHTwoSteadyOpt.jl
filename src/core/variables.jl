######################################Node Variables########################################
"Square Pressure Variable"
function variable_pressure_sqr!(model,nw,var)

    Π = 
        var[:Π] = JuMP.@variable
        (model, 
        [i in keys(nw[:node])],
        lower_bound = (nw[:node][i]["p_min"])^2,
        upper_bound = (nw[:node][i]["p_max"])^2,
        base_name = "node_pressure_square"
        )

    return
end

"H2-conc in node"
function variable_node_conc!(model,nw,var)

    η = 
        var[:η] = JuMP.@variable
        (model, 
        [i in keys(nw[:node])],
        lower_bound = nw[:node][i]["conc_min"],
        upper_bound = nw[:node][i]["conc_max"],
        base_name = "node_H2-conc"
        )

    return
end

"supply/injection flow rate"
function variable_production_mass_flow!(model,nw,var)

    qs = 
        var[:qs] = JuMP.@variable
        (model, 
        [i in keys(nw[:dispatchable_receipt])],
        lower_bound = nw[:dispatchable_receipt][i]["injection_min"],
        upper_bound = nw[:dispatchable_receipt][i]["injection_max"],
        base_name = "supply"
        )

    return
end

"demand/withdrawal flow rate"
function variable_load_mass_flow!(model,nw,var)

    qw = 
        var[:qs] = JuMP.@variable
        (model, 
        [i in keys(nw[:dispatchable_delivery])],
        lower_bound = nw[:dispatchable_delivery][i]["withdrawal_min"],
        upper_bound = nw[:dispatchable_delivery][i]["withdrawal_max"],
        base_name = "demand"
        )

    return
end

######################################Edge Variables########################################

"mass flow in pipes"
function variable_pipe_mass_flow!(model,nw,var)

    f_pipe = 
        var[:f_pipe] = JuMP.@variable
        (model, 
        [i in keys(nw[:pipe])],
        lower_bound = nw[:pipe][i]["flow_min"],
        upper_bound = nw[:pipe][i]["flow_max"],
        base_name = "pipe_flow"
        )

    return
end

"mass flow in compressors"
function variable_compressor_mass_flow!(model,nw,var)

    f_comp = 
        var[:f_comp] = JuMP.@variable
        (model, 
        [i in keys(nw[:compressor])],
        lower_bound = nw[:compressor][i]["flow_min"],
        upper_bound = nw[:compressor][i]["flow_max"],
        base_name = "compressor_flow"
        )

    return
end

"H2-conc in pipe"
function variable_pipe_conc!(model,nw,var)

    γ_pipe = 
        var[:γ_pipe] = JuMP.@variable
        (model, 
        [i in keys(nw[:pipe])],
        lower_bound = nw[:pipe][i]["conc_min"],
        upper_bound = nw[:pipe][i]["conc_max"],
        base_name = "pipe_H2-conc"
        )

    return
end

"H2-conc in compressor"
function variable_compressor_conc!(model,nw,var)

    γ_comp = 
        var[:γ_comp] = JuMP.@variable
        (model, 
        [i in keys(nw[:compressor])],
        lower_bound = nw[:compressor][i]["conc_min"],
        upper_bound = nw[:compressor][i]["conc_max"],
        base_name = "compressor_H2-conc"
        )

    return
end

# "Compressor Ratio"
# function variable_compressor_ratio_sqr(model,nw)

#     ω = 
#         var[:ω] = JuMP.@variable
#         (model, 
#         [i in keys(nw[:compressor])],
#         lower_bound = nw[:compressor][i]["c_ratio_min"]^2,
#         upper_bound = nw[:compressor][i]["c_ratio_max"]^2,
#         base_name = "compressor_ratio_sqr"
#         )

#     return
# end

"Building variables"
function build_variables!(ss, model)

    nw = ss.ref

    var = Dict()

    ####Defining and adding the Variables####
    
    variable_pressure_sqr!(model, nw, var)
    variable_node_conc!(model, nw, var)
    variable_production_mass_flow!(model, nw, var)
    variable_load_mass_flow!(model, nw, var)

    variable_pipe_mass_flow!(model, nw, var)
    variable_compressor_mass_flow!(model, nw, var)
    variable_pipe_conc!(model, nw, var)
    variable_compressor_conc!(model, nw, var)

    return model, var

end

