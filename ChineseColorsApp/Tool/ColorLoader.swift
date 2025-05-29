//
//  Loader.swift
//  ChineseColorsApp
//
//  (\(\
//  ( -.-)
//  o_(")(")
//  -----------------------
//  Created by jeffy on 5/29/25.
//
import OrderedCollections
import SwiftUI

enum ColorLoaderError: Error {
    case fileNotFound(String)
    case dataLoadingError(Error, String)
    case parsingFailed(String, Error?)
}

extension ColorLoader {
    static let shared = ColorLoader()

    func loadChinaColorData() {
        Task {
            do {
                let colors = try await loadColors(from: "china")
                // 使用 colors 数据
            } catch {
                print("加载颜色数据失败: \(error)")
            }
        }
    }
}

actor ColorLoader {

    func loadColors(from fileName: String) throws -> OrderedDictionary<String, [ColorModel]> {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json", subdirectory: "Color Jsons") else {
            throw ColorLoaderError.fileNotFound("Color Jsons/\(fileName).json")
        }

        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw ColorLoaderError.dataLoadingError(error, "Color Jsons/\(fileName).json")
        }

        let jsonArray: [[Any]]
        do {
            guard let parsedJson = try JSONSerialization.jsonObject(with: data) as? [[Any]] else {
                throw ColorLoaderError.parsingFailed("\(fileName).json", nil)
            }
            jsonArray = parsedJson
        } catch {
            throw ColorLoaderError.parsingFailed("\(fileName).json", error)
        }

        var result = OrderedDictionary<String, [ColorModel]>()

        for categoryArray in jsonArray {
            for item in categoryArray {
                if let colorDict = item as? [String: Any],
                   let name = colorDict["name"] as? String,
                   let categoryName = colorDict["category"] as? String,
                   let hex = colorDict["hex"] as? String
                {
                    let model = ColorModel(name: name, category: categoryName, hex: hex)

                    if let r = colorDict["r"] as? Double,
                       let g = colorDict["g"] as? Double,
                       let b = colorDict["b"] as? Double
                    {
                        model.r = r
                        model.g = g
                        model.b = b
                    } else {
                        let hexColor = Color.f.hex(hex)
                        if let components = hexColor.cgColor?.components, components.count >= 3 {
                            model.r = Double(components[0])
                            model.g = Double(components[1])
                            model.b = Double(components[2])
                        } else {
                            model.r = 0; model.g = 0; model.b = 0; // 转换失败的回退
                        }
                    }
                    model.fontColor = colorDict["fontColor"] as? String ?? ""

                    if result[categoryName] == nil {
                        result[categoryName] = []
                    }
                    result[categoryName]?.append(model)
                }
            }
        }
        // 示例：如果使用缓存
        // cache[fileName] = result
        return result
    }
}
