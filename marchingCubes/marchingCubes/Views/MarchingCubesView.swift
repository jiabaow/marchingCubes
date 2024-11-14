import SwiftUI
import SceneKit

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
                        Text("\(filename.replacingOccurrences(of: ".obj", with: "").capitalized)")
                            .font(.largeTitle)
                            .padding()

                        SceneView(scnNodes: dataLoader.scnNodesByLayer[0])
                            .frame(width: 300, height: 300)
                            .edgesIgnoringSafeArea(.all)

                        ForEach(1...dataLoader.numLayer, id: \.self) { iLayer in
                            VStack {
                                Text("Layer \(iLayer)")
                                    .font(.headline)
                                    .padding(.top)

                                SceneView(scnNodes: dataLoader.scnNodesByLayer[iLayer])
                                    .frame(width: 300, height: 300)
                                    .edgesIgnoringSafeArea(.all)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            dataLoader.loadVoxelData(filename: filename, divisions: divisions)
        }
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
    
    static func loadSCNNodesByLayer(numLayer: Int, voxelData: [[[Int]]], isTopLayer: Bool) -> [SCNNode?] {
        var res: [SCNNode?] = []
        let algo = MarchingCubesAlgo()
        let layeredData = getLayeredData(data: voxelData, numLayer: numLayer)
        let mcNode2 = algo.marchingCubesV2(data: layeredData)
        res.append(mcNode2)
        
        if (isTopLayer == false) {
            let algo2d = MarchingCubes2D()
            let colorNode = algo2d.marchingCubes2D(data: get2DDataFromLayer(data: voxelData, numLayer: numLayer - 1))
            colorNode.position.y += Float(numLayer - 1) + 0.01
            
            res.append(colorNode)
        }
        return res
    }
}

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

struct MarchingCubes_Previews: PreviewProvider {
    static var previews: some View {
        MarchingCubesView()
    }
}
