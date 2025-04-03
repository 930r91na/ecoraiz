import UIKit
import Vision
import CoreML

class ImageProcessingHelper {
    static let shared = ImageProcessingHelper()
    
    /// Resize and crop an image to prepare it for CoreML processing
    /// - Parameters:
    ///   - image: The original UIImage
    ///   - targetSize: The desired output size
    /// - Returns: A resized and center-cropped UIImage
    func prepareImageForClassification(_ image: UIImage, targetSize: CGSize = CGSize(width: 224, height: 224)) -> UIImage? {
        // First, resize the image to match the target dimensions while maintaining aspect ratio
        let size = image.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Use the smaller ratio to ensure the image fits within the target size
        var newSize: CGSize
        if widthRatio < heightRatio {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        } else {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        }
        
        // Create a new context with the proper size
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let resized = resizedImage else { return nil }
        
        // Now center crop to exact target size if needed
        if resized.size.width != targetSize.width || resized.size.height != targetSize.height {
            let xOffset = (resized.size.width - targetSize.width) / 2.0
            let yOffset = (resized.size.height - targetSize.height) / 2.0
            
            let cropRect = CGRect(x: xOffset, y: yOffset, width: targetSize.width, height: targetSize.height)
            
            if let cgImage = resized.cgImage?.cropping(to: cropRect) {
                return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
            }
        }
        
        return resized
    }
    
    /// Normalize pixel values from 0-255 to normalized range (typically 0-1 or -1 to 1)
    /// - Parameters:
    ///   - image: Input UIImage
    ///   - meanRGB: RGB mean values to subtract (for models trained with specific normalization)
    ///   - standardDeviation: Standard deviation values for normalization
    /// - Returns: CVPixelBuffer ready for CoreML
    func normalizeImage(_ image: UIImage, meanRGB: (r: Float, g: Float, b: Float)? = nil, standardDeviation: Float = 255.0) -> CVPixelBuffer? {
        // First prepare the image
        guard let preparedImage = prepareImageForClassification(image) else { return nil }
        
        // Convert to pixel buffer
        var pixelBuffer: CVPixelBuffer?
        let width = Int(preparedImage.size.width)
        let height = Int(preparedImage.size.height)
        
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                        width, height,
                                        kCVPixelFormatType_32ARGB,
                                        attrs,
                                        &pixelBuffer)
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else { return nil }
        
        CVPixelBufferLockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
        let context = CGContext(data: CVPixelBufferGetBaseAddress(buffer),
                                width: width, height: height,
                                bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                                space: CGColorSpaceCreateDeviceRGB(),
                                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.draw(preparedImage.cgImage!, in: CGRect(x: 0, y: 0, width: width, height: height))
        CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
        
        // Apply normalization if needed
        if let means = meanRGB {
            CVPixelBufferLockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
            
            guard let baseAddress = CVPixelBufferGetBaseAddress(buffer) else {
                CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
                return buffer
            }
            
            let bytesPerRow = CVPixelBufferGetBytesPerRow(buffer)
            let bufferHeight = CVPixelBufferGetHeight(buffer)
            
            for y in 0..<bufferHeight {
                var pixel = baseAddress.advanced(by: y * bytesPerRow).bindMemory(to: UInt32.self, capacity: width)
                for _ in 0..<width {
                    var rgba = pixel.pointee
                    
                    let r = Float(rgba & 0xFF) - means.r
                    let g = Float((rgba >> 8) & 0xFF) - means.g
                    let b = Float((rgba >> 16) & 0xFF) - means.b
                    
                    let normalizedR = max(0, min(255, r)) / standardDeviation
                    let normalizedG = max(0, min(255, g)) / standardDeviation
                    let normalizedB = max(0, min(255, b)) / standardDeviation
                    
                    rgba = (UInt32(normalizedB * standardDeviation) << 16) |
                           (UInt32(normalizedG * standardDeviation) << 8) |
                           UInt32(normalizedR * standardDeviation)
                    
                    pixel.pointee = rgba
                    pixel = pixel.advanced(by: 1)
                }
            }
            
            CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
        }
        
        return buffer
    }
    
    /// Extract top predictions from Vision classification results
    /// - Parameters:
    ///   - results: Array of VNClassificationObservation from Vision request
    ///   - topK: Number of top results to return
    ///   - threshold: Minimum confidence threshold (0-1)
    /// - Returns: Array of tuples with class name and confidence
    func extractTopPredictions(from results: [VNClassificationObservation],
                               topK: Int = 3,
                               threshold: Float = 0.1) -> [(String, Float)] {
        let filtered = results.filter { $0.confidence >= threshold }
        let sorted = filtered.sorted { $0.confidence > $1.confidence }
        let topResults = Array(sorted.prefix(topK))
        
        return topResults.map { ($0.identifier, $0.confidence) }
    }
}
