"""
example: x::Int = 23
"""
struct ArgumentAssigment{T}
    arg::Symbol
	type::Symbol
	value::T
end

function capture(::Type{ArgumentAssigment{T}}, e::Any) where T
    @capture(e, arg_::type_ = value_) && return ArgumentAssigment(arg, type, value)
    @capture(e, arg_ = value_) && return ArgumentAssigment(arg, :Any, value)
    @capture(e, arg_::type_) && return ArgumentAssigment(arg, type, nothing)
    return nothing
end

argument(x::ArgumentAssigment) = :($(x.arg)::$(x.type))
kwargument(x::ArgumentAssigment) = Expr(:kw, argument(x), x.value)
pair(x::ArgumentAssigment) = :($(x.arg)=>$(x.value))
assignment(x::ArgumentAssigment) = :($(x.arg)=$(x.value))
value(x::ArgumentAssigment) = :($(x.value))

"""
example: 2 * x
"""
struct BinaryFunction{T,U}
    func::Symbol
    argtypes::Tuple{DataType, DataType}
    BinaryFunction{T,U}(f::Symbol) where {T, U} = new(f, (T, U))
end


function capture(::Type{BinaryFunction{T,U}}, e::Expr) where {T,U}
    if e.head == :call && length(e.args) == 3
        return BinaryFunction{T,U}(e.args[1])
    end
    return nothing
end

"""
example:  :println
"""
struct SymbolExpr{T}
    symbol::Symbol
    type::DataType
    SymbolExpr{T}(s::Symbol) where T = new(s, T) 
end

function capture(::Type{SymbolExpr{Function}}, e::Symbol)
    if isdefined(Main, e) && isa(getfield(Main, e), Function)
        return SymbolExpr{Function}(e)
    end
    return nothing
end

function capture(::Type{Pair}, e::Any)
    @capture(e, x_ => y_) && return Pair(x, y)
    return nothing
end

function capture(::Type{SymbolExpr{DataType}}, e::Any)
    typeof(eval(e)) == DataType && return SymbolExpr{DataType}(e, eval(e))
    return nothing
end

capture(::Type{SymbolExpr{Function}}, e::Any) = nothing

"""
example:   "abc"
"""
struct LiteralExpr{T}
    value::T
    type::DataType
    LiteralExpr{T}(x) where T = new(x, T) 
end

function capture(::Type{LiteralExpr{Int}}, e::Any)
	typeof(e) == Int && return LiteralExpr{Int}(e)
	return nothing
end

function capture(::Type{LiteralExpr{Float64}}, e::Any)
	typeof(e) == Float64 && return LiteralExpr{Float64}(e)
	return nothing
end

function capture(::Type{LiteralExpr{String}}, e::Any)
	typeof(e) == String && return LiteralExpr{String}(e)
	return nothing
end

"""
example: sqrt(x)
"""
struct UnaryFunction{T}
    func::Function
    argtype::DataType
    UnaryFunction{T}(x) where T = new(x, T) 
end

function capture(::Type{UnaryFunction{T}}, e::Expr) where T 
    if e.head == :call && length(e.args) == 2
        return UnaryFunction(e.args[1], e.args[2])
    end
    return nothing
end
