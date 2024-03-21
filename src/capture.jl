"""
Parse expressions for specific metadata types. Return a
and array of the metadata objects captured from the 
input expressions.
"""
function parseinput(targets=Vector{Type}, y...)
	results = []
	for input in y
		if hasproperty(input, :head) && input.head == :block
			append!(results, parseinput(targets, input.args...))
		else
			println("JSKS", typeof(input))
			capture!(results, input, targets...)
		end
	end
	results
end

"""
Capture expression metadata into an array
"""
function capture!(arr::Vector{Any}, expr::Any, T::Type...)
	captured = nothing
	for tp in T
		captured = capture(tp, expr)
		if !isnothing(captured)
			push!(arr, captured)
			break
		end
	end
	return arr
end

function capture(::Type{ArgExpression{T}}, e::Any) where T
    
    @capture(e, arg_::type_ = value_) && return ArgExpression(arg, type, value)
    @capture(e, arg_ = value_) && return ArgExpression(arg, :Any, value)
    @capture(e, arg_::type_) && return ArgExpression(arg, type, nothing)		

    return nothing
end

function capture(::Type{LiteralExpression{Int}}, e::Any) where T

	typeof(e) == Int && return LiteralExpression{Int}(e)
	return nothing
end

function capture(::Type{LiteralExpression{Float64}}, e::Any) where T

	typeof(e) == Float64 && return LiteralExpression{Float64}(e)
	return nothing
end

function capture(::Type{LiteralExpression{String}}, e::Any) where T

	typeof(e) == String && return LiteralExpression{String}(e)
	return nothing
end

function capture(::Type{SymbolExpression{Function}}, e::Symbol)
    
    if isdefined(Main, e) && isa(getfield(Main, e), Function)
        return SymbolExpression{Function}(e)
    end
    return nothing
end

capture(::Type{SymbolExpression{Function}}, e::Any) = nothing

function capture(::Type{Pair}, e::Any)

    @capture(e, x_ => y_) && return Pair(x, y)
    return nothing

end

function capture(::Type{SymbolExpression{DataType}}, e::Any)

    typeof(eval(e)) == DataType && return SymbolExpression{DataType}(e, eval(e))
    return nothing

end

"""
Deconstruct an expression. Capture its metadata if the patterns 
found in the expression's AST match a specific pattern.
"""
function capture(::Type{SymbolExpression{Enum}}, e::Any)
    
    typeof(eval(e)) <: Enum && return SymbolExpression{Enum}(e, typeof(eval(e)))
    return nothing

end
