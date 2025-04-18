//
//  ColorCardView.swift
//  ChineseColorsApp
//
//  (\(\
//  ( -.-)
//  o_(")(")
//  -----------------------
//  Created by jeffy on 4/18/25.
//


import SwiftUI

// 单个颜色卡片的视图
struct ColorCardView: View {
    let colorInfo: ColorInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 0) { // 移除 Vstack 内部间距以使颜色块填充顶部
            // 显示颜色本身的矩形
            Rectangle()
                .fill(colorInfo.swiftUIColor)
                .frame(height: 100) // 固定颜色块高度

            // 显示颜色信息的 VStack
            VStack(alignment: .leading, spacing: 5) { // 调整信息部分的间距
                Text(colorInfo.name ?? "未知名称")
                    .font(.headline)
                    .lineLimit(1) // 限制名称为一行

                Text(colorInfo.hex ?? "#??????")
                    .font(.subheadline)
                    .foregroundColor(.secondary) // 使用次要颜色显示十六进制值

                // 如果有句子信息，则显示
                if let sentence = colorInfo.sentence,
                   let author = colorInfo.author,
                   let from = colorInfo.sentenceFrom {
                    Divider().padding(.vertical, 3) // 添加分隔线
                    Text(sentence)
                        .font(.system(size: 13)) // 调整字体大小
                        .lineLimit(3) // 限制句子行数
                        .fixedSize(horizontal: false, vertical: true) // 允许垂直扩展

                    Spacer() // 推送作者信息到底部

                    Text("— \(author)，《\(from)》")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .trailing) // 作者信息右对齐
                        .lineLimit(1)
                } else {
                     Spacer() // 如果没有句子，也添加 Spacer 以保持布局一致
                }
            }
            .padding(10) // 为文本信息添加内边距
            // 根据 fontColor 设置文本颜色，否则使用默认主颜色
            .foregroundColor(colorInfo.fontColor != nil ? colorInfo.swiftUIFontColor : .primary)
            .frame(height: 120) // 固定信息区域高度以统一卡片大小
        }
        .background(Color(UIColor.secondarySystemBackground)) // 使用系统辅助背景色
        .cornerRadius(8) // 圆角
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2) // 添加细微阴影
    }
}

// 预览提供者
struct ColorCardView_Previews: PreviewProvider {
    // 创建一个示例 ColorInfo 用于预览
    static var sampleColorInfo: ColorInfo {
        // 手动创建一个 ColorInfo 实例用于预览，因为直接从 JSON 解码可能复杂
        // 这里需要模拟一个解码过程或直接构造
        // 注意：直接构造可能需要调整 ColorInfo 的 init 或添加一个便利构造器
        // 为了简单起见，我们假设有一个可以这样构造的 ColorInfo
         // 这是一个占位符，您需要提供一个真实的 ColorInfo 实例用于预览
         // 例如，从 loadColorData() 中获取一个
         let sampleData = loadColorData()
         return sampleData["小暑"]?.first ?? ColorInfo( // 使用一个默认的空构造器或者修改结构体
             // 提供默认值或修改结构体以允许无参数初始化（如果需要）
             // name: "示例", category: "示例", r: 100, g: 150, b: 200, hex: "#6496C8",
             // sentence: "示例句子", author: "示例作者", sentenceFrom: "示例来源", fontColor: nil
             // 由于 ColorInfo 的 init(from:) 是必须的，这里需要不同的方法
             // 最简单的方法是修改 ColorInfo 让其属性可以外部设置或添加便利构造器
             // 或者在预览中加载真实数据
             name: "柔蓝", category: "小暑", r: 16, g: 104, b: 152, hex: "#106898", sentence: "欲教魚目無分別，須學揉藍染釣絲。", author: "方乾", sentenceFrom: "贈江上老人", fontColor: nil
         )
    }

    static var previews: some View {
        ColorCardView(colorInfo: sampleColorInfo)
            .padding()
            .previewLayout(.sizeThatFits) // 调整预览布局
    }
}
// 临时的 ColorInfo 扩展，仅用于预览（如果 ColorInfo 没有默认构造器）
extension ColorInfo {
     init(name: String?, category: String?, r: Double?, g: Double?, b: Double?, hex: String?, sentence: String?, author: String?, sentenceFrom: String?, fontColor: String?) {
        self.name = name
        self.category = category
        self.r = r
        self.g = g
        self.b = b
        self.hex = hex
        self.sentence = sentence
        self.author = author
        self.sentenceFrom = sentenceFrom
        self.fontColor = fontColor
    }
}