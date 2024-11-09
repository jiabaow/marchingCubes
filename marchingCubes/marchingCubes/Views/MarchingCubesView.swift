import SwiftUI
import SceneKit

struct MarchingCubesView: View {
    let filename: String
    let divisions: Int

    @State private var isLoading = true
    
    // Optional initializer
    init(filename: String = "rabbit", divisions: Int = 5) {
        self.filename = filename
        self.divisions = divisions
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    Text("\(filename.replacingOccurrences(of: ".obj", with: "").capitalized)")
                        .font(.largeTitle)
                        .padding()

                    SceneView(filename: filename, divisions: divisions,
                              numLayer: divisions + 1, isLoading: $isLoading)
                        .frame(width: 300, height: 300)
                        .edgesIgnoringSafeArea(.all)
                    
                    ForEach(1...divisions+1, id: \.self) { iLayer in
                        VStack {
                            Text("Layer \(iLayer)")
                                .font(.headline)
                                .padding(.top)

                            SceneView(filename: filename, divisions: divisions,
                                      numLayer: iLayer, isLoading: $isLoading)
                                .frame(width: 300, height: 300)
                                .edgesIgnoringSafeArea(.all)
                        }
                    }

                }
            }

            LoadingView(filename: filename, isLoading: isLoading)
        }
    }
}

struct SceneView: UIViewRepresentable {
    let filename: String
    let divisions: Int
    // the index of layer, -1 stands for the whole object
    let numLayer: Int
    @Binding var isLoading: Bool

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.allowsCameraControl = true
        scnView.backgroundColor = UIColor(red: 0.0, green: 0.4, blue: 0.65, alpha: 1.0) // UCI Blue

        let scene = SCNScene()
        scnView.scene = scene

        Task {
            await loadAndProcessModel(in: scene, scnView: scnView, numLayer: numLayer)
        }

        return scnView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {}

    private func loadAndProcessModel(in scene: SCNScene, scnView: SCNView, numLayer: Int) async {
        DispatchQueue.main.async {
            isLoading = true
        }

        let result: [SCNNode?] = await Task {
            var voxArray: MDLVoxelArray? = nil;
            if let fileURL = get3DModelURL(filename: filename) {
                guard let obj = loadObjAsset(filename: fileURL),
                      let voxarr = voxelize(asset: obj, divisions: Int32(divisions)) else {
                    print("Failed to load or voxelize the model.")
                    return []
                }
                voxArray = voxarr
            } else {
                guard let obj = loadOBJ(filename: filename),
                      let voxarr = voxelize(asset: obj, divisions: Int32(divisions)) else {
                    print("Failed to load or voxelize the model.")
                    return []
                }
                voxArray = voxarr;
            }

            let voxelGrid = convertTo3DArray(voxelArray: voxArray!)
            let layeredData = getLayeredData(data: voxelGrid, numLayer: numLayer)
            
            let algo = MarchingCubesAlgo()
            let mcNode2 = algo.marchingCubesV2(data: layeredData)
                     
//             let mcNode2 = testGetCube()
            
            return [mcNode2]
//            return [mcNodeTest]
//            return [mcNode, outlineNode]
        }.value

        // Update UI on the main thread
        DispatchQueue.main.async {
            for node in result {
                if let validNode = node {
                    scene.rootNode.addChildNode(validNode)
                }
            }
            addLights(to: scene)
            isLoading = false
        }
    }

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
    let isLoading: Bool

    var body: some View {
        if isLoading {
            Text("Converting \(filename) to cubes...")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(10)
                .transition(.opacity)
                .animation(.easeInOut, value: isLoading)
        }
    }
}

struct MarchingCubes_Previews: PreviewProvider {
    static var previews: some View {
        MarchingCubesView()
    }
}
