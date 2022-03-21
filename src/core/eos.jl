function _get_eos(eos::Symbol)
    (eos == :ideal) &&
        (return _ideal_coeffs, _pressure_to_density_ideal, _density_to_pressure_ideal)
    @error "Unrecognized EOS. Supported EOS is [:ideal]."
end

function _ideal_coeffs(nominal_values::Dict{Symbol,Any}, params::Dict{Symbol,Any})
    return 1.0
end


function _pressure_to_density_ideal(p, gamma, nominal_values::Dict{Symbol,Any}, params::Dict{Symbol,Any})
    a_sqr = params[:speed_h2]^2 * gamma + params[:speed_ng]^2 * (1 - gamma)
    euler_num = nominal_values[:pressure] / (nominal_values[:density] * a_sqr)
    return p * euler_num
end

function _density_to_pressure_ideal(rho, gamma, nominal_values::Dict{Symbol,Any}, params::Dict{Symbol,Any}) 
    a_sqr = params[:speed_h2]^2 * gamma + params[:speed_ng]^2 * (1 - gamma)
    euler_num = nominal_values[:pressure] / (nominal_values[:density] * a_sqr)
    return rho / euler_num
end