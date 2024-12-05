//
//  SwiftUIView.swift
//  marchingCubes
//
//  Created by 温嘉宝 on 04.12.2024.
//

import SwiftUI

struct DivisionSliderView: View {
    @Binding var division: Double
    @Binding var selectedScheme: ColorScheme
    var onDismiss: () -> Void
    
    var body: some View {
        VStack {
            Text("Choose Divisions")
                .font(.headline)
                .padding()
            
            Picker("Color Scheme", selection: $selectedScheme) {
                Image("color_scheme_1")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .tag(ColorScheme.scheme1)
                
                Image("color_scheme_2")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .tag(ColorScheme.scheme2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            Slider(value: $division, in: 1...25, step: 1)
                .padding()
            
            Text("Divisions: \(Int(division))")
                .font(.subheadline)
                .padding()
            
            Button("Done") {
                onDismiss()
            }
            .padding()
        }
        .presentationDetents([.medium, .fraction(0.3)])
    }
}
