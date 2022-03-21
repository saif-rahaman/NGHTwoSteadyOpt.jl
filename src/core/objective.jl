
function load_shed(model,nw,var)
    
    load_shed_expressions = []

    qs = var[:qs]
    qw = var[:qw]

    for (i, receipt) in nw[:dispatchable_receipt]
        push!(
            load_shed_expressions,
            JuMP.@NLexpression(model, receipt["offer_price"] * qs[i])
        )
    end
    for (i, delivery) in nw[:dispatchable_delivery]
        push!(
            load_shed_expressions,
            JuMP.@NLexpression(model, -delivery["bid_price"] * qw[i])
        )
    end

    return load_shed_expressions
end

function compressor_cost(model,nw,var)

    compressor_cost_expression= []
    
    λ = 1e+04
    Π = var[:Π]

    for (i,compressor) in nw[:compressor]
        Π_to = Π[pipe["to_junction"]]
        Π_fr = Π[pipe["fr_junction"]]

        push!(
            compressor_cost_expression,
            JuMP.@NLexpression(model, λ * (Π_to - Π_fr))
        )
    end

    return compressor_cost_expression
end
