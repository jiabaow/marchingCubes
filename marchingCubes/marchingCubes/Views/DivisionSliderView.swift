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
            
            // Display the image based on the selected scheme
            SafeImage(imageName: selectedScheme == .scheme1 ? "color_scheme_1.jpg" : "color_scheme_2.jpg")
                .frame(width: 300, height: 30)
                .cornerRadius(5)
                .padding()
            
            Picker("Color Scheme", selection: $selectedScheme) {
                Text("Scheme 1").tag(ColorScheme.scheme1)
                Text("Scheme 2").tag(ColorScheme.scheme2)
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
    @State static private var colorScheme: ColorScheme = .scheme2
    
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

struct SafeImage: View {
    let imageName: String

    var body: some View {
        if let uiImage = UIImage(named: imageName) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
        } else {
            Color.red // Placeholder view
                .overlay(
                    Text("Image not found")
                        .foregroundColor(.white)
                        .padding()
                )
        }
    }
}
