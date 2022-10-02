//
//  Util.swift
//  Utilites and extensions
//
//  Created by Joe Diragi on 9/29/22.
//

import Foundation

enum RecurrableError: Error {
    case noValues(String)
    case invalidDateFormat(String)
}

extension Collection where Element == Optional<Any> {
    func allNil() -> Bool {
        return allSatisfy { $0 == nil }
    }
}

public func addCronJob(entry: any Recurrable) throws -> String {
    // Create pipes and process for piping to crontab
    let cronInput = Pipe()
    let cronOutput = Pipe()
    let cronWrite = Process()
    let cronRead = Process()
    let cronReadOut = Pipe()
    cronRead.standardOutput = cronReadOut
    cronRead.arguments = ["-l"]
    cronRead.executableURL = URL(fileURLWithPath: "/usr/bin/crontab")
    try cronRead.run()
    cronRead.waitUntilExit()
    print("Test")
    
    cronWrite.standardOutput = cronOutput
    cronWrite.standardError = cronOutput
    cronWrite.arguments = ["-c", "crontab", "-"]
    cronWrite.executableURL = URL(fileURLWithPath: "/bin/sh")
    cronWrite.standardInput = cronInput
    
    // Add previous jobs
    cronInput.fileHandleForWriting.write(cronReadOut.fileHandleForReading.readDataToEndOfFile())
    
    // Add newline to bottom of crontab
    cronInput.fileHandleForWriting.write("\n\n".data(using: .utf8)!)
    
    // Label this entry
    let label = try entry.makeLabel()
    cronInput.fileHandleForWriting.write(label.data(using: .utf8)!)
    
    // new line
    cronInput.fileHandleForWriting.write("\n".data(using: .utf8)!)
    
    // Add this job to crontab under label comment
    cronInput.fileHandleForWriting.write(entry.toCronEntry().data(using: .utf8)!)
    cronInput.fileHandleForWriting.write("\n".data(using: .utf8)!)
    cronInput.fileHandleForWriting.closeFile()
    
    try cronWrite.run()
    cronWrite.waitUntilExit()
    
    let outputData = cronOutput.fileHandleForReading.readDataToEndOfFile()
    return (String(data: cronReadOut.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)!)
}

func findJob(_ id: String) -> Int {
    return 0
}
