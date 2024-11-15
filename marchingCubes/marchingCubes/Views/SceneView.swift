import SwiftUI
import SceneKit

struct SceneView: UIViewRepresentable {
    let scnNodes: [SCNNode?]?

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.allowsCameraControl = true
        scnView.backgroundColor = UIColor(red: 0.0, green: 0.4, blue: 0.65, alpha: 1.0) // UCI Blue

        let scene = SCNScene()
        scnView.scene = scene

        // Add all nodes to the scene's rootNode
        if let nodes = scnNodes {
            for node in nodes {
                if let validNode = node {
                    scene.rootNode.addChildNode(validNode)
                }
            }
        }

        // Record the original position of the rootNode
        context.coordinator.rootNode = scene.rootNode
        context.coordinator.originalPosition = scene.rootNode.position

        addLights(to: scene)

        // Add pinch gesture recognizer
        let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handlePinch(_:)))
        scnView.addGestureRecognizer(pinchGesture)

        // Add double-tap gesture recognizer
        let doubleTapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        scnView.addGestureRecognizer(doubleTapGesture)

        return scnView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject {
        var rootNode: SCNNode?
        var originalPosition = SCNVector3Zero // Store the original position of the root node

        @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            guard let rootNode = rootNode else { return }
            
            let dampingFactor: Float = 0.05 // Adjust this value to control the scaling speed
            let scale = Float(gesture.scale)
            
            switch gesture.state {
            case .changed:
                let currentScale = rootNode.scale
                let newScaleX = currentScale.x * (1 + (scale - 1) * dampingFactor)
                let newScaleY = currentScale.y * (1 + (scale - 1) * dampingFactor)
                let newScaleZ = currentScale.z * (1 + (scale - 1) * dampingFactor)
                rootNode.scale = SCNVector3(newScaleX, newScaleY, newScaleZ)
            case .ended:
                gesture.scale = 1.0
            default:
                break
            }
        }

        @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
            guard let rootNode = rootNode else { return }
            rootNode.scale = SCNVector3(1, 1, 1)
            rootNode.position = originalPosition
            rootNode.rotation = SCNVector4Zero
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

struct SceneView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a white cube node for the preview
        let cubeGeometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
        cubeGeometry.firstMaterial?.diffuse.contents = UIColor.white
        let cubeNode = SCNNode(geometry: cubeGeometry)
        cubeNode.position = SCNVector3(0, 0, 0)

        // Pass the cube node to the SceneView
        return SceneView(scnNodes: [cubeNode])
            .frame(width: 300, height: 500)
    }
}
