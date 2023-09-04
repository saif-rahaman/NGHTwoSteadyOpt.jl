function initialize_optimizer(data_folder::AbstractString;
    case_name::AbstractString="", 
    case_types::Vector{Symbol}=Symbol[],
    initial_guess_filename::AbstractString="",
    kwargs...)::SteadyOptimizer
    data = _parse_data(data_folder; 
        case_name=case_name, 
        case_types=case_types, 
        initial_guess_filename=initial_guess_filename
    )
    return initialize_optimizer(data; kwargs...)
end

function initialize_optimizer(data::Dict{String,Any}; eos::Symbol=:ideal)::SteadyOptimizer
    params, nominal_values = process_data!(data)
    make_per_unit!(data, params, nominal_values)
    ref = build_ref(data,
                    params,
                    nominal_values, 
                    ref_extensions= 
                    [_add_pipe_info_at_nodes!,
                    _add_compressor_info_at_nodes!,
                    _add_dispatchable_info_at_nodes!] 
                    #_update_pipe_fields!]
                    )   

    ss = SteadyOptimizer(data,
        ref,
        _initialize_solution(),
        nominal_values,
        params,
        _build_ig(data),
        _build_bc(data), 
        _get_eos(eos)...
    )

    return ss
end
