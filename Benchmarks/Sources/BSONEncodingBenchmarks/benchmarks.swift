import Benchmark
import BSON

@MainActor
let benchmarks =
{
    Benchmark.init("EncodeDates",
        configuration: .init(
            metrics: BenchmarkMetric.all,
            timeUnits: .microseconds,
            maxDuration: .seconds(10)))
    {
        benchmark in

        // generate dates
        var dates:[Date] = []
        var index:Int = 4
        for year:Date.Year in 1492 ... 2022
        {
            for month:Date.Month in Date.Month.allCases
            {
                for day:Int in 1 ... year.days(in: month)
                {
                    let date:Date = .init(year: year, month: month, day: day,
                        weekday: Date.Weekday.allCases[index % 7])
                    dates.append(date)
                    index += 1
                }
            }
        }
        print("generated \(dates.count) dates")

        benchmark.startMeasurement()

        for _:Int in 0 ..< 5
        {
            blackHole(encode(dates: dates))
        }
    }
}

@inline(never)
func encode(dates:[Date]) -> [BSON.Document]
{
    dates.map { .init(with: $0.encode(to:)) }
}
