//
//  Upload.swift
//  marchingCubes
//
//  Created by Charles Weng on 10/23/24.
//
import Foundation
import SwiftUI
import SceneKit

struct AddModelView: View {
    @State private var selectedFileURL: URL?
    @State private var showDocumentPicker = false
    @State private var scene: SCNScene? = nil
    @State private var zoomLevel: Float = 20.0 // Initial zoom level
    @EnvironmentObject var viewModel: ProjectViewModel
    @StateObject private var dataLoader = VoxelDataLoader()
    @Environment(\.modelContext) var modelContext

    var body: some View {
        VStack {
            Text("Add Your Model")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)

            ZStack {
                // Dashed rounded rectangle as placeholder
                RoundedRectangle(cornerRadius: 10)
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [10, 5]))
                    .frame(height: 200)
                    .foregroundColor(.gray)
                    .overlay(
                        Group {
                            if (dataLoader.isActive && dataLoader.isLoading) {
                                let fileName = self.selectedFileURL?.lastPathComponent ?? "Unknown File"
                                LoadingView(filename: fileName)
                            } else if let scnNodes = dataLoader.scnNodesByLayer[0] {
                                let fileName = self.selectedFileURL?.lastPathComponent ?? "Unknown File"
                                SceneView(scnNodes: scnNodes, labelText: fileName, backgroundColor:  UIColor(red: 0.0, green: 0.4, blue: 0.65, alpha: 1.0)) { scnScene in
                                    self.scene = scnScene
                                }
                                .frame(height: 200)
                                .onAppear {
                                    if let scene = scene {
                                        takeScreenshot(scene: scene)
                                    }
                                }
                            } else {
                                Text("Choose file (.obj)")
                                    .foregroundColor(.gray)
                            }
                        }
                    )
                    .padding(.horizontal)
                    .padding(.top)
                    .onTapGesture {
                        showDocumentPicker = true
                    }
            }
            .sheet(isPresented: $showDocumentPicker) {
                DocumentPicker { url in
                    self.selectedFileURL = url
                    dataLoader.isActive = true
                    saveDocumentToCache(from: url)
                    if let fileUrl = self.selectedFileURL {
                        dataLoader.loadVoxelData2(filename: fileUrl.lastPathComponent, divisions: 5)
                    }
                    showDocumentPicker = false
                }
            }

            Spacer()
            
            // Zoom controls
//            HStack {
//                Button(action: {
//                    zoomLevel += 1.0 // Zoom in
//                }) {
//                    Image(systemName: "minus.magnifyingglass")
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(5)
//                }
//                Button(action: {
//                    zoomLevel -= 1.0
//                }) {
//                    Image(systemName: "plus.magnifyingglass")
//                        .padding()
//                        .background(Color.red)
//                        .foregroundColor(.white)
//                        .cornerRadius(5)
//                }
//            }
//            .padding(.bottom, 30)

            if let url = selectedFileURL {
                Text("File: " + url.lastPathComponent)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray)
                    .cornerRadius(10)
            }

            Spacer()


            // Conditional Button: Plus or Save
            if let url = selectedFileURL {
                Button(action: {
                    guard let fileURL = selectedFileURL else { return }
                    viewModel.addModel(title: fileURL.lastPathComponent, image: "\(fileURL.lastPathComponent).png", modelContext: modelContext)
                    saveDocumentToCache(from: fileURL)
                    takeScreenshot(scene: scene)
                    print("Model obj filename: ", fileURL.lastPathComponent)
                    print("Models inside save: ", viewModel.models)
                    selectedFileURL = nil
                    dataLoader.isLoading = true
                    dataLoader.isActive = false
                    dataLoader.scnNodesByLayer = [:]
                    // scene = nil // Clear the scene after saving
                }) {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 24))
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
                .padding(.bottom, 30)
            } else {
                Button(action: {
                    showDocumentPicker = true
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 24))
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
                .padding(.bottom, 30)
            }
        }
        .padding()
    }
    
    private func loadScene(from url: URL) {
        let sceneSource = SCNSceneSource(url: url, options: nil)
        if let loadedScene = sceneSource?.scene(options: nil) {
            // Calculate the bounding box of the model
            let (minVec, maxVec) = loadedScene.rootNode.boundingBox
            let center = SCNVector3(
                (minVec.x + maxVec.x) / 2,
                (minVec.y + maxVec.y) / 2,
                (minVec.z + maxVec.z) / 2
            )
            let size = SCNVector3(
                maxVec.x - minVec.x,
                maxVec.y - minVec.y,
                maxVec.z - minVec.z
            )
            
            // Calculate the optimal camera position
            let maxDimension = max(size.x, size.y, size.z)
            let cameraDistance = maxDimension * 1.5 // Adjust multiplier as needed for zoom level

            // Add a camera node
            let cameraNode = SCNNode()
            cameraNode.camera = SCNCamera()
            cameraNode.position = SCNVector3(
                center.x + cameraDistance, // Diagonal from top-right
                center.y + cameraDistance,
                center.z + cameraDistance
            )
            cameraNode.look(at: center) // Ensure the camera points to the center of the model
            loadedScene.rootNode.addChildNode(cameraNode)
            
            // Add a light source
            let lightNode = SCNNode()
            lightNode.light = SCNLight()
            lightNode.light?.type = .omni
            lightNode.position = SCNVector3(
                center.x + cameraDistance / 2,
                center.y + cameraDistance / 2,
                center.z + cameraDistance / 2
            )
            loadedScene.rootNode.addChildNode(lightNode)
            
            // Add an ambient light for better visibility
            let ambientLightNode = SCNNode()
            ambientLightNode.light = SCNLight()
            ambientLightNode.light?.type = .ambient
            ambientLightNode.light?.color = UIColor(white: 0.8, alpha: 1.0)
            loadedScene.rootNode.addChildNode(ambientLightNode)

            // Assign the loaded scene
            self.scene = loadedScene
        } else {
            print("Failed to load the scene from URL: \(url)")
        }
    }


    // Load the scene from the selected .obj file
