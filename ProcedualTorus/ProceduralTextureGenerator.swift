//
//  ProceduralTextureGenerator.swift
//  ProcedualTorus
//
//  Created by jimbook on 7/9/2025.
//

import SwiftUI
import RealityKit
import GameplayKit

enum ProceduralTextureGeneratorError: Error {
    case convertSeedFailed
    case providerCreationFailed
    case imageCreationFailed
}

struct ProceduralTextureGenerator {
    static func generate(seed: Int) throws -> TextureResource {
        let length = 1024
        let bytesPerPixel = 1
        let bitsPerComponent = 8
        
        let generator = GKARC4RandomSource()
        guard let seedData = "\(seed)".data(using: .ascii) else {
            throw ProceduralTextureGeneratorError.convertSeedFailed
        }
        generator.seed = seedData
        
        var pixels: [UInt8] = Array(repeating: 0, count: length * length)
        
        for i in 0..<pixels.count {
            pixels[i] = generator.nextUniform() < 0.5 ? 255 : 0
        }
        
        guard let provider = CGDataProvider(data: Data(pixels) as CFData) else {
            throw ProceduralTextureGeneratorError.providerCreationFailed
        }
        
        guard let cgImage = CGImage(
            width: length,
            height: length,
            bitsPerComponent: bitsPerComponent,
            bitsPerPixel: bitsPerComponent * bytesPerPixel,
            bytesPerRow: length * bytesPerPixel,
            space: CGColorSpaceCreateDeviceGray(), // Grayscale
            bitmapInfo: CGBitmapInfo(),
            provider: provider,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent
        ) else {
            throw ProceduralTextureGeneratorError.imageCreationFailed
        }
        
        return try TextureResource(image: cgImage, options: TextureResource.CreateOptions(semantic: .color))
    }
}
