# CronKit

A Swift package for managing Cron jobs on macOS/Linux

## Getting started

First, add `CronKit` as a dependency in your project. This can be done by selecting `File > Add Packages` in Xcode and pasting the URL for 
this repo into the `Search or enter package URL` field, or by adding the following to your `Package.swift` in the `dependencies` section:

> .package(url: "https://github.com/TheNightmanCodeth/CronKit.git", from: "1.0.0")

Once that's done, you can start creating cron jobs!

**This library is meant for linux only. It does not work on macOS. Use launchd on mac.**

## Creating Cron Jobs

Start by deciding when you want this task to run.

Will it run every day? Use `DailyCronJob`.
Weekly? `WeeklyCronJob`.

Once you've decided what type of task you want to schedule go ahead and create one of the afformentioned jobs:

```swift
let dailyTask = DailyCronJob(
    name: "Daily Task",
    timeMinute: 0,
    timeHour: 16,
    operation: #"/bin/sh -c echo \"hello, world!\""#,
    outputFile: "/home/user/daily-task.log"
)
```

Check out the [documentation]() for a list of tasks and how to create them.

## Registering Cron Jobs

Registering jobs is super easy. Just call `.commit()` on your job like so:

```swift
dailyTask.commit()
```

The job will be added to the system crontab and registered.

## Creating Custom Cron Jobs

CronKit is made to be extensible. To create a custom CronJob, simply "implement" the `Recurrable` protocol.

For example:

```swift
struct CustomCronJob: Recurrable {
    var name: String
    var time: CronTime
    var operation: String
    // Anything else you'd like to add...'
    
    init(name: String, time: CronTime, operation: String, outputFile: String) {
        self.name = name
        self.time = time
        self.operation = operation
        if outputFile != nil { // outputFile defaults to ">/dev/null 2>&1"
            self.outputFile = outputFile
        }
        // Anything else you'd like to add...
    }
    
    override func toCronEntry() -> String {
        // Do some operations to generate your own cron entry...
        // This method is called when you `.commit` your job to generate
        // the crontab entry
    }
    
    override func commit() throws -> String {
        // Do some operations to add the crontab entry yourself
        // Stock implementation simply pipes a newline, a comment 
        // that describes the entry with a timestamp for easy access later.
        // Make sure to match the format using `makeLabel(name)`
    }
}
```
