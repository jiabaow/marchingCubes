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

// Load an OBJ file from a URL
func loadOBJ(filename: URL) -> MDLAsset? {
    return MDLAsset(url: filename)
}

// Load an OBJ file from the app bundle using its filename
func loadOBJ(filename: String) -> MDLAsset? {
    guard let url = Bundle.main.url(forResource: filename, withExtension: "obj") else {
        print("Failed to find the .obj file.")
        return nil
    }
    return MDLAsset(url: url)
}

// Voxelize a given MDLAsset with specified divisions
func voxelize(asset: MDLAsset, divisions: Int32) -> MDLVoxelArray? {
    guard let mesh = asset.object(at: 0) as? MDLMesh else {
        print("Failed to extract MDLMesh.")
        return nil
    }
    return MDLVoxelArray(asset: asset, divisions: divisions, patchRadius: 0)
}

// Test function to create a cube node using SceneKit
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

//    parentNode.addChildNode(createBall(at: v_a1, radius: 0.05, color: UIColor.red))
//    parentNode.addChildNode(createBall(at: v_a2, radius: 0.05, color: UIColor.green))
//    parentNode.addChildNode(createBall(at: v_a3, radius: 0.05, color: UIColor.blue))
//    parentNode.addChildNode(createBall(at: v_a4, radius: 0.05, color: UIColor.yellow))
//    parentNode.addChildNode(createBall(at: v_b1, radius: 0.05, color: UIColor.cyan))
//    parentNode.addChildNode(createBall(at: v_b2, radius: 0.05, color: UIColor.magenta))
//    parentNode.addChildNode(createBall(at: v_b3, radius: 0.05, color: UIColor.orange))
//    parentNode.addChildNode(createBall(at: v_b4, radius: 0.05, color: UIColor.purple))
    
    let algo = MarchingCubesAlgo()
  
//  algo.getMC4_4(vertices: &vertices, indices: &indices, v1: v_a1, v2: v_a2, v3: v_a3, v4: v_a4, v5: v_b1, v6: v_b2, v7: v_b3, v8: v_b4)
    
//    parentNode.addChildNode(marchingCubes2D(data:[[0, 0, 0], [ 0, 1, 0],[0, 0, 0]]))

    
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

func getCube(cube: String, colorScheme: ColorScheme) -> SCNNode {
    let parentNode = SCNNode() // Create a parent node to hold all generated nodes
    
    var a1: Int = 1
    var a2: Int = 1
    var a3: Int = 1
    var a4: Int = 1
    var b1: Int = 1
    var b2: Int = 1
    var b3: Int = 1
    var b4: Int = 1
    
    let algo = MarchingCubesAlgo()
    switch cube {
    case "MC0_1":
        a1 = 1
    case "MC7_1":
        a1 = 0
        a2 = 0
        a3 = 0
        a4 = 0
        b1 = 0
        b2 = 0
        b3 = 0
    case "MC1_1":
        a1 = 0
    case "MC2_1":
        a1 = 0
        a3 = 0
    case "MC6_3":
        a1 = 0
        a3 = 0
        b1 = 0
        b2 = 0
        b3 = 0
        b4 = 0
    case "MC2_2":
        a2 = 0
        b2 = 0
    case "MC6_2":
        a1 = 0
        a2 = 0
        a3 = 0
        b1 = 0
        b2 = 0
        b3 = 0
    case "MC2_3":
        a2 = 0
        b4 = 0
//    case "MC2_3N":
    case "MC3_1":
        a1 = 0
        b1 = 0
        a3 = 0
    case "MC5_6":
        a2 = 0
        a4 = 0
        b2 = 0
        b3 = 0
        b4 = 0
    case "MC3_3":
        a1 = 0
        a3 = 0
        b2 = 0
    case "MC3_4":
        a1 = 0
        a2 = 0
        b2 = 0
    case "MC5_4":
        a1 = 0
        a2 = 0
        b1 = 0
        b2 = 0
        a3 = 0
    case "MC4_1":
        a1 = 0
        b2 = 0
        a3 = 0
        b4 = 0
    case "MC4_2":
        a1 = 0
        a3 = 0
        b3 = 0
        b4 = 0
    case "MC4_3":
        b1 = 0
        b2 = 0
        a3 = 0
        a4 = 0
    case "MC4_4":
        a1 = 0
        a2 = 0
        b1 = 0
        b2 = 0
    case "MC4_5":
        a1 = 0
        a2 = 0
        b2 = 0
        a3 = 0
    case "MC4_6":
        a1 = 0
        a4 = 0
        b3 = 0
        a3 = 0
    case "MC4_7":
        a2 = 0
        a3 = 0
        a4 = 0
        b4 = 0
    case "MC5_5":
        a2 = 0
        a3 = 0
        a4 = 0
        b3 = 0
        b1 = 0
    default:
        print("received an unknown cube", cube)
    }
    
    let voxelData : [[[Int]]] = [
        [[b4, a4],
         [b1, a1]],
        [[b3, a3],
         [b2, a2]]
    ]
    
    parentNode.addChildNode(algo.marchingCubesV2(data: voxelData))
    
    parentNode.addChildNode(drawShapeWithColorForCubes(a1: a1, a2: a2, a3: a3, a4: a4, b1: b1, b2: b2, b3: b3, b4: b4, colorScheme: colorScheme))
    
    parentNode.addChildNode(createBall(at: SCNVector3(-0.5, -0.5, -0.5), radius: 0.001, color: .white))
    parentNode.addChildNode(createBall(at: SCNVector3(1.5, 1.5, 1.5), radius: 0.001, color: .white))
    return parentNode
}

