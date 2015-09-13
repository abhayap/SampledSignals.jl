@testset "SampleBuf Tests" begin
    TEST_SR = 48000
    TEST_T = Float32
    const StereoBuf = TimeSampleBuf{2, TEST_SR, TEST_T}

    @testset "Supports audio interface" begin
        buf = StereoBuf(zeros(TEST_T, 64, 2))
        @test samplerate(buf) == TEST_SR
        @test nchannels(buf) == 2
    end

    @testset "Supports size()" begin
        buf = StereoBuf(zeros(TEST_T, 64, 2))
        @test size(buf) == (64, 2)
    end

    @testset "Can be indexed with 1D indices" begin
        arr = reshape(TEST_T[1:16;], (8, 2))
        buf = TimeSampleBuf(arr, TEST_SR)
        buf[12] = 1.5
        @test buf[12] == 1.5

        arr = reshape(TEST_T[1:16;], (8, 2))
        buf = FrequencySampleBuf(arr, TEST_SR)
        buf[12] = 1.5
        @test buf[12] == 1.5
    end

    @testset "Can be indexed with 2D indices" begin
        arr = reshape(TEST_T[1:16;], (8, 2))
        buf = TimeSampleBuf(arr, TEST_SR)
        buf[5, 2] = 1.5
        @test buf[5, 2] == 1.5

        arr = reshape(TEST_T[1:16;], (8, 2))
        buf = FrequencySampleBuf(arr, TEST_SR)
        buf[5, 2] = 1.5
        @test buf[5, 2] == 1.5
    end

    @testset "SampleBuf can be indexed with 1D ranges" begin
        arr = reshape(TEST_T[1:16;], (8, 2))
        buf1 = TimeSampleBuf(arr, TEST_SR)
        # linear indexing gives you a mono buffer
        slice = buf1[6:12]
        @test typeof(slice) == TimeSampleBuf{1, TEST_SR, TEST_T}
        @test slice == TimeSampleBuf(TEST_T[6:12;], TEST_SR)

        buf2 = FrequencySampleBuf(arr, TEST_SR)
        # linear indexing gives you a mono buffer
        slice = buf2[6:12]
        @test typeof(slice) == FrequencySampleBuf{1, TEST_SR, TEST_T}
        @test slice == FrequencySampleBuf(TEST_T[6:12;], TEST_SR)
    end

    @testset "Can get type params from contained array" begin
        timebuf = TimeSampleBuf(Array(TEST_T, 32, 2), TEST_SR)
        @test typeof(timebuf) == TimeSampleBuf{2, TEST_SR, TEST_T}
        monotimebuf = TimeSampleBuf(Array(TEST_T, 32), TEST_SR)
        @test typeof(monotimebuf) == TimeSampleBuf{1, TEST_SR, TEST_T}
        freqbuf = FrequencySampleBuf(Array(TEST_T, 32, 2), TEST_SR)
        @test typeof(freqbuf) == FrequencySampleBuf{2, TEST_SR, TEST_T}
        monofreqbuf = FrequencySampleBuf(Array(TEST_T, 32), TEST_SR)
        @test typeof(monofreqbuf) == FrequencySampleBuf{1, TEST_SR, TEST_T}
    end

    @testset "supports equality" begin
        arr1 = rand(TEST_T, (64, 2))
        arr2 = arr1 + 1
        arr3 = arr1[:, 1]
        buf1 = TimeSampleBuf(arr1, TEST_SR)
        buf2 = TimeSampleBuf(arr1, TEST_SR)
        buf3 = TimeSampleBuf(arr1, TEST_SR+1)
        buf4 = TimeSampleBuf(arr2, TEST_SR)
        buf5 = TimeSampleBuf(arr3, TEST_SR)
        @test buf1 == buf2
        @test buf2 != buf3
        @test buf2 != buf4
        @test buf2 != buf5
    end

    # @testset "TimeSampleBufs can be range-indexed in seconds" begin
    #     # array with 1sec of audio
    #     arr = rand(TEST_T, (TEST_SR, 2))
    #     buf = TimeSampleBuf(arr, TEST_SR)
    #     expected_arr = arr[round(Int, TEST_SR*0.25):round(Int, TEST_SR*0.5), :]
    #     @test buf[0.25s:0.5s, :] == TimeSampleBuf(expected_arr)
    # end

end
