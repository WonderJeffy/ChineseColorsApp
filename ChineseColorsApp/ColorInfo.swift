//
//  ColorInfo.swift
//  ChineseColorsApp
//
//  (\(\
//  ( -.-)
//  o_(")(")
//  -----------------------
//  Created by jeffy on 4/18/25.
//

import FVendors
import Foundation
import OrderedCollections
import SwiftData
import SwiftUI

@Model
final class ColorModel {
    var name: String
    var project: String?
    var category: String
    var hex: String
    var r: Double?
    var g: Double?
    var b: Double?
    var fontColor: String = ""

    init(name: String, category: String, hex: String) {
        self.name = name
        self.hex = hex
        self.category = category
    }

    var swiftUIColor: Color {
        Color.f.hex(hex)
    }

    var swiftUIFontColor: Color {
        Color.f.hex(fontColor)
    }

    var rgb: (r: Double, g: Double, b: Double)? {
        get {
            if let r = r, let g = g, let b = b {
                return (r: r, g: g, b: b)
            }
            return nil
        }
        set {
            r = newValue?.r
            g = newValue?.g
            b = newValue?.b
        }
    }
}

