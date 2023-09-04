
function load_shed!(model,nw,var)
    
    load_shed_expressions = []

    qs = var[:qs]
    qw = var[:qw]
   
    for (i, receipt) in nw[:dispatchable_receipt]
        η_s = receipt["injection_conc"]
        push!(
            load_shed_expressions,
            JuMP.@expression(model, (η_s*receipt["h2_offer_price"] + (1-η_s)*receipt["ng_offer_price"]) * qs[i])
        )
    end
    for (i, delivery) in nw[:dispatchable_delivery]
        η = var[:η][delivery["node_id"]]
        push!(
            load_shed_expressions,
            JuMP.@expression(model, - (η*delivery["h2_bid_price"] + (1-η)*delivery["ng_bid_price"]) * qw[i])
        )
    end

    return load_shed_expressions
end

function compressor_cost!(model,nw,var)

    compressor_cost_expression= []
    
    λ = 0.13/3600
    #Π = var[:Π]
    P_w = var[:P_w]

    # for (i,compressor) in nw[:compressor]
    #     Π_to = Π[compressor["to_node"]]
    #     Π_fr = Π[compressor["fr_node"]]

    #     push!(
    #         compressor_cost_expression,
    #         JuMP.@expression(model, λ * (Π_to - Π_fr))
    #     )
    # end

    for (i,compressor) in nw[:compressor]
        
        push!(
            compressor_cost_expression,
            JuMP.@expression(model, λ*P_w[i])
        )

    end

    return compressor_cost_expression
end

function build_objective!(ss, model, var)
    
    nw = ss.ref;

    load_shed_expressions = load_shed!(model, nw, var)

    compressor_cost_expressions = compressor_cost!(model, nw, var)

    econ_weight = 0.95;

    JuMP.@objective(
            model,
            Min,
            econ_weight *
            sum(load_shed_expressions[i] for i = 1:length(load_shed_expressions)) +
            (1 - econ_weight) *
            sum(compressor_cost_expressions[i] for i = 1:length(compressor_cost_expressions))
        )


    return model

end