//    private func loadScene(from url: URL) {
//        let sceneSource = SCNSceneSource(url: url, options: nil)
//        if let loadedScene = sceneSource?.scene(options: nil) {
//            // Add a camera if it doesn't exist
//            let cameraNode = SCNNode()
//            cameraNode.camera = SCNCamera()
//            // Use zoomLevel for camera position
//            cameraNode.position = SCNVector3(x: 0, y: 0, z: zoomLevel)
//            loadedScene.rootNode.addChildNode(cameraNode)
//
//            // Add lighting
//            let lightNode = SCNNode()
//            lightNode.light = SCNLight()
//            lightNode.light?.type = .omni
//            lightNode.position = SCNVector3(x: 0, y: 0, z: 10) // Adjust position as needed
//            loadedScene.rootNode.addChildNode(lightNode)
//
//            self.scene = loadedScene
//        } else {
//            // Handle error loading the scene
//            print("Failed to load the scene from URL: \(url)")
//        }
//    }
    
    // Take a screenshot of the current scene
    private func takeScreenshot(scene: SCNScene?, size: CGSize = CGSize(width: 80, height: 80)) {
        guard let currentScene = scene else { return }
        guard let selectedFileURL = selectedFileURL else { return }
        
        // Create an SCNView with the specified size
        let scnView = SCNView(frame: CGRect(origin: .zero, size: size))
        scnView.scene = currentScene
        scnView.backgroundColor = UIColor(red: 0.0, green: 0.4, blue: 0.65, alpha: 1.0)
        
        // Ensure the scene's background is transparent
        currentScene.background.contents = UIColor.clear

        // Add a camera node and adjust its position
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 10, y: 10, z: 15) // Diagonal position (45 degrees)
        cameraNode.look(at: SCNVector3(0, 0, 0)) // Look at the scene's origin
        currentScene.rootNode.addChildNode(cameraNode)

        // Ensure the SCNView is fully rendered
        scnView.pointOfView = cameraNode // Use the newly added camera
        scnView.layoutIfNeeded()
        
        // Capture the screenshot
        let image = scnView.snapshot()
        
        // Save the image
        saveImageToCache(image, "\(selectedFileURL.lastPathComponent)")
    }

}

// UIViewRepresentable for SCNView
struct SCNViewWrapper: UIViewRepresentable {
    var scene: SCNScene
    @Binding var zoomLevel: Float // Binding to zoom level

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.allowsCameraControl = true
        scnView.showsStatistics = true
        scnView.backgroundColor = UIColor.gray
        return scnView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        uiView.scene = scene
        
        // Ensure camera is not reset
        if let cameraNode = scene.rootNode.childNodes.first(where: { $0.camera != nil }) {
            cameraNode.position.z = zoomLevel // Update only the zoom level if needed
        }
    }
}

struct Upload_Previews: PreviewProvider {
    static var previews: some View {
        AddModelView()
    }
}




// Search Bar
//            HStack {
//                TextField("Search files...", text: $searchQuery)
//                    .padding(10)
//                    .background(Color(UIColor.systemGray5))
//                    .cornerRadius(10)
//                    .padding(.leading)
//                Spacer()
//                Image(systemName: "magnifyingglass")
//                    .padding(.trailing)
//            }
//            .padding(.bottom, 10)



// The new cached files list view
//            List {
//                ForEach(viewModel.models.filter { model in
//                    searchQuery.isEmpty || model.title.lowercased().contains(searchQuery.lowercased())
//                }) { model in
//                    HStack {
//                        VStack(alignment: .leading) {
//                            Text(model.title)
//                                .font(.headline)
//                        }
//                        Spacer()
//                        Button(action: {
//                            viewModel.removeModel(model, modelContext: modelContext)
//                        }) {
//                            Image(systemName: "trash")
//                                .foregroundColor(.red)
//                        }
//                        .buttonStyle(PlainButtonStyle())
//                    }
//                }
//            }
