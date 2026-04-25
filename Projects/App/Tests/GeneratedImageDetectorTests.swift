import Testing
import UIKit
@testable import App

struct GeneratedImageDetectorTests {
    @Test
    func isLikelySameImageData_whenEncodingDiffers_returnsTrue() {
        let image = makePatternImage(isFlipped: false)
        let pngData = image.pngData()
        let jpegData = image.jpegData(compressionQuality: 0.6)

        let result = GeneratedImageDetector.isLikelySameImageData(pngData, jpegData)

        #expect(result)
    }

    @Test
    func isGeneratedImage_whenDifferentImage_returnsFalse() {
        let generated = makePatternImage(isFlipped: false).pngData()
        let manual = makePatternImage(isFlipped: true).pngData()

        let result = GeneratedImageDetector.isGeneratedImage(
            currentImageData: manual,
            generatedImageData: generated
        )

        #expect(!result)
    }

    @Test
    func isGeneratedImage_whenCurrentMatchesGeneratedVisually_returnsTrue() {
        let baseImage = makePatternImage(isFlipped: false)
        let generated = baseImage.pngData()
        let rewritten = baseImage.jpegData(compressionQuality: 0.7)

        let result = GeneratedImageDetector.isGeneratedImage(
            currentImageData: rewritten,
            generatedImageData: generated
        )

        #expect(result)
    }

    private func makePatternImage(isFlipped: Bool, size: CGSize = CGSize(width: 64, height: 64)) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.black.setFill()
            context.cgContext.fill(CGRect(origin: .zero, size: size))

            UIColor.white.setFill()
            if isFlipped {
                context.cgContext.fill(CGRect(x: size.width / 2, y: 0, width: size.width / 2, height: size.height))
            } else {
                context.cgContext.fill(CGRect(x: 0, y: 0, width: size.width / 2, height: size.height))
            }
        }
    }
}

