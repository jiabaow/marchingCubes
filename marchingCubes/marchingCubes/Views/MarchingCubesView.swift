import SwiftUI
import SceneKit

struct MarchingCubesView: View {
    let filename: String
    let divisions: Int

    @State private var isLoading = true
    
    // Optional initializer
    init(filename: String = "Mesh_Anteater", divisions: Int = 7) {
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

                    SceneView(filename: filename, divisions: divisions, isLoading: $isLoading)
                        .frame(width: 300, height: 300)
                        .edgesIgnoringSafeArea(.all)
                }
            }

            LoadingView(filename: filename, isLoading: isLoading)
        }
    }
}

struct SceneView: UIViewRepresentable {
    let filename: String
    let divisions: Int
    @Binding var isLoading: Bool

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.allowsCameraControl = true
        scnView.backgroundColor = UIColor(red: 0.0, green: 0.4, blue: 0.65, alpha: 1.0) // UCI Blue

        let scene = SCNScene()
        scnView.scene = scene

        Task {
            await loadAndProcessModel(in: scene, scnView: scnView)
        }

        return scnView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {}

    private func loadAndProcessModel(in scene: SCNScene, scnView: SCNView) async {
        DispatchQueue.main.async {
            isLoading = true
        }

        let result: (SCNNode?, SCNNode?) = await Task {
            var voxelArray: MDLVoxelArray? = nil
            
//            if let url = get3DModelURL(filename: filename) {
//                guard let obj = loadObjAsset(filename: url),
//                      let voxarr = voxelize(asset: obj, divisions: Int32(divisions)) else {
//                    print("Failed to load or voxelize the model.")
//                    return (nil, nil)
//                }
//                voxelArray = voxarr
//            }
//            else {
                guard let obj = loadOBJ(filename: filename),
                      let voxarr = voxelize(asset: obj, divisions: Int32(divisions)) else {
                    print("Failed to load or voxelize the model.")
                    return (nil, nil)
                }
                voxelArray = voxarr
//            }
            
            
            let voxelGrid = convertTo3DArray(voxelArray: voxelArray!)
            let mcNode = marchingCubes(data: voxelGrid)

            // Create outline by duplicating the node
             let outlineNode = mcNode.clone()
             outlineNode.geometry = mcNode.geometry?.copy() as? SCNGeometry
             outlineNode.geometry?.firstMaterial = SCNMaterial()
             outlineNode.geometry?.firstMaterial?.diffuse.contents = UIColor.black
             outlineNode.geometry?.firstMaterial?.fillMode = .lines
            
//            let mcNode2 = marchingCubesV2(data: voxelGrid)
            
//             let mcNodeTest = testGetCube()
            
            // Return an array of nodes
//            return [mcNode]
            return (mcNode, outlineNode)
//            return [mcNodeTest]
        }.value

        // Update UI on the main thread
        DispatchQueue.main.async {
            if let mcNode = result.0, let outlineNode = result.1 {
                scene.rootNode.addChildNode(mcNode)
                scene.rootNode.addChildNode(outlineNode)
            }
            addLights(to: scene)
//            for node in result {
//                if let validNode = node {
//                    scene.rootNode.addChildNode(validNode)
//                }
//            }
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
