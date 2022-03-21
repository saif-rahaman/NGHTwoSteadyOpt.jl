"Builds the JuMP model"

function build_gas_model(ss::SteadyOptimizer)

    gas_model = JuMP.Model(Ipopt.Optimizer)
    JuMP.set_optimizer_attribute(gas_model, "max_cpu_time", 60.0)
    JuMP.set_optimizer_attribute(gas_model, "print_level", 5)
    JuMP.set_optimizer_attribute(gas_model, "linear_solver", "ma27")

    ref = ref(ss)

    params = ref(ss)

    gas_model, gas_variables = build_variables!(ref, gas_model)

    gas_model, gas_variables, gas_constraints = build_constraints!(ref, gas_model, gas_variables, params)

    JuMP.optimize!(gas_model)

    status = termination_status(gas_model)

    return gas_model, status
end


    

    
