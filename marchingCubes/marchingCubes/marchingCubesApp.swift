//
//  marchingCubesApp.swift
//  marchingCubes
//
//  Created by 温嘉宝 on 22.10.2024.
//

import SwiftUI
import SwiftData

@main
struct MyAppApp: App {
    @StateObject private var viewModel = ProjectViewModel()

    init() {
        // testRabbitModel()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: ProjectModel.self)
                .environmentObject(viewModel) 
        }
    }
}

