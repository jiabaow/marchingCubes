//
//  ContentView.swift
//  MarchingCubeDemoVoxel
//
//  Created by Charles Weng on 10/18/24.
//

import SwiftUI
import Foundation
import ModelIO
import SceneKit
    
let DIVISIONS = 2

struct SceneView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> SCNView {
        let obj = loadOBJ(filename: "tank")
        let voxarr = voxelize(asset: obj!)
        let scnode = voxelArrayToNode(voxelArray: voxarr!)
        
        
        let scnView = SCNView()
        scnView.allowsCameraControl = true
        scnView.showsStatistics = true
        scnView.backgroundColor = UIColor.black

        // Create and configure the scene
        let scene = SCNScene()

        // Create a light source and add it to the scene
        let light = SCNLight()
        light.type = .omni
        light.color = UIColor.white
        let lightNode = SCNNode()
        lightNode.position = SCNVector3(x: 0, y: 2, z: 50)  // Position the light above the scene
        scene.rootNode.addChildNode(lightNode)
        scene.rootNode.addChildNode(scnode)

        // Create a camera and add it to the scene
        let camera = SCNCamera()
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 0, y: 2, z: 0.8) // Adjust position as needed
        cameraNode.look(at: SCNVector3(0, 0, 0))
//        cameraNode.camera?.fieldOfView = 100
        // Look at the origin
        scene.rootNode.addChildNode(cameraNode)

        // Example of creating a voxel array (replace with your actual voxel array)
        // let voxelArray: MDLVoxelArray = ... // Your voxel array initialization here

        // Create a simple voxel cube for demonstration
        let voxelGeometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        let voxelMaterial = SCNMaterial()
        voxelMaterial.diffuse.contents = UIColor.red
        voxelGeometry.materials = [voxelMaterial]
        let voxelNode = SCNNode(geometry: voxelGeometry)
        voxelNode.position = SCNVector3(0, 0, 0) // Position the voxel cube
//        scene.rootNode.addChildNode(voxelNode)
        

        // Set the scene to the SCNView
        scnView.scene = scene

        return scnView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        // Handle updates if needed
    }
}

func loadOBJ(filename: String) -> MDLAsset? {
    guard let url = Bundle.main.url(forResource: filename, withExtension: "obj") else {
        print("Failed to find the .obj file.")
        return nil
    }
    
    // Create an MDLAsset from the .obj file URL
    let asset = MDLAsset(url: url)
    
    // Optional: Load textures/materials if available
    asset.loadTextures()

    if let object = asset.object(at: 0) as? MDLMesh {
        print("Successfully loaded: \(object)")
    } else {
        print("Failed to convert .obj to MDLMesh.")
    }

    return asset
}

// Function to voxelize an MDLAsset
func voxelize(asset: MDLAsset, divisions: Int32 = Int32(DIVISIONS)) -> MDLVoxelArray? {
    guard asset.object(at: 0) is MDLMesh else {
        print("Failed to extract MDLMesh.")
        return nil
    }
    
    // Create a voxel array with the specified divisions
    let voxelArray = MDLVoxelArray(asset: asset, divisions: divisions, patchRadius: 0)
    print("Voxelization complete: \(voxelArray.count) voxels generated.")
    
    return voxelArray
}



func getVoxelCoordinates(index: Int, divisions: Int) -> (x: Int, y: Int, z: Int) {
    let width = divisions
    let height = divisions
    let depth = divisions
    
    let x = index % width
    let y = (index / width) % height
    let z = index / (width * height)
    
    return (x, y, z)
}



/// Converts an `MDLVoxelArray` into a SceneKit node with individual voxel cubes.
func voxelArrayToNode(voxelArray: MDLVoxelArray, voxelSize: Float = 0.1) -> SCNNode {
    let parentNode = SCNNode()  // Root node to hold all voxels

    // Iterate through all voxels in the array
    let voxelCoordinates = voxelArray.voxelIndices()
    

    for voxel in voxelCoordinates! {
        // Extract x, y, z coordinates using the getVoxelCoordinates function
        let (x, y, z) = getVoxelCoordinates(index: Int(voxel), divisions: DIVISIONS)
        
        // Create a cube for each voxel
        let voxelGeometry = SCNBox(width: CGFloat(voxelSize),
                                   height: CGFloat(voxelSize),
                                   length: CGFloat(voxelSize),
                                   chamferRadius: 0)

        // Optional: Apply a material to the cube
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red  // Change color as needed
        voxelGeometry.materials = [material]

        // Create a node for the voxel cube
        let voxelNode = SCNNode(geometry: voxelGeometry)

        // Position the node according to its coordinates
        voxelNode.position = SCNVector3(
                    Float(x) * voxelSize,
                    Float(y) * voxelSize,
                    Float(z) * voxelSize
                )

        // Add the voxel node to the parent node
        parentNode.addChildNode(voxelNode)
    }

    return parentNode
}


struct ContentView: View {
    var body: some View {
        VStack {
            SceneView() // Integrate the SceneView here
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
