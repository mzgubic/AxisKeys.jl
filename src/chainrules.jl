using ChainRulesCore

function ChainRulesCore.ProjectTo(x::KaNda)
    return ProjectTo{KeyedArray}(;data=ProjectTo(parent(x)), keys=named_axiskeys(x))
end

function ChainRulesCore.ProjectTo(x::KeyedArray) # TODO: determine whether this is needed
    return ProjectTo{KeyedArray}(;data=ProjectTo(keyless(x)), keys=axiskeys(x))
end

(project::ProjectTo{KeyedArray})(dx::AbstractZero) = dx
function (project::ProjectTo{KeyedArray})(dx)
    @show project.data(dx)
    @show project.keys
    new_data = project.data(dx)
    new_keys = NamedTuple{dimnames(new_data)}(project.keys)
    @show new_keys
    return KeyedArray(new_data; new_keys...)
end

_KeyedArray_pullback(ȳ, project) = (NoTangent(), project(ȳ))
_KeyedArray_pullback(ȳ::Tangent, project) = _KeyedArray_pullback(ȳ.data, project)
_KeyedArray_pullback(ȳ::AbstractThunk, project) = _KeyedArray_pullback(unthunk(ȳ), project)

function ChainRulesCore.rrule(::typeof(keyless_unname), x)
    pb(y) = _KeyedArray_pullback(y, ProjectTo(x))
    return keyless_unname(x), pb
end
