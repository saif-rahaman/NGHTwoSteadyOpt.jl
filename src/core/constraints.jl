
"Constraint:Pipe Pressure Drop"
function constraint_pipe_pressure!(model,nw,var,con,params)
    con[:pipe_physics] = Dict()

    Π = var[:Π]
    f_pipe = var[:f_pipe]
    γ_pipe = var[:γ_pipe]
    #ζ_pipe = var[:ζ_pipe]
    
    for (i, pipe) in nw[:pipe]
        Π_fr = Π[pipe["fr_node"]]
        Π_to = Π[pipe["to_node"]]
        f = f_pipe[i]
        γ = γ_pipe[i]
        #ζ = ζ_pipe[i]
        resistance = pipe["resistance"]
        
        multiplier = nw[:multiplier]
        a_h2 = params[:speed_h2]
        a_ng = params[:speed_ng]
        a_0 = params[:speed_geometric_mean]
        V = (a_h2^2 * γ + a_ng^2 * (1 - γ))/(a_0^2)

        con[:pipe_physics][i] =
            JuMP.@NLconstraint(model, Π_fr - Π_to - resistance * multiplier * V * f * abs(f) == 0)
    end

    return
end

"Constraint:Pipe Square Sound Speed"
function constraint_pipe_sound_speed!(model,nw,var,con,params)
    con[:pipe_sound_speed] = Dict()

    a_h2 = params[:speed_h2]
    a_ng = params[:speed_ng]

    for (i,pipe) in nw[:pipe]
        ζ = var[:ζ_pipe][i]
        γ = var[:γ_pipe][i]

        con[:pipe_sound_speed][i] =
            JuMP.@NLconstraint(model, ζ == (a_h2^2 * γ + a_ng^2 * (1 - γ)))
    end

    return
end

"Constraint:Compressor Pressure"
function constraint_compressor_pressure!(model,nw,var,con)
    con[:compressor_boost] = Dict()
    #con[:compressor_boost_le] = Dict()
    #con[:compressor_boost_ge] = Dict()

    Π = var[:Π]
    ω = var[:ω]

    for (i, compressor) in nw[:compressor]
        Π_fr = Π[compressor["fr_node"]]
        Π_to = Π[compressor["to_node"]]
        #ω = ω[i]
        
        ω_max = nw[:compressor][i]["c_ratio_max"]^2 

        con[:compressor_boost][i] = 
            JuMP.@NLconstraint(model, Π_to - ω[i] * Π_fr == 0)

        # con[:compressor_boost_le][i] = 
        #     JuMP.@constraint(model, Π_to - ω_max * Π_fr <= 0)
        # con[:compressor_boost_ge][i] = 
        #     JuMP.@constraint(model, Π_to - Π_fr >= 0)

    end

    return
end

"Constraint:Node mass flow balance"
function constraint_mass_flow_balance!(model,nw,var,con)
    con[:nodal_mass_flow_balance] = Dict()
    var[:net_nodal_injection] = Dict()
    var[:net_nodal_edge_out_flow] = Dict()

    qs = var[:qs]
    qw = var[:qw]
    f_pipe = var[:f_pipe]
    f_comp = var[:f_comp]

    for (i, node) in nw[:node]
        var[:net_nodal_injection][i] = 0
        for j in nw[:dispatchable_receipts_in_node][i]
            var[:net_nodal_injection][i] += qs[j]
        end
        for j in nw[:dispatchable_deliveries_in_node][i]
            var[:net_nodal_injection][i] -= qw[j]
        end
        # for j in nw[:nondispatchable_receipts_in_node][i]
        #     var[:net_nodal_injection][i] += nw[:receipt][j]["injection_nominal"]
        # end
        # for j in nw[:nondispatchable_deliveries_in_node][i]
        #     var[:net_nodal_injection][i] -= nw[:delivery][j]["withdrawal_nominal"]
        # end
    end

    for (i, node) in nw[:node]
        var[:net_nodal_edge_out_flow][i] = 0
        for j in nw[:outgoing_pipes][i]
            var[:net_nodal_edge_out_flow][i] += f_pipe[j]
        end
        for j in nw[:outgoing_compressors][i]
            var[:net_nodal_edge_out_flow][i] += f_comp[j]
        end
        for j in nw[:incoming_pipes][i]
            var[:net_nodal_edge_out_flow][i] -= f_pipe[j]
        end
        for j in nw[:incoming_compressors][i]
            var[:net_nodal_edge_out_flow][i] -= f_comp[j]
        end
    end

    for (i, node) in nw[:node]
        net_injection = var[:net_nodal_injection][i]
        net_nodal_edge_out_flow = var[:net_nodal_edge_out_flow][i]
        con[:nodal_mass_flow_balance][i] =
            JuMP.@constraint(model, net_injection == net_nodal_edge_out_flow)
    end

    return
