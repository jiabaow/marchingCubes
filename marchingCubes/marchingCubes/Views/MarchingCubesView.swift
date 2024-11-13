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

struct SceneView: UIViewRepresentable {
    let scnNodes: [SCNNode?]?

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.allowsCameraControl = true
        scnView.backgroundColor = UIColor(red: 0.0, green: 0.4, blue: 0.65, alpha: 1.0) // UCI Blue

        let scene = SCNScene()
        scnView.scene = scene

        // Safely unwrap scnNodes before iterating
        if let nodes = scnNodes {
            for node in nodes {
                if let validNode = node {
                    scene.rootNode.addChildNode(validNode)
                }
            }
        }

        addLights(to: scene)

        return scnView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {}

    private func addLights(to scene: SCNScene) {
        let keyLightNode1 = SCNNode()
        let keyLight1 = SCNLight()
        keyLight1.type = .directional
        keyLight1.intensity = 500
        keyLight1.castsShadow = true
        keyLight1.shadowRadius = 3.0
        keyLight1.shadowColor = UIColor(white: 0.0, alpha: 0.5)
        keyLightNode1.light = keyLight1
        keyLightNode1.eulerAngles = SCNVector3(-Float.pi / 4, -Float.pi / 4, 0)
        scene.rootNode.addChildNode(keyLightNode1)
        
        let keyLightNode2 = SCNNode()
        let keyLight2 = SCNLight()
        keyLight2.type = .directional
        keyLight2.intensity = 500
        keyLight2.castsShadow = true
        keyLight2.shadowRadius = 3.0
        keyLight2.shadowColor = UIColor(white: 0.0, alpha: 0.5)
        keyLightNode2.light = keyLight2
        keyLightNode2.eulerAngles = SCNVector3(Float.pi / 4, Float.pi / 4, 0)
        scene.rootNode.addChildNode(keyLightNode2)
        
        let fillLightNode = SCNNode()
        let fillLight = SCNLight()
        fillLight.type = .ambient
        fillLight.intensity = 600
        fillLightNode.light = fillLight
        scene.rootNode.addChildNode(fillLightNode)
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

class VoxelDataLoader: ObservableObject {
    @Published var voxelData: [[[Int]]] = []
    @Published var numLayer: Int = 0
    @Published var isLoading: Bool = true
    @Published var scnNodesByLayer: [Int: [SCNNode?]] = [:]

    func loadVoxelData(filename: String, divisions: Int) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let (loadedVoxelData, loadedNumLayer) = MarchingCubesView.loadVoxelData(filename: filename, divisions: divisions) else {
                print("Failed to load voxel data.")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }

            DispatchQueue.main.async {
                self.voxelData = loadedVoxelData
                self.numLayer = loadedNumLayer
                self.isLoading = false
                self.loadSCNNodesForAllLayers()
            }
        }
    }

    private func loadSCNNodesForAllLayers() {
        for layer in 0...numLayer {
            let isTopLayer = (layer == numLayer)
            let nodes = MarchingCubesView.loadSCNNodesByLayer(numLayer: layer + 1, voxelData: voxelData, isTopLayer: isTopLayer)
            scnNodesByLayer[layer] = nodes
        }
        let fullNode = MarchingCubesView.loadSCNNodesByLayer(numLayer: numLayer + 1, voxelData: voxelData, isTopLayer: false)
        scnNodesByLayer[0] = fullNode
    }
}

struct MarchingCubes_Previews: PreviewProvider {
    static var previews: some View {
        MarchingCubesView()
    }
}
