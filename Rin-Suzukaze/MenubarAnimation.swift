//
//  FurinAnimation.swift
//  Rin-Suzukaze
//
//  Copyright © 2022 Yafu Glass. All rights reserved.
//

import Foundation
import Cocoa

class MenubarAnimation {
    private var interval: Double = 0.1
    private var frames: Dictionary<String, NSImage> = [:]
    private var count: Int = 0
    private var frameName: String = "furin_1C0"
    func setupFrames() {
        for i in (1 ..< 7) {
            frames["furin_\(i)C0"] = NSImage(imageLiteralResourceName: "furin_\(i)C0")
            for j in (1 ..< 6) {
                frames["furin_\(i)L\(j)"] = NSImage(imageLiteralResourceName: "furin_\(i)L\(j)")
                frames["furin_\(i)R\(j)"] = NSImage(imageLiteralResourceName: "furin_\(i)R\(j)")
            }
        }
    }
    func proceed(theta: Double){
        count = (count + 1) % 6
        if count == 0 {count = 6}
        switch theta {
        case -100 ..< -0.4:
            frameName = "furin_\(count)L5"
        case -0.4 ..< -0.32:
            frameName = "furin_\(count)L4"
        case -0.32 ..< -0.24:
            frameName = "furin_\(count)L3"
        case -0.24 ..< -0.16:
            frameName = "furin_\(count)L2"
        case -0.16 ..< -0.08:
            frameName = "furin_\(count)L1"
        case -0.08 ..< 0.08:
            frameName = "furin_\(count)C0"
        case 0.08 ..< 0.16:
            frameName = "furin_\(count)R1"
        case 0.16 ..< 0.24:
            frameName = "furin_\(count)R2"
        case 0.24 ..< 0.32:
            frameName = "furin_\(count)R3"
        case 0.32 ..< 0.4:
            frameName = "furin_\(count)R4"
        default:
            frameName = "furin_\(count)R5"
        }
        
//        print("theta:", theta, "count:", count, "frameName:", frameName)
    }
    func getCurrentFrame() -> NSImage {
        return frames[frameName]!
    }
    func updateInterval(cpuUsage: Double){
        self.interval = 0.02 * (100 - max(0.0, min(99.0, cpuUsage))) / 6
    }
    func getInterval() -> Double {
        return 0.1
    }
}
