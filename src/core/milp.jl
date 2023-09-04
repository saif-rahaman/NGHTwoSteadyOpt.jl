#MILP Formulation for the Mixed H2-NG Steady State Gas Model"
function build_milp_formulation_mixed_gas!(ss::SteadyOptimizer, model, var)

    nw = ss.ref;
    params = ss.params;

    f_pipe = var[:f_pipe]
    γ_pipe = var[:γ_pipe]
    ζ_pipe = var[:ζ_pipe]

    f_comp = var[:f_comp]
    γ_comp = var[:γ_comp]

    Π = var[:Π]
    η = var[:η]

    qs = var[:qs]
    qw = var[:qw]

    a_h2 = params[:speed_h2]
    a_ng = params[:speed_ng]

    #####################Auxiliary variables##########################
    aux_var = Dict()

    "Univariate polyhedral term for pressure drop (z1 = f|f|)"
    z1 = 
        aux_var[:z1] = JuMP.@variable(
        model,
        [i in keys(nw[:pipe])]
        )

    
    "Biilinear term for pressure drop (z2 = V(γ).z1)"
    z2  =  
        aux_var[:z2] = JuMP.@variable(
        model,
        [i in keys(nw[:pipe])] 
        )

    "Bilinear term for h2-balance (pipe) (z3 = γ.f)"
    z3 = 
        aux_var[:z3] = JuMP.@variable(
        model,
        [i in keys(nw[:pipe])]
        )

    "Bilinear term for h2-balance (comp) (z4 = γ.f)"
    z4 = 
        aux_var[:z4] = JuMP.@variable(
        model,
        [i in keys(nw[:compressor])]
        )

    "Bilinear term for h2-balance (delivery) (z5 = η.qw)"
    z5 = 
        aux_var[:z5] = JuMP.@variable(
        model,
        [i in keys(nw[:dispatchable_delivery])]
        )

    #####################Polyhedral Relaxations##########################
    aux_con = Dict()
    #aux_milp_var = Dict()
    aux_con[:flow] = Dict()
    aux_con[:pressure_drop] = Dict()
    aux_con[:pipe_h2_balance] = Dict()
    aux_con[:comp_h2_balance] = Dict()
    aux_con[:delivery_h2_balance] = Dict()
    
    "Number of partitions(preferrably odd (atleast 3))"
    n = 5

    for (i,_) in nw[:pipe]
        f = f_pipe[i]
        fmin = nw[:pipe][i]["flow_min"]
        fmax = nw[:pipe][i]["flow_max"]

        if fmin < 0
            pf1 = Array(LinRange(fmin, 0.0, Int(ceil(n/2))))
            pf2 = Array(LinRange(0.0, fmax, Int(ceil(n/2))))
            pf = vcat(pf1,pf2);
            deleteat!(pf,Int(ceil(n/2)));
        else
            pf = Array(LinRange(fmin, fmax, n))
        end

        form1 = construct_univariate_relaxation!(
            model, 
            a -> a*abs(a), f , z1[i], pf, 
            f_dash = a -> 2*abs(a),
            true)

        aux_con[:flow][i] = form1.constraints

        ζ = ζ_pipe[i]

        if fmin < 0
            pg = Array(LinRange(- fmin^2, fmax^2, 2))
        else
            pg = Array(LinRange(fmin^2, fmax^2, 2)) 
        end

        γ = γ_pipe[i]
        γ_min = nw[:pipe][i]["concentration_min"]
        γ_max = nw[:pipe][i]["concentration_max"]

        a2_min = a_h2^2 * γ_min + (1-γ_min)*a_ng^2
        a2_max = a_h2^2 * γ_max + (1-γ_max)*a_ng^2
        L = Array(LinRange(a2_min,a2_max,n))

        form2 = construct_bilinear_relaxation!(
            model,
            ζ, z1[i], z2[i], L, pg)

        aux_con[:pressure_drop][i] = form2.constraints

        form3 = construct_bilinear_relaxation!(
            model,
            γ, f, z3[i], [γ_min, γ_max], pf)

        aux_con[:pipe_h2_balance][i] = form3.constraints
    end
        
    for (i,_) in nw[:compressor]
        f = f_comp[i]
        fmin = nw[:compressor][i]["flow_min"]
        fmax = nw[:compressor][i]["flow_max"]

        γ = γ_comp[i]
        γ_min = nw[:compressor][i]["concentration_min"]
        γ_max = nw[:compressor][i]["concentration_max"]

        ph = Array(LinRange(fmin,fmax,n))
        
        form4 = construct_bilinear_relaxation!(
            model,
            γ, f, z4[i], [γ_min, γ_max], ph)

        aux_con[:comp_h2_balance][i] = form4.constraints

    end

    for (i,_) in nw[:node]
        η_w = η[i]
        η_min = nw[:node][i]["concentration_min"]
        η_max = nw[:node][i]["concentration_max"]
        for j in nw[:dispatchable_deliveries_in_node][i]
            q = qw[j]
            q_min = nw[:dispatchable_delivery][j]["withdrawal_min"]
            q_max = nw[:dispatchable_delivery][j]["withdrawal_max"]

            form5 = construct_bilinear_relaxation!(
                model,
                η_w, q, z5[j], [η_min, η_max], [q_min, q_max])

            aux_con[:delivery_h2_balance][j] = form5.constraints
        end
    end

    

    #####################Linear Constraints##########################
    con = Dict()
    con[:pipe_physics] = Dict()
    con[:compressor_boost_le] = Dict()
    con[:compressor_boost_ge] = Dict()

    "Constraint:Pipe Pressure Drop"
    for (i, pipe) in nw[:pipe]
        Π_fr = Π[pipe["fr_node"]]
        Π_to = Π[pipe["to_node"]]

        resistance = pipe["resistance"]
        multiplier = nw[:multiplier]

        con[:pipe_physics][i] =
            JuMP.@constraint(model, Π_fr^2 - Π_to^2 - resistance * multiplier * z2[i] == 0)
    end

    "Constraint:Compressor Pressure"
    for (i, compressor) in nw[:compressor]
        Π_fr = Π[compressor["fr_node"]]
        Π_to = Π[compressor["to_node"]]

        ω_max = nw[:compressor][i]["c_ratio_max"]^2 

        con[:compressor_boost_le][i] = 
            JuMP.@constraint(model, Π_to - ω_max * Π_fr <= 0)
        con[:compressor_boost_ge][i] = 
            JuMP.@constraint(model, Π_to - Π_fr >= 0)
    end

    "Constraint:Node mass flow balance"
    con[:nodal_mass_flow_balance] = Dict()
    var[:net_nodal_injection] = Dict()
    var[:net_nodal_edge_out_flow] = Dict()

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

    "Constraint:Node H2 mass flow balance"
    con[:nodal_h2_mass_flow_balance] = Dict()
    var[:net_h2_nodal_injection] = Dict()
    var[:net_h2_nodal_edge_out_flow] = Dict()

    for (i,node) in nw[:node]
        var[:net_h2_nodal_injection][i] = 0
        for j in nw[:dispatchable_receipts_in_node][i]
            η_s = nw[:dispatchable_receipt][j]["injection_conc"]
            var[:net_h2_nodal_injection][i] += η_s * qs[j]
        end
        for j in nw[:dispatchable_deliveries_in_node][i]
            var[:net_h2_nodal_injection][i] -= z5[j]
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
            var[:net_h2_nodal_edge_out_flow][i] += z3[j]
        end
        for j in nw[:outgoing_compressors][i]
            var[:net_h2_nodal_edge_out_flow][i] += z4[j]
        end
        for j in nw[:incoming_pipes][i]
            var[:net_h2_nodal_edge_out_flow][i] -= z3[j]
        end
        for j in nw[:incoming_compressors][i]
            var[:net_h2_nodal_edge_out_flow][i] -= z4[j]
        end
    end

    for (i, node) in nw[:node]
        net_h2_injection = var[:net_h2_nodal_injection][i]
        net_h2_nodal_edge_out_flow = var[:net_h2_nodal_edge_out_flow][i]
        con[:nodal_h2_mass_flow_balance][i] =
            JuMP.@constraint(model, net_h2_injection == net_h2_nodal_edge_out_flow)
    end

    "Constraint:Slack Pressure"
    con[:slack_pressure] = Dict()
    for (i, node) in nw[:slack_nodes]
        con[:slack_pressure][i] = 
            JuMP.@constraint(model, Π[i] == node["nominal_pressure"]^2)
    end

    "Constraint:Node and Compressor concentration"
    con[:node_compressor_conc] = Dict()
    for (i, compressor) in nw[:compressor]
        γ = γ_comp[i]
        η_fr = η[compressor["fr_node"]]
        con[:node_compressor_conc][i] = 
            JuMP.@constraint(model, γ - η_fr == 0)
    end

    "Constraint:Node and Edge concentration"
    con[:node_pipe_conc_int_eq] = Dict()
    con[:node_pipe_conc_int_ineq_1] = Dict()
    con[:node_pipe_conc_int_ineq_2] = Dict()

    "Binary variable for directional flow"
    y = 
        var[:y] = JuMP.@variable(
        model,
        [i in keys(nw[:pipe])],
        binary = true,
        base_name = "pipe_node_conc_binary_variable"
        )

    "Bilinear term for Big M-integer formulation ()"
    z6 = 
        aux_var[:z6] = JuMP.@variable(
        model,
        [i in keys(nw[:pipe])] 
        )

    z7 = 
        aux_var[:z7] = JuMP.@variable(
        model,
        [i in keys(nw[:pipe])] 
        )

    aux_con[:big_M_1] = Dict()
    aux_con[:big_M_2] = Dict()

    for (i, pipe) in nw[:pipe]

        η_fr = η[pipe["fr_node"]]
        η_to = η[pipe["to_node"]]

        ηf_min = nw[:node][pipe["fr_node"]]["concentration_min"] #0
        ηf_max = nw[:node][pipe["fr_node"]]["concentration_max"] #max(pipe["fr_node"]["concentration_max"],pipe["to_node"]["concentration_max"])

        ηt_min = nw[:node][pipe["to_node"]]["concentration_min"] #0
        ηt_max = nw[:node][pipe["to_node"]]["concentration_max"] #max(pipe["fr_node"]["concentration_max"],pipe["to_node"]["concentration_max"])

        "MILP relaxation for the bilinear terms in big-M formulation"
        form6 = construct_bilinear_relaxation!(
                model,
                η_fr, y[i], z6[i], [ηf_min, ηf_max], [0.0, 1.0])

        aux_con[:big_M_1][i] = form6.constraints        

        form7 = construct_bilinear_relaxation!(
                model,
                η_to, y[i], z7[i], [ηt_min, ηt_max], [0.0, 1.0])
        
        aux_con[:big_M_2][i] = form7.constraints

        M = max(abs(pipe["flow_min"]),abs(pipe["flow_max"]))

        con[:node_pipe_conc_int_eq][i] = 
            JuMP.@constraint(model, γ_pipe[i] == z6[i] + η_to - z7[i])

        con[:node_pipe_conc_int_ineq_1][i] = 
            JuMP.@constraint(model, f_pipe[i] >= - M * (1-y[i]))

        con[:node_pipe_conc_int_ineq_2][i] = 
            JuMP.@constraint(model, f_pipe[i] <= M * y[i])

    end

    return model, var, con, aux_var, aux_con

end 




 




