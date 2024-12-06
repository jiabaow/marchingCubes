import SwiftUI
import SceneKit
import ModelIO

struct MarchingCubesView: View {
    let filename: String
    let divisions: Int
    let colorScheme: ColorScheme
    let fileURLString: String

    @StateObject private var dataLoader = VoxelDataLoader()
    @State private var isSceneLoading: Bool = true

    // Optional initializer
    init(filename: String = "rabbit", divisions: Int = 5, colorScheme: ColorScheme = .scheme2, fileURLString: String = "") {
        self.filename = filename
        self.divisions = divisions
        self.colorScheme = colorScheme
        self.fileURLString = fileURLString
        
        // Customize the appearance of the page control dots
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.primaryBlue
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.lightGray
    }
    
    var body: some View {
        ZStack {
            if dataLoader.isLoading {
                LoadingView(filename: filename)
            } else {
                TabView {
                    ScrollView {
                        VStack {
                            headerView
                            ZStack {
                                if isSceneLoading {
                                    Text("Building scene...")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.black.opacity(0.7))
                                        .cornerRadius(10)
                                        .transition(.opacity)
                                        .animation(.easeInOut, value: true)
                                }
                                SceneView(scnNodes: dataLoader.scnNodesByLayer[0],
                                          labelText: " ", backgroundColor: .lighterLightGray,
                                          onLoadingComplete: { withAnimation { isSceneLoading = true }} // works with true but not false. to check
                                )
                                    .frame(width: 320, height: 380)
                                    .clipShape(InvertedCornerShape(cornerRadius: 20))
                                    .edgesIgnoringSafeArea(.all)
                            }
                            unitsCountView(caseCounts: dataLoader.cumulativeCaseCounts)
                        }
                    }
                    .tag(0)
                    
                    layersView
                        .tag(1)
                    
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .frame(minHeight: 500)
            }
        }
        .onAppear {
            dataLoader.loadVoxelData(filename: filename, divisions: divisions, colorScheme: colorScheme, fileURLString: fileURLString)
        }
    }
    
    private var headerView: some View {
        Text("\(filename.replacingOccurrences(of: ".obj", with: "").capitalized)")
            .font(.custom("Poppins-SemiBold", size: 30))
            .padding()
    }
    
    private var layersView: some View {
        ForEach(1...dataLoader.numLayer, id: \.self) { iLayer in
            ScrollView {
                VStack {
                    Text("Layer \(iLayer)")
                        .font(.custom("Poppins-SemiBold", size: 30))
                        .padding()
                    SceneView(scnNodes: dataLoader.scnNodesByLayer[iLayer],
                              labelText: " ",
                              backgroundColor: iLayer == dataLoader.numLayer ? .lighterLightGray : .darkerLightGray)
                        .frame(width: 320, height: 320)
                        .clipShape(InvertedCornerShape(cornerRadius: 20))
                        .edgesIgnoringSafeArea(.all)
                    
                    if let layerCounts = dataLoader.layerCaseCounts[iLayer] {
                        unitsCountView(caseCounts: layerCounts)
                    }
                }
            }
        }
    }

    private func unitsCountView(caseCounts: [String: Int]) -> some View {
        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible())
        ]

        return VStack(alignment: .leading) { // Align the entire VStack to the leading edge
            Text("Units")
                .font(.custom("Poppins-SemiBold", size: 20))
                .frame(maxWidth: .infinity, alignment: .leading) // Align text to the left
                .padding(.leading, 25) // Add left padding

            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(caseCounts.sorted(by: { $0.key < $1.key }), id: \.key) { key, count in
                        SceneView(scnNodes: [getCube(cube: key, colorScheme: colorScheme)], labelText: "\(count) x", backgroundColor: .darkerLightGray)
                            .frame(width: 150, height: 150)
                            .clipShape(InvertedCornerShape(cornerRadius: 15))
                            .padding()
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
    }
    
}

struct MarchingCubes_Previews: PreviewProvider {
    static var previews: some View {
        MarchingCubesView()
    }
}
