import SwiftUI
import SceneKit
import ModelIO

struct MarchingCubesView: View {
    let filename: String
    let divisions: Int

    @StateObject private var dataLoader = VoxelDataLoader()

    // Optional initializer
    init(filename: String = "rabbit", divisions: Int = 5) {
        self.filename = filename
        self.divisions = divisions
        
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
                            SceneView(scnNodes: dataLoader.scnNodesByLayer[0],
                                      labelText: " ", backgroundColor: .white)
                                .frame(width: 320, height: 380)
                                .edgesIgnoringSafeArea(.all)
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
            dataLoader.loadVoxelData(filename: filename, divisions: divisions)
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
                              labelText: " ", backgroundColor: .lightPurple)
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
                        SceneView(scnNodes: [getCube(cube: key)], labelText: "\(count) x", backgroundColor: .lightPurple)
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
    
    // Helper function to load and voxelize the model
     static func loadVoxelData(filename: String, divisions: Int) -> ([[[Int]]], Int)? {
         var voxArray: MDLVoxelArray? = nil
         if let fileURL = get3DModelURL(filename: filename) {
             guard let obj = loadObjAsset(filename: fileURL),
                   let voxarr = voxelize(asset: obj, divisions: Int32(divisions)) else {
                 print("Failed to load or voxelize the model.")
                 return nil
             }
             voxArray = voxarr
         } else {
             guard let obj = loadOBJ(filename: filename),
                   let voxarr = voxelize(asset: obj, divisions: Int32(divisions)) else {
                 print("Failed to load or voxelize the model.")
                 return nil
             }
             voxArray = voxarr
         }
         let voxelGrid = convertTo3DArray(voxelArray: voxArray!)
         let voxelData = getAllLayers(data: voxelGrid)
         let numLayer = voxelData[0].count - 1
         return (voxelData, numLayer)
     }
}

struct MarchingCubes_Previews: PreviewProvider {
    static var previews: some View {
        MarchingCubesView()
    }
}
