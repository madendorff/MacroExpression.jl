"""
Parse expressions for specific metadata types. Return a
and array of the metadata objects captured from the 
input expressions.
"""
function parseinput(targets=Vector{Type}, y...)
	results = []
	for input in y
		if iscollection(input)
			append!(results, parseinput(targets, input.args...))
		else
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



"""
	capture(::T, expr)

Parse an expression looking for a pattern associated with a specific logical expression type T. 
Return an object or type T if the expression matches the pattern. Otherwise return nothing.

example: capture(LiteralExpr{Int}, :(34)) 
  >> LiteralExpr(34, Int)

"""
function capture(::Type{SymbolExpr{Enum}}, e::Any)
    
    typeof(eval(e)) <: Enum && return SymbolExpr{Enum}(e, typeof(eval(e)))
    return nothing

end


function iscollection(e::Any)

	if hasproperty(e, :head) && e.head in (:block, :tuple)
		return true
	end

	return false
end