func drawShapeWithColorForCubes(a1: Int, a2: Int, a3: Int, a4: Int,
                                b1: Int, b2: Int, b3: Int, b4: Int, colorScheme: ColorScheme)-> SCNNode {
    let parentNode = SCNNode()
    // 6 faces of the cube
    let tbl = [
        [[b1, a1], [b2, a2]],
        [[b4, a4], [b3, a3]],
        [[b4, a4], [b1, a1]],
        [[b3, a3], [b2, a2]],
        [[a1, a4], [a2, a3]],
        [[b1, b4], [b2, b3]]
    ]
    let algo = MarchingCubes2D(colorScheme: colorScheme)
    let node1 = algo.marchingCubes2D(data: tbl[0])
    node1.position.y += 1.01
    parentNode.addChildNode(node1)
    
    let node2 = algo.marchingCubes2D(data: tbl[1])
    node2.position.y += -0.01
    parentNode.addChildNode(node2)
    
    let node3 = algo.marchingCubes2D(data: tbl[2])
    node3.eulerAngles.z += Float.pi / 2
    node3.position.x += -0.01
    parentNode.addChildNode(node3)
    
    let node4 = algo.marchingCubes2D(data: tbl[3])
    node4.eulerAngles.z += Float.pi / 2
    node4.position.x += 1.01
    parentNode.addChildNode(node4)

    let node5 = algo.marchingCubes2D(data: tbl[4])
    node5.eulerAngles.x += Float.pi / 2
    node5.position.y += 1
    node5.position.z += 1.01
    parentNode.addChildNode(node5)
    
    let node6 = algo.marchingCubes2D(data: tbl[5])
    node6.eulerAngles.x += Float.pi / 2
    node6.position.y += 1
    node6.position.z += -0.01
    parentNode.addChildNode(node6)
    
    return parentNode
}


func convertTo3DArray(voxelArray: MDLVoxelArray) -> [[[Int]]] {
    // Retrieve the voxel indices
    guard let voxelData = voxelArray.voxelIndices() else {
        return []
    }

    let voxelCount = voxelData.count / MemoryLayout<MDLVoxelIndex>.stride
    var minX = Int.max, minY = Int.max, minZ = Int.max
    var maxX = Int.min, maxY = Int.min, maxZ = Int.min

    // Calculate the minimum and maximum indices to determine the grid size
    voxelData.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) in
        let voxelIndices = pointer.bindMemory(to: MDLVoxelIndex.self)
        for i in 0..<voxelCount {
            let voxelIndex = voxelIndices[i]
            minX = min(minX, Int(voxelIndex.x) - 1)
            minY = min(minY, Int(voxelIndex.y) - 1)
            minZ = min(minZ, Int(voxelIndex.z) - 1)
            maxX = max(maxX, Int(voxelIndex.x) + 1)
            maxY = max(maxY, Int(voxelIndex.y) + 1)
            maxZ = max(maxZ, Int(voxelIndex.z) + 1)
        }
    }

    // Calculate the size of the grid
    let sizeX = maxX - minX + 1
    let sizeY = maxY - minY + 1
    let sizeZ = maxZ - minZ + 1

    // Initialize the 3D array
    var voxelGrid = Array(
        repeating: Array(
            repeating: Array(repeating: 0, count: sizeZ),
            count: sizeY
        ),
        count: sizeX
    )

    // Populate the 3D array with voxel data
    voxelData.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) in
        let voxelIndices = pointer.bindMemory(to: MDLVoxelIndex.self)
        for i in 0..<voxelCount {
            let voxelIndex = voxelIndices[i]
            let x = Int(voxelIndex.x) - minX
            let y = Int(voxelIndex.y) - minY
            let z = Int(voxelIndex.z) - minZ
            voxelGrid[x][y][z] = 1
        }
    }

    return voxelGrid
}

// Extract all non-zero layers from a 3D data array
func getAllLayers(data: [[[Int]]]) -> [[[Int]]] {
    var layeredData: [[[Int]]] = []
    
    // Initialize bounds for non-empty layers
    var li: Int = data.count
    var ri: Int = 0
    var lj: Int = data[0].count
    var rj: Int = 0
    var lk: Int = data[0][0].count
    var rk: Int = 0
    
    let xDim = data.count - 1
    let yDim = data[0].count - 1
    let zDim = data[0][0].count - 1
    
    // Determine bounds of non-empty layers
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
    
    // Extract layers within bounds
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

// Get a 2D slice from a specific layer in a 3D data array
func get2DDataFromLayer(data: [[[Int]]], numLayer: Int) -> [[Int]] {
    var layeredData: [[Int]] = []
    if (numLayer < 0 || numLayer > data[0].count) {
        print("wrong numLayer input, in get2DDataFromLayer, numLayer", numLayer)
        return []
    }
    
    for i in 0..<data.count {
        var row: [Int] = []
        for k in 0..<data[i][numLayer].count {
            row.append(data[i][numLayer][k])
        }
        layeredData.append(row)
    }
    return layeredData
}

// Get layered data from a 3D data array up to a specific layer
func getLayeredData(data: [[[Int]]], numLayer: Int) -> [[[Int]]] {
    var layeredData: [[[Int]]] = []
    if (numLayer < 0 || numLayer > data[0].count) {
        print("wrong numLayer input, in getLayeredData, numLayer", numLayer)
        return []
    }
    for i in 0..<data.count {
        var layer2D: [[Int]] = []
        for j in 0..<numLayer {
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

// Create a sphere node at a given position with specified radius and color
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

// Multiplication by scalar
func *(lhs: SCNVector3, rhs: Float) -> SCNVector3 {
    return SCNVector3(lhs.x * rhs, lhs.y * rhs, lhs.z * rhs)
}

// Apply mirror symmetry to a set of vertices along a specified axis
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
