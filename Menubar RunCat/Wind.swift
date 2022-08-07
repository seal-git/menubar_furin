//
//  Wind.swift
//  Menubar RunCat
//
//  Created by 健一郎金子 on 2022/08/06.
//  Copyright © 2022 Takuto Nakamura. All rights reserved.
//


import Foundation

class Wind {
    
    let c : Double = 0.166
    let k : Double = 1.46
    let EPS : Double = pow(10,-10)
    let array : [Double] = [-1, 0, 1]
    var count : Int = 0
    var windPrev : Double = 0
    var windNew : Double = 0
    var direction : Double = 1
    
    func getWind(CPU: Double) -> (Double) { // 10回同じ風を使う
        
        if CPU.isNaN {
            return 0
        }
        if  0 < count && count < 10 {
            windNew = windPrev
            count += 1
        }
        else {
            direction = array.randomElement() ?? 0
            windNew = c * calculateAverageWind(CPU: CPU) * pow( -log(1 + EPS - Double.random(in:0...1)), 1/k) * direction
            windPrev = windNew
            count = 1
        }
        return windNew
    }
    
    func calculateAverageWind(CPU: Double) -> (Double) {
        return CPU / 20 // 風速0~5m/s
    }
}
