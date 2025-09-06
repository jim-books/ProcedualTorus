//
//  EntityView.swift
//  ProcedualTorus
//
//  Created by jimbook on 7/9/2025.
//

import SwiftUI
import RealityKit

struct EntityView: View {
    var body: some View {
        RealityView { content in
            do {
                let entity = try await ModelEntity(named: "Torus")
                content.add(entity)
        
            } catch {
                print ("Error loading model: \(error)")
            }
        }
    }
}

#Preview {
    EntityView()
}
