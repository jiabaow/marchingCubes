//
//  Upload.swift
//  marchingCubes
//
//  Created by Charles Weng on 10/23/24.
import Foundation
import SwiftUI
import SceneKit
import AWSS3

struct OverlayContent: View {
    let scene: SCNScene?
    @Binding var selectedFileURL: URL?
    @Binding var sceneView: SCNView?
    @Binding var translateX: Float
    @Binding var translateY: Float
    @Binding var translateZ: Float
    @Binding var rotateX: Float
    @Binding var rotateY: Float
    @Binding var rotateZ: Float
    
    var body: some View {
        VStack {
            if let scene = scene {
                SCNViewWrapper(
                    scene: scene,
                    translateZ: $translateZ,
                    translateX: $translateX,
                    translateY: $translateY,
                    rotateX: $rotateX,
                    rotateY: $rotateY,
                    rotateZ: $rotateZ,
                    sceneView: $sceneView
                )
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            translateX += Float(value.translation.width) / 10
                            translateY -= Float(value.translation.height) / 10
                        }
                )
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            translateZ += Float(1.0 - value) * 15.0
                        }
                )
                .frame(height: 400)
            } else if let fileName = selectedFileURL?.lastPathComponent {
                LoadingView(filename: fileName).frame(height: 400)
            } else {
                VStack {
                    Image(systemName: "plus")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("Drag & drop or Choose file")
                        .foregroundColor(.gray)
                        .font(.headline)
                }
            }
        }
    }
}


struct AddModelView: View {
    @State private var selectedFileURL: URL?
    @State private var showDocumentPicker = false
    @State private var scene: SCNScene? = nil
    @State private var sceneView: SCNView? = nil
    @State private var translateZ: Float = 100.0 // Initial zoom level
    @State private var translateX: Float = 0.0 // Initial X translation
    @State private var translateY: Float = 0.0 // Initial Y translation
    @State private var rotateX: Float = 0.0 // Rotation around X-axis
    @State private var rotateY: Float = 0.0 // Rotation around Y-axis
    @State private var rotateZ: Float = 0.0 // Rotation around Z-axis
    @State private var isDownloading = false // Tracks if downloading is in progress
    @State private var isLoading = false
    @EnvironmentObject var viewModel: ProjectViewModel
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        NavigationView {
            VStack {
                // Upload title
                VStack {
                    Text("Add your model")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("File should be OBJ")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.top)
                
                ZStack {
                    // Dashed rounded rectangle as placeholder
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [10, 5]))
                        .frame(height: 400)
                        .foregroundColor(.gray)
                        .overlay(
                            OverlayContent(
                                scene: scene,
                                selectedFileURL: $selectedFileURL,
                                sceneView: $sceneView,
                                translateX: $translateX,
                                translateY: $translateY,
                                translateZ: $translateZ,
                                rotateX: $rotateX,
                                rotateY: $rotateY,
                                rotateZ: $rotateZ
                            )
                        )
                        .padding(.horizontal)
                        .padding(.top)
                        .onTapGesture {
                            showDocumentPicker = true && selectedFileURL == nil
                        }
                }
                .sheet(isPresented: $showDocumentPicker) {
                    DocumentPicker { url in
                        self.selectedFileURL = url
                        loadScene(from: url)
                        showDocumentPicker = false
                    }
                }
                .disabled(isDownloading)
                
                Spacer()
                
