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
        menubarAnimation.proceed()
        if !isRunning { return }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + menubarAnimation.getInterval()) {
            self.animate()
        }
    }
    
    func simulate() {
        simulation.sound()
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

fileprivate class MenubarAnimation {
    private var interval: Double = 1.0
    private var frames = [NSImage]()
    private var count: Int = 0
    func setupFrames() {
        for i in (0 ..< 5) {
            frames.append(NSImage(imageLiteralResourceName: "cat_page\(i)"))
        }
    }
    func proceed(){
        count = (count + 1)%frames.count
    }
    func getCurrentFrame() -> NSImage {
        return frames[count]
    }
    func updateInterval(cpuUsage: Double){
        self.interval = 0.02 * (100 - max(0.0, min(99.0, cpuUsage))) / 6
    }
    func getInterval() -> Double {
        return interval
    }
}

fileprivate class Simulation {
    private let interval: Double = 1.0
    private var count: Int = 0
    // private let wind = Wind()
    // private var furin = Furin()
    private var furinSound = FurinSound()
    // 風鈴の状態を進める
    func proceed(cpuUsage: Double){
        // 仮の実装
        count = (count + 1)%4
        // 本実装のイメージ
        // furin.proceed( wind.getWind(CPU: cpuUsage), interval )
    }
    // 風鈴の状態に応じて音を鳴らす
    func sound(){
        // 仮の実装
        furinSound.playSound(movingSpeed: count)
        // 本実装のイメージ
        // if furin.willSound() {
        //     furinSound.playSound(movingSpeed: furin.speed)
        // }
    }
    
    func getInterval() -> Double {
        return interval
    }
}
