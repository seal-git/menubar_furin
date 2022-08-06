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
    let EPS : Double = pow(1,-10)
     
    func getWind(CPU: Double) -> (Double) {
        return CPU * c * pow( -log(1 + EPS - Double.random(in:0...1)), 1/k)
    }
}
