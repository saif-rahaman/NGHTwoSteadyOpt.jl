
function _build_ig(data::Dict{String,Any})::Dict{Symbol,Any}
    ig = Dict{Symbol,Any}()

    ig[:node_pressure] = Dict()
    ig[:node_concentration] = Dict() 
    ig[:node_slack_injection] = Dict() 
    ig[:pipe_flow] = Dict()
    ig[:pipe_concentration] = Dict()
    ig[:compressor_flow] = Dict()
    ig[:compressor_concentration] = Dict()

    for (i, value) in get(data, "node_pressure", [])
        id = parse(Int64, i)
        ig[:node_pressure][id] = value
    end 

    if isempty(get(data, "node_pressure", []))
        for (i, _) in get(data, "nodes", [])
            id = parse(Int64, i)
            ig[:node_pressure][id] = 1.0
        end 
    end 

    for (i, value) in get(data, "node_concentration", [])
        id = parse(Int64, i)
        ig[:node_concentration][id] = value
    end 

    if isempty(get(data, "node_concentration", []))
        for (i, _) in get(data, "nodes", [])
            id = parse(Int64, i)
            ig[:node_concentration][id] = 0.1
        end 
    end 

    for (i, value) in get(data, "node_slack_injection", [])
        id = parse(Int64, i)
        ig[:node_slack_injection][id] = value
    end 

    if isempty(get(data, "node_slack_injection", []))
        for (i, node) in get(data, "nodes", [])
            if node["slack_bool"] == 1
                id = parse(Int64, i)
                ig[:node_slack_injection][id] = 1.0
            end 
        end 
    end 

    for (i, value) in get(data, "pipe_flow", [])
        id = parse(Int64, i) 
        ig[:pipe_flow][id] = value 
    end 

    if isempty(get(data, "pipe_flow", []))
        for (i, _) in get(data, "pipes", [])
            id = parse(Int64, i)
            ig[:pipe_flow][id] = 0.5
        end 
    end 

    for (i, value) in get(data, "pipe_concentration", [])
        id = parse(Int64, i) 
        ig[:pipe_concentration][id] = value 
    end 

    if isempty(get(data, "pipe_concentration", []))
        for (i, _) in get(data, "pipes", [])
            id = parse(Int64, i)
            ig[:pipe_concentration][id] = 0.1
        end 
    end

    for (i, value) in get(data, "compressor_flow", [])
        id = parse(Int64, i)
        ig[:compressor_flow][id] = value
    end 

    if isempty(get(data, "compressor_flow", []))
        for (i, _) in get(data, "compressors", [])
            id = parse(Int64, i)
            ig[:compressor_flow][id] = 0.5
        end 
    end 

    for (i, value) in get(data, "compressor_concentration", [])
        id = parse(Int64, i)
        ig[:compressor_concentration][id] = value
    end 

    if isempty(get(data, "compressor_concentration", []))
        for (i, _) in get(data, "compressors", [])
            id = parse(Int64, i)
            ig[:compressor_concentration][id] = 0.1
        end 
    end

    return ig
end 