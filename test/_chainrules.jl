@testset "chainrules.jl" begin

    function FiniteDifferences.to_vec(k::AxisKeys.KaNda)
        v, b = to_vec(k.data)
        back(x) = wrapdims(b(x); AxisKeys.named_axiskeys(k)...)
        return v, back
    end

    function FiniteDifferences.to_vec(k::KeyedArray)
        v, b = to_vec(k.data)
        back(x) = wrapdims(b(x), axiskeys(k)...)
        return v, back
    end

    @testset "ProjectTo" begin
        ka = wrapdims(rand(3, 3); a=1:3, b='a':'c')

        @testset "NoTangent()" begin
            @test NoTangent() == ProjectTo(ka)(NoTangent())
        end

        @testset "(:c, :d) -> (:a, :b) == error" begin
            kb = wrapdims(rand(3, 3); c=1:3, d='a':'c')
            @test_throws DimensionMismatch ProjectTo(ka)(kb)
        end

        @testset "(:_, :_) -> (:a, :b) == (:a, :b)" begin
            x = rand(3, 3)
            projected = @inferred ProjectTo(ka)(x)
            @test dimnames(projected) == dimnames(ka)
        end

        @testset "(:a, :_) -> (:a, :b) == (:a, :b)" begin
            kb = wrapdims(rand(3, 3); a=1:3, _='a':'c')
            projected = @inferred ProjectTo(ka)(kb)
            @test dimnames(projected) == dimnames(ka)
        end

        @testset "(:a, :b) -> (:a, :_) == (:a, :b)" begin
            kb = wrapdims(rand(3, 3); a=1:3, _='a':'c')
            projected = @inferred ProjectTo(kb)(ka) # switched order compared to above
            @test dimnames(projected) == dimnames(ka)
        end

        @testset "(:_, :b) -> (:a, :_) == (:a, :b)" begin
            k1 = wrapdims(rand(3, 3); a=1:3, _='a':'c')
            k2 = wrapdims(rand(3, 3); _=1:3, b='a':'c')
            projected = @inferred ProjectTo(k1)(k2)
            @test dimnames(projected) == (:a, :b)
        end
    end

    @testset "KeyedVector" begin
        data = rand(3)
        test_rrule(AxisKeys.keyless_unname, wrapdims(data, a=1:3); check_inferred=false)
        test_rrule(AxisKeys.keyless_unname, wrapdims(data, 1:3); check_inferred=false)
        test_rrule(AxisKeys.keyless_unname, data; check_inferred=false)

        # with matrix output tangent
        test_rrule(AxisKeys.keyless_unname, wrapdims(data, a=1:3); output_tangent=rand(3, 1), check_inferred=false)
        test_rrule(AxisKeys.keyless_unname, wrapdims(data, 1:3); output_tangent=rand(3, 1), check_inferred=false)
        test_rrule(AxisKeys.keyless_unname, data; output_tangent=rand(3, 1), check_inferred=false)
    end

    @testset "KeyedMatrix" begin
        data = rand(3, 4)
        test_rrule(AxisKeys.keyless_unname, wrapdims(data, a=1:3, b='a':'d'); check_inferred=false)
        test_rrule(AxisKeys.keyless_unname, wrapdims(data, 1:3, 'a':'d'); check_inferred=false)
        test_rrule(AxisKeys.keyless_unname, data; check_inferred=false)
    end

end
