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
    }
    
    var body: some View {
            ZStack {
                if dataLoader.isLoading {
                    LoadingView(filename: filename)
                } else {
                    ScrollView {
                        VStack {
                            headerView
                            
                            SceneView(scnNodes: dataLoader.scnNodesByLayer[0])
                                .frame(width: 300, height: 300)
                                .edgesIgnoringSafeArea(.all)

                            TabView {
                                unitsCountView
                                    .tag(0)
                                
                                layersView
                                    .tag(1)
                                
                            }
                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                            .frame(height: 350)
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
                VStack {
                    Text("Layer \(iLayer)")
                        .font(.headline)
//                        .padding(.top)

                    SceneView(scnNodes: dataLoader.scnNodesByLayer[iLayer])
                        .frame(width: 300, height: 300)
                        .edgesIgnoringSafeArea(.all)
                }
            }
        }
    
    private var unitsCountView: some View {
        VStack {
            Text("Units Count")
                .font(.headline)
                .padding(.top)

            ScrollView { // Add a ScrollView
                ForEach(dataLoader.cumulativeCaseCounts.sorted(by: { $0.key < $1.key }), id: \.key) { key, count in
                    VStack {
                        // Call sceneView with key.obj, load the obj with name key and voxelize it

                        HStack {
                            SceneView(scnNodes: [getCube(cube: key)]).frame(width: 200, height: 200)
                            Text("x\(count)")
                                .font(.subheadline)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom) // Optional: Add some padding between items
                }
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
