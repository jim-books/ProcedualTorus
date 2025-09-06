//
//  ContentView.swift
//  ProcedualTorus
//
//  Created by jimbook on 4/9/2025.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    @State private var seed: Int = 0
    
    var body: some View {
        HStack {
            EntityView(seed: seed)
            
            Divider ()
            
            Button("Regenerate") {
                seed += 1
            }
            .padding()
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
