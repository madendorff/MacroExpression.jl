using MacroExpression
using Test

@testset "MacroExpression.jl" begin
    
    @testset "Test Types" begin

        s1 = SymbolExpression{Function}(:println)
        @test eval(s1.symbol) == println
        s2 = LiteralExpression{Int}(12)
        @test s2.value == 12

        a1 = ArgExpression(:a, :Int, 37)
        @test typeof(a1) == ArgExpression{Int}

    end

    @testset "Test Literal and Symbol" begin
        
        # construct a literal expression
        l1 = LiteralExpression{Int}(12)
        @test l1.value == 12

        # collect a literal expression from a macro
        inputs = @parsemacro 356
        @test inputs[1].value == 356

        # collect a float
        inputs = @parsemacro 6.2
        @test inputs[1].value == 6.2

        # each type is targetted separately
        inputs = @parsemacro "abc"
        @test inputs[1].value == "abc"

        
        # Each type of symbol is collected separately too
        inputs = @parsemacro println
        @test inputs[1].symbol == :println
        @test inputs[1].type == Function
    
        # Test literal retrieval inside a macro
        # This macro returns a literal
        l2 = MacroExpression.@testlit 13
        @test l2.value == 13

        # collect array of floats
        arr = MacroExpression.@testlits "yw"
        @test arr == ["yw"]

        #Test assigning a new identifier to a literal
        MacroExpression.@testlitassign var1 62
        @test var1 == 62

    end

end
