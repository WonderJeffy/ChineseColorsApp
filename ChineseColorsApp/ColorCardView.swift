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
    let colorInfo: ColorModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {  // 移除 Vstack 内部间距以使颜色块填充顶部
            // 显示颜色本身的矩形
            Rectangle()
                .fill(colorInfo.swiftUIColor)
                .frame(height: 100)  // 固定颜色块高度

            // 显示颜色信息的 VStack
            VStack(alignment: .leading, spacing: 5) {  // 调整信息部分的间距
                Text(colorInfo.name ?? "未知名称")
                    .font(.headline)
                    .lineLimit(1)  // 限制名称为一行

                Text(colorInfo.hex ?? "#??????")
                    .font(.subheadline)
                    .foregroundColor(.secondary)  // 使用次要颜色显示十六进制值
            }
            .padding(10)  // 为文本信息添加内边距
            // 根据 fontColor 设置文本颜色，否则使用默认主颜色
            .foregroundColor(colorInfo.fontColor != nil ? colorInfo.swiftUIFontColor : .primary)
            .frame(height: 120)  // 固定信息区域高度以统一卡片大小
        }
        .background(Color(UIColor.secondarySystemBackground))  // 使用系统辅助背景色
        .cornerRadius(8)  // 圆角
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)  // 添加细微阴影
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}

