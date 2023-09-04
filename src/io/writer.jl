function write_bc_output(ss::SteadyOptimizer,report::SSReport, 
    bc_file::AbstractString)

    nw = ss.ref
    sol = report.sol 

    global BC = Dict()

    open(bc_file, "r") do f 
        BC_String = read(f, String)
        BC = JSON.parse(BC_String)
    end 

    for (i,slack) in nw[:slack_nodes]
            id = slack["node_id"]
            BC["boundary_pslack"][string(id)]["pressure"] = sol[:pressure][i]
            BC["boundary_pslack"][string(id)]["concentration"] = sol[:node_concentration][i]
    end

    for (i,receipt) in nw[:dispatchable_receipt]
        id = receipt["node_id"]
        if nw[:node][id]["is_slack"] == 1
            continue
        else
            BC["boundary_nonslack_flow"][string(id)]["injection"] = sol[:injection_flows][i]
            BC["boundary_nonslack_flow"][string(id)]["withdrawal"] = nothing
            BC["boundary_nonslack_flow"][string(id)]["concentration"] = receipt["injection_conc"]
        end
    end

    for (i,delivery) in nw[:dispatchable_delivery]
        id = delivery["node_id"]
        BC["boundary_nonslack_flow"][string(id)]["injection"] = nothing
        BC["boundary_nonslack_flow"][string(id)]["withdrawal"] = sol[:withdrawal_flows][i]
        BC["boundary_nonslack_flow"][string(id)]["concentration"] = nothing
    end

    for (i,compressor) in nw[:compressor]
        BC["boundary_compressor"][string(i)]["value"] = sol[:compressor_ratio][i]
    end

    open(bc_file, "w") do f 
        JSON.print(f, BC, 2)
    end

    return 

end

function write_ig_output(ss::SteadyOptimizer,report::SSReport, 
    ig_file::AbstractString)

    nw = ss.ref
    sol = report.sol 

    global IG = Dict()

    open(ig_file, "r") do f 
        IG_String = read(f, String)
        IG = JSON.parse(IG_String)
    end 

    for (i,node) in nw[:node]
        id = node["node_id"]
        IG["node_pressure"][string(id)] = sol[:pressure][i]
        IG["node_concentration"][string(id)] = sol[:node_concentration][i]
        if node["is_slack"] == 1
            injection_id = nw[:dispatchable_receipts_in_node][id][1]
            IG["node_slack_injection"][string(i)] = sol[:injection_flows][injection_id]
        else 
            IG["node_slack_injection"][string(i)] = 0
        end
    end

    # for (i,slack) in nw[:slack_nodes]
    #     node_id = slack["node_id"]
    #     injection_id = nw[:dispatchable_receipts_in_node][node_id]
    #     IG["node_slack_injection"][string(i)] = sol[:injection_flows][injection_id]
    # end

    for (i,pipe) in nw[:pipe]
        id = pipe["pipe_id"]
        IG["pipe_flow"][string(id)] = sol[:pipe_flows][i]
        IG["pipe_concentration"][string(id)] = sol[:pipe_concentration][i]
    end

    for (i,compressor) in nw[:compressor]
        id = compressor["comp_id"]
        IG["compressor_flow"][string(id)] = sol[:compressor_flows][i]
        IG["compressor_concentration"][string(id)] = sol[:compressor_concentration][i]
    end     

    open(ig_file, "w") do f 
        JSON.print(f, IG, 2)
    end

    return 

end