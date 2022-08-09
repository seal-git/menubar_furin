//
//  Furin.swift
//  Rin-Suzukaze
//
//  Copyright © 2022 Yafu Glass. All rights reserved.
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
    private let m: Double = 0.004// kg
    
    // 短冊
    private let width: Double = 0.035 // m
    private let height: Double = 0.18 // m
    
    // 傘
    private let e: Double = 0.94 //
    private let thetaEdge: Double = 0.3 // rad

    // 風鈴の状態
    private var theta: Double = 0.1
    private var v: Double = 0.0
    private var currentTime = Date()
    
    // 抵抗係数
    private func cx(_ alpha: Double) -> Double {
        return 1.0221 * pow(fabs(cos(alpha)) * width / height, -0.1063)
    }

    private func tNewton(t0: Double, x: Double, a: Double, k: Double, c1: Double, c2: Double) -> Double {
        let c3 = -k / m
        let c4 = -c1 * m / k
        let c5 = m * a / k
        let c6 = c2 - x

        var ti = t0
        for _ in 0..<32 {
            let expc3t = exp(c3*ti)
            let xt = c4 * expc3t + c5 * ti + c6
            let vt = c1 * expc3t + c5
            ti = ti - Double(xt / vt)
        }
        return ti
    }
    
    
    private let furinSound = FurinSound()

    func proceed(windSpeed: Double){
        let dt = Date().timeIntervalSince(currentTime)

        // 短冊の角度
        let alpha = Double.random(in: 0 ..< Double.pi)

        // 短冊の面積
        let s = width * height * fabs(cos(alpha))

        // 加速度
        let k = rho * cx(alpha) * s * cos(theta) 
        let a = windSpeed * k / m - g * sin(theta)

        // 次の状態
        let c1 = v - m * a / k
        let c2 = theta + m * c1 / k
        let c1exp = c1 * exp(-k * dt / m)
        var vNew =  m * a / k + c1exp
        var thetaNew = c2 + m * a * dt / k - m / k * c1exp
        // 傘に当たらなかった場合は状態を更新して終了
        if thetaEdge > thetaNew && thetaNew > -thetaEdge {
            updateStaus(thetaNew, vNew, Date())
            return
        }

        // 当たり判定
        var c1Prev = c1
        var c2Prev = c2
        var c1expPrev = c1exp
        var dtPrev = dt
        var thetaPrev = theta
        var vPrev = v
        var hitList: [Hit] = []
        while((thetaNew >= thetaEdge || thetaNew <= -thetaEdge)){
            
            var t0 = (sqrt(vPrev * vPrev + 2 * a * (thetaEdge - thetaPrev)) - vPrev) / a
            if thetaNew <= -thetaEdge {
                t0 = (-sqrt(vPrev * vPrev + 2 * a * (-thetaEdge - thetaPrev)) - vPrev) / a
            }
            let tBefore = tNewton(t0:t0, x:thetaPrev, a:a, k:k, c1:c1Prev, c2:c2Prev) // 傘に当たるまでの時間
            let vEdgeBefore = m * a / k + c1expPrev // 傘に当たる直前の速度
            hitList.append(Hit(dt: tBefore, v: vEdgeBefore))
            
            dtPrev = dtPrev - tBefore; // 傘に当たった後の時間
            vPrev = -e * vEdgeBefore // 傘に当たった直後の速度
            thetaPrev = thetaEdge

            c1Prev = vPrev - m * a / k
            c2Prev = thetaPrev + m * c1Prev / k
            c1expPrev = c1Prev * exp(-k * dtPrev / m)
            vNew =  m * a / k + c1expPrev
            thetaNew = c2Prev + m * a * dtPrev / k - m / k * c1expPrev
            
            if hitList.count > 5 {
                thetaNew = thetaEdge
                vNew = vPrev
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

