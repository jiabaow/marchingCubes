import SwiftUI
import SceneKit
import ModelIO

struct MarchingCubesView: View {
    let filename: String
    let divisions: Int

    @StateObject private var dataLoader = VoxelDataLoader()
    
    private let lightPurple = UIColor(red: 229/255.0, green: 230/255.0, blue: 246/255.0, alpha: 1.0)

    // Optional initializer
    init(filename: String = "rabbit", divisions: Int = 5) {
        self.filename = filename
        self.divisions = divisions
    }
    
    var body: some View {
        ZStack {
            if dataLoader.isLoading {
                LoadingView(filename: filename)
            } else {
                ScrollView {
                    VStack {
                        headerView
                        SceneView(scnNodes: dataLoader.scnNodesByLayer[0],
                                  labelText: " ", backgroundColor: lightPurple)
                            .frame(width: 320, height: 400)
                            .clipShape(InvertedCornerShape(cornerRadius: 20))
                            .edgesIgnoringSafeArea(.all)
                        
                        TabView {
                            unitsCountView(caseCounts: dataLoader.cumulativeCaseCounts)
                                .tag(0)
                            
                            layersView
                                .tag(1)
                            
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                        .frame(minHeight: 500)
                    }
                }
            }
        }
        .onAppear {
            dataLoader.loadVoxelData(filename: filename, divisions: divisions)
        }
    }
    
    private var headerView: some View {
        Text("\(filename.replacingOccurrences(of: ".obj", with: "").capitalized)")
            .font(.largeTitle)
            .padding()
    }
    
    private var layersView: some View {
        ForEach(1...dataLoader.numLayer, id: \.self) { iLayer in
            ScrollView {
                VStack {
                    SceneView(scnNodes: dataLoader.scnNodesByLayer[iLayer],
                              labelText: "Layer \(iLayer)", backgroundColor: lightPurple)
                        .frame(width: 320, height: 300)
                        .clipShape(InvertedCornerShape(cornerRadius: 20))
                        .edgesIgnoringSafeArea(.all)
                    
                    if let layerCounts = dataLoader.layerCaseCounts[iLayer] {
                        unitsCountView(caseCounts: layerCounts)
                    }
                }
                .padding()
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
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading) // Align text to the left
                .padding(.leading, 25) // Add left padding

            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(caseCounts.sorted(by: { $0.key < $1.key }), id: \.key) { key, count in
                        SceneView(scnNodes: [getCube(cube: key)], labelText: "\(count) x", backgroundColor: lightPurple)
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
