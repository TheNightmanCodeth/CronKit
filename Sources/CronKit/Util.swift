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
    cronWrite.standardOutput = cronOutput
    cronWrite.standardError = cronOutput
    cronWrite.arguments = ["-c", "crontab", "-"]
    cronWrite.executableURL = URL(fileURLWithPath: "/bin/sh")
    cronWrite.standardInput = cronInput
    
    // Add newline to bottom of crontab
    cronInput.fileHandleForWriting.write("\n".data(using: .utf8)!)
    
    // Label this entry
    let label = try entry.makeLabel()
    cronInput.fileHandleForWriting.write(label.data(using: .utf8)!)
    
    // Linebreak
    cronInput.fileHandleForWriting.write("\n".data(using: .utf8)!)
    
    // Add this job to crontab under label comment
    cronInput.fileHandleForWriting.write(entry.toCronEntry().data(using: .utf8)!)
    cronInput.fileHandleForWriting.closeFile()
    
    try cronWrite.run()
    cronWrite.waitUntilExit()
    
    let outputData = cronOutput.fileHandleForReading.readDataToEndOfFile()
    return (String(data: outputData, encoding: .utf8)!)
}
