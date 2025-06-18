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

class ColorDataStore: ObservableObject {
    @Published var colorDict = OrderedDictionary<String, [ColorModel]>()
    @Published var currentDataSource: String = "china"
    @Published var availableDataSources: [String] = ["china"]  // 可扩展其他数据源
    @Published var isLoading: Bool = false
    
    // 根据节气顺序获取排序后的类别键
    var sortedCategories: [String] {
        colorDict.keys.elements
    }
    
    init() {
        // 在初始化时设置默认值，通过外部调用来加载数据
    }
    
    @MainActor
    func loadColors(from fileName: String) async {
        isLoading = true
        do {
            let dict = try ColorLoader.loadColors(from: fileName)
            colorDict = dict
            currentDataSource = fileName
        } catch {
            print("加载颜色数据失败: \(error)")
        }
        isLoading = false
    }
    
    @MainActor
    func switchDataSource(to fileName: String) async {
        guard fileName != currentDataSource else { return }
        await loadColors(from: fileName)
    }
}

enum ColorLoaderError: Error {
    case fileNotFound(String)
    case dataLoadingError(Error, String)
    case parsingFailed(String, Error?)
}

struct ColorLoader {
    static func loadColors(from fileName: String) throws -> OrderedDictionary<String, [ColorModel]> {
        // 首先尝试在 Color Jsons 子目录中查找
        guard
            let url = Bundle.main.url(forResource: fileName, withExtension: "json", subdirectory: "ColorJsons")
                ?? Bundle.main.url(forResource: fileName, withExtension: "json")
        else {
            // 调试信息：打印 Bundle 中的所有路径
            if let bundlePath = Bundle.main.resourcePath {
                print("Bundle 资源路径: \(bundlePath)")
                do {
                    let contents = try FileManager.default.contentsOfDirectory(atPath: bundlePath)
                    print("Bundle 内容: \(contents)")
                } catch {
                    print("无法读取 Bundle 内容: \(error)")
                }
            }
            throw ColorLoaderError.fileNotFound("找不到 \(fileName).json 文件")
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
                            model.r = 0
                            model.g = 0
                            model.b = 0  // 转换失败的回退
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
        return result
    }
}
