//
//  ContributionDay.swift
//  ChineseColorsApp
//
//  (\(\
//  ( -.-)
//  o_(")(")
//  -----------------------
//  Created by jeffy on 4/21/25.
//
import SwiftUI

struct ContributionDay: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
    
    // 根据贡献数量确定颜色强度
    var colorIntensity: Color {
        switch count {
        case 0:
            return Color(.systemGray6)
        case 1...4:
            return Color.green.opacity(0.3)
        case 5...9:
            return Color.green.opacity(0.5)
        case 10...14:
            return Color.green.opacity(0.7)
        default:
            return Color.green.opacity(0.9)
        }
    }
}
