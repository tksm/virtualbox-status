//
//  VBoxManage.swift
//  VirtualBoxStatus
//
//  Created by tkusumi on 1/3/16.
//  Copyright © 2016 tkusumi. All rights reserved.
//

import Foundation

class VBoxManage {
    static let command = "VBoxManage"
    static let shell = "/bin/bash"

    static func listRunningVMs() -> [VirtualMachine] {
        let (terminationStatus, output) = execute(["list", "runningvms"])
        
        var results: [VirtualMachine] = []
        if terminationStatus != 0 {
            return results
        }
        
        output.enumerateLinesUsingBlock { (line, stop) -> () in
            var columns = line.componentsSeparatedByString(" ")
            if columns.count != 2 {
                // unexpected format
                return
            }
            var name = columns[0]
            name = name.stringByReplacingOccurrencesOfString("\"", withString: "")
            let uuid = columns[1]
            
            results.append(VirtualMachine(name:name, uuid:uuid))
        }
        
        return results
    }
    
    static func sendAcpiPowerButton(uuid: String) -> Int32 {
        let (terminationStatus, _) = execute(["controlvm", uuid, "acpipowerbutton"])
        return terminationStatus
    }
    
    static func execute(args: [String]) -> (terminationStatus: Int32, result: NSString){
        let argStr = args.map {(str) in "'" + str + "'"}.joinWithSeparator(" ")
        let task = NSTask()
        task.launchPath = shell
        task.arguments = ["-l", "-c", command + " " + argStr]
        let pipe = NSPipe()
        task.standardOutput = pipe
        task.launch()
        task.waitUntilExit()
        
        let outputData = pipe.fileHandleForReading.readDataToEndOfFile()
        let encoded = NSString(data:outputData, encoding:NSUTF8StringEncoding)!
        return (task.terminationStatus, encoded)
    }
}