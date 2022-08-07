//
//  FurinViewController.swift
//  Menubar RunCat
//
//  Created by Takumi Nakai on 2022/08/07.
//  Copyright © 2022 Takuto Nakamura. All rights reserved.
//

import Cocoa
import AppKit

class FurinStatusViewController: NSViewController {
    // シングルトンクラスの値をUIに反映する
    private let furin: Furin = Furin.shared
    private let wind: Wind = Wind.shared
    private let cpu: CPU = CPU.shared
    
    @IBOutlet weak var thetaText: NSTextFieldCell!
    @IBOutlet weak var movingSpeedText: NSTextFieldCell!
    @IBOutlet weak var windSpeedText: NSTextFieldCell!
    @IBOutlet weak var cpuUsageText: NSTextFieldCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 値の初期化
        updateUI()
        
        // Furinクラスからの通知を監視
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateUI),
            name: .updateFurinNotification,
            object: nil
        )
    }

    @objc func updateUI(){
        thetaText.stringValue = furin.getThetaDescription()
        movingSpeedText.stringValue = furin.getMovingSpeedDescription()
        windSpeedText.stringValue = wind.getCurrentWindSpeedDescription()
        cpuUsageText.stringValue = cpu.usageCPU().value.description
    }
}
