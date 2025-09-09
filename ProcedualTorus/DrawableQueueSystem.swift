//
//  DrawableQueueSystem.swift
//  ProcedualTorus
//
//  Created by jimbook on 9/9/2025.
//

import RealityKit

struct DrawableQueueSystem: System {
    static let query = EntityQuery(where: .has(DrawableQueueComponent.self))
    
    init(scene: RealityKit.Scene) { }
    
    func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            if var comp = entity.components[DrawableQueueComponent.self] {
                comp.update(deltaTime: context.deltaTime)
                
                entity.components[DrawableQueueComponent.self] = comp
            }
        }
    }
}
