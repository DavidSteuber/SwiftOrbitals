//
//  Complex.swift
//  SwiftOrbitals
//
//  Created by David Steuber on 3/2/15.
//  Copyright (c) 2015 David Steuber. All rights reserved.
//

import Foundation

struct Complex {
    var r = 0.0, i = 0.0

    init() {}

    init(a: Double, b: Double) {
        r = a
        i = b
    }
}

func + (left: Complex, right: Complex) -> Complex {
    return Complex(a: left.r + right.r, b: right.i + left.i)
}

func * (left: Complex, right: Complex) -> Complex {
    return Complex(a: left.r*right.r - left.i*right.i, b: left.r*right.i + left.i*right.r)
}

func > (left: Complex, right: Double) -> Bool {
    // to avoid square root operator, we will square the right arg.
    let amplitude = right * right
    let sum = left.r * left.r + left.i * left.i
    return sum > amplitude
}
