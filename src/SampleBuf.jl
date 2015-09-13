"""
Represents a multi-channel sample buffer. The wrapped data is a MxN array with M
samples and N channels. Signals in the time domain are represented by the
concrete type TimeSampleBuf and frequency-domain signals are represented by
FrequencySampleBuf. So a 1-second stereo audio buffer sampled at 44100Hz with
32-bit floating-point samples in the time domain would have the type
TimeSampleBuf{2, 44100.0, Float32}.
"""
abstract SampleBuf{N, SR, T <: Number} <: AbstractArray{T, 2}

"A time-domain signal. See SampleBuf for details"
type TimeSampleBuf{N, SR, T} <: SampleBuf{N, SR, T}
    data::Array{T, 2}
end

TimeSampleBuf{T}(arr::AbstractArray{T, 2}, SR::Real) = TimeSampleBuf{size(arr, 2), SR, T}(arr)
TimeSampleBuf{T}(arr::AbstractArray{T, 1}, SR::Real) = TimeSampleBuf{1, SR, T}(reshape(arr, (length(arr), 1)))

# function TimeSampleBuf{SR}(arr::Array{T, 2})
#     channels = size(arr, 2)
#     TimeSampleBuf{channels, SR, T}(arr)
# end

"A frequency-domain signal. See SampleBuf for details"
type FrequencySampleBuf{N, SR, T} <: SampleBuf{N, SR, T}
    data::Array{T, 2}
end

FrequencySampleBuf{T}(arr::AbstractArray{T, 2}, SR::Real) = FrequencySampleBuf{size(arr, 2), SR, T}(arr)
FrequencySampleBuf{T}(arr::AbstractArray{T, 1}, SR::Real) = FrequencySampleBuf{1, SR, T}(reshape(arr, (length(arr), 1)))

# audio methods
samplerate{N, SR, T}(buf::SampleBuf{N, SR, T}) = SR
nchannels{N, SR, T}(buf::SampleBuf{N, SR, T}) = N


# AbstractArray interface methods
Base.size(buf::SampleBuf) = size(buf.data)
Base.linearindexing{T <: SampleBuf}(::Type{T}) = Base.LinearFast()
Base.getindex(buf::SampleBuf, i::Int) = buf.data[i];
# we define the range indexing here so that we can wrap the result in the
# appropriate SampleBuf type. Otherwise you just get a bare array out
Base.getindex(buf::TimeSampleBuf, r::Range) = TimeSampleBuf(buf.data[r], samplerate(buf))
Base.getindex(buf::FrequencySampleBuf, r::Range) = FrequencySampleBuf(buf.data[r], samplerate(buf))
Base.getindex(buf::TimeSampleBuf, r1::Range, r2::Range) = TimeSampleBuf(buf.data[r1, r2], samplerate(buf))
Base.getindex(buf::FrequencySampleBuf, r1::Range, r2::Range) = FrequencySampleBuf(buf.data[r1, r2], samplerate(buf))
function Base.setindex!{N, SR, T}(buf::SampleBuf{N, SR, T}, val, i::Int)
    buf.data[i] = val
end

# equality
import Base.==
=={N1, N2, SR1, SR2, T1, T2}(buf1::SampleBuf{N1, SR1, T1}, buf2::SampleBuf{N2, SR2, T2}) = (SR1 == SR2 && buf1.data == buf2.data)
