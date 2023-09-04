function _add_components_to_ref!(ref::Dict{Symbol,Any}, data::Dict{String,Any}, nominal_values)

    for (i, node) in get(data, "nodes", [])
        name = :node
        (!haskey(ref, name)) && (ref[name] = Dict())
        id = parse(Int64, i)
        ref[name][id] = Dict()
        @assert id == node["node_id"]
        ref[name][id]["node_id"] = id
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
        ref[name][id]["pipe_id"] = id
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
        ref[name][id]["comp_id"] = id
        ref[name][id]["to_node"] = compressor["to_node"]
        ref[name][id]["fr_node"] = compressor["from_node"]
        ref[name][id]["control_type"] = 0
        ref[name][id]["c_ratio"] = NaN
        ref[name][id]["c_ratio_min"] = compressor["c_min"]
        ref[name][id]["c_ratio_max"] = compressor["c_max"]
        ref[name][id]["discharge_pressure"] = NaN
        ref[name][id]["flow"] = NaN
        ref[name][id]["flow_min"] = compressor["min_flow"]
        ref[name][id]["flow_max"] = compressor["max_flow"]
        ref[name][id]["max_power"] = compressor["max_power"]
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
        ref[name][id]["h2_offer_price"] = receipt["h2_offer_price"]
        ref[name][id]["ng_offer_price"] = receipt["ng_offer_price"]
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
        ref[name][id]["min_heat_demand"] = delivery["min_heat_content"]/nominal_values[:mass_flow]
        ref[name][id]["max_heat_demand"] = delivery["max_heat_content"]/nominal_values[:mass_flow]
        ref[name][id]["h2_bid_price"] = delivery["h2_bid_price"]
        ref[name][id]["ng_bid_price"] = delivery["ng_bid_price"]
    end

    ref[:non_dispatchable_receipt] = Dict()
    ref[:non_dispatchable_delivery] = Dict()

    ref[:slack_nodes] = Dict()

    for (i, node) in get(data, "boundary_pslack", [])
        id = parse(Int64,i) 
        ref[:slack_nodes][id] = Dict()
        ref[:slack_nodes][id]["node_id"] = id
        ref[:slack_nodes][id]["nominal_pressure"] = node["pressure"]
        ref[:slack_nodes][id]["injection_conc"] = node["concentration"] 
    end

    return
end

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
    ref[:dispatchable_receipts_in_node] = Dict{Int64, Vector{Int64}}()
    ref[:dispatchable_deliveries_in_node] = Dict{Int64, Vector{Int64}}()

    for (i, _) in ref[:node]
        ref[:dispatchable_receipts_in_node][i] = []
        ref[:dispatchable_deliveries_in_node][i] = []
    end

    for (id, receipt) in ref[:dispatchable_receipt]
        push!(ref[:dispatchable_receipts_in_node][receipt["node_id"]], id)
    end

    for (id, delivery) in ref[:dispatchable_delivery]
        push!(ref[:dispatchable_deliveries_in_node][delivery["node_id"]], id)
    end

    ref[:nondispatchable_receipts_in_node] = Dict{Int64, Vector{Int64}}()
    ref[:nondispatchable_deliveries_in_node] = Dict{Int64, Vector{Int64}}()

    return
end

function _update_pipe_fields!(ref::Dict{Symbol,Any}, params, nominal_values, data::Dict{String,Any})
    for (_, pipe) in ref[:pipe]
        i = pipe["fr_node"]
        j = pipe["to_node"]
        
        pd_max = ref[:node][i]["p_max"]^2 - ref[:node][j]["p_min"]^2
        pd_min = ref[:node][i]["p_min"]^2 - ref[:node][j]["p_max"]^2
        
        lambda = pipe["friction_factor"]
        L = pipe["length"]
        D = pipe["diameter"]
        A = pipe["area"]
        pipe["resistance"] = lambda * L / (D * A^2)

        γ_min = pipe["concentration_min"]
        a2_min = γ_min * params[:speed_h2]^2 + (1-γ_min) * params[:speed_ng]^2
        a2_scale = a2_min/(nominal_values[:velocity]^2)

        "scaling factor"
        K = (nominal_values[:mass_flux] * nominal_values[:velocity] / nominal_values[:pressure])^2 

        w = 1 / (a2_scale * pipe["resistance"] * K)
        min_flux = pd_min < 0 ? -sqrt(w * abs(pd_min)) : sqrt(w * abs(pd_min))
        max_flux = pd_max < 0 ? -sqrt(w * abs(pd_max)) : sqrt(w * abs(pd_max))
        pipe["flow_min"] = min_flux * pipe["area"]
        pipe["flow_max"] = max_flux * pipe["area"]
    end

    return
end

function build_ref(data::Dict{String,Any},
    params,
    nominal_values;
    ref_extensions=[])::Dict{Symbol,Any}

    ref = Dict{Symbol,Any}()

    _add_components_to_ref!(ref, data, nominal_values)

    for extension in ref_extensions
        extension(ref, data)
    end

    _update_pipe_fields!(ref, params, nominal_values, data)

    ref[:multiplier] = ((nominal_values[:density] * nominal_values[:velocity]^2) / (nominal_values[:pressure] * params[:mach_number]))^2

    return ref
end