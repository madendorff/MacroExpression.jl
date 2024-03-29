argument(x) = :nothing
argumentvalue(x) = :nothing
assignment(x) = :nothing
func(x) = :nothing
literal(x) = nothing
kwargument(x) = :nothing
pair(x) = :nothing
isparsable(x) = True

"""
example: x::Int = 23
"""
struct ArgumentAssigment{T}
    expr::Any
    arg::Symbol
	type::Symbol
	value::T
end

function capture(::Type{ArgumentAssigment{T}}, e::Any) where T
    @capture(e, arg_::type_ = value_) && return ArgumentAssigment(e, arg, type, value)
    @capture(e, arg_ = value_) && return ArgumentAssigment(e, arg, :Any, value)
    @capture(e, arg_::type_) && return ArgumentAssigment(e, arg, type, nothing)
    return nothing
end

argument(x::ArgumentAssigment) = :($(x.arg)::$(x.type))
kwargument(x::ArgumentAssigment) = Expr(:kw, argument(x), x.value)
pair(x::ArgumentAssigment) = :($(x.arg)=>value(x))
assignment(x::ArgumentAssigment) = :($(x.arg) = $(x.value))
argumentvalue(x::ArgumentAssigment) = :($(x.value))

"""
example: 2 * x
"""
struct BinaryFunction{T,U}
    expr::Any
    func::Symbol
    argtypes::Tuple{DataType, DataType}
    BinaryFunction{T,U}(e, f::Symbol) where {T, U} = new(e, f, (T, U))
end

func(x::BinaryFunction) = x.func

function capture(::Type{BinaryFunction{T,U}}, e) where {T,U}
    if hasproperty(e, :head) && e.head == :call && length(e.args) == 3
        return BinaryFunction{T,U}(e, e.args[1])
    end
    return nothing
end


"""
example: :x
"""
struct SymbolExpr{T}
    expr::Any
    symbol::Symbol
    type::DataType
    SymbolExpr{T}(s::Symbol) where T = new(s, s, T) 
end

literal(x::SymbolExpr) = x.symbol

function capture(::Type{SymbolExpr{Function}}, e::Symbol)
    isfunction(e) && return SymbolExpr{Function}(e)
    return nothing
end

func(x::SymbolExpr{Function}) = x.symbol

isfunction(e) = isdefined(Main, e) && isa(getfield(Main, e), Function)

function capture(::Type{SymbolExpr{Enum}}, e::Any)
    
    typeof(eval(e)) <: Enum && return SymbolExpr{Enum}(e)
    return nothing

end

capture(::Type{Symbol}, e::Any) = SymbolExpr{Symbol}(e)

function capture(::Type{SymbolExpr{Symbol}}, e::Symbol)
    isfunction(e) && return SymbolExpr{Symbol}(e)
    return nothing
end

function capture(::Type{Pair}, e::Any)
    @capture(e, x_ => y_) && return Pair(x, y)
    return nothing
end

function capture(::Type{SymbolExpr{DataType}}, e::Any)
    typeof(eval(e)) == DataType && return SymbolExpr{DataType}(eval(e))
    return nothing
end

literal(x::SymbolExpr) = x.symbol

capture(::Type{SymbolExpr{Function}}, e::Any) = nothing

"""
example:   "abc"
"""
struct LiteralExpr{T}
    expr::Any
    value::T
    type::DataType
    LiteralExpr{T}(e) where T = new(e, e, T) 
end

literal(x::LiteralExpr) = x.value

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
    expr::Any
    func::Symbol
    argtype::DataType
    UnaryFunction{T}(e, func) where T = new(e, func, T) 
end

func(x::UnaryFunction) = x.func

"""
	capture(::T, expr)

Parse an expression looking for a pattern associated with a specific logical expression type T. 
Return an object or type T if the expression matches the pattern. Otherwise return nothing.

example: capture(LiteralExpr{Int}, :(34)) 
  >> LiteralExpr(34, Int)

"""
function capture(::Type{UnaryFunction{T}}, e) where T 
    if hasproperty(e, :head) &&  e.head == :call && length(e.args) == 2
        return UnaryFunction{T}(e, e.args[1])
    end
    return nothing
end


struct UnparsableExpression
    expr::Any
end

expr(x::UnparsableExpression) = x.expr
isparsable(x::UnparsableExpression) = false


