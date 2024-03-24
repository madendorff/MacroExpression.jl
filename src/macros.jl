const ALL_INPUTS = [
    LiteralExpr{Int},
    LiteralExpr{String},
    LiteralExpr{Float64},
    SymbolExpr{Function},
]

function printinput(y...)
	results = []
	for input in y
		if iscollection(input)
			append!(results, showinput(input.args...))
		else
			print(input, targets...)
		end
	end
	results
end


macro printinput(y...)
	inputs = printinput(ALL_INPUTS, y...)
	return inputs
end


macro parsemacro(y...)
	inputs = parseinput(ALL_INPUTS, y...)
	return inputs
end

macro testlit(x)
    args = parseinput( ALL_INPUTS, x)
    arg = args[1] 
    return quote
        $arg
    end
end

macro testlits(x...)
    args = parseinput( ALL_INPUTS, x...) 
    values = [x.value for x in args]
    return quote
        $values
    end
end


macro testlitassign(name, x)
    args = parseinput(ALL_INPUTS, x)
    name = name |> esc                      # name has to be escaped
    argvalue = args[1].value
    return quote
        $name = $argvalue                   # if not escaped it would have local context
    end
end


macro testarg(x)
    args = parseinput([ArgumentAssigment{Int}], x)
    arg = args[1] |> argument |> esc
    v = args[1] |> value
    return quote
        $arg = $v
    end
end

macro testargs(x...)
    args = parseinput([ArgumentAssigment{Int}], x...)
    argassign = [assignment(a) |> esc for a in args]
    return quote
        $(argassign...)
    end
end