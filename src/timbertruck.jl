
abstract TimberTruck

log(t::TimberTruck, a::Dict) = error("please implement `log(truck::$(typeof(t)), args::Dict)`")

# -------

type CommonLog <: TimberTruck
    out::IO

    # for use by the framework, will be
    # ignored if absent or set to nothing
    _mode
end

function log(truck::CommonLog, l::Dict)
    println(truck.out, "$(l[:remotehost]) $(l[:rfc931]) $(l[:authuser]) $(l[:date]) \"$(l[:request])\" $(l[:status]) $(l[:bytes])")
end

# -------

type LumberjackLog <: TimberTruck
    out::IO

    _mode

    LumberjackLog(out::IO, mode = nothing) = new(out, mode)
    function LumberjackLog(filename::String, mode = nothing)
        file = open(filename, "a")
        truck = new(file, mode)
        finalizer(truck, (t)->close(t.out))
        truck
    end
end

function log(truck::LumberjackLog, l::Dict)
    l = copy(l)

    date_stamp = get(l, :date, nothing)
    record = date_stamp == nothing ? "" : "$date_stamp - "

    record = string(record, "$(l[:mode]):$(repr(l[:msg]))")
    delete!(l, :date)
    delete!(l, :mode)
    delete!(l, :msg)

    for (k, v) in l
        record = string(record, " $k:$(repr(v))")
    end

    println(truck.out, record)
    flush(truck.out)
end

# -------
