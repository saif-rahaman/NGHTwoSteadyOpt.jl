con = Dict()

"Constraint:Pipe Pressure Drop"
function constraint_pipe_pressure(model,nw,con,var)
    con[:pipe_physics] = Dict()

    Π = var[:Π]
    f_pipe = var[:f_pipe]
    γ_pipe = var[:γ_pipe]
    
    for (i, pipe) in nw[:pipe]
        Π_fr = Π[pipe["fr_junction"]]
        Π_to = Π[pipe["to_junction"]]
        f = f_pipe[i]
        γ = γ_pipe[i]
        resistance = pipe["resistance"]
        
        multiplier = nw[:multiplier]
        a_h2 = nw[:speed_h2]
        a_ng = nw[:speed_NG]
        V = (a_h2^2 * γ + a_ng^2 * (1 - γ))

        con[:pipe_physics][i] =
            JuMP.@NLconstraint(model, Π_fr^2 - Π_to^2 - resistance * multiplier * V * f * abs(f) == 0)
    end

    return
end

"Constraint:Compressor Pressure"
function constraint_compressor_pressure(model,nw,con,var)
    con[:compressor_boost] = Dict()
    #con[:compressor_boost_le] = Dict()
    #con[:compressor_boost_ge] = Dict()

    Π = var[:Π]
    #ω = var[:ω]

    for (i, compressor) in nw[:compressor]
        Π_fr = Π[compressor["fr_junction"]]
        Π_to = Π[compressor["to_junction"]]
        #ω = ω[i]
        
        ω_max = nw[:compressor][i]["c_ratio_max"]^2 

        con[:compressor_boost][i] = 
            JuMP.@NLconstraint(model, Π_to - ω * Π_fr == 0)

        #con[:compressor_boost_le][i] = 
            #JuMP.@constraint(model, Π_to - ω_max* Π_fr <= 0)
        #con[:compressor_boost_ge][i] = 
            #JuMP.@constraint(model, Π_to - Π_fr >= 0)

    end

    return
end

"Constraint:Node mass flow balance"
function constraint_mass_flow_balance(model,nw,con,var)
    con[:nodal_mass_flow_balance] = Dict()
    var[:net_nodal_injection] = Dict()
    var[:net_nodal_edge_out_flow] = Dict()

    qs = var[:qs]
    qw = var[:qw]
    f_pipe = var[:f_pipe]
    f_comp = var[:f_comp]

    for (i, junction) in nw[:junction]
        var[:net_nodal_injection][i] = 0
        for j in nw[:dispatchable_receipts_in_junction][i]
            var[:net_nodal_injection][i] += qs[j]
        end
        for j in nw[:dispatchable_deliveries_in_junction][i]
            var[:net_nodal_injection][i] -= qw[j]
        end
        for j in nw[:nondispatchable_receipts_in_junction][i]
            var[:net_nodal_injection][i] += nw[:receipt][j]["injection_nominal"]
        end
        for j in nw[:nondispatchable_deliveries_in_junction][i]
            var[:net_nodal_injection][i] -= nw[:delivery][j]["withdrawal_nominal"]
        end
    end

    for (i, junction) in nw[:junction]
        var[:net_nodal_edge_out_flow][i] = 0
        for j in nw[:pipes_fr][i]
            var[:net_nodal_edge_out_flow][i] += f_pipe[j]
        end
        for j in nw[:compressors_fr][i]
            var[:net_nodal_edge_out_flow][i] += f_comp[j]
        end
        for j in nw[:pipes_to][i]
            var[:net_nodal_edge_out_flow][i] -= f_pipe[j]
        end
        for j in nw[:compressors_to][i]
            var[:net_nodal_edge_out_flow][i] -= f_comp[j]
        end
    end

    for (i, junction) in nw[:junction]
        net_injection = var[:net_nodal_injection][i]
        net_nodal_edge_out_flow = var[:net_nodal_edge_out_flow][i]
        con[:nodal_mass_flow_balance][i] =
            JuMP.@constraint(model, net_injection == net_nodal_edge_out_flow)
    end

    return
end

