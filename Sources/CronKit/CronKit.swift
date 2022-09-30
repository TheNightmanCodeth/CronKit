/// Basic Swift Library for managing Cron jobs on Linux
/// Made for `Feeder` (https://github.com/TheNightmanCodeth/Feeder)

public struct CronKit {
    static func getCurrentJobs() -> [any Recurrable]? {
        return nil
    }
}

public struct DailyCronJob: DailyRecurrable {
    public var name: String
    public var time: CronTime
    public var operation: String
    public var outputFile: String = ">/dev/null 2>&1"
    
    init(name: String, time: CronTime, operation: String, _ outputFile: String? = nil) {
        self.name = name
        self.time = time
        self.operation = operation
        if outputFile != nil {
            self.outputFile = outputFile!
        }
    }
    
    /// Initialize job with int values for time instead of CronTime
    init(name: String, timeMinute: Int, timeHour: Int, operation: String, _ outputFile: String? = nil) {
        let time = CronTime(hour: timeHour, minute: timeMinute)
        self.init(name: name, time: time, operation: operation, outputFile)
    }
}

public struct WeeklyCronJob: WeeklyRecurrable {
    public var name: String
    public var day: DayOfWeek
    public var time: CronTime
    public var operation: String
    public var outputFile: String = ">/dev/null 2>&1"
    
    init(name: String, day: DayOfWeek, time: CronTime, operation: String, _ outputFile: String? = nil) {
        self.name = name
        self.day = day
        self.time = time
        self.operation = operation
        if outputFile != nil {
            self.outputFile = outputFile!
        }
    }
    
    /// Initialize job with int values for time instead of CronTime
    init(name: String, day: DayOfWeek, timeMinute: Int, timeHour: Int, operation: String, _ outputFile: String? = nil) {
        let time = CronTime(hour: timeHour, minute: timeMinute)
        self.init(name: name, day: day, time: time, operation: operation, outputFile)
    }
}
