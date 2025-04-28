//
//  ContentView.swift
//  ChineseColorsApp
//
//  (\(\
//  ( -.-)
//  o_(")(")
//  -----------------------
//  Created by jeffy on 4/18/25.
//

import SwiftUI


// 主内容视图
struct ContentView: View {
    // 加载并按类别分组颜色数据
    let groupedColors: [String: [ColorInfo]] = loadColorData()

    // 搜索文本状态
    @State private var searchText: String = ""

    // 根据节气顺序获取排序后的类别键
    var sortedCategories: [String] {
        groupedColors.keys.sorted { key1, key2 in
            // 查找类别在预定义顺序中的索引
            guard let index1 = solarTermOrder.firstIndex(of: key1),
                  let index2 = solarTermOrder.firstIndex(of: key2) else {
                // 如果某个类别不在预定义顺序中，将其排在后面
                return solarTermOrder.contains(key1)
            }
            return index1 < index2 // 按索引排序
        }
    }

    // 搜索过滤逻辑
    var filteredColors: [ColorInfo] {
        groupedColors.values.flatMap { $0 }.filter { colorInfo in
            searchText.isEmpty || (colorInfo.name?.contains(searchText) ?? false)
        }
    }

    // 定义网格布局：自适应列宽，最小宽度 160
    let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 160), spacing: 15) // 调整最小宽度和间距
    ]

    var body: some View {
        NavigationView {
            VStack {
                // 搜索栏
                TextField("搜索颜色名称", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                ScrollView { // 使用 ScrollView 包含 LazyVGrid
                    LazyVGrid(columns: columns, spacing: 15) { // 网格视图显示所有颜色
                        ForEach(sortedCategories, id: \.self) { category in
                            NavigationLink(destination: CategoryDetailView(category: category, colors: groupedColors[category] ?? [])) {
                                VStack(alignment: .leading) {
                                    Text(category)
                                        .font(.headline)
                                        .padding(.bottom, 5)

                                    // 显示颜色小格子
                                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 10))], spacing: 5) {
                                        ForEach(groupedColors[category] ?? []) { colorInfo in
                                            Rectangle()
                                                .fill(colorInfo.swiftUIColor)
                                                .frame(width: 10, height: 10)
                                        }
                                    }
                                }
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.horizontal) // 给网格添加水平内边距
                }
            }
            .navigationTitle("中国传统色") // 设置导航栏标题
        }
        // 在 iPad 上使用堆叠导航样式，避免分栏视图
        .navigationViewStyle(StackNavigationViewStyle())
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}

#Preview {
    ContentView()
}