"Constraint:Node H2 mass flow balance"
function constraint_mass_flow_balance(model,nw,con)
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

    for (i, junction) in nw[:junction]
        var[:net_h2_nodal_injection][i] = 0
        for j in nw[:dispatchable_receipts_in_junction][i]
            η_s = nw[:dispatchable_receipt][j]
            var[:net_h2_nodal_injection][i] += η_s * qs[j]
        end
        for j in nw[:dispatchable_deliveries_in_junction][i]
            var[:net_h2_nodal_injection][i] -= η[i] * qw[j]
        end
        for j in nw[:nondispatchable_receipts_in_junction][i]
            η_s = nw[:dispatchable_receipt][j]
            var[:net_h2_nodal_injection][i] += η_s * nw[:receipt][j]["injection_nominal"]
        end
        for j in nw[:nondispatchable_deliveries_in_junction][i]
            var[:net_h2_nodal_injection][i] -= η[i] * nw[:delivery][j]["withdrawal_nominal"]
        end
    end

    for (i, junction) in nw[:junction]
        var[:net_h2_nodal_edge_out_flow][i] = 0
        for j in nw[:pipes_fr][i]
            var[:net_h2_nodal_edge_out_flow][i] += γ_pipe[j] * f_pipe[j]
        end
        for j in nw[:compressors_fr][i]
            var[:net_h2_nodal_edge_out_flow][i] += γ_comp[j] * f_comp[j]
        end
        for j in nw[:pipes_to][i]
            var[:net_h2_nodal_edge_out_flow][i] -= γ_pipe[j] * f_pipe[j]
        end
        for j in nw[:compressors_to][i]
            var[:net_h2_nodal_edge_out_flow][i] -= γ_comp[j] * f_comp[j]
        end
    end

    for (i, junction) in nw[:junction]
        net_h2_injection = var[:net_h2_nodal_injection][i]
        net_h2_nodal_edge_out_flow = var[:net_h2_nodal_edge_out_flow][i]
        con[:nodal_mass_flow_balance][i] =
            JuMP.@constraint(model, net_h2_injection == net_h2_nodal_edge_out_flow)
    end

    return
end

"Constraint:Slack Pressure"
function constraint_slack_pressure(model,nw,con,var)
    con[:slack_pressure] = Dict()
    Π = var[:Π]
    for (i, junction) in nw[:slack_junctions]
        con[:slack_pressure][i] = 
            JuMP.@constraint(model, Π[i] == junction["p_nominal"]^2)
    end

    return
end

"Constraint:Node and Edge concentration"

"Equation-based"
function constraint_node_edge_conc_equation(model,nw,con,var)
    con[:node_edge_conc_eq_pos] = Dict()
    con[:node_edge_conc_eq_neg] = Dict()
    
    f_pipe = var[:f_pipe]
    γ_pipe = var[:γ_pipe]
    η = var[:η]


    for (i, pipe) in nw[:pipe]
        f = f_pipe[i]
        γ = γ_pipe[i]
        η_fr = η[pipe["fr_junction"]]
        η_to = η[pipe["to_junction"]]
        
        con[:node_edge_conc_eq_pos][i] = 
            JuMP.@NLconstraint(model, (f^2 + f * abs(f)) * (γ - η_fr) == 0)

        con[:node_edge_conc_eq_neg][i] = 
            JuMP.@NLconstraint(model, (f^2 - f * abs(f)) * (γ - η_to) == 0)

    end

    return
end

"Complementarity-based"
function constraint_node_edge_conc_complementarity(model,nw,con,var)
    con[:node_edge_conc_flow] = Dict()
    con[:node_edge_conc_eq] = Dict()
    con[:node_edge_conc_complementarity_1] = Dict()
    con[:node_edge_conc_complementarity_2] = Dict()
    
    f_pipe = var[:f_pipe]
    γ_pipe = var[:γ_pipe]
    η = var[:η]

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
        η_fr = η[pipe["fr_junction"]]
        η_to = η[pipe["to_junction"]]
        
        s1 = aux_1[i]
        s2 = aux_2[i]
        ν = aux_3[i]

        con[:node_edge_conc_flow][i] = 
            JuMP.@constraint(model, f = s1 - s2)

        con[:node_edge_conc_eq][i] = 
            JuMP.@NLconstraint(model, γ = ν * η_fr + (1-ν) * η_to )

        con[:node_edge_conc_complementarity_1][i] = 
            JuMP.@constraint(model, s1 ⟂ 1-ν)

        con[:node_edge_conc_complementarity_2][i] = 
            JuMP.@constraint(model, s2 ⟂ ν)


    end

    return
end

"Integer variable based"
function constraint_node_edge_conc_integer(model,nw,con,var)
    con[:node_edge_conc_int_eq] = Dict()
    con[:node_edge_conc_int_ineq_1] = Dict()
    con[:node_edge_conc_int_ineq_2] = Dict()

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
        η_fr = η[pipe["fr_junction"]]
        η_to = η[pipe["to_junction"]]

        M = max(abs(pipe["flow_min"]),abs(pipe["flow_max"]))

        con[:node_edge_conc_int_eq][i] = 
            JuMP.@NLconstraint(model, γ = y[i] * η_fr + (1-y[i]) * η_to )

        con[:node_edge_conc_int_ineq_1][i] = 
            JuMP.@constraint(model, f >= - M * (1-y[i]))

        con[:node_edge_conc_int_ineq_2][i] = 
            JuMP.@constraint(model, f <= - M * y[i])
    end

    return
end