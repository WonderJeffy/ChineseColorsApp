//
//  GitHubHeatMapView.swift
//  ChineseColorsApp
//
//  (\(\
//  ( -.-)
//  o_(")(")
//  -----------------------
//  Created by jeffy on 4/21/25.
//

import ColorfulX
import SwiftUI

struct GitHubHeatMapView: View {
    let contributions: [[ContributionDay]]
    let weekLabels = ["", "Mon", "", "Wed", "", "Fri", ""]
    let monthLabels = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 月份标签
            HStack {
                ForEach(monthLabels, id: \.self) { month in
                    Text(month)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.leading, 20)

            HStack(alignment: .top, spacing: 2) {
                // 星期标签
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(weekLabels, id: \.self) { day in
                        Text(day)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .frame(height: 10)
                    }
                }

                // 热力图
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 2) {
                        ForEach(0..<contributions.count, id: \.self) { weekIndex in
                            VStack(spacing: 2) {
                                ForEach(0..<7, id: \.self) { dayIndex in
                                    if dayIndex < contributions[weekIndex].count {
                                        let day = contributions[weekIndex][dayIndex]
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(day.colorIntensity)
                                            .frame(width: 10, height: 10)
                                            .overlay(
                                                ContributionTooltip(day: day)
                                            )
                                    } else {
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(Color.clear)
                                            .frame(width: 10, height: 10)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            // 图例
            HStack(spacing: 4) {
                Text("Less")
                    .font(.caption2)
                    .foregroundColor(.secondary)

                ForEach([0, 1, 5, 10, 15], id: \.self) { level in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(ContributionDay(date: Date(), count: level).colorIntensity)
                        .frame(width: 10, height: 10)
                }

                Text("More")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}

// 悬停提示
struct ContributionTooltip: View {
    let day: ContributionDay
    @State private var showTooltip = false

    var body: some View {
        Color.clear
            .contentShape(Rectangle())
            .onTapGesture {
                showTooltip.toggle()
            }
            .popover(isPresented: $showTooltip) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(day.date, style: .date)
                        .font(.caption)
                        .bold()

                    Text("\(day.count) contributions")
                        .font(.caption)
                }
                .padding(8)
            }
    }
}

struct GitContentView: View {
    let contributionData: [[ContributionDay]] = generateSampleData()

    var body: some View {
        ColorfulView(
            color: [.orange, .yellow, .green, .blue, .purple],
            bias: .constant(0.05),
            noise: .constant(0.5),
            frameLimit: .constant(0)
        )
        .ignoresSafeArea()
        //        GitHubHeatMapView(contributions: contributionData)
        //            .frame(maxWidth: .infinity)
        //            .background(Color(.systemBackground))
    }

    static func generateSampleData() -> [[ContributionDay]] {
        // 生成一年52周的样本数据
        var weeks: [[ContributionDay]] = []
        let calendar = Calendar.current
        let today = Date()

        for weekOffset in 0..<52 {
            var week: [ContributionDay] = []
            for dayOffset in 0..<7 {
                if let date = calendar.date(byAdding: .day, value: -((52 - weekOffset) * 7) + dayOffset, to: today) {
                    // 随机生成贡献数据
                    let count = Int.random(in: 0...20)
                    week.append(ContributionDay(date: date, count: count))
                }
            }
            weeks.append(week)
        }
        return weeks
    }
}

#Preview(body: {
    GitContentView()
})
