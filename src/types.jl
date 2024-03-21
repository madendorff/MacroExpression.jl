struct ArgExpression{T}
    arg::Symbol
	type::Symbol
	value::T
end

exprarg(x::ArgExpression) = :($(x.arg)::$(x.type))
exprkw(x::ArgExpression) = Expr(:kw, exprarg(x), x.value)
exprpair(x::ArgExpression) = :($(x.arg)=>$(x.value))

struct SymbolExpression{T}
    symbol::Symbol
    type::DataType
    SymbolExpression{T}(s::Symbol) where T = new(s, T) 
end


struct LiteralExpression{T}
    value::T
    type::DataType
    LiteralExpression{T}(x) where T = new(x, T) 
end
