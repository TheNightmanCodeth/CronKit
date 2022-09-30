import XCTest
@testable import CronKit

final class CronKitTests: XCTestCase {
    func testCronCommit() throws {
        let dailyTask = DailyCronJob(name: "test", timeMinute: 30, timeHour: 12, operation: "/bin/sh -c echo \"test\"")
        let response: String = try dailyTask.commit()
        print(response)
    }
}
