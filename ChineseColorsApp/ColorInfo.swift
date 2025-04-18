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


import SwiftUI
import Foundation

// 定义颜色信息的结构体，遵循 Decodable 和 Identifiable 协议
struct ColorInfo: Decodable, Identifiable {
    let id = UUID() // 为 SwiftUI 列表提供唯一标识
    let name: String?
    let category: String? // 节气分类
    let r: Double?
    let g: Double?
    let b: Double?
    let hex: String?
    let sentence: String?
    let author: String?
    let sentenceFrom: String?
    let fontColor: String? // 字体颜色（十六进制字符串）

    // 计算属性：将 RGB 值转换为 SwiftUI 的 Color
    var swiftUIColor: Color {
        guard let r = r, let g = g, let b = b else { return .gray } // 如果 RGB 值无效，返回灰色
        return Color(red: r / 255.0, green: g / 255.0, blue: b / 255.0)
    }

    // 计算属性：将十六进制字体颜色字符串转换为 SwiftUI 的 Color
    var swiftUIFontColor: Color {
        guard let hex = fontColor else { return .primary } // 如果未指定，返回默认主颜色

        // 处理常见的 #343333 黑色字体
         if hex == "#343333" {
             return Color(red: 52/255.0, green: 51/255.0, blue: 51/255.0)
         }

        // 尝试解析其他十六进制颜色
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        let scanner = Scanner(string: hexSanitized)

        if scanner.scanHexInt64(&rgb) {
            let red = Double((rgb & 0xFF0000) >> 16) / 255.0
            let green = Double((rgb & 0x00FF00) >> 8) / 255.0
            let blue = Double(rgb & 0x0000FF) / 255.0
            return Color(red: red, green: green, blue: blue)
        } else {
            // 如果解析失败，返回默认主颜色
            return .primary
        }
    }

    // 自定义 Codable Keys 以匹配 JSON 字段
    private enum CodingKeys: String, CodingKey {
        case name, category, r, g, b, hex, sentence, author, sentenceFrom, fontColor
    }

     // 自定义解码器以优雅地处理可选字段
     init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        category = try container.decodeIfPresent(String.self, forKey: .category)
        r = try container.decodeIfPresent(Double.self, forKey: .r)
        g = try container.decodeIfPresent(Double.self, forKey: .g)
        b = try container.decodeIfPresent(Double.self, forKey: .b)
        hex = try container.decodeIfPresent(String.self, forKey: .hex)
        sentence = try container.decodeIfPresent(String.self, forKey: .sentence)
        author = try container.decodeIfPresent(String.self, forKey: .author)
        sentenceFrom = try container.decodeIfPresent(String.self, forKey: .sentenceFrom)
        fontColor = try container.decodeIfPresent(String.self, forKey: .fontColor)
    }

    // 检查这是否是一个有效的颜色条目（包含必要信息）
    var isValidColor: Bool {
        return name != nil && category != nil && r != nil && g != nil && b != nil && hex != nil
    }
}

// JSON 数据的顶层结构类型别名
typealias ColorData = [[ColorInfo]]

// 加载和解析 JSON 数据的函数
func loadColorData() -> [String: [ColorInfo]] {
    // 获取 color.json 文件的 URL
    guard let url = Bundle.main.url(forResource: "color", withExtension: "json"),
          // 读取文件数据
          let data = try? Data(contentsOf: url) else {
        fatalError("错误：无法找到或加载 color.json 文件。请确保已将其添加到项目中并包含在目标中。")
    }

    let decoder = JSONDecoder()
    // 解码 JSON 数据
    guard let jsonData = try? decoder.decode(ColorData.self, from: data) else {
         fatalError("错误：无法解码 color.json。请检查 JSON 格式是否正确。")
    }

    // 按类别（节气）分组颜色
    var groupedColors: [String: [ColorInfo]] = [:]
    for categoryArray in jsonData {
        for colorInfo in categoryArray {
            // 只添加包含有效颜色信息和类别的条目
            if colorInfo.isValidColor, let category = colorInfo.category {
                if groupedColors[category] == nil {
                    groupedColors[category] = [] // 如果类别不存在，则创建新数组
                }
                groupedColors[category]?.append(colorInfo) // 添加到对应类别的数组中
            }
        }
    }
    return groupedColors
}

// 定义节气的顺序，用于排序列表
let solarTermOrder: [String] = [
    "立春", "雨水", "驚蟄", "春分", "清明", "穀雨",
    "立夏", "小滿", "芒種", "夏至", "小暑", "大暑",
    "立秋", "處暑", "白露", "秋分", "寒露", "霜降",
    "立冬", "小雪", "大雪", "冬至", "小寒", "大寒"
]