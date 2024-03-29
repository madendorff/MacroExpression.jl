const LITERALS = [
    LiteralExpr{Int},
    LiteralExpr{String},
    LiteralExpr{Float64},
    LiteralExpr{Symbol},
    SymbolExpr{Function},
]


macro parsemacro(y...)
	inputs = parseinput(LITERALS, y...)
	return inputs
end

macro testlit(x)
    args = parseinput( LITERALS, x)
    arg = literal(args[1])
    return quote
        $arg
    end
end

macro testlits(x...)
    args = parseinput( LITERALS, x...)
    dump(args)
    values = [literal(x) for x in args]
    return quote
        $values
    end
end


macro testlitassign(name, x)
    args = parseinput(LITERALS, x)
    name = name |> esc                      # name has to be escaped
    argvalue = args[1].value
    return quote
        $name = $argvalue                   # if not escaped it would have local context
    end
end


macro testarg(x)
    args = parseinput([ArgumentAssigment{Int}], x)
    arg = args[1] |> argument |> esc
    v = args[1] |> argumentvalue
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