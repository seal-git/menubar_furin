//
//  Wind.swift
//  Rin-Suzukaze
//
//  Copyright © 2022 Yafu Glass. All rights reserved.
//


import Foundation

class Wind {
    
    // 値の参照を簡略にするためシングルトン化
    static let shared: Wind = Wind()
    private init() {}
    
    private let c : Double = 0.166
    private let k : Double = 1.46
    private let EPS : Double = pow(10,-10)
    private let array : [Double] = [-1, 0, 1]
    private var windPrev : Double = 0
    private var windNew : Double = 0
    private var direction : Double = 1
    
    func getWind(CPU: Double) -> (Double) { // 10回同じ風を使う
        
        if CPU.isNaN {
            return windPrev
        }
        if  Double.random(in:0...1) >= 0.1 {
            windNew = windPrev
        }
        else {
            direction = array.randomElement() ?? 0
            windNew = c * calculateAverageWind(CPU: CPU) * pow( -log(1 + EPS - Double.random(in:0...1)), 1/k) * direction
            windPrev = windNew
        }
        return windNew
    }
    func getCurrentWind() -> Double {
        return windPrev
    }
    func getCurrentWindSpeedDescription() -> String {
        let order: Double = 10000
        let value: Double = round(windPrev*order)/order
        return value.description
    }
    
    private func calculateAverageWind(CPU: Double) -> (Double) {
        return CPU / 4 // 風速0~5m/s
    }
}

