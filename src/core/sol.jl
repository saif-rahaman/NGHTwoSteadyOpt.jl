
function _initialize_solution()::Dict{String,Any}
    sol = Dict{String,Any}()
    sol["nodal_pressure"] = Dict{Int64,Float64}()
    sol["nodal_density"] = Dict{Int64,Float64}()
    sol["nodal_concentration"] = Dict{Int64,Float64}()
    sol["slack_injection"] = Dict{Int64,Float64}()
    sol["pipe_flow"] = Dict{Int64,Float64}()
    sol["pipe_concentration"] = Dict{Int64,Float64}()
    sol["compressor_flow"] = Dict{Int64,Float64}()
    sol["compressor_concentration"] = Dict{Int64,Float64}()
    sol["withdrawal_heat_content"] = Dict{Int64,Float64}()
    return sol
end