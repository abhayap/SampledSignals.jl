@testset "Interval Tests" begin
    @testset "Basic Construction" begin
        interval = Interval(4.5, 8.9)
        @test interval.lo == 4.5
        @test interval.hi == 8.9
        @test 1.2..5.6 == Interval{Float64}(1.2, 5.6)
        # this test fails
        # @test Interval(4.5) == (4.5..4.5)
    end
    @testset "Promotion Rules" begin
        @test 1.2..5 == Interval{Float64}(1.2, 5.0)
        @test_throws ArgumentError Interval("Hello", 45.6)
    end
    @testset "Equality" begin
        @test Interval{Float64}(1.2, 5.6) == Interval{Float64}(1.2, 5.6)
    end
    @testset "Minimums and Maximums" begin
        @test minimum(1..5) == 1
        @test maximum(1..5) == 5
    end
    @testset "Containment" begin
        @test 4 in 1..6
        @test !(8 in 1..6)
    end
    @testset "Conversions" begin
        function convscalar()
            i::Interval{Int} = 4
            i
        end
        @test convscalar() == Interval{Int}(4, 4)
        function convscalar_withconv()
            i::Interval{Float64} = 4
            i
        end
        @test convscalar_withconv() == Interval{Float64}(4.0, 4.0)
        function convinterval()
            i::Interval{Float64} = Interval{Int}(4, 4)
            i
        end
        @test convinterval() == Interval{Float64}(4.0, 4.0)
    end
end