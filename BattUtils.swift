//
//  BattUtils.swift
//  BatteryTest
//
//  Created by Pasquale Nardiello on 05/07/24.
//

import Foundation

struct BatteryInfo: Codable {
    let voltage: Int
    let currentCapacity: Int
    let maxCapacity: Int
    let designCapacity: Int
    let cycleCount: Int
    let serial: String
    var charging: Bool
    let temp: Int
}

func getBattInfo() -> [String] {
    let task = Process()
    task.launchPath = "/usr/sbin/ioreg"
    var arguments = [String]();
    arguments.append("-l")
    arguments.append("-n")
    arguments.append("AppleSmartBattery")
    arguments.append("-r")
    task.arguments = arguments
    let outpipe = Pipe()
    task.standardOutput = outpipe
    task.standardError = outpipe
    do {
        try task.run()
    } catch {
        print("error in process")
        return ["none"]
    }
    let outputData = outpipe.fileHandleForReading.readDataToEndOfFile()
    let resultInformation = String(data: outputData, encoding: .utf8)
    task.waitUntilExit()
    guard let results = resultInformation?.components(separatedBy: "\n") else { return ["none"] }
    return results
}

func getOptInfo(s : [String]) -> [String:String] {
    var bmap : [String:String] = [:]
    for i in s {
        if (i.contains("DeviceName") || i.contains("Temperature") || i.contains("CurrentCapacity") || i.contains("AppleRawCurrentCapacity") || i.contains("AppleRawBatteryVoltage") || i.contains("IsCharging") || i.contains("Serial") || i.contains("NominalChargeCapacity") || i.contains("DesignCapacity") || i.contains("Voltage") || i.contains("CycleCount") || i.contains("AppleRawMaxCapacity")) && !i.contains("IOReportLegend") && !i.contains("CarrierMode") && !i.contains("BatteryData") && !i.contains("KioskMode") && !i.contains("ChargerData") && !i.contains("FedDetails") && !i.contains("PowerTelemetryData") {
            var j = i.replacingOccurrences(of: "\"", with: "")
            j = j.replacingOccurrences(of: " ", with: "")
            let comp = j.components(separatedBy: "=")
            bmap[comp[0]] = comp[1]
        }
    }
    return bmap
}

func getBattString() -> String {
    let results : [String:String] = getOptInfo(s: getBattInfo())
    let ordkeys = results.keys.sorted()
    var s : String = ""
    for i in ordkeys {
        s = s + i + " : " + (results[i] ?? "none") + "\n"
    }
    return s
}

func saveBatteryInfo() {
    var dc = 0
    let bmap = getOptInfo(s: getBattInfo())
    let v = Int(bmap["Voltage"]!)
    let cc = Int(bmap["AppleRawCurrentCapacity"]!)
    let mc = Int(bmap["AppleRawMaxCapacity"]!)
    dc = Int(bmap["DesignCapacity"]!)!
    let ccnt = Int(bmap["CycleCount"]!)
    let sr = bmap["Serial"]
    let ic = bmap["IsCharging"]
    let t : String = bmap["Temperature"] ?? "0"
    if mc! >= dc {
        dc = mc!
    }
    var batteryInfo = BatteryInfo(voltage: v!, currentCapacity: cc!, maxCapacity: mc!, designCapacity: dc, cycleCount: ccnt!, serial: sr!, charging: false, temp: Int(String(t.prefix(2))) ?? 0)
    if ic != "No" {
        batteryInfo.charging = true
    }
    let defaults = UserDefaults(suiteName: "group.com.yourcompany.BatteryTest")
    let encoder = JSONEncoder()
    if let encoded = try? encoder.encode(batteryInfo) {
        defaults?.set(encoded, forKey: "BatteryInfo")
    }
}

func getBatteryInfo() -> BatteryInfo {
    saveBatteryInfo()
    let defaults = UserDefaults(suiteName: "group.com.yourcompany.BatteryTest")
    if let savedData = defaults?.data(forKey: "BatteryInfo") {
        let decoder = JSONDecoder()
        if let savedInfo = try? decoder.decode(BatteryInfo.self, from: savedData) {
            return savedInfo
        }
    }
    return BatteryInfo(voltage: 0, currentCapacity: 0, maxCapacity: 0, designCapacity: 0, cycleCount: 0, serial: "None", charging: false, temp: 0)
}
