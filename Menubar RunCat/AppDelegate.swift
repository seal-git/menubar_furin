//
//  AppDelegate.swift
//  Menubar RunCat
//
//  Created by Takuto Nakamura on 2019/08/06.
//  Copyright © 2019 Takuto Nakamura. All rights reserved.
//

import Cocoa
import AVFoundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, AVAudioPlayerDelegate {

    @IBOutlet weak var menu: NSMenu!
    
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let nc = NSWorkspace.shared.notificationCenter
    private var frames = [NSImage]()
    private var cnt: Int = 0
    private var isRunning: Bool = false
    private var interval: Double = 1.0
    private let cpu = CPU()
    private var cpuTimer: Timer? = nil
    private var usage: (value: Double, description: String) = (0.0, "")
    private var isShowUsage: Bool = false
    
    // 効果音鳴らす用のクラスのインスタンス
    var player1 =  player()
    var player2 =  player()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        for i in (0 ..< 5) {
            frames.append(NSImage(imageLiteralResourceName: "cat_page\(i)"))
        }
        statusItem.menu = menu
        statusItem.button?.imagePosition = .imageRight
        statusItem.button?.image = frames[cnt]
        cnt = (cnt + 1) % frames.count
        
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
        cpuTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: { (t) in
            self.usage = self.cpu.usageCPU()
            self.interval = 0.02 * (100 - max(0.0, min(99.0, self.usage.value))) / 6
            self.statusItem.button?.title = self.isShowUsage ? self.usage.description : ""
        })
        cpuTimer?.fire()
        isRunning = true
        animate()
    }
    
    func stopRunning() {
        isRunning = false
        cpuTimer?.invalidate()
    }

    func animate() {
        statusItem.button?.image = frames[cnt]
        cnt = (cnt + 1) % frames.count
        if (cnt % frames.count == 0){
            player1.playSound(name: "チーン")
        } else if (cnt % frames.count == 1) {
            player2.playSound(name: "チーン1")
        }
        if !isRunning { return }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + interval) {
            self.animate()
        }
    }
    
//    func furin() {
//
//    }
    
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

// 同時に音楽を再生するために、関数と変数のセットを複数作れるよう、クラスとして定義する。
class player{
    var audioPlayer: AVAudioPlayer!
    func playSound(name: String) {
        guard let path = Bundle.main.path(forResource: name, ofType: "mp3") else {
            print("音源ファイルが見つかりません")
            return
        }
        do {
            // AVAudioPlayerのインスタンス化
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            // AVAudioPlayerのデリゲートをセット
            audioPlayer.delegate = self as? AVAudioPlayerDelegate
            // 音声の再生
            audioPlayer.play()
        } catch {
        }
    }
}
