//
//  DrawableQueueComponent.swift
//  ProcedualTorus
//
//  Created by jimbook on 9/9/2025.
//

import SwiftUI
import RealityKit

struct DrawableQueueComponent: Component {
    var texture: TextureResource
    
    var mtlTextureRead: MTLTexture
    var mtlTextureWrite: MTLTexture

    let mtlCommandQueue: MTLCommandQueue
    
    let pipeState: MTLComputePipelineState

    var time: TimeInterval = 0

    init(texture: TextureResource) throws {
        DrawableQueueSystem.registerSystem()

        self.texture = texture

        guard let mtlDevice = MTLCreateSystemDefaultDevice() else {
            throw DrawableComponentError.deviceCreationFailed
        }
        
        let desc = MTLTextureDescriptor()
        desc.width = texture.width
        desc.height = texture.height
        desc.pixelFormat = .r16Float

        desc.usage = [.shaderRead]
        self.mtlTextureRead = mtlDevice.makeTexture(descriptor: desc)!
        desc.usage = [.shaderWrite]
        self.mtlTextureWrite = mtlDevice.makeTexture(descriptor: desc)!

        try texture.copy(to: mtlTextureWrite)

        let queueDesc = TextureResource.DrawableQueue.Descriptor(
            pixelFormat: .rgba16Float,
            width: texture.width,
            height: texture.height,
            usage: [.shaderRead, .shaderWrite],
            mipmapsMode: .none
        )

        guard let queue = try? TextureResource.DrawableQueue(queueDesc) else {
            throw DrawableComponentError.queueCreationFailed
        }
        texture.replace(withDrawables: queue)

        let shaderFunctionName: String = "textureShader"

        guard let library = mtlDevice.makeDefaultLibrary(), let function = library.makeFunction(name: shaderFunctionName) else {
            throw DrawableComponentError.shaderFunctionCreationFailed
        }
        self.pipeState = try mtlDevice.makeComputePipelineState(function: function)

        guard let newQueue = mtlDevice.makeCommandQueue() else {
            throw DrawableComponentError.commandQueueCreationFailed
        }
        self.mtlCommandQueue = newQueue
    }

    mutating func update(deltaTime: TimeInterval) {
        // Increment the value of time with amount of time.
        time += deltaTime
        
        guard let drawable = try? texture.drawableQueue?.nextDrawable(),
            let commandBuffer = mtlCommandQueue.makeCommandBuffer() else {
            return
        }

        let blit = commandBuffer.makeBlitCommandEncoder()!
        blit.copy(from: mtlTextureWrite, to: mtlTextureRead)
        blit.endEncoding()

        let encoder = commandBuffer.makeComputeCommandEncoder()!

        encoder.setComputePipelineState(pipeState)
        
        var timeArg: Float = Float(time)
        
        encoder.setBytes(&timeArg, length: MemoryLayout<Float>.stride, index: 0)
        encoder.setTexture(mtlTextureRead, index: 0)
        encoder.setTexture(mtlTextureWrite, index: 1)
        encoder.setTexture(drawable.texture, index: 2)

        let threadGroupCount = MTLSizeMake(8, 8, 1)
        
        let threadGroups = MTLSizeMake(
            texture.width / threadGroupCount.width,
            texture.height / threadGroupCount.height,
            1
        )
        
        encoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupCount)
        
        encoder.endEncoding()

        commandBuffer.commit()
        
        drawable.present()
    }
}

enum DrawableComponentError: Error {
    case deviceCreationFailed
    /// The `Metal` texture creation fails.
    case textureCreationFailed
    /// The drawable queue creation fails.
    case queueCreationFailed
    /// The shader function creation fails.
    case shaderFunctionCreationFailed
    /// The pipline state creation fails.
    case pipelineStateCreationFailed
    /// The command queue creation fails.
    case commandQueueCreationFailed
}