end

"Constraint:Node H2 mass flow balance"
function constraint_h2_mass_flow_balance!(model,nw,var,con)
    con[:nodal_h2_mass_flow_balance] = Dict()
    var[:net_h2_nodal_injection] = Dict()
    var[:net_h2_nodal_edge_out_flow] = Dict()

    qs = var[:qs]
    qw = var[:qw]
    f_pipe = var[:f_pipe]
    f_comp = var[:f_comp]
    η = var[:η]
    γ_pipe = var[:γ_pipe]
    γ_comp = var[:γ_comp]

    for (i,node) in nw[:node]
        var[:net_h2_nodal_injection][i] = 0
        for j in nw[:dispatchable_receipts_in_node][i]
            η_s = 1.0*nw[:dispatchable_receipt][j]["injection_conc"]
            var[:net_h2_nodal_injection][i] += η_s * qs[j]
        end
        for j in nw[:dispatchable_deliveries_in_node][i]
            var[:net_h2_nodal_injection][i] -= η[i] * qw[j]
        end
        # for j in nw[:nondispatchable_receipts_in_node][i]
        #     η_s = nw[:dispatchable_receipt][j]
        #     var[:net_h2_nodal_injection][i] += η_s * nw[:receipt][j]["injection_nominal"]
        # end
        # for j in nw[:nondispatchable_deliveries_in_node][i]
        #     var[:net_h2_nodal_injection][i] -= η[i] * nw[:delivery][j]["withdrawal_nominal"]
        # end
    end

    for (i, node) in nw[:node]
        var[:net_h2_nodal_edge_out_flow][i] = 0
        for j in nw[:outgoing_pipes][i]
            var[:net_h2_nodal_edge_out_flow][i] += γ_pipe[j] * f_pipe[j]
        end
        for j in nw[:outgoing_compressors][i]
            var[:net_h2_nodal_edge_out_flow][i] += γ_comp[j] * f_comp[j]
        end
        for j in nw[:incoming_pipes][i]
            var[:net_h2_nodal_edge_out_flow][i] -= γ_pipe[j] * f_pipe[j]
        end
        for j in nw[:incoming_compressors][i]
            var[:net_h2_nodal_edge_out_flow][i] -= γ_comp[j] * f_comp[j]
        end
    end

    for (i, node) in nw[:node]
        net_h2_injection = var[:net_h2_nodal_injection][i]
        net_h2_nodal_edge_out_flow = var[:net_h2_nodal_edge_out_flow][i]
        con[:nodal_h2_mass_flow_balance][i] =
            JuMP.@constraint(model, net_h2_injection == net_h2_nodal_edge_out_flow)
    end

    return
end

"Constraint:Slack Pressure"
function constraint_slack_pressure!(model,nw,var,con)
    con[:slack_pressure] = Dict()
    Π = var[:Π]
    for (i, node) in nw[:slack_nodes]
        con[:slack_pressure][i] = 
            JuMP.@constraint(model, Π[i] == node["nominal_pressure"]^2)
    end

    return
end

"Constraint:Node and Compressor concentration"
function constraint_node_compressor_conc!(model,nw,var,con)
    con[:node_compressor_conc] = Dict()

    γ_comp = var[:γ_comp]
    η = var[:η]

    for (i, compressor) in nw[:compressor]
        γ = γ_comp[i]
        η_fr = η[compressor["fr_node"]]
        con[:node_compressor_conc][i] = 
            JuMP.@NLconstraint(model, γ - η_fr == 0)
    end

    return
end

