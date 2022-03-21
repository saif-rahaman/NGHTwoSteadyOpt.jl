function _add_components_to_ref!(ref::Dict{Symbol,Any}, data::Dict{String,Any})

    for (i, node) in get(data, "nodes", [])
        name = :node
        (!haskey(ref, name)) && (ref[name] = Dict())
        id = parse(Int64, i)
        ref[name][id] = Dict()
        @assert id == node["node_id"]
        ref[name][id]["id"] = id
        ref[name][id]["is_slack"] = node["slack_bool"]
        ref[name][id]["p_min"] = node["min_pressure"]
        ref[name][id]["p_max"] = node["max_pressure"]
        ref[name][id]["density"] = NaN 
        ref[name][id]["withdrawal"] = NaN
        ref[name][id]["injection"] = NaN
        ref[name][id]["concentration_min"] = node["min_concentration"]
        ref[name][id]["concentration_max"] = node["max_concentration"]
        ref[name][id]["potential"] = NaN
    end

    for (i, pipe) in get(data, "pipes", [])
        name = :pipe
        (!haskey(ref, name)) && (ref[name] = Dict())
        id = parse(Int64, i)
        ref[name][id] = Dict()
        @assert id == pipe["pipe_id"]
        ref[name][id]["id"] = id
        ref[name][id]["fr_node"] = pipe["from_node"]
        ref[name][id]["to_node"] = pipe["to_node"]
        ref[name][id]["diameter"] = pipe["diameter"]
        ref[name][id]["area"] = pipe["area"]
        ref[name][id]["length"] = pipe["length"]
        ref[name][id]["friction_factor"] = pipe["friction_factor"]
        ref[name][id]["flow"] = NaN
        ref[name][id]["flow_min"] = NaN
        ref[name][id]["flow_max"] = NaN
        ref[name][id]["p_min"] = pipe["min_pressure"]
        ref[name][id]["p_max"] = pipe["max_pressure"]
        ref[name][id]["concentration_min"] = pipe["min_concentration"]
        ref[name][id]["concentration_max"] = pipe["max_concentration"]
    end

    for (i, compressor) in get(data, "compressors", [])
        name = :compressor
        (!haskey(ref, name)) && (ref[name] = Dict())
        id = parse(Int64, i)
        ref[name][id] = Dict()
        @assert id == compressor["comp_id"]
        ref[name][id]["id"] = id
        ref[name][id]["to_node"] = compressor["to_node"]
        ref[name][id]["fr_node"] = compressor["from_node"]
        ref[name][id]["control_type"] = unknown_control
        ref[name][id]["c_ratio"] = NaN
        ref[name][id]["discharge_pressure"] = NaN
        ref[name][id]["flow"] = NaN
        ref[name][id]["flow_min"] = compressor["min_flow"]
        ref[name][id]["flow_max"] = compressor["max_flow"]
        ref[name][id]["concentration_min"] = compressor["min_concentration"]
        ref[name][id]["concentration_max"] = compressor["max_concentration"]
    end

    for (i, receipt) in get(data, "receipt", [])
        name = :dispatchable_receipt
        (!haskey(ref, name)) && (ref[name] = Dict())
        id = parse(Int64, i)
        ref[name][id] = Dict()
        #@assert id == receipt["node_id"]
        ref[name][id]["node_id"] = receipt["node_id"]
        ref[name][id]["injection_min"] = receipt["min_injection"]
        ref[name][id]["injection_max"] = receipt["max_injection"]
        ref[name][id]["injection_conc"] = receipt["concentration"]
        ref[name][id]["offer_price"] = receipt["offer_price"]
    end

    for (i, delivery) in get(data, "delivery", [])
        name = :dispatchable_delivery
        (!haskey(ref, name)) && (ref[name] = Dict())
        id = parse(Int64, i)
        ref[name][id] = Dict()
        #@assert id == delivery["node_id"]
        ref[name][id]["node_id"] = delivery["node_id"]
        ref[name][id]["withdrawal_min"] = delivery["min_withdrawal"]
        ref[name][id]["withdrawal_max"] = delivery["max_withdrawal"]
        ref[name][id]["bid_price"] = delivery["bid_price"]
    end

    ref[:non_dispatchable_receipt] = Dict()
    ref[:non_dispatchable_delivery] = Dict()

    return
end

"""
    Adding and Preprocessing Info
"""
# function _add_index_info!(ref::Dict{Symbol, Any}, data::Dict{String, Any})
#     dofid = 1
#     ref[:dof] = Dict{Int64, Any}()
    
#     for (i, node) in ref[:node]
#         node["dof_pressure"] = dofid
#         ref[:dof][dofid] = (:node_pressure, i)
#         dofid += 1
#     end

#     for (i, node) in ref[:node]
#         node["dof_concentration"] = dofid
#         ref[:dof][dofid] = (:node_concentration, i)
#         dofid += 1
#     end

#     for (i, node) in ref[:node]
#         if (node["is_slack"] == 1)
#             node["dof_slack_injection"] = dofid 
#             ref[:dof][dofid] = (:node_slack_injection, i)
#             dofid += 1
#         end
#     end 

#     for (i, pipe) in ref[:pipe]
#         pipe["dof_flow"] = dofid
#         ref[:dof][dofid] = (:pipe_flow, i)
#         dofid += 1
#     end

#     for (i, pipe) in ref[:pipe]
#         pipe["dof_concentration"] = dofid
#         ref[:dof][dofid] = (:pipe_concentration, i)
#         dofid += 1
#     end

