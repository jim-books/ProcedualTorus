//
//  EntityView.swift
//  ProcedualTorus
//
//  Created by jimbook on 7/9/2025.
//

import SwiftUI
import RealityKit

struct EntityView: View {
    var seed: Int
    
    var body: some View {
        RealityView { content in
            do {
                let entity = try makeEntity()
                content.add(entity)
            } catch {
                print("Error creating entity: \(error)")
            }
        } update: { content in
            for entity in content.entities {
                if let modelEntitty = entity as? ModelEntity {
                    // Attempt to update each entity in scene updates.
                    try? updateEntity(modelEntitty)
                } else {
                    print("Entity is not a ModelEntity.")
                }
            }
        }
    }
    
    @MainActor
    func makeEntity() throws -> ModelEntity {
        let fileName: String = "Torus"
        
        let entity = try Entity.loadModel(named: fileName)

        entity.scale /= entity.visualBounds(relativeTo: nil).boundingRadius

        let scale: Float = 0.2
        
        entity.scale *= scale
        
        entity.transform.rotation *= simd_quatf(from: SIMD3<Float>(0, 1, 0), to: SIMD3<Float>(0, 0, 1))

        try updateEntity(entity)

        return entity
    }
    
    @MainActor
    func updateEntity(_ entity: ModelEntity) throws {
        /// The texture based on the seed values.
        let texture = try ProceduralTextureGenerator.generate(seed: seed)

        var sampler = PhysicallyBasedMaterial.Texture.Sampler()
        sampler.modify { $0.magFilter = .nearest }

        var material = PhysicallyBasedMaterial()

        let textureAndSampler = PhysicallyBasedMaterial.Texture(
            texture,
            sampler: sampler
        )
        
        material.baseColor = PhysicallyBasedMaterial.BaseColor(texture: textureAndSampler)

        entity.model?.materials = [material]

        entity.components[DrawableQueueComponent.self] = try DrawableQueueComponent(texture: texture)
    }

}


#Preview {
    EntityView(seed: 1)
}
