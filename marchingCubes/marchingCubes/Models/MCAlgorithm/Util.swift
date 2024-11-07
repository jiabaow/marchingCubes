//
//  Util.swift
//  marchingCubes
//
//  Created by Mingxin Hou on 10/31/24.
//

import SceneKit
import ModelIO

// Test function to load and process the rabbit OBJ file
func testRabbitModel() {
    if let obj = loadOBJ(filename: "rabbit") {
        print("Successfully loaded the rabbit model.")
        
        if let voxarr = voxelize(asset: obj, divisions: 5) {
            print("Successfully voxelized the model.")
            
            let voxelGrid = convertTo3DArray(voxelArray: voxarr)
            print("Voxel grid size: \(voxelGrid.count) x \(voxelGrid[0].count) x \(voxelGrid[0][0].count)")
            
            let mcNode = marchingCubes(data: voxelGrid)
            print("Marching cubes node created with geometry: \(mcNode.geometry?.description ?? "None")")
        } else {
            print("Failed to voxelize the model.")
        }
    } else {
        print("Failed to load the rabbit model.")
    }
}

func loadOBJ(filename: URL) -> MDLAsset? {
    return MDLAsset(url: filename)
}

func loadOBJ(filename: String) -> MDLAsset? {
    guard let url = Bundle.main.url(forResource: filename, withExtension: "obj") else {
        print("Failed to find the .obj file.")
        return nil
    }
    return MDLAsset(url: url)
}

func voxelize(asset: MDLAsset, divisions: Int32) -> MDLVoxelArray? {
    guard let mesh = asset.object(at: 0) as? MDLMesh else {
        print("Failed to extract MDLMesh.")
        return nil
    }
    return MDLVoxelArray(asset: asset, divisions: divisions, patchRadius: 0)
}

func testGetCube() -> SCNNode{
    let parentNode = SCNNode() // Create a parent node to hold all generated nodes
    var vertices: [SCNVector3] = []
    var indices: [Int32] = []
    
    let i = 0
    let j = 0
    let k = 0
    
    // vertices
    let v_b4 = SCNVector3(Float(i), Float(j), Float(k))
    let v_b3 = SCNVector3(Float(i) + 1, Float(j), Float(k))
    let v_a3 = SCNVector3(Float(i) + 1, Float(j), Float(k) + 1)
    let v_a4 = SCNVector3(Float(i), Float(j), Float(k) + 1)
    let v_b1 = SCNVector3(Float(i), Float(j) + 1, Float(k))
    let v_b2 = SCNVector3(Float(i) + 1, Float(j) + 1, Float(k))
    let v_a2 = SCNVector3(Float(i) + 1, Float(j) + 1, Float(k) + 1)
    let v_a1 = SCNVector3(Float(i), Float(j) + 1, Float(k) + 1)
    
    parentNode.addChildNode(createBall(at: v_a1, radius: 0.05, color: UIColor.red))
    parentNode.addChildNode(createBall(at: v_a2, radius: 0.05, color: UIColor.green))
    parentNode.addChildNode(createBall(at: v_a3, radius: 0.05, color: UIColor.blue))
    parentNode.addChildNode(createBall(at: v_a4, radius: 0.05, color: UIColor.yellow))
    parentNode.addChildNode(createBall(at: v_b1, radius: 0.05, color: UIColor.cyan))
    parentNode.addChildNode(createBall(at: v_b2, radius: 0.05, color: UIColor.magenta))
    parentNode.addChildNode(createBall(at: v_b3, radius: 0.05, color: UIColor.orange))
    parentNode.addChildNode(createBall(at: v_b4, radius: 0.05, color: UIColor.purple))
    
    
    getMC3_4N(vertices: &vertices, indices: &indices, v1: v_a2, v2: v_b2,
             v3: v_b1, v4: v_a1, v5: v_a3, v6: v_b3, v7: v_b4, v8: v_a4)
    
    if (vertices.count != 0 && indices.count != 0) {
        // Create geometry source
        let vertexSource = SCNGeometrySource(vertices: vertices)
        
        // Create geometry element
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        
        // Create geometry
        let geometry = SCNGeometry(sources: [vertexSource], elements: [element])
        
        // Create a material and make it double-sided
        let material = SCNMaterial()
        material.isDoubleSided = true
        
        // Assign the material to the geometry
        geometry.materials = [material]
        
        // Use the geometry in a node
        let node = SCNNode(geometry: geometry)
        
        parentNode.addChildNode(node)
    }
    
    return parentNode
}

func convertTo3DArray(voxelArray: MDLVoxelArray) -> [[[Int]]] {
    let extent = voxelArray.boundingBox
    let sizeX = Int((extent.maxBounds.x - extent.minBounds.x) * 4)
    let sizeY = Int((extent.maxBounds.y - extent.minBounds.y) * 4)
    let sizeZ = Int((extent.maxBounds.z - extent.minBounds.z) * 4)
    
    var voxelGrid = Array(
        repeating: Array(
            repeating: Array(repeating: 0, count: sizeZ),
            count: sizeY
        ),
        count: sizeX
    )

    if let voxelData = voxelArray.voxelIndices() {
        let voxelCount = voxelData.count / MemoryLayout<MDLVoxelIndex>.stride
        voxelData.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) in
            let voxelIndices = pointer.bindMemory(to: MDLVoxelIndex.self)
            for i in 0..<voxelCount {
                let voxelIndex = voxelIndices[i]
                let x = Int(voxelIndex.x)
                let y = Int(voxelIndex.y)
                let z = Int(voxelIndex.z)
                if x >= 0 && x < sizeX && y >= 0 && y < sizeY && z >= 0 && z < sizeZ {
                    voxelGrid[x][y][z] = 1
                } else {
                    print("Index out of bounds: (\(x), \(y), \(z))")
                }
            }
        }
    }

    return voxelGrid
}

func createBall(at position: SCNVector3, radius: CGFloat, color: UIColor) -> SCNNode {
    // Create a sphere geometry with the specified radius
    let sphereGeometry = SCNSphere(radius: radius)
    
    // Create a material for the sphere
    let sphereMaterial = SCNMaterial()
    sphereMaterial.diffuse.contents = color
    sphereGeometry.materials = [sphereMaterial]
    
    // Create a node with the sphere geometry
    let sphereNode = SCNNode(geometry: sphereGeometry)
    
    // Set the position of the node
    sphereNode.position = position
    
    // Return the created sphere node
    return sphereNode
}

// Define custom operators for SCNVector3
// Subtraction
func -(lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
    return SCNVector3(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z)
}

// Addition
func +(lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
    return SCNVector3(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
}

// Division by scalar
func /(lhs: SCNVector3, rhs: Float) -> SCNVector3 {
    return SCNVector3(lhs.x / rhs, lhs.y / rhs, lhs.z / rhs)
}

func applyMirrorSymmetry(to vertices: inout [SCNVector3], along axis: String, through point: SCNVector3) {
    for index in vertices.indices {
        // Translate the vertex to the origin relative to the specified point
        var translatedVertex = vertices[index] - point
        
        // Apply the mirror symmetry
        switch axis {
        case "x":
            translatedVertex.x = -translatedVertex.x
        case "y":
            translatedVertex.y = -translatedVertex.y
        case "z":
            translatedVertex.z = -translatedVertex.z
        default:
            print("Invalid axis specified. Use 'x', 'y', or 'z'.")
            return
        }
        
        // Translate the vertex back to its original position
        vertices[index] = translatedVertex + point
    }
}