#     for (i, compressor) in get(ref, :compressor, [])
#         compressor["dof_flow"] = dofid
#         ref[:dof][dofid] = (:compressor_flow, i)
#         dofid += 1
#     end

#     for (i, compressor) in get(ref, :compressor, [])
#         compressor["dof_concentration"] = dofid
#         ref[:dof][dofid] = (:compressor_concentration, i)
#         dofid += 1
#     end
# end

# function _add_incident_dofs_info_at_nodes!(ref::Dict{Symbol,Any}, data::Dict{String,Any})
#     ref[:incoming_dofs] = Dict{Int64, Vector{Tuple{Int64,Int64}}}()
#     ref[:outgoing_dofs] = Dict{Int64, Vector{Tuple{Int64,Int64}}}()

#     for (i, _) in ref[:node]
#         ref[:incoming_dofs][i] = []
#         ref[:outgoing_dofs][i] = []
#     end

#     for (_, pipe) in ref[:pipe]
#         push!(ref[:incoming_dofs][pipe["to_node"]], (pipe["dof_flow"], pipe["dof_concentration"]))
#         push!(ref[:outgoing_dofs][pipe["fr_node"]], (pipe["dof_flow"], pipe["dof_concentration"]))
#     end

#     for (_, compressor) in get(ref, :compressor, [])
#         push!(ref[:incoming_dofs][compressor["to_node"]], (compressor["dof_flow"], compressor["dof_concentration"]))
#         push!(ref[:outgoing_dofs][compressor["fr_node"]], (compressor["dof_flow"], compressor["dof_concentration"]))
#     end

#     return
# end

function _add_pipe_info_at_nodes!(ref::Dict{Symbol,Any}, data::Dict{String,Any})
    ref[:incoming_pipes] = Dict{Int64, Vector{Int64}}()
    ref[:outgoing_pipes] = Dict{Int64, Vector{Int64}}()

    for (i, _) in ref[:node]
        ref[:incoming_pipes][i] = []
        ref[:outgoing_pipes][i] = []
    end

    for (id, pipe) in ref[:pipe]
        push!(ref[:incoming_pipes][pipe["to_node"]], id)
        push!(ref[:outgoing_pipes][pipe["fr_node"]], id)
    end

    return
end

function _add_compressor_info_at_nodes!(ref::Dict{Symbol,Any}, data::Dict{String,Any})
    ref[:incoming_compressors] = Dict{Int64, Vector{Int64}}()
    ref[:outgoing_compressors] = Dict{Int64, Vector{Int64}}()
    
    for (i, _) in ref[:node]
        ref[:incoming_compressors][i] = []
        ref[:outgoing_compressors][i] = []
    end

    for (id, compressor) in get(ref, :compressor, [])
        push!(ref[:incoming_compressors][compressor["to_node"]], id)
        push!(ref[:outgoing_compressors][compressor["fr_node"]], id)
    end

    return
end

function _add_dispatchable_info_at_nodes!(ref::Dict{Symbol,Any}, data::Dict{String,Any})
    ref[:dispatchable_receipts_in_junction] = Dict{Int64, Vector{Int64}}()
    ref[:dispatchable_deliveries_in_junction] = Dict{Int64, Vector{Int64}}()

    for (i, _) in ref[:node]
        ref[:dispatchable_receipts_in_junction][i] = []
        ref[:dispatchable_deliveries_in_junction][i] = []
    end

    for (id, receipt) in ref[:dispatchable_receipt]
        push!(ref[:dispatchable_receipts_in_junction][receipt["node_id"]], id)
    end

    for (id, delivery) in ref[:dispatchable_delivery]
        push!(ref[:dispatchable_deliveries_in_junction][delivery["node_id"]], id)
    end

    ref[:nondispatchable_receipts_in_junction] = Dict{Int64, Vector{Int64}}()
    ref[:nondispatchable_deliveries_in_junction] = Dict{Int64, Vector{Int64}}()

    return
end

function _update_pipe_fields!(ref::Dict{Symbol,Any}, data::Dict{String,Any})
    for (_, pipe) in ref[:pipe]
        i = pipe["fr_node"]
        j = pipe["to_node"]
        pd_max = max(ref[:node][i]["p_max"],ref[:node][j]["p_max"]) - min(ref[:node][i]["p_min"],ref[:node][j]["p_min"])
        pd_min = min(ref[:node][i]["p_max"],ref[:node][j]["p_max"]) - max(ref[:node][i]["p_min"],ref[:node][j]["p_min"])
        lambda = pipe["friction_factor"]
        L = pipe["length"] * ref[:base_length]
        D = pipe["diameter"]
        pipe["resistance"] = lambda * L / D
        w = 1 / pipe["resistance"]
        min_flux = pd_min < 0 ? -sqrt(w * abs(pd_min)) : sqrt(w * abs(pd_min))
        max_flux = pd_max < 0 ? -sqrt(w * abs(pd_max)) : sqrt(w * abs(pd_max))
        pipe["flow_min"] = min_flux * pipe["area"]
        pipe["flow_max"] = max_flux * pipe["area"]
    end

    return
end

function build_ref(data::Dict{String,Any};
    ref_extensions=[])::Dict{Symbol,Any}

    ref = Dict{Symbol,Any}()

    _add_components_to_ref!(ref, data)

    for extension in ref_extensions
        extension(ref, data)
    end

    return ref
end