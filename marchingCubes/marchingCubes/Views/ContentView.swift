//
//  ContentView.swift
//  marchingCubes
//
//  Created by 温嘉宝 on 22.10.2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            MyView()
                .navigationTitle("My Items")
        }
    }
}

#Preview {
    ContentView()
}