"Constraint:Withdrawal Heat Content Demand"
function constraint_withdrawal_heat_content!(model,nw,var,con,params)
    con[:withdrawal_heat_content] = Dict()

    R_h2 = params[:h2_calorific_value]
    R_ng = params[:ng_calorific_value]

    for (i,delivery) in nw[:dispatchable_delivery]
        g = var[:g][i]
        η = var[:η][delivery["node_id"]]
        f = var[:qw][i]

        con[:withdrawal_heat_content][i] = 
            JuMP.@NLconstraint(model, g == (R_h2*η + R_ng*(1-η))*f)
    end

    return

end

"Constraint:Compressor Power"
function constraint_compressor_power!(model,nw,var,con,params)
    
    κ_h2 = params[:h2_specific_heat_ratio]
    κ_ng = params[:ng_specific_heat_ratio]

    G_h2 = params[:h2_specific_gravity]
    G_ng = params[:ng_specific_gravity]

    con[:specific_gravity] = Dict()
    con[:specific_heat_ratio] = Dict()
    con[:compressor_power] = Dict()

    T = params[:temperature]

    G_s = var[:G]
    κ_s = var[:κ]
    P_w = var[:P_w]
    ω = var[:ω]

    for (i,compressor) in nw[:compressor]
        f = var[:f_comp][i]
        γ = var[:γ_comp][i]
        
        con[:specific_gravity][i] = 
            JuMP.@NLconstraint(model, G_s[i] == γ*G_h2 + (1-γ)*G_ng)

        con[:specific_heat_ratio][i] = 
            JuMP.@NLconstraint(model, κ_s[i] == γ*κ_h2 + (1-γ)*κ_ng)
        
        con[:compressor_power][i] = 
            JuMP.@NLconstraint(model, P_w[i] == f * (286.76 * T/G_s[i]) * (κ_s[i]/κ_s[i]-1) * (ω[i]^(κ_s[i]-1/(2*κ_s[i])) - 1)  )

    end

end

"Constraint:Node and Edge concentration"

"Smooth-Heaviside"
function constraint_node_pipe_conc_smooth!(model,nw,var,con)
    con[:node_pipe_conc_smooth] = Dict()

    f_pipe = var[:f_pipe]
    γ_pipe = var[:γ_pipe]
    η = var[:η]

    a = 5;
    
    for (i,pipe) in nw[:pipe]
        f = f_pipe[i]
        γ = γ_pipe[i]
        η_fr = η[pipe["fr_node"]]
        η_to = η[pipe["to_node"]]   

        con[:node_pipe_conc_smooth][i] = 
            JuMP.@NLconstraint(model, γ == (η_fr/(1 + exp(-a * f)))  +  (η_to * exp(-a *f)/(1 + exp(-a * f))))

    end


end


"Equation-based"
function constraint_node_pipe_conc_equation!(model,nw,var,con)
    con[:node_pipe_conc_eq_pos] = Dict()
    con[:node_pipe_conc_eq_neg] = Dict()
    con[:node_pipe_conc_eq] = Dict()
    
    f_pipe = var[:f_pipe]
    γ_pipe = var[:γ_pipe]
    η = var[:η]

    ϵ = 1e-03

    for (i, pipe) in nw[:pipe]
        f = f_pipe[i]
        γ = γ_pipe[i]
        η_fr = η[pipe["fr_node"]]
        η_to = η[pipe["to_node"]]

        # con[:node_pipe_conc_eq][i] = 
        #     JuMP.@NLconstraint(model, γ - η_fr == 0)
        
        con[:node_pipe_conc_eq_pos][i] = 
            JuMP.@NLconstraint(model, (f^2 + f * abs(f)) * (γ - η_fr) == 0)

        con[:node_pipe_conc_eq_neg][i] = 
            JuMP.@NLconstraint(model, (f^2 - f * abs(f)) * (γ - η_to) == 0)

    end

    return
end

