"""
Parse expressions for specific metadata types. Return a
and array of the metadata objects captured from the 
input expressions.
"""
function parseinput(targets=Vector{Type}, y...; includeunparseable=false)
	results = []
	for input in y
		if iscollection(input)
			append!(results, parseinput(targets, input.args...))
		else
			capture!(results, input, targets..., includeunparseable=false)
		end
	end
	results
end

"""
Capture expression metadata into an array
"""
function capture!(arr::Vector{Any}, expr::Any, T::Type...; includeunparseable=false)
	captured = nothing
	for tp in T
		captured = capture(tp, expr)
		if !isnothing(captured)
			push!(arr, captured)
			return arr
		end
	end
	includeunparseable && push!(arr, UnparsableExpression(expr))
	return arr
end



function iscollection(e::Any)

	if hasproperty(e, :head) && e.head in (:block, :tuple)
		return true
	end

	return false
end