                if let url = selectedFileURL {
                    Text("File: " + url.lastPathComponent)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray)
                        .cornerRadius(10)
                }
                
                if (selectedFileURL == nil) {
                    Button(action: {
                        isDownloading = true // Block UI
                        Task {
                            await downloadFile(context: self)
                            isDownloading = false // Unblock UI
                        }
                    }) {
                        Text("Download Sample Files")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(hex: "5A60E3"))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Conditional Button: Plus or Save
                if let url = selectedFileURL {
                    HStack {
                        Button(action: {
                            selectedFileURL = nil
                            scene = nil
                            resetCameraValues()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 24))
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        .padding(.bottom, 30)
                        Spacer()
                        Button(action: {
                            guard let fileURL = selectedFileURL else { return }
                            print(fileURL.absoluteString)
                            viewModel.addModel(title: fileURL.lastPathComponent, image: "\(fileURL.lastPathComponent).png", modelContext: modelContext, fileURLString: fileURL.absoluteString)
                            print(viewModel.models)
                            saveDocumentToCache(from: fileURL)
                            //                            takeScreenshot()
                            takeScreenShot(sceneView: self.sceneView, selectedFileURL: self.selectedFileURL)
                            print("Model obj filename: ", fileURL.lastPathComponent)
                            print("Models inside save: ", viewModel.models)
                            selectedFileURL = nil
                            scene = nil // Clear the scene after saving
                            resetCameraValues()
                        }) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 24))
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        .padding(.bottom, 30)
                    }
                }
                
                if isDownloading {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                    VStack {
                        ProgressView("Loading...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                            .foregroundColor(.white)
                    }
                }
            }
            .padding()
        }
    }
    
    private func calculateBoundingBox(for scene: SCNScene) -> (min: SCNVector3, max: SCNVector3) {
        var minPoint = SCNVector3(Float.greatestFiniteMagnitude,
                                  Float.greatestFiniteMagnitude,
                                  Float.greatestFiniteMagnitude)
        var maxPoint = SCNVector3(-Float.greatestFiniteMagnitude,
                                   -Float.greatestFiniteMagnitude,
                                   -Float.greatestFiniteMagnitude)
        
        // Recursively traverse all nodes in the scene
        scene.rootNode.enumerateChildNodes { node, _ in
            var localMin = SCNVector3Zero
            var localMax = SCNVector3Zero
            
            // Check if the node has a bounding box
            if node.__getBoundingBoxMin(&localMin, max: &localMax) {
                // Transform the local bounding box to world space
                let transformedMin = node.convertPosition(localMin, to: nil)
                let transformedMax = node.convertPosition(localMax, to: nil)
                
                // Update the global bounding box
                minPoint.x = min(minPoint.x, transformedMin.x)
                minPoint.y = min(minPoint.y, transformedMin.y)
                minPoint.z = min(minPoint.z, transformedMin.z)
                
                maxPoint.x = max(maxPoint.x, transformedMax.x)
                maxPoint.y = max(maxPoint.y, transformedMax.y)
                maxPoint.z = max(maxPoint.z, transformedMax.z)
            }
        }
        
        return (min: minPoint, max: maxPoint)
    }
    
    private func resetCameraValues() {
        self.translateX = 0
        self.translateY = 0
        self.translateZ = 0
        self.rotateX = 0
        self.rotateY = 0
        self.rotateZ = 0
    }
    
    private func addLights(to scene: SCNScene, center: SCNVector3, radius: Float) {
        // Positions for lights around the model
        let lightPositions: [SCNVector3] = [
            SCNVector3(center.x + radius, center.y, center.z), // Right
            SCNVector3(center.x - radius, center.y, center.z), // Left
            SCNVector3(center.x, center.y + radius, center.z), // Top
            SCNVector3(center.x, center.y - radius, center.z), // Bottom
            SCNVector3(center.x, center.y, center.z + radius), // Front
            SCNVector3(center.x, center.y, center.z - radius)  // Back
        ]
        
        for position in lightPositions {
            let lightNode = SCNNode()
            lightNode.light = SCNLight()
            lightNode.light?.type = .omni // Omni-directional light
            lightNode.light?.intensity = 1000 // Adjust intensity as needed
            lightNode.position = position
            scene.rootNode.addChildNode(lightNode)
        }
        
        // Add an ambient light for overall illumination
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.intensity = 500 // Adjust as needed
        scene.rootNode.addChildNode(ambientLightNode)
    }
    
    // Load the scene from the selected .obj file
    private func loadScene(from url: URL) {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            
            // Define loading options
            let options: [SCNSceneSource.LoadingOption: Any] = [
                .checkConsistency: true,
                .createNormalsIfAbsent: true,
                .convertToYUp: true,
                .convertUnitsToMeters: true
            ]
            
            let sceneSource = SCNSceneSource(url: url, options: options)
            
            if let loadedScene = sceneSource?.scene(options: nil) {
                // Calculate bounding box for centering
                let (min, max) = calculateBoundingBox(for: loadedScene)
                let center = SCNVector3(
                    (min.x + max.x) / 2,
                    (min.y + max.y) / 2,
                    (min.z + max.z) / 2
                )
                
                // Translate the root node to center the model
                loadedScene.rootNode.enumerateChildNodes { node, _ in
                    node.position = SCNVector3(
                        node.position.x - center.x,
                        node.position.y - center.y,
                        node.position.z - center.z
                    )
                }
                
                // Apply a white material to all geometries in the scene
                loadedScene.rootNode.enumerateChildNodes { node, _ in
                    if let geometry = node.geometry {
                        let whiteMaterial = SCNMaterial()
                        whiteMaterial.diffuse.contents = UIColor.white
                        geometry.materials = [whiteMaterial]
                    }
                }
                
                // Add a camera if it doesn't exist
                let cameraNode = SCNNode()
                cameraNode.camera = SCNCamera()
                cameraNode.camera?.zFar = [10_000.0, Double(translateZ * 10.0)].max()!
                cameraNode.camera?.zNear = 0.1
                cameraNode.position = SCNVector3(x: 0, y: 0, z: translateZ)
                loadedScene.rootNode.addChildNode(cameraNode)
                
                // Add lights
                let size = SCNVector3(max.x - min.x, max.y - min.y, max.z - min.z)
                var curmax = (max.x > max.y) ? max.x : max.y
                curmax = (max.z > curmax) ? max.z : curmax
                let radius = curmax
                addLights(to: loadedScene, center: SCNVector3Zero, radius: radius)
                
                DispatchQueue.main.async {
                    self.scene = loadedScene
                    self.isLoading = false
                }
            } else {
                // Handle error loading the scene
                DispatchQueue.main.async {
                    print("Failed to load the scene.")
                    self.isLoading = false
                }
            }
            
        }
    }
    
    private func takeScreenShot(sceneView: SCNView?, selectedFileURL: URL?) {
        guard let scnView = sceneView else {
            print("Unable to get scnView")
            return
        }
        guard let selectedFileURL = selectedFileURL else {
            print("Selected file null")
            return
        }
        let image = scnView.snapshot()
        _ = saveImageToCache(image, "\(selectedFileURL.lastPathComponent)")
    }
    
    private func takeScreenshot(scene: SCNScene? = nil, size: CGSize = CGSize(width: 80, height: 80)) {
        guard let currentScene = scene ?? self.scene else { return }
        guard let selectedFileURL = self.selectedFileURL else { return }
        
        let scnView = SCNView(frame: CGRect(origin: .zero, size: size))
        scnView.scene = currentScene
        
        // Set the background color for the scene
        currentScene.background.contents = UIColor.lightGray
        scnView.backgroundColor = UIColor.lightGray
        
        // Configure the camera node to match SCNViewWrapper's camera
        if let cameraNode = currentScene.rootNode.childNodes.first(where: { $0.camera != nil }) {
            // Apply transformations
            let translation = SCNMatrix4MakeTranslation(translateX, translateY, translateZ)
            let rotationX = SCNMatrix4MakeRotation(rotateX * .pi / 180, 1, 0, 0)
            let rotationY = SCNMatrix4MakeRotation(rotateY * .pi / 180, 0, 1, 0)
            let rotationZ = SCNMatrix4MakeRotation(rotateZ * .pi / 180, 0, 0, 1)
            let combinedTransform = SCNMatrix4Mult(SCNMatrix4Mult(SCNMatrix4Mult(rotationX, rotationY), rotationZ), translation)
            
            cameraNode.transform = combinedTransform
        }
        
        currentScene.rootNode.enumerateChildNodes { node, _ in
            if let geometry = node.geometry {
                let whiteMaterial = SCNMaterial()
                whiteMaterial.diffuse.contents = UIColor.white
                geometry.materials = [whiteMaterial]
            }
        }
        
        // Take a snapshot
        let image = scnView.snapshot()
        
        // Save the image to the cache
        _ = saveImageToCache(image, "\(selectedFileURL.lastPathComponent)")
    }
    
    private func downloadFile(context: AddModelView) async {
        do {
            let fileManager = FileManager.default
            // Get the Documents directory
            let documentsURL = try fileManager.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            
            // Define destination URLs for sample files
            let destinationURL1 = documentsURL.appendingPathComponent("Mesh_Anteater.obj")
            let destinationURL2 = documentsURL.appendingPathComponent("rabbit.obj")
            
            // Start downloading files
            let s3Service = try await S3ServiceHandler()
            
            print("Downloading to \(destinationURL1)")
            try await s3Service.downloadFile(
                bucket: "marchingcubesmodels",
                key: "samples/Mesh_Anteater.obj",
                to: destinationURL1
            )
            
            print("Downloading to \(destinationURL2)")
            try await s3Service.downloadFile(
                bucket: "marchingcubesmodels",
                key: "samples/rabbit.obj",
                to: destinationURL2
            )
            
            print("Download completed successfully.")
        } catch {
            print("Error downloading files: \(error)")
        }
    }
}

