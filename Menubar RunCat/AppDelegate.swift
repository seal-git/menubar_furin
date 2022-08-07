//
//  AppDelegate.swift
//  Menubar RunCat
//
//  Created by Takuto Nakamura on 2019/08/06.
//  Copyright © 2019 Takuto Nakamura. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var menu: NSMenu!
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let nc = NSWorkspace.shared.notificationCenter
    private var isRunning: Bool = false
    private let cpu = CPU()
    private var applicationTimer: Timer? = nil
    private var usage: (value: Double, description: String) = (0.0, "")
    private var isShowUsage: Bool = false
    private var menubarAnimation = MenubarAnimation()
    private var simulation = Simulation()
    
    // 風鈴の音を鳴らすだけ
    private let furinSound = FurinSound()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        menubarAnimation.setupFrames()
        statusItem.menu = menu
        statusItem.button?.imagePosition = .imageRight
        statusItem.button?.image = menubarAnimation.getCurrentFrame()
        startRunning()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        stopRunning()
    }
    
    func setNotifications() {
        nc.addObserver(self, selector: #selector(AppDelegate.receiveSleepNote),
                       name: NSWorkspace.willSleepNotification, object: nil)
        nc.addObserver(self, selector: #selector(AppDelegate.receiveWakeNote),
                       name: NSWorkspace.didWakeNotification, object: nil)
    }
    
    @objc func receiveSleepNote() {
        stopRunning()
    }
    
    @objc func receiveWakeNote() {
        startRunning()
    }
    
    func startRunning() {
        applicationTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: { (t) in
            self.usage = self.cpu.usageCPU()
            self.menubarAnimation.updateInterval(cpuUsage: self.usage.value)
            self.statusItem.button?.title = self.isShowUsage ? self.usage.description : ""
        })
        applicationTimer?.fire()
        isRunning = true
        animate()
        simulate()
    }
    
    func stopRunning() {
        isRunning = false
        applicationTimer?.invalidate()
    }

    func animate() {
        statusItem.button?.image = menubarAnimation.getCurrentFrame()
        menubarAnimation.proceed(theta: simulation.getTheta())
        if !isRunning { return }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + menubarAnimation.getInterval()) {
            self.animate()
        }
    }
    
    func simulate() {
        simulation.proceed(cpuUsage: cpu.usageCPU().value)
        if !isRunning { return }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + simulation.getInterval()) {
            self.simulate()
        }
    }
    
    @IBAction func toggleShowUsage(_ sender: NSMenuItem) {
        isShowUsage = sender.state == .off
        sender.state = isShowUsage ? .on : .off
        statusItem.button?.title = isShowUsage ? usage.description : ""
    }
    
    @IBAction func showAbout(_ sender: Any) {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.orderFrontStandardAboutPanel(nil)
    }

}

fileprivate class Simulation {
    private let interval: Double = 0.5
    private var count: Int = 0
     private let wind = Wind()
     private var furin = Furin()
    private var furinSound = FurinSound()
    private var theta: Double = 0
    // 風鈴の状態を進める
    func proceed(cpuUsage: Double){
        furin.proceed( windSpeed: 0.01 )
        theta = furin.getTheta()
    }
    func getInterval() -> Double {
        return interval
    }
    func getTheta() -> Double {
        return theta
    }
}
