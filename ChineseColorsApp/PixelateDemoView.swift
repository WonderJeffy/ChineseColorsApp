import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins // 引入 CIFilter.pixellate() 等强类型滤镜
import PhotosUI // 引入 PhotosPicker

struct PixelateDemoView: View {
    // MARK: - State Properties
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var inputUIImage: UIImage?
    @State private var pixelatedSwiftUIImage: Image?
    @State private var blockSize: Float = 80.0 // 默认像素块大小

    // CIContext 可以复用以提高性能
    private let coreImageContext = CIContext()

    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 1. 图片选择器
                PhotosPicker(
                    selection: $selectedPhotoItem,
                    matching: .images, // 只允许选择图片
                    photoLibrary: .shared() // 使用共享照片库
                ) {
                    Label("选择图片", systemImage: "photo.on.rectangle.angled")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .onChange(of: selectedPhotoItem) { oldValue, newValue in
                    // 当选择的图片变化时，异步加载图片数据
                    Task {
                        do {
                            if let data = try await newValue?.loadTransferable(type: Data.self) {
                                inputUIImage = UIImage(data: data)
                                updatePixelatedImage() // 加载新图片后立即更新像素化效果
                            } else {
                                // 如果没有选择图片或加载失败
                                inputUIImage = nil
                                pixelatedSwiftUIImage = nil
                            }
                        } catch {
                            print("加载图片失败: \(error)")
                            inputUIImage = nil
                            pixelatedSwiftUIImage = nil
                        }
                    }
                }

                // 2. 显示原始图片
                if let uiImage = inputUIImage {
                    VStack {
                        Text("原始图片")
                            .font(.headline)
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 250)
                            .cornerRadius(8)
                            .shadow(radius: 5)
                    }
                }

                // 3. 显示像素化图片和控制滑块
                if pixelatedSwiftUIImage != nil {
                    VStack {
                        Text("像素化图片 (块大小: \(Int(blockSize)))")
                            .font(.headline)
                        pixelatedSwiftUIImage!
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 250)
                            .cornerRadius(8)
                            .shadow(radius: 5)
                    }

                    VStack {
                        Text("调整像素块大小:")
                        Slider(value: $blockSize, in: 160...1600, step: 80) {
                            // Slider 的标签，可选
                        }
                        .padding(.horizontal)
                        .onChange(of: blockSize) { oldValue, newValue in
                            // 当滑块值变化时，更新像素化效果
                            updatePixelatedImage()
                        }
                    }
                } else if inputUIImage != nil {
                    // 如果有输入图片但像素化图片还未生成（例如正在处理或失败）
                    ProgressView("正在处理...")
                }


                Spacer() // 将内容推向顶部
            }
            .padding()
            .navigationTitle("图片像素化演示")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Helper Methods

    /// 更新像素化后的 SwiftUI Image
    private func updatePixelatedImage() {
        guard let currentUIImage = inputUIImage else {
            pixelatedSwiftUIImage = nil
            return
        }
        // 调用核心的像素化逻辑
        pixelatedSwiftUIImage = generatePixelatedImage(from: currentUIImage, currentBlockSize: blockSize)
    }

    /// 使用 CIPixellate 滤镜生成像素化图片
    /// - Parameters:
    ///   - uiImage: 原始 UIImage.
    ///   - currentBlockSize: 像素块的边长 (对应 CIPixellate 的 'scale' 参数).
    /// - Returns: 像素化后的 SwiftUI Image，如果失败则返回 nil.
    private func generatePixelatedImage(from uiImage: UIImage, currentBlockSize: Float) -> Image? {
        // 1. UIImage -> CIImage
        guard let ciImage = CIImage(image: uiImage) else {
            print("无法将 UIImage 转换为 CIImage")
            return nil
        }

        // 2. 创建并配置 CIPixellate 滤镜
        let filter = CIFilter.pixellate() // 使用强类型 API
        filter.inputImage = ciImage
        filter.scale = currentBlockSize // 'scale' 参数控制像素块的大小

        // 注意: CIPixellate 还有一个 'center' 参数，默认为 (150, 150)。
        // 对于全图像素化，通常不需要修改它，滤镜会基于 scale 应用于整个图像。
        // 如果效果不理想，可以尝试设置为图像中心:
        // filter.center = CIVector(x: ciImage.extent.midX, y: ciImage.extent.midY)

        // 3. 获取输出 CIImage
        guard let outputCIImage = filter.outputImage else {
            print("CIPixellate 滤镜处理失败，无法获取 outputImage")
            return nil
        }

        // 4. CIImage -> CGImage -> UIImage -> SwiftUI Image
        // 确保从 outputCIImage 的正确范围创建 CGImage
        if let cgImage = coreImageContext.createCGImage(outputCIImage, from: outputCIImage.extent) {
            // 创建 UIImage 时保留原始图像的缩放比例和方向
            let resultUIImage = UIImage(cgImage: cgImage, scale: uiImage.scale, orientation: uiImage.imageOrientation)
            return Image(uiImage: resultUIImage)
        } else {
            print("无法从 CIImage 创建 CGImage")
            return nil
        }
    }
}

// MARK: - Preview
// 你可以在 Xcode 的预览画布中看到这个视图的效果
#Preview {
    PixelateDemoView()
}