// UIViewRepresentable for SCNView
struct SCNViewWrapper: UIViewRepresentable {
    var scene: SCNScene
    @Binding var translateZ: Float
    @Binding var translateX: Float
    @Binding var translateY: Float
    @Binding var rotateX: Float
    @Binding var rotateY: Float
    @Binding var rotateZ: Float
    @Binding var sceneView: SCNView?
    var onLoadingComplete: ((SCNScene) -> Void)?
    
    class Coordinator {
        var scnView: SCNView?
        
        init(scnView: SCNView? = nil) {
            self.scnView = scnView
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.allowsCameraControl = true
        scnView.cameraControlConfiguration.allowsTranslation = true
        scnView.backgroundColor = UIColor.lightGray
        scnView.scene = scene
        
        // Notify the parent that the scene is ready
        DispatchQueue.main.async {
            onLoadingComplete?(scene)
        }
        
        // Store the SCNView instance in the coordinator
        context.coordinator.scnView = scnView
        self.sceneView = scnView
        return scnView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        uiView.scene = scene
        
        if let cameraNode = scene.rootNode.childNodes.first(where: { $0.camera != nil }) {
            let translation = SCNMatrix4MakeTranslation(translateX, translateY, translateZ)
            let rotationX = SCNMatrix4MakeRotation(rotateX * .pi / 180, 1, 0, 0)
            let rotationY = SCNMatrix4MakeRotation(rotateY * .pi / 180, 0, 1, 0)
            let rotationZ = SCNMatrix4MakeRotation(rotateZ * .pi / 180, 0, 0, 1)
            
            let combinedTransform = SCNMatrix4Mult(SCNMatrix4Mult(SCNMatrix4Mult(rotationX, rotationY), rotationZ), translation)
            cameraNode.transform = combinedTransform
        }
        
        // Update SCNView in the coordinator
        context.coordinator.scnView = uiView
        self.sceneView = uiView
    }
    
