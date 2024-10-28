//
//  File.swift
//  marchingCubes
//
//  Created by Charles Weng on 10/27/24.
//

import SwiftUI
import SceneKit
import Voxels

struct CubeView: View {
    var body: some View {
        CubeViewRep()
    }
}

struct CubeView_Previews: PreviewProvider {
    static var previews: some View {
        CubeViewRep()
    }
}

struct CubeViewRep: UIViewRepresentable {
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView(frame: .zero)
        setupSceneView(scnView: scnView)
        createVoxelMesh(scnView: scnView)
        return scnView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        // Update the view if necessary
    }

    private func setupSceneView(scnView: SCNView) {
        let scene = SCNScene()
        scnView.scene = scene
        scnView.allowsCameraControl = true
        scnView.showsStatistics = true
        scnView.autoenablesDefaultLighting = true // Optional: enable lighting
    }

    private func createVoxelMesh(scnView: SCNView) {
        let asset3d = loadOBJ(filename: "rabbit")
        let voxelData = convertTo3DArray(voxelArray: voxelize(asset: asset3d!, divisions: 15)!)
        

        // Create the marching cubes renderer
        let marchingCubesRenderer = MarchingCubesRenderer()
        
        // Define the origin and cube size for the voxel data
        let origin = SIMD3<Float>(0, 0, 0) // Origin of the voxel grid
        let cubeSize: Float = 1.0 // Size of each voxel cube
        let spacing: Float = 2.0
        let scale = VoxelScale(origin: origin, cubeSize: cubeSize) // Create the scale with origin and size
            
        // Define the bounds for the voxel data using tuples
        let minBounds = (0, 0, 0) // Minimum coordinates for the voxel grid
        let maxBounds = (voxelData.count, voxelData[0].count, voxelData[0][0].count) // Maximum coordinates for the voxel grid
        let bounds = VoxelBounds(min: minBounds, max: maxBounds) // Create VoxelBounds using tuples
        
        var voxelArray = VoxelArray<Float>(bounds: bounds, initialValue: 0.0)
        let xDim = voxelData.count - 1
        let yDim = voxelData[0].count - 1
        let zDim = voxelData[0][0].count - 1
        print(xDim, yDim, zDim)

        for i in 0..<xDim {
            for j in 0..<yDim {
                for k in 0..<zDim {
                    voxelArray.set(VoxelIndex(i, j, k), newValue: Float(voxelData[i][j][k]))
                    
                    // Position adjustment
                    let position = SIMD3<Float>(
                        Float(i) * (cubeSize + spacing),
                        Float(j) * (cubeSize + spacing),
                        Float(k) * (cubeSize + spacing)
                    )
                    
                    // Only create a cube if it's filled
                    if voxelData[i][j][k] > 0 {
                        // Create a cube node for the filled voxel
                        let cubeNode = createCubeNode(size: cubeSize)
                        cubeNode.position = SCNVector3(position.x, position.y, position.z)
                        scnView.scene?.rootNode.addChildNode(cubeNode)
                    }
                }
            }
        }

        // Create the mesh buffer from the voxel data
        let meshBuffer = marchingCubesRenderer.render(voxelArray, scale: scale, within: bounds, adaptive: false)

        // Convert the MeshBuffer to SCNGeometry
        if let geometry = SCNGeometry(meshBuffer: meshBuffer) {
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.blue
            geometry.materials = [material]
            
            // Adjust vertex positions for spacing
            let newGeometry = adjustVertexPositions(for: geometry, spacing: spacing)

            // Create a single node for the entire geometry
            let node = SCNNode(geometry: newGeometry)
            
            // Optionally, position the node in the scene
            node.position = SCNVector3(Float(xDim) * (cubeSize / 2), Float(yDim) * (cubeSize / 2), Float(zDim) * (cubeSize / 2))
            
            scnView.scene?.rootNode.addChildNode(node)
        } else {
            print("Failed to create SCNGeometry from MeshBuffer.")
        }
    }
}

private func adjustVertexPositions(for geometry: SCNGeometry, spacing: Float) -> SCNGeometry? {
    let sources = geometry.sources(for: .vertex)

    // Create a new array to hold adjusted vertices
    var adjustedVertices = [SCNVector3]()
    
    for source in sources {
        let vertexCount = source.vectorCount
        
        // Access the raw vertex data
        let data = source.data
        let stride = MemoryLayout<SCNVector3>.size

        // Read and adjust the vertex data
        for i in 0..<vertexCount {
            let offset = i * stride
            let vertex = data.withUnsafeBytes {
                $0.load(fromByteOffset: offset, as: SCNVector3.self)
            }
            // Adjust positions
            adjustedVertices.append(SCNVector3(vertex.x + spacing, vertex.y + spacing, vertex.z + spacing))
        }
    }

    // Create a new geometry with the adjusted vertices
    let newSource = SCNGeometrySource(vertices: adjustedVertices)
    let element = geometry.elements.first!

    // Create new SCNGeometry with the modified vertex source
    let newGeometry = SCNGeometry(sources: [newSource], elements: [element])
    return newGeometry
}



private func createCubeNode(size: Float) -> SCNNode {
    let boxGeometry = SCNBox(width: CGFloat(size), height: CGFloat(size), length: CGFloat(size), chamferRadius: 0)
    let material = SCNMaterial()
    material.diffuse.contents = UIColor.blue
    boxGeometry.materials = [material]
    return SCNNode(geometry: boxGeometry)
}

// A simple extension to convert MeshBuffer to SCNGeometry
extension SCNGeometry {
    convenience init?(meshBuffer: MeshBuffer) {
        guard !meshBuffer.positions.isEmpty, !meshBuffer.indices.isEmpty else {
            print("MeshBuffer does not contain valid positions or indices.")
            return nil
        }

        // Convert positions from SIMD3<Float> to SCNVector3
        let positionArray = meshBuffer.positions.map { SCNVector3($0.x, $0.y, $0.z) }
        
        // Convert normals from SIMD3<Float> to SCNVector3
        let normalArray = meshBuffer.normals.map { SCNVector3($0.x, $0.y, $0.z) }

        let positionSource = SCNGeometrySource(vertices: positionArray)
        let normalSource = SCNGeometrySource(normals: normalArray)
        let element = SCNGeometryElement(indices: meshBuffer.indices, primitiveType: .triangles)

        self.init(sources: [positionSource, normalSource], elements: [element])
    }
}
