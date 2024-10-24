import SwiftUI
import SceneKit

struct MarchingCubesView: View {
    let filename = "rabbit" // Store the filename here
    let divisions = 5 // Define divisions as a variable

    var body: some View {
        ScrollView {
            VStack {
                Text("\(filename.capitalized)") // Use the filename as the title
                    .font(.largeTitle)
                    .padding()

                SceneView(filename: filename, divisions: divisions) // Pass divisions
                    .frame(width: 300, height: 300) // Set fixed size
                    .edgesIgnoringSafeArea(.all)
                
//                SceneView(filename: filename, divisions: 5) // Pass divisions
//                    .frame(width: 300, height: 300) // Set fixed size
//                    .edgesIgnoringSafeArea(.all)
//                
//                SceneView(filename: filename, divisions: 4) // Pass divisions
//                    .frame(width: 300, height: 300) // Set fixed size
//                    .edgesIgnoringSafeArea(.all)
//                
//                SceneView(filename: filename, divisions: 3) // Pass divisions
//                    .frame(width: 300, height: 300) // Set fixed size
//                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

struct MarchingCubes_Previews: PreviewProvider {
    static var previews: some View {
        MarchingCubesView()
    }
}

struct SceneView: UIViewRepresentable {
    let filename: String // Receive the filename
    let divisions: Int // Receive divisions

    func makeUIView(context: Context) -> SCNView {
        guard let obj = loadOBJ(filename: filename),
              let voxarr = voxelize(asset: obj, divisions: Int32(divisions)) else {
            print("Failed to load or voxelize the model.")
            return SCNView()
        }
        
        let scnView = SCNView()
        scnView.allowsCameraControl = true
//        scnView.showsStatistics = true
        scnView.backgroundColor = UIColor(red: 0.0, green: 0.4, blue: 0.65, alpha: 1.0) // UCI Blue
        
        let scene = SCNScene()

        let voxelGrid = convertTo3DArray(voxelArray: voxarr)
        let mcNode = marchingCubes(data: voxelGrid)
//        let mcNode = marchingCubesSingleLayer(data: voxelGrid, layer: 40)
        
        // Make the object shiny
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.white
        material.specular.contents = UIColor.white
        material.shininess = 30 // Adjust shininess for more shine
        mcNode.geometry?.firstMaterial = material
        
        // Create outline by duplicating the node
        let outlineNode = mcNode.clone()
        outlineNode.geometry = mcNode.geometry?.copy() as? SCNGeometry
        outlineNode.geometry?.firstMaterial = SCNMaterial()
        outlineNode.geometry?.firstMaterial?.diffuse.contents = UIColor.black
        outlineNode.geometry?.firstMaterial?.fillMode = .lines

        scene.rootNode.addChildNode(mcNode)
        scene.rootNode.addChildNode(outlineNode)
        
        // Add lights to the scene
        addLights(to: scene)
    
        scnView.scene = scene
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
        
//        let keyLightNode3 = SCNNode()
//        let keyLight3 = SCNLight()
//        keyLight3.type = .directional
//        keyLight3.intensity = 100
//        keyLight3.castsShadow = false
//        keyLightNode3.light = keyLight3
//        keyLightNode3.eulerAngles = SCNVector3(-Float.pi / 4, Float.pi / 4, 0)
//        scene.rootNode.addChildNode(keyLightNode3)
//        
//        let keyLightNode4 = SCNNode()
//        let keyLight4 = SCNLight()
//        keyLight4.type = .directional
//        keyLight4.intensity = 100
//        keyLight4.castsShadow = false
//        keyLightNode4.light = keyLight4
//        keyLightNode4.eulerAngles = SCNVector3(Float.pi / 4, -Float.pi / 4, 0)
//        scene.rootNode.addChildNode(keyLightNode4)
        
        let fillLightNode = SCNNode()
        let fillLight = SCNLight()
        fillLight.type = .ambient
        fillLight.intensity = 600
        fillLightNode.light = fillLight
        scene.rootNode.addChildNode(fillLightNode)
    }
}
