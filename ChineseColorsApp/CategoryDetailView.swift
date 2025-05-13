import Foundation
import SwiftUI

struct CategoryDetailView: View {
    let category: String
    let colors: [ColorModel]

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20) {
                    ForEach(colors, id: \ .id) { colorInfo in
                        VStack(alignment: .leading) {
                            Text(colorInfo.name ?? "未知颜色")
                                .font(.headline)
                            Rectangle()
                                .fill(colorInfo.swiftUIColor)
                                .frame(height: 50)
                                .cornerRadius(8)
                        }
                        .padding()
                        .background(Color.gray)
                        .cornerRadius(10)
                        .id(colorInfo.id)
                    }
                }
                .padding()
            }
            .onAppear {
                proxy.scrollTo(category, anchor: .top)
            }
        }
        .navigationTitle(category)
    }
}

#Preview {
    CategoryDetailView(category: "示例类别", colors: [])
}