    func getCurrentSCNView(context: Context) -> SCNView? {
        return context.coordinator.scnView
    }
}


struct Upload_Previews: PreviewProvider {
    static var previews: some View {
        AddModelView()
    }
}


//
//struct AddModelView: View {
//    @State private var selectedFileURL: URL?
//    @State private var showDocumentPicker = false
//    @State private var scene: SCNScene? = nil
//    @State private var zoomLevel: Float = 20.0 // Initial zoom level
//    @EnvironmentObject var viewModel: ProjectViewModel
//    @StateObject private var dataLoader = VoxelDataLoader()
//    @Environment(\.modelContext) var modelContext

//
//    var body: some View {
//        ZStack {
//            VStack {
//                Text("Add Your Model")
//                    .font(.largeTitle)
//                    .fontWeight(.bold)
//                    .padding(.top)
//
//                ZStack {
//                    RoundedRectangle(cornerRadius: 10)
//                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [10, 5]))
//                        .frame(height: 400)
//                        .foregroundColor(.gray)
//                        .overlay(
//                            Group {
//                                if dataLoader.isActive && dataLoader.isLoading {
//                                    Text("Loading...")
//                                        .foregroundColor(.gray)
//                                } else if let scnNodes = dataLoader.scnNodesByLayer[0] {
//                                    SceneView(scnNodes: scnNodes, labelText: "Preview", backgroundColor: UIColor.blue) { scnScene in
//                                        self.scene = scnScene
//                                    }
//                                    .frame(height: 400)
//                                    .onAppear {
//                                        if let scene = scene {
//                                            takeScreenshot(scene: scene)
//                                        }
//                                    }
//                                } else {
//                                    Text("Choose file (.obj)")
//                                        .foregroundColor(.gray)
//                                }
//                            }
//                        )
//                        .padding(.horizontal)
//                        .padding(.top)
//                        .onTapGesture {
//                            showDocumentPicker = true
//                        }
//                }
//                .sheet(isPresented: $showDocumentPicker) {
//                    DocumentPicker { url in
//                        self.selectedFileURL = url
//                        dataLoader.isActive = true
//                        saveDocumentToCache(from: url)
//                        if let fileUrl = self.selectedFileURL {
//                            dataLoader.loadVoxelData2(filename: fileUrl.lastPathComponent, divisions: 5)
//                        }
//                        showDocumentPicker = false
//                    }
//                }
//
//                Spacer()
//
//                Button(action: {
//                    isDownloading = true // Block UI
//                    Task {
//                        await downloadFile(context: self)
//                        isDownloading = false // Unblock UI
//                    }
//                }) {
//                    Text("Download Sample Files")
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                }
//                .padding(.horizontal)
//
//                Spacer()
//            }
//            .disabled(isDownloading) // Disable user interaction during download
//
//            // Overlay when downloading
//            if isDownloading {
//                Color.black.opacity(0.5)
//                    .ignoresSafeArea()
//                VStack {
//                    ProgressView("Downloading...")
//                        .progressViewStyle(CircularProgressViewStyle())
//                        .padding()
//                    Text("\(Int(downloadProgress * 100))% completed")
//                        .font(.subheadline)
//                        .foregroundColor(.white)
//                }
//            }
//
//            Spacer()
//
//            // Conditional Button: Plus or Save
//            if let url = selectedFileURL {
//                Button(action: {
//                    guard let fileURL = selectedFileURL else { return }
//                    viewModel.addModel(title: fileURL.lastPathComponent, image: "\(fileURL.lastPathComponent).png", modelContext: modelContext)
//                    saveDocumentToCache(from: fileURL)
//                    takeScreenshot(scene: scene)
//                    print("Model obj filename: ", fileURL.lastPathComponent)
//                    print("Models inside save: ", viewModel.models)
//                    selectedFileURL = nil
//                    dataLoader.isLoading = true
//                    dataLoader.isActive = false
//                    dataLoader.scnNodesByLayer = [:]
//                    // scene = nil // Clear the scene after saving
//                }) {
//                    Image(systemName: "square.and.arrow.down")
//                        .font(.system(size: 24))
//                        .padding()
//                        .background(Color.green)
//                        .foregroundColor(.white)
//                        .clipShape(Circle())
//                        .shadow(radius: 5)
//                }
//                .padding(.bottom, 30)
//            } else {
//                Button(action: {
//                    showDocumentPicker = true
//                }) {
//                    Image(systemName: "plus")
//                        .font(.system(size: 24))
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .clipShape(Circle())
//                        .shadow(radius: 5)
//                }
//                .padding(.bottom, 30)
//            }
//        }
//        .padding()
//        }
//
//
//    private func takeScreenshot(scene: SCNScene?, size: CGSize = CGSize(width: 80, height: 80)) {
//        guard let currentScene = scene else { return }
//        guard let selectedFileURL = self.selectedFileURL else { return }
//
//        let scnView = SCNView(frame: CGRect(origin: .zero, size: size))
//        scnView.scene = currentScene
//        scnView.backgroundColor = UIColor.clear
//        let image = scnView.snapshot()
//
//        saveImageToCache(image, "\(selectedFileURL.lastPathComponent)")
//    }
//}
