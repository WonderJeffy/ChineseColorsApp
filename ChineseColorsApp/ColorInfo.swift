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
import SwiftData
import SwiftUI

// 定义节气的顺序，用于排序列表
private(set) var solarTermOrder: [String] = []

@Model
final class ColorModel {
    var name: String
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

func loadColorJson() -> [String: [ColorModel]] {
    // 获取 color.json 文件的 URL
    guard let url = Bundle.main.url(forResource: "color", withExtension: "json"),
        // 读取文件数据
        let data = try? Data(contentsOf: url)
    else {
        fatalError("错误：无法找到或加载 color.json 文件。请确保已将其添加到项目中并包含在目标中。")
    }

    // 解析 JSON 数据
    guard let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [[Any]] else {
        fatalError("错误：无法解析 color.json 文件。")
    }

    var groupedModels: [String: [ColorModel]] = [:]
    solarTermOrder = []  // 重置节气顺序

    // 遍历嵌套数组
    for seasonArray in jsonArray {
        for item in seasonArray {
            if let colorDict = item as? [String: Any],
                let name = colorDict["name"] as? String,
                let category = colorDict["category"] as? String,
                let hex = colorDict["hex"] as? String
            {
                let model = ColorModel(name: name, category: category, hex: hex)

                // 设置 RGB 值
                if let r = colorDict["r"] as? Double,
                    let g = colorDict["g"] as? Double,
                    let b = colorDict["b"] as? Double
                {
                    model.r = r
                    model.g = g
                    model.b = b
                } else {
                    // 如果没有提供 RGB 值，则使用 hex 值计算
                    let hexColor = UIColor.f.hexString(hex)
                    model.r = hexColor?.cgColor.components?[0] ?? 0
                    model.g = hexColor?.cgColor.components?[1] ?? 0
                    model.b = hexColor?.cgColor.components?[2] ?? 0
                }

                // 设置字体颜色
                model.fontColor = colorDict["fontColor"] as? String ?? ""

                // 添加到对应类别的分组
                if groupedModels[category] == nil {
                    groupedModels[category] = []
                    solarTermOrder.append(category)
                }
                groupedModels[category]?.append(model)
            }
        }
    }

    return groupedModels
}
