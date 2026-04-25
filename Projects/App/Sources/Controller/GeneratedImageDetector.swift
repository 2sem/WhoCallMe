import UIKit

enum GeneratedImageDetector {
    private static let maxAverageHashDistance = 8

    static func isGeneratedImage(currentImageData: Data?, generatedImageData: Data?) -> Bool {
        guard let currentImageData, let generatedImageData else { return false }
        return isLikelySameImageData(currentImageData, generatedImageData)
    }

    static func isLikelySameImageData(_ lhs: Data?, _ rhs: Data?) -> Bool {
        guard let lhs, let rhs else { return false }

        if lhs == rhs {
            return true
        }

        guard
            let lhsImage = UIImage(data: lhs),
            let rhsImage = UIImage(data: rhs),
            let lhsHash = averageHash(lhsImage),
            let rhsHash = averageHash(rhsImage)
        else {
            return false
        }

        let distance = hammingDistance(lhsHash, rhsHash)
        return distance <= maxAverageHashDistance
    }

    private static func averageHash(_ image: UIImage) -> UInt64? {
        let size = CGSize(width: 8, height: 8)
        var pixels = [UInt8](repeating: 0, count: Int(size.width * size.height))
        let colorSpace = CGColorSpaceCreateDeviceGray()

        guard let cgImage = normalizedCGImage(from: image) else { return nil }
        guard let context = CGContext(
            data: &pixels,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: Int(size.width),
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        ) else {
            return nil
        }

        context.interpolationQuality = .low
        context.draw(cgImage, in: CGRect(origin: .zero, size: size))

        let average = pixels.reduce(0, { $0 + Int($1) }) / pixels.count
        var hash: UInt64 = 0

        for (index, pixel) in pixels.enumerated() where Int(pixel) >= average {
            hash |= UInt64(1) << UInt64(index)
        }

        return hash
    }

    private static func normalizedCGImage(from image: UIImage) -> CGImage? {
        if let cgImage = image.cgImage {
            return cgImage
        }

        let size = image.size
        guard size.width > 0, size.height > 0 else { return nil }

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        let normalized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        return normalized.cgImage
    }

    private static func hammingDistance(_ lhs: UInt64, _ rhs: UInt64) -> Int {
        Int((lhs ^ rhs).nonzeroBitCount)
    }
}
