//
//  ContentView.swift
//  marchingCubes
//
//  Created by 温嘉宝 on 22.10.2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Dashboard()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
//            MarchingCubesView()
//                .tabItem {
//                    Label("Test", systemImage: "person.fill")
//                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
