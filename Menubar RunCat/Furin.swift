//
//  Furin.swift
//  Menubar RunCat
//
//  Created by Takumi Nakai on 2022/08/06.
//  Copyright © 2022 Takuto Nakamura. All rights reserved.
//

import Foundation
import Cocoa

 
class Furin {
    
    // 値の参照を簡略にするためシングルトン化
    static let shared = Furin()
    private init() {}
    
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    // 物理定数
    private let rho: Double = 1.225 // kg/m^3
    private let g: Double = 9.8 // m/s^2

    // 風鈴
    private let m: Double = 0.008// kg
    
    // 短冊
    private let width: Double = 0.035 // m
    private let height: Double = 0.18 // m
    
    // 傘
    private let e: Double = 0.94 //
    private let thetaEdge: Double = 0.5 // rad

    // 風鈴の状態
    private var theta: Double = 0.0
    private var v: Double = 0.0
    private var currentTime = Date()
    
    // 抵抗係数
    private func cx(_ alpha: Double) -> Double {
        return 1.0221 * pow(fabs(cos(alpha)) * width / height, -0.1063)
    }
    
    
    private let furinSound = FurinSound()

    func proceed(windSpeed: Double){
        let dt = Date().timeIntervalSince(currentTime)

        // 短冊の角度
        let alpha = Double.random(in: 0 ..< Double.pi)

        // 短冊の面積
        let s = width * height * fabs(cos(alpha))

        // 加速度
        let a = (windSpeed * windSpeed * rho * s * cx(alpha) * cos(theta) * 0.5 / m - g * sin(theta)) - 100 * s * cx(alpha) * (v - windSpeed)
        let dv = a * dt

        // 次の状態
        var thetaNew = theta + v * dt + dv * dt * 0.5
        var vNew = v + dv
        // 傘に当たらなかった場合は状態を更新して終了
        if thetaEdge > thetaNew && thetaNew > -thetaEdge {
            updateStaus(thetaNew, vNew, Date())
            return
        }

        // 当たり判定
        var dtPrev = dt
        var thetaPrev = theta
        var vPrev = v
        var hitList: [Hit] = []
        while((thetaNew >= thetaEdge || thetaNew <= -thetaEdge)){
            var vEdgeBefore = sqrt(vPrev * vPrev + 2 * a * (thetaEdge - thetaPrev)) // 傘に当たる直前の速度
            if thetaNew <= -thetaEdge {
                vEdgeBefore = -sqrt(vPrev * vPrev + 2 * a * (-thetaEdge - thetaPrev))
            }
            let tBefore = (vEdgeBefore - vPrev) / a // 傘に当たるまでの時間
            hitList.append(Hit(dt: tBefore,v: vEdgeBefore))
            
            let tAfter = dtPrev - tBefore; // 傘に当たった後の時間
            let vEdgeAfter = -e * vEdgeBefore // 傘に当たった直後の速度
            thetaNew = thetaEdge + vEdgeAfter * tAfter + a * tAfter * tAfter * 0.5
            vNew = a * tAfter + vEdgeAfter
            dtPrev = tAfter
            thetaPrev = thetaEdge
            vPrev = vEdgeAfter
            
            if hitList.count > 3 {
                thetaNew = thetaEdge
                vNew = vEdgeAfter
                break
            }
        }
        // 状態を更新
        updateStaus(thetaNew, vNew, Date())

        // 音を鳴らす
        sound(hitList)
    }
    
    private func updateStaus(_ theta:Double, _ v:Double, _ currentTime:Date) {
        self.theta = theta
        self.v = v
        self.currentTime = currentTime
        // 状態の変更を監視者に通知
        NotificationCenter.default.post(
            name: .updateFurinNotification,
            object: nil
        )
    }
    
    private func sound(_ hitList:[Hit]) {
        if hitList.isEmpty { return }
        var passedTime: Double = 0
        for hit in hitList {
            let nextSoundTime = DispatchTime.now() + passedTime + hit.getDt()
            DispatchQueue.main.asyncAfter(deadline: nextSoundTime) {
                self.furinSound.playSound(movingSpeed: hit.getV())
            }
            passedTime += hit.getDt()
        }
    }
    
    func getTheta() -> Double {
        return theta
    }
    func getThetaDescription() -> String {
        return roundDoubleValue(theta).description
    }
    func getMovingSpeedDescription() -> String {
        return roundDoubleValue(v).description
    }
    private func roundDoubleValue(_ value: Double) -> Double {
        let order: Double = 10000
        return round(value*order)/order
    }
}

fileprivate class Hit {
    private var dt: Double = 0
    private var v: Double = 0
    init(dt: Double, v:Double){
        self.dt = dt
        self.v = v
    }
    func getDt() -> Double {
        return dt
    }
    func getV() -> Double {
        return v
    }
}

