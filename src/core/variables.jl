# ######################################Node Variables########################################
# "Square Pressure Variable"
function variable_pressure_sqr!(model, nw::Dict{Symbol,Any}, var)

    Π = 
        var[:Π] = JuMP.@variable(
        model, 
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
        var[:η] = JuMP.@variable(
        model, 
        [i in keys(nw[:node])],
        lower_bound = nw[:node][i]["concentration_min"],
        upper_bound = nw[:node][i]["concentration_max"],
        base_name = "node_H2-conc"
        )

    return
end

"supply/injection flow rate"
function variable_production_mass_flow!(model,nw,var)

    qs = 
        var[:qs] = JuMP.@variable(
        model, 
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
        var[:qw] = JuMP.@variable(
        model, 
        [i in keys(nw[:dispatchable_delivery])],
        lower_bound = 0, #nw[:dispatchable_delivery][i]["withdrawal_min"],
        upper_bound = Inf, #nw[:dispatchable_delivery][i]["withdrawal_max"],
        base_name = "demand"
        )

    return
end

######################################Edge Variables########################################

"mass flow in pipes"
function variable_pipe_mass_flow!(model,nw,var)

    f_pipe = 
        var[:f_pipe] = JuMP.@variable(
        model, 
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
        var[:f_comp] = JuMP.@variable(
        model, 
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
        var[:γ_pipe] = JuMP.@variable(
        model, 
        [i in keys(nw[:pipe])],
        lower_bound = nw[:pipe][i]["concentration_min"],
        upper_bound = nw[:pipe][i]["concentration_max"],
        base_name = "pipe_H2-conc"
        )

    return
end

"H2-conc in compressor"
function variable_compressor_conc!(model,nw,var)

    γ_comp = 
        var[:γ_comp] = JuMP.@variable(
        model, 
        [i in keys(nw[:compressor])],
        lower_bound = nw[:compressor][i]["concentration_min"],
        upper_bound = nw[:compressor][i]["concentration_max"],
        base_name = "compressor_H2-conc"
        )

    return
end

"Square speed of sound in pipe"
function variable_square_sound_speed!(model,nw,var,params)

    ζ_pipe = 
        var[:ζ_pipe] = JuMP.@variable(model, 
        [i in keys(nw[:pipe])],
        lower_bound = params[:speed_h2]^2 * nw[:pipe][i]["concentration_min"]  +  params[:speed_ng]^2 * (1-nw[:pipe][i]["concentration_min"]),
        upper_bound = params[:speed_h2]^2 * nw[:pipe][i]["concentration_max"]  +  params[:speed_ng]^2 * (1-nw[:pipe][i]["concentration_max"]),
        base_name = "pipe_sqr_sound_speed"
        )

    return
end

"Compressor Ratio"
function variable_compressor_ratio_sqr!(model,nw,var)

    ω = 
        var[:ω] = JuMP.@variable(
        model, 
        [i in keys(nw[:compressor])],
        lower_bound = nw[:compressor][i]["c_ratio_min"]^2,
        upper_bound = nw[:compressor][i]["c_ratio_max"]^2,
        base_name = "compressor_ratio_sqr"
        )

    return
end

"Specific_gravity"
function variable_specific_gravity!(model,nw,var,params)

    G = 
        var[:G] = JuMP.@variable(
        model,
        [i in keys(nw[:compressor])],
        lower_bound = params[:h2_specific_gravity],
        upper_bound = params[:ng_specific_gravity],
        base_name = "gas_specific_gravity"
        )

    return
end

"Specific heat capacity ratio"
function variable_specific_heat_ratio!(model,nw,var,params)

    κ = 
        var[:κ] = JuMP.@variable(
        model,
        [i in keys(nw[:compressor])],
        lower_bound = params[:ng_specific_heat_ratio],
        upper_bound = params[:h2_specific_heat_ratio],
        base_name = "gas_specific_heat_ratio"
        )

    return
end


"Compressor Power"
function variable_compressor_power!(model,nw,var)

    P_w = 
        var[:P_w] = JuMP.@variable(
        model, 
        [i in keys(nw[:compressor])],
        lower_bound = 0,
        upper_bound = nw[:compressor][i]["max_power"],
        base_name = "compressor_power"
        )

    return
end

"Gas Heat Content"
function variable_gas_heat_content!(model,nw,var)

    g =
        var[:g] = JuMP.@variable(
        model,
        [i in keys(nw[:dispatchable_delivery])],
        lower_bound = nw[:dispatchable_delivery][i]["min_heat_demand"],
        upper_bound = nw[:dispatchable_delivery][i]["max_heat_demand"],
        base_name = "gas_heat_content"
        )

    return
end

"Building variables"
function build_variables!(ss::SteadyOptimizer, model)

    nw = ss.ref;
    params = ss.params;

    var = Dict{Symbol,Any}()

    ####Defining and adding the Variables####
    
    variable_pressure_sqr!(model, nw, var)
    variable_node_conc!(model, nw, var)
    variable_production_mass_flow!(model, nw, var)
    variable_load_mass_flow!(model, nw, var)

    variable_pipe_mass_flow!(model, nw, var)
    variable_compressor_mass_flow!(model, nw, var)
    variable_pipe_conc!(model, nw, var)
    variable_compressor_conc!(model, nw, var)
    variable_square_sound_speed!(model, nw, var,params)
    variable_gas_heat_content!(model, nw, var)
    variable_compressor_ratio_sqr!(model, nw, var)
    variable_specific_gravity!(model, nw, var, params)
    variable_specific_heat_ratio!(model, nw, var, params)
    variable_compressor_power!(model, nw, var)

    return model, var

end

