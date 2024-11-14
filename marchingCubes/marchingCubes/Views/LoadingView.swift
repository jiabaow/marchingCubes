//
//  LoadingView.swift
//  marchingCubes
//
//  Created by 温嘉宝 on 13.11.2024.
//

import SwiftUI

struct LoadingView: View {
    let filename: String

    var body: some View {
        Text("Converting \(filename) to cubes...")
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .background(Color.black.opacity(0.7))
            .cornerRadius(10)
            .transition(.opacity)
            .animation(.easeInOut, value: true)
    }
}
