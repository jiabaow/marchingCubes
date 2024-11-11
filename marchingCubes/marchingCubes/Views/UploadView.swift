//
//  Upload.swift
//  marchingCubes
//
//  Created by Charles Weng on 10/23/24.
//
import Foundation
import SwiftUI
import SceneKit

struct UploadView: View {
    @State private var selectedFileURL: URL?
    @State private var showDocumentPicker = false
    @State private var scene: SCNScene? = nil
    @State private var zoomLevel: Float = 20.0 // Initial zoom level
    @EnvironmentObject var viewModel: ProjectViewModel
//    @StateObject var viewModel = ProjectViewModel()
    @Environment(\.modelContext) var modelContext

    var body: some View {
        VStack {
            // Upload title
            Text("Upload Your File")
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
                        // 3D Scene View
                        Group {
                            if let scene = scene {
                                SCNViewWrapper(scene: scene, zoomLevel: $zoomLevel)
                                    .frame(height: 200)
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
                    loadScene(from: url)
                    showDocumentPicker = false
                }
            }

            Spacer()
            
            // Zoom controls
            HStack {
                Button(action: {
                    zoomLevel += 1.0 // Zoom in
                }) {
                    Image(systemName: "minus.magnifyingglass")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
                Button(action: {
                    zoomLevel -= 1.0
                }) {
                    Image(systemName: "plus.magnifyingglass")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
            }
            .padding(.bottom, 30)

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
                    takeScreenshot()
                    print("Model obj filename: ", fileURL.lastPathComponent)
                    print("Models inside save: ", viewModel.models)
                    selectedFileURL = nil
                    scene = nil // Clear the scene after saving
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

    // Load the scene from the selected .obj file
    private func loadScene(from url: URL) {
        let sceneSource = SCNSceneSource(url: url, options: nil)
        if let loadedScene = sceneSource?.scene(options: nil) {
            // Add a camera if it doesn't exist
            let cameraNode = SCNNode()
            cameraNode.camera = SCNCamera()
            // Use zoomLevel for camera position
            cameraNode.position = SCNVector3(x: 0, y: 0, z: zoomLevel)
            loadedScene.rootNode.addChildNode(cameraNode)

            // Add lighting
            let lightNode = SCNNode()
            lightNode.light = SCNLight()
            lightNode.light?.type = .omni
            lightNode.position = SCNVector3(x: 0, y: 0, z: 10) // Adjust position as needed
            loadedScene.rootNode.addChildNode(lightNode)

            self.scene = loadedScene
        } else {
            // Handle error loading the scene
            print("Failed to load the scene from URL: \(url)")
        }
    }
    
    // Take a screenshot of the current scene
    private func takeScreenshot() {
        guard let currentScene = scene else { return }
        guard let selectedFileURL = selectedFileURL else { return }
        
        let scnView = SCNView()
        scnView.scene = currentScene
        
        // Capture screenshot
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
        
        // Update camera position based on zoom level
        if let cameraNode = scene.rootNode.childNodes.first(where: { $0.camera != nil }) {
            cameraNode.position.z = zoomLevel
        }
    }
}

struct Upload_Previews: PreviewProvider {
    static var previews: some View {
        UploadView().environmentObject(ProjectViewModel())
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
