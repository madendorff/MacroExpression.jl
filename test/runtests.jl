using MacroExpression
using Test

@testset "MacroExpression.jl" begin
    
    @testset "Test Types" begin

        s1 = SymbolExpr{Function}(:println)
        @test eval(s1.symbol) == println
        s2 = LiteralExpr{Int}(12)
        @test s2.value == 12

        a1 = ArgumentAssigment(:a, :Int, 37)
        @test typeof(a1) == ArgumentAssigment{Int}

    end

    @testset "Test Literal and Symbol" begin
        
        # construct a literal expression
        l1 = LiteralExpr{Int}(12)
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

        # collect array of strings
        arr = MacroExpression.@testlits "yw"
        @test arr == ["yw"]

        # collect array of strings
        arr = MacroExpression.@testlits "yw", "hj"
        @test arr == ["yw", "hj"]

        # collect mixed array in body
        arr = MacroExpression.@testlits begin
            34
            "hj"
        end
        @test arr == [34, "hj"]     
        
        # collect mixed array
        arr = MacroExpression.@testlits "kx", begin
            34
            "hj"
        end
        @test arr == ["kx", 34, "hj"]

        # Test assigning a new identifier to a literal
        # var1 is assigned inside the macro
        MacroExpression.@testlitassign var1 62
        @test var1 == 62

        # Test assigning a new variable from an input
        MacroExpression.@testarg var2::Int = 79
        @test var2 == 79

        # Test assigning multiple variables
        MacroExpression.@testargs begin
            var3::Int = 22
            var4::Int = 12
        end
        @test var3 == 22
        @test var4 == 12

    end

end
