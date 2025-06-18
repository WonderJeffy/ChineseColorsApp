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
    @StateObject private var store = ColorDataStore()
    @State private var searchText: String = ""
    @State private var showingDataSourcePicker = false

    // 搜索过滤逻辑
    var filteredCategories: [String] {
        if searchText.isEmpty {
            return store.sortedCategories
        } else {
            return store.sortedCategories.filter { category in
                let colorsInCategory = store.colorDict[category] ?? []
                return colorsInCategory.contains { color in
                    color.name.contains(searchText)
                }
            }
        }
    }
    
    // 搜索到的单个颜色
    var filteredColors: [ColorModel] {
        if searchText.isEmpty {
            return []
        } else {
            var allColors: [ColorModel] = []
            for category in store.sortedCategories {
                let colorsInCategory = store.colorDict[category] ?? []
                let matchingColors = colorsInCategory.filter { color in
                    color.name.contains(searchText)
                }
                allColors.append(contentsOf: matchingColors)
            }
            return allColors
        }
    }

    // 定义网格布局：自适应列宽，最小宽度 160
    let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 160), spacing: 15)
    ]

    var body: some View {
        NavigationView {
            VStack {
                if store.isLoading {
                    ProgressView("加载中...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack {
                            // 搜索栏
                            TextField("搜索颜色名称", text: $searchText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)
                        }
                        LazyVGrid(columns: columns, spacing: 15) {
                            if searchText.isEmpty {
                                // 显示分组
                                ForEach(filteredCategories, id: \.self) { category in
                                    NavigationLink(
                                        destination: CategoryDetailView(
                                            category: category,
                                            colors: store.colorDict[category] ?? []
                                        )
                                    ) {
                                        VStack(alignment: .leading) {
                                            Text(category)
                                                .font(.headline)
                                                .padding(.bottom, 5)

                                            // 显示颜色小格子
                                            LazyVGrid(
                                                columns: [GridItem(.adaptive(minimum: 10))],
                                                spacing: 5
                                            ) {
                                                ForEach(store.colorDict[category] ?? [], id: \.name) {
                                                    colorInfo in
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
                            } else {
                                // 显示搜索到的单个颜色
                                ForEach(filteredColors, id: \.name) { color in
                                    ColorCardView(colorInfo: color)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("中国传统色")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("切换数据源") {
                        showingDataSourcePicker = true
                    }
                    .font(.caption)
                }
            }
            .onAppear {
                Task {
                    await store.loadColors(from: store.currentDataSource)
                }
            }
            .sheet(isPresented: $showingDataSourcePicker) {
                DataSourcePickerView(store: store)
            }
        }
        
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// 数据源选择器视图
struct DataSourcePickerView: View {
    @ObservedObject var store: ColorDataStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List {
                ForEach(store.availableDataSources, id: \.self) { dataSource in
                    HStack {
                        Text(dataSource)
                        Spacer()
                        if dataSource == store.currentDataSource {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        Task {
                            await store.switchDataSource(to: dataSource)
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle("选择数据源")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
