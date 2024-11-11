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
            
            let data = getLayeredData(data: voxelGrid, numLayer: -1)
            
//            let mcNode = marchingCubes(data: voxelGrid)
//            print("Marching cubes node created with geometry: \(mcNode.geometry?.description ?? "None")")
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
    
    let algo = MarchingCubesAlgo()
    
    algo.getMC4_2(vertices: &vertices, indices: &indices, v1: v_a3, v2: v_a4, v3: v_a1, v4: v_a2, v5: v_b3, v6: v_b4, v7: v_b1, v8: v_b2)
    
    if (vertices.count != 0 ) {
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
        
        let element4Lines = SCNGeometryElement(indices: algo.indices4Lines, primitiveType: .line)
        let geometry4Lines = SCNGeometry(sources: [vertexSource], elements: [element4Lines])
        let material4Lines = SCNMaterial()
            material4Lines.diffuse.contents = UIColor.black
        geometry4Lines.materials = [material4Lines]
        let node4Lines = SCNNode(geometry: geometry4Lines)
        parentNode.addChildNode(node4Lines)
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

func getAllLayers(data: [[[Int]]]) -> [[[Int]]] {
    var layeredData: [[[Int]]] = []
    
    var li: Int = data.count
    var ri: Int = 0
    var lj: Int = data[0].count
    var rj: Int = 0
    var lk: Int = data[0][0].count
    var rk: Int = 0
    
    let xDim = data.count - 1
    let yDim = data[0].count - 1
    let zDim = data[0][0].count - 1
    
    for i in 0..<xDim {
        for j in 0..<yDim {
            for k in 0..<zDim {
                let b4 = data[i][j][k]
                let b3 = data[i+1][j][k]
                let a3 = data[i+1][j][k+1]
                let a4 = data[i][j][k+1]
                let b1 = data[i][j+1][k]
                let b2 = data[i+1][j+1][k]
                let a2 = data[i+1][j+1][k+1]
                let a1 = data[i][j+1][k+1]

                if (a1 + a2 + a3 + a4 + b1 + b2 + b3 + b4 > 0) {
                    li = min(li, i)
                    ri = max(ri, i)
                    lj = min(lj, j)
                    rj = max(rj, j)
                    lk = min(lk, k)
                    rk = max(rk, k)
                }
            }
        }
    }
    

    for i in li...ri+1 {
        var layer2D: [[Int]] = []
        for j in lj...rj+1 {
            var row: [Int] = []
            for k in lk...rk+1 {
                row.append(data[i][j][k])
            }
            layer2D.append(row)
        }
        layeredData.append(layer2D)
    }
    return layeredData
}

func getLayeredData(data: [[[Int]]], numLayer: Int) -> [[[Int]]] {
    var layeredData: [[[Int]]] = []

    for i in 0..<data.count {
        var layer2D: [[Int]] = []
        for j in 0..<min(numLayer, data[i].count) {
            var row: [Int] = []
            for k in 0..<data[i][j].count {
                row.append(data[i][j][k])
            }
            layer2D.append(row)
        }
        layeredData.append(layer2D)
    }
    return layeredData
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
