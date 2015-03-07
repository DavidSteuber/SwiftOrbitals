//
//  Bitmap.swift
//
//  Created by David Steuber on 3/2/15.
//  Copyright (c) 2015 David Steuber. All rights reserved.
//
//  A bitmap class to manage pixel level drawing using CGImage

import Foundation
import QuartzCore

struct Color {
    var red: UInt8
    var green: UInt8
    var blue: UInt8
    var alpha: UInt8

    init() {
        red = 0
        green = 0
        blue = 0
        alpha = 255
    }

    init(r: UInt8, g: UInt8, b: UInt8, a: UInt8) {
        red = r
        green = g
        blue = b
        alpha = a
    }
}

final class Bitmap {
    var width: Int
    var height: Int
    var bytesPerRow: Int
    var data = [UInt8]()

    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        bytesPerRow = width * 4
        data = [UInt8](count: Int(width * height * 4), repeatedValue: 255)
    }

    func createBitmapContext () -> CGContext! {
        return CGBitmapContextCreateWithData(UnsafeMutablePointer<Void>(data),
            width,
            height,
            8,
            4 * Int(width),
            CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB),
            CGBitmapInfo(CGImageAlphaInfo.PremultipliedLast.rawValue),
            nil, nil)
    }

    func setColorData(data: [UInt8]) {
        self.data = data
    }

    func drawRow(rowNumber: Int, rowData: [UInt8]) {
        var index = rowNumber * bytesPerRow
        for b in rowData {
            data[index++] = b
        }
    }

    func drawPixel(x: Int, y: Int, c: Color) {
        let offset = y * bytesPerRow + x * 4
        data[offset] = c.red
        data[offset + 1] = c.green
        data[offset + 2] = c.blue
        data[offset + 3] = c.alpha
    }

    func readPixel(x: Int, y: Int) -> Color {
        let offset = y * bytesPerRow + x * 4
        return Color(r: data[offset], g: data[offset + 1], b: data[offset + 2], a: data[offset + 3])
    }

    func createImage() -> CGImage! {
        return CGBitmapContextCreateImage(createBitmapContext())
    }

    func saveImage(path: String, type: String) {
        let image = createImage()
        let options: [NSString:AnyObject] = [kCGImagePropertyOrientation : 1, // top left
            kCGImagePropertyHasAlpha : true,
            kCGImageDestinationLossyCompressionQuality : 0.80]
        let url = NSURL.fileURLWithPath(path, isDirectory: false)
        var imageType = kUTTypePNG
        if type == "JPEG" {
            imageType = kUTTypeJPEG
        }
        let file = CGImageDestinationCreateWithURL(url, imageType, 1, nil)
        CGImageDestinationAddImage(file, image, options)
        CGImageDestinationFinalize(file)
    }

}