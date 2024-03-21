const ALL_INPUTS = [
    LiteralExpression{Int},
    LiteralExpression{String},
    LiteralExpression{Float64},
    SymbolExpression{Function},
]

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
    args = parseinput([ArgExpression], x)
    arg = args[1] |> exprarg |> esc
    return quote
        $(arg) = 719
    end
end