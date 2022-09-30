//
//  Recurrables.swift
//  
//
//  Created by Joe Diragi on 9/29/22.
//

/// Represents a day of the week
public enum DayOfWeek: Int {
    case Sunday = 0
    case Monday = 1
    case Tuesday = 2
    case Wednesday = 3
    case Thursday = 4
    case Friday = 5
    case Saturday = 6
}

/// Represents a month of the year
public enum Month: Int {
    case None = 0
    case January = 1
    case February = 2
    case March = 3
    case April = 4
    case May = 5
    case June = 6
    case July = 7
    case August = 8
    case September = 9
    case October = 10
    case November = 11
    case December = 12
}

/// Represents a time (ie. 13:30)
public struct CronTime {
    var hour: Int
    var minute: Int
}

/// Represents a date (ie. July 24th)
public struct CronDate {
    /// The day of the month (ie. the 22nd)
    var dayOfMonth: Int
    /// The [Month] of the date (ie. February)
    var month: Month
}

/// Cron entries are formatted like so:
/// {Minute} {Hour} {DayOfMonth} {Month} {DayOfWeek} {command} {output}
/// ie. A command that runs on Monday, Wednesday and Friday at 3:00pm
/// ->  0 15 * * 1,3,5 /path/to/command -args 2 /path/to/log-out.log

/// Base entry protocol. Every scheduled event must have a time
public protocol Recurrable {
    /// The **unique** name of this job. Used for managing crontab
    var name: String { get }
    /// The [CronTime] at which the operation should be called
    var time: CronTime { get set }
    /// The operation to be run
    /// ie. /usr/bin/echo "Hello, world!"
    var operation: String { get set }
    /// The path to the file to print operation output
    /// ie. /var/log/operation-output.log
    var outputFile: String { get set }
    /// Returns the entry to be added as cron job
    func toCronEntry() -> String
    /// Adds this job to crontab
    func commit() throws -> String
}
extension Recurrable {
    public func commit() throws -> String {
        return try addCronJob(entry: self)
    }
}

/// Runs every day at certain time
/// ie. Every day at noon
protocol DailyRecurrable: Recurrable {}
extension DailyRecurrable {
    public func toCronEntry() -> String {
        return "\(time.minute) \(time.hour) * * * \(operation) \(outputFile)"
    }
}

/// An operation that runs once a week on a certain day at a certain time
/// ie. Every Monday at noon
protocol WeeklyRecurrable: Recurrable {
    var day: DayOfWeek { get set }
}
extension WeeklyRecurrable {
    public func toCronEntry() -> String {
        return "* * * * \(day) \(operation) \(outputFile)"
    }
}

/// An operation that runs once a week on a certain date at a certain time
/// ie. Every month on the 12th at noon
protocol MonthlyRecurrable: Recurrable {
    var dayOfMonth: Int { get set }
}
extension MonthlyRecurrable {
    public func toCronEntry() -> String {
        return "* * \(dayOfMonth) * * \(operation) \(outputFile)"
    }
}

/// An operation that runs once a year in a certain month on a certain date at a certain time
/// ie. Every July 24th at midnight
protocol YearlyRecurrable: Recurrable {
    var date: CronDate { get set }
}
extension YearlyRecurrable {
    public func toCronEntry() -> String {
        return "* * \(date.dayOfMonth) \(date.month) * \(operation) \(outputFile)"
    }
}

/// An operation that runs every {days of week} at certain time.
/// ie. every Monday, Wednesday and Friday at 18:30
protocol DaysOfWeekRecurrable: Recurrable {
    var days: [DayOfWeek] { get set }
}
extension DaysOfWeekRecurrable {
    public func toCronEntry() -> String {
        // Convert list to comma-seperated string
        let daysString = days.map{String($0.rawValue)}.joined(separator: ",")
        return "* * * * \(daysString) \(operation) \(outputFile)"
    }
}

/// Runs on specific dates at certain time
protocol DatesRecurrable: Recurrable {
    /// The dates at which to run the operation.
    var dates: [CronDate] { get set }
}
extension DatesRecurrable {
    func toCronEntry() -> String {
        // Convert list to comma-seperated string of months and dates
        let monthsString = dates.map{String($0.month.rawValue)}.joined(separator: ",")
        let dayOfMonthString = dates.map{String($0.dayOfMonth)}.joined(separator: ",")
        return "* * \(dayOfMonthString) \(monthsString) * \(operation) \(outputFile)"
    }
}

/// A custom recurring operation. Can be run at any interval
/// ie. Every Monday, Tuesday or Friday (dayOfWeeks) in April, June or August (months)
/// that falls on the 12th, 2nd or 3rd (dayOfMonths) at noon, 13:30 or 18:00 (times)
protocol CustomRecurrable: Recurrable {
    var dayOfWeeks: [DayOfWeek]? { get set }
    var dayOfMonths: [Int]? { get set }
    var months: [Month]? { get set }
    var times: [CronTime]? { get set }
}
extension CustomRecurrable {
    func toCronEntry() throws -> String {
        guard ![dayOfWeeks, dayOfMonths, months, times].allNil() else {
            throw RecurrableError.noValues("No values were provided in CustomRecurrable")
        }
        var minutesString: String?
        var hoursString: String?
        var dayOfMonthsString: String?
        var monthsString: String?
        var dayOfWeeksString: String?
        if times != nil {
            minutesString = times!.map{String($0.minute)}.joined(separator: ",")
            hoursString = times!.map{String($0.hour)}.joined(separator: ",")
        }
        if dayOfMonths != nil {
            dayOfMonthsString = dayOfMonths!.map{String($0)}.joined(separator: ",")
        }
        if months != nil {
            monthsString = months!.map{String($0.rawValue)}.joined(separator: ",")
        }
        if dayOfWeeks != nil {
            dayOfWeeksString = dayOfWeeks!.map{String($0.rawValue)}.joined(separator: ",")
        }
        
        return "\(minutesString ?? "*") \(hoursString ?? "*") \(dayOfMonthsString ?? "*") \(monthsString ?? "*") \(dayOfWeeksString ?? "*") \(operation) \(outputFile)"
    }
}

