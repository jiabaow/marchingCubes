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
            Text("Choose Configuration")
                .font(.headline)
                .padding()
            
            Picker("Color Scheme", selection: $selectedScheme) {
                Text("Scheme 1")
                    .tag(ColorScheme.scheme1)
                
                Text("Scheme 2")
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

struct DivisionSliderView_Previews: PreviewProvider {
    @State static private var division: Double = 5.0
    @State static private var colorScheme: ColorScheme = .scheme1
    
    static var previews: some View {
        DivisionSliderView(
            division: $division,
            selectedScheme: $colorScheme,
            onDismiss: {
                print("Dismissed")
            }
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