"Complementarity-based"
function constraint_node_pipe_conc_complementarity!(model,nw,var,con)
    con[:node_pipe_conc_flow] = Dict()
    con[:node_pipe_conc_eq] = Dict()
    con[:node_pipe_conc_complementarity_1] = Dict()
    con[:node_pipe_conc_complementarity_2] = Dict()
    
    f_pipe = var[:f_pipe]
    γ_pipe = var[:γ_pipe]
    η = var[:η]
    eps = 1e-04

    aux_1 = var[:s1] = 
            JuMP.@variable(model, 
            [i in keys(nw[:pipe])],
            lower_bound = 0,
            base_name = "positive_auxiliary"
            )

    aux_2 = var[:s2] = 
            JuMP.@variable(model, 
            [i in keys(nw[:pipe])],
            lower_bound = 0,
            base_name = "negative_auxiliary"
            )

    aux_3 = var[:ν] = 
            JuMP.@variable(model, 
            [i in keys(nw[:pipe])],
            lower_bound = 0,
            upper_bound = 1,
            base_name = "switching_variable"
            )

    for (i, pipe) in nw[:pipe]
        f = f_pipe[i]
        γ = γ_pipe[i]
        η_fr = η[pipe["fr_node"]]
        η_to = η[pipe["to_node"]]
        
        s1 = aux_1[i]
        s2 = aux_2[i]
        ν = aux_3[i]

        con[:node_pipe_conc_flow][i] = 
            JuMP.@constraint(model, f == s1 - s2)

        con[:node_pipe_conc_eq][i] = 
            JuMP.@NLconstraint(model, γ == ν * η_fr + (1-ν) * η_to )

        con[:node_pipe_conc_complementarity_1][i] = 
            #JuMP.@constraint(model, s1 ⟂ 1-ν)
            JuMP.@constraint(model, s1 * (1-ν) <= eps)

        con[:node_pipe_conc_complementarity_2][i] = 
            #JuMP.@constraint(model, s2 ⟂ ν)
            JuMP.@constraint(model, s2 * ν <= eps)


    end

    return
end

"Integer variable based"
function constraint_node_pipe_conc_integer!(model,nw,var,con)
    con[:node_pipe_conc_int_eq] = Dict()
    con[:node_pipe_conc_int_ineq_1] = Dict()
    con[:node_pipe_conc_int_ineq_2] = Dict()

    f_pipe = var[:f_pipe]
    γ_pipe = var[:γ_pipe]
    η = var[:η]

    y = var[:y] = 
        JuMP.@variable(model,
        [i in keys(nw[:pipe])],
        binary = true,
        base_name = "switching_binary_variable"
        )

    for (i, pipe) in nw[:pipe]
        f = f_pipe[i]
        γ = γ_pipe[i]
        η_fr = η[pipe["fr_node"]]
        η_to = η[pipe["to_node"]]

        M = max(abs(pipe["flow_min"]),abs(pipe["flow_max"]))

        con[:node_pipe_conc_int_eq][i] = 
            JuMP.@NLconstraint(model, γ == y[i] * η_fr + (1-y[i]) * η_to )

        con[:node_pipe_conc_int_ineq_1][i] = 
            JuMP.@constraint(model, f >= - M * (1-y[i]))

        con[:node_pipe_conc_int_ineq_2][i] = 
            JuMP.@constraint(model, f <= M * y[i])
    end

    return
end


"Building constraints"
function build_constraints!(ss, model, var)

    con = Dict()

    nw = ss.ref;
    params = ss.params;

    ####Defining and adding the Constraints####

    constraint_pipe_pressure!(model, nw, var, con, params)
    #constraint_pipe_sound_speed!(model,nw,var,con,params)
    constraint_withdrawal_heat_content!(model, nw, var, con, params)
    constraint_compressor_pressure!(model, nw, var, con)
    constraint_mass_flow_balance!(model, nw, var, con)
    constraint_h2_mass_flow_balance!(model, nw, var, con)
    constraint_slack_pressure!(model, nw, var, con)
    constraint_compressor_power!(model, nw, var, con, params)
    

    constraint_node_pipe_conc_equation!(model, nw, var, con)
    #constraint_node_pipe_conc_smooth!(model, nw, var, con)
    #constraint_node_pipe_conc_complementarity!(model, nw, var, con)
    #constraint_node_pipe_conc_integer!(model,nw,var,con)

    constraint_node_compressor_conc!(model, nw, var, con)

    return model, var, con

end
