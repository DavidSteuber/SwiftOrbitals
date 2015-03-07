//
//  main.swift
//  SwiftOrbitals
//
//  Created by David Steuber on 3/2/15.
//  Copyright (c) 2015 David Steuber. All rights reserved.
//
//  Partial transliteration of Orbitals C program with threading and
//  Complex number partial implimentation added.
//
//  Image drawing is performed by Bitmap instead of Targa code

import Foundation

//  Evil global constants
let PIXELS = 2880
let MAX_ITERATIONS = 4000

//  Evil global variables
var gMap = [Int](count: PIXELS * PIXELS, repeatedValue: 0)
var gMArray = [Double](count: PIXELS, repeatedValue: 0.0)
var gMaxHits = 0

// Worker functions

func initGMarray() {
        for i in 0 ..< PIXELS {
            gMArray[i] = Double(i) * 4.0 / Double(PIXELS) - 2.0
        }
}

func indexForDouble(x: Double) -> Int {
    return max(min(Int(0.25 * (x + 2.0) * Double(PIXELS)), PIXELS - 1), 0)
}

func incrementGMap(ca:[Complex]) {
    for c in ca {
        let x = indexForDouble(c.r)
        let y = indexForDouble(c.i)
        gMap[PIXELS * y + x]++
        let m = gMap[PIXELS * y + x]
        if m > gMaxHits {gMaxHits = m}
    }
}

func computePixel(a:Int, b:Int) -> (Int, [Complex]) {
    let c = Complex(a: gMArray[a], b: gMArray[b])
    var z = Complex()
    var cVec = [Complex]()

    for i in 1 ... MAX_ITERATIONS {
        z = z * z + c
        if z > 2.0 {
            return (0, cVec)
        }
        cVec.append(z)
    }

    return (1, cVec)
}

func drawImage() {
    let multiplier = 255.0 / log(Double(gMaxHits))
    let normalizedMap = gMap.map(){return Int($0 < 1 ? 0:log(Double($0)) * multiplier)}
    var image = Bitmap(width: PIXELS, height: PIXELS)
    var index = 0
    for v in normalizedMap {
        image.data[index++] = 0
        image.data[index++] = UInt8(min(v, 255))
        image.data[index++] = 0
        index++
    }
    image.saveImage("/Users/david/Desktop/orbitals.png", type: "PNG")
}

func main() {
    initGMarray()
    for y in 0 ..< PIXELS {
        threads.runOnComputationThread() {
            threads.runOnSerialThread(){println("Line: \(y)")}
            for x in 0 ..< PIXELS {
                let (r, cVec) = computePixel(x, y)
                if r == 1 {
                    threads.runOnSerialThread() {
                        incrementGMap(cVec)
                    }
                }
            }
        }
    }
    threads.waitAll()
    drawImage()
    println("Done!")
    exit(0)
}

threads.runOnMainThread(main)
threads.run()





























