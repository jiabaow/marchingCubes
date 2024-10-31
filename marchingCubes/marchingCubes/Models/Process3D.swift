//
//  Process3D.swift
//  marchingCubes
//
//  Created by Mingxin Hou on 10/23/24.
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

func loadOBJ(filename: String) -> MDLAsset? {
    guard let url = Bundle.main.url(forResource: filename, withExtension: "obj") else {
        print("Failed to find the .obj file.")
        return nil
    }
    return MDLAsset(url: url)
}

func voxelize(asset: MDLAsset, divisions: Int32) -> MDLVoxelArray? {
//    guard let mesh = asset.object(at: 0) as? MDLMesh else {
//        print("Failed to extract MDLMesh.")
//        return nil
//    }
    return MDLVoxelArray(asset: asset, divisions: divisions, patchRadius: 0)
}

func marchingCubes(data: [[[Int]]]) -> SCNNode {
    var vertices: [SCNVector3] = []
    var indices: [Int32] = []

    let xDim = data.count - 1
    let yDim = data[0].count - 1
    let zDim = data[0][0].count - 1
    print(xDim, yDim, zDim)

    for i in 0..<xDim {
        for j in 0..<yDim {
            for k in 0..<zDim {
                let v1 = data[i][j][k]
                let v2 = data[i+1][j][k]
                let v3 = data[i+1][j][k+1]
                let v4 = data[i][j][k+1]
                let v5 = data[i][j+1][k]
                let v6 = data[i+1][j+1][k]
                let v7 = data[i+1][j+1][k+1]
                let v8 = data[i][j+1][k+1]

                let index = v1 | (v2 << 1) | (v3 << 2) | (v4 << 3) |
                            (v5 << 4) | (v6 << 5) | (v7 << 6) | (v8 << 7)

                let e = [
                    SCNVector3(Float(i) + 0.5, Float(j), Float(k)),
                    SCNVector3(Float(i) + 1, Float(j), Float(k) + 0.5),
                    SCNVector3(Float(i) + 0.5, Float(j), Float(k) + 1),
                    SCNVector3(Float(i), Float(j), Float(k) + 0.5),
                    SCNVector3(Float(i) + 0.5, Float(j) + 1, Float(k)),
                    SCNVector3(Float(i) + 1, Float(j) + 1, Float(k) + 0.5),
                    SCNVector3(Float(i) + 0.5, Float(j) + 1, Float(k) + 1),
                    SCNVector3(Float(i), Float(j) + 1, Float(k) + 0.5),
                    SCNVector3(Float(i), Float(j) + 0.5, Float(k)),
                    SCNVector3(Float(i) + 1, Float(j) + 0.5, Float(k)),
                    SCNVector3(Float(i), Float(j) + 0.5, Float(k) + 1),
                    SCNVector3(Float(i) + 1, Float(j) + 0.5, Float(k) + 1)
                ]

                var faceVertices: [Int: Int32] = [:]
                
                for face in lookupTable[index] {
                    for vertex in face {
                        if vertex == -1 { break }
                        let idx = vertex - 1
                        if faceVertices[idx] == nil {
                            faceVertices[idx] = Int32(vertices.count)
                            vertices.append(e[idx])
                        }
                    }
                }

                for face in lookupTable[index] {
                    if face.contains(-1) { break }
                    indices.append(faceVertices[face[0] - 1]!)
                    indices.append(faceVertices[face[1] - 1]!)
                    indices.append(faceVertices[face[2] - 1]!)
                }
            }
        }
    }
    
    let geometry = SCNGeometry(
        sources: [SCNGeometrySource(vertices: vertices)],
        elements: [SCNGeometryElement(indices: indices, primitiveType: .triangles)]
    )
    
    return SCNNode(geometry: geometry)
}

func marchingCubes2(data: [[[Int]]], spacing: Float) -> SCNNode {
    let parentNode = SCNNode() // Create a parent node to hold all generated nodes
    var vertices: [SCNVector3] = []
    var indices: [Int32] = []

    let xDim = data.count - 1
    let yDim = data[0].count - 1
    let zDim = data[0][0].count - 1

    for i in 0..<xDim {
        for j in 0..<yDim {
            for k in 0..<zDim {
                let v1 = data[i][j][k]
                let v2 = data[i+1][j][k]
                let v3 = data[i+1][j][k+1]
                let v4 = data[i][j][k+1]
                let v5 = data[i][j+1][k]
                let v6 = data[i+1][j+1][k]
                let v7 = data[i+1][j+1][k+1]
                let v8 = data[i][j+1][k+1]
                
                let index = v1 | (v2 << 1) | (v3 << 2) | (v4 << 3) |
                            (v5 << 4) | (v6 << 5) | (v7 << 6) | (v8 << 7)

                let e = [
                    SCNVector3(Float(i) + 0.5, Float(j), Float(k)),
                    SCNVector3(Float(i) + 1, Float(j), Float(k) + 0.5),
                    SCNVector3(Float(i) + 0.5, Float(j), Float(k) + 1),
                    SCNVector3(Float(i), Float(j), Float(k) + 0.5),
                    SCNVector3(Float(i) + 0.5, Float(j) + 1, Float(k)),
                    SCNVector3(Float(i) + 1, Float(j) + 1, Float(k) + 0.5),
                    SCNVector3(Float(i) + 0.5, Float(j) + 1, Float(k) + 1),
                    SCNVector3(Float(i), Float(j) + 1, Float(k) + 0.5),
                    SCNVector3(Float(i), Float(j) + 0.5, Float(k)),
                    SCNVector3(Float(i) + 1, Float(j) + 0.5, Float(k)),
                    SCNVector3(Float(i), Float(j) + 0.5, Float(k) + 1),
                    SCNVector3(Float(i) + 1, Float(j) + 0.5, Float(k) + 1)
                ]

                var faceVertices: [Int: Int32] = [:]
                
                // Loop through the lookup table for this cube configuration
                for face in lookupTable[index] {
                    var currentFaceIndices: [Int32] = []
                    
                    for vertex in face {
                        if vertex == -1 { break }
                        let idx = vertex - 1
                        if faceVertices[idx] == nil {
                            faceVertices[idx] = Int32(vertices.count)
                            vertices.append(e[idx])
                        }
                        currentFaceIndices.append(faceVertices[idx]!)
                    }

                    // Create triangles from the face indices
                    for triangle in stride(from: 0, to: currentFaceIndices.count, by: 3) {
                        if triangle + 2 < currentFaceIndices.count {
                            indices.append(currentFaceIndices[triangle])
                            indices.append(currentFaceIndices[triangle + 1])
                            indices.append(currentFaceIndices[triangle + 2])
                        }
                    }
                }
                
                let b4 = data[i][j][k]
                let b3 = data[i+1][j][k]
                let a3 = data[i+1][j][k+1]
                let a4 = data[i][j][k+1]
                let b1 = data[i][j+1][k]
                let b2 = data[i+1][j+1][k]
                let a2 = data[i+1][j+1][k+1]
                let a1 = data[i][j+1][k+1]

                if !indices.isEmpty {
                    if (b4 == 1 && a1 == 0 && a2 == 0 && a3 == 0 && a4 == 0 && b1 == 0 && b2 == 0 && b3 == 0) {
                        // Temporary container for geometries
                        var brepTemp: [SCNGeometry] = []

                        // Create the boundary face (z = 0.5)
                        let pt_a = SCNVector3(Float(i), Float(j), Float(k) + 0.5)   // PointAt(0, 0, 0.5) => mid z
                        let pt_b = SCNVector3(Float(i) + 0.5, Float(j), Float(k))   // PointAt(0.5, 0, 0) => mid x
                        let pt_c = SCNVector3(Float(i), Float(j) + 0.5, Float(k))   // PointAt(0, 0.5, 0) => mid y
                        let boundaryFace = createTriangleGeometry(ptA: pt_a, ptB: pt_b, ptC: pt_c)
                        brepTemp.append(boundaryFace)

                        // Create the x=0 face
                        let pt_x0_a = SCNVector3(Float(i), Float(j), Float(k))
                        let pt_x0_b = SCNVector3(Float(i), Float(j) + 0.5, Float(k)) // PointAt(0, 0.5, 0)
                        let pt_x0_c = SCNVector3(Float(i), Float(j), Float(k) + 0.5) // PointAt(0, 0, 0.5)
                        let x0Face = createTriangleGeometry(ptA: pt_x0_a, ptB: pt_x0_b, ptC: pt_x0_c)
                        brepTemp.append(x0Face)

                        // Create the y=0 face
                        let pt_y0_a = SCNVector3(Float(i), Float(j), Float(k))
                        let pt_y0_b = SCNVector3(Float(i) + 0.5, Float(j), Float(k)) // PointAt(0.5, 0, 0)
                        let pt_y0_c = SCNVector3(Float(i), Float(j), Float(k) + 0.5) // PointAt(0, 0, 0.5)
                        let y0Face = createTriangleGeometry(ptA: pt_y0_a, ptB: pt_y0_b, ptC: pt_y0_c)
                        brepTemp.append(y0Face)

                        // Create the z=0 face
                        let pt_z0_a = SCNVector3(Float(i), Float(j), Float(k))
                        let pt_z0_b = SCNVector3(Float(i), Float(j) + 0.5, Float(k)) // PointAt(0, 0.5, 0)
                        let pt_z0_c = SCNVector3(Float(i) + 0.5, Float(j), Float(k)) // PointAt(0.5, 0, 0)
                        let z0Face = createTriangleGeometry(ptA: pt_z0_a, ptB: pt_z0_b, ptC: pt_z0_c)
                        brepTemp.append(z0Face)
                        
                        for geometry in brepTemp {
                            let node = SCNNode(geometry: geometry)
                            // Disable backface culling to show all faces
                            node.geometry?.firstMaterial?.writesToDepthBuffer = true
                            node.geometry?.firstMaterial?.readsFromDepthBuffer = false
                            node.geometry?.firstMaterial?.isDoubleSided = true
                            parentNode.addChildNode(node)
                        }
                    }
                    
                    let geometry = SCNGeometry(
                        sources: [SCNGeometrySource(vertices: vertices)],
                        elements: [SCNGeometryElement(indices: indices, primitiveType: .triangles)]
                    )
                    
                    let node = SCNNode(geometry: geometry)
                    node.position = SCNVector3(Float(i), Float(j), Float(k)) // Set position with spacing
                    parentNode.addChildNode(node) // Add the node to the parent

                    // Clear vertices and indices for the next cube
                    vertices.removeAll()
                    indices.removeAll()
                }
            }
        }
    }
    
    return parentNode // Return the parent node containing all child nodes
}


// Function to create a triangular geometry from three points
func createTriangleGeometry(ptA: SCNVector3, ptB: SCNVector3, ptC: SCNVector3) -> SCNGeometry {
    let vertices: [SCNVector3] = [ptA, ptB, ptC]
    let indices: [Int32] = [0, 1, 2]
    
    let vertexSource = SCNGeometrySource(vertices: vertices)
    let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
    
    return SCNGeometry(sources: [vertexSource], elements: [element])
}

func marchingCubesSingleLayer(data: [[[Int]]], layer: Int) -> SCNNode {
    var vertices: [SCNVector3] = []
    var indices: [Int32] = []

    let xDim = data.count - 1
    let zDim = data[0][0].count - 1

    for i in 0..<xDim {
        for k in 0..<zDim {
            let j = layer // Focus on a specific layer
            let v1 = data[i][j][k]
            let v2 = data[i+1][j][k]
            let v3 = data[i+1][j][k+1]
            let v4 = data[i][j][k+1]
            let v5 = data[i][j+1][k]
            let v6 = data[i+1][j+1][k]
            let v7 = data[i+1][j+1][k+1]
            let v8 = data[i][j+1][k+1]

            let index = v1 | (v2 << 1) | (v3 << 2) | (v4 << 3) |
                        (v5 << 4) | (v6 << 5) | (v7 << 6) | (v8 << 7)

            let e = [
                SCNVector3(Float(i) + 0.5, Float(j), Float(k)),
                SCNVector3(Float(i) + 1, Float(j), Float(k) + 0.5),
                SCNVector3(Float(i) + 0.5, Float(j), Float(k) + 1),
                SCNVector3(Float(i), Float(j), Float(k) + 0.5),
                SCNVector3(Float(i) + 0.5, Float(j) + 1, Float(k)),
                SCNVector3(Float(i) + 1, Float(j) + 1, Float(k) + 0.5),
                SCNVector3(Float(i) + 0.5, Float(j) + 1, Float(k) + 1),
                SCNVector3(Float(i), Float(j) + 1, Float(k) + 0.5),
                SCNVector3(Float(i), Float(j) + 0.5, Float(k)),
                SCNVector3(Float(i) + 1, Float(j) + 0.5, Float(k)),
                SCNVector3(Float(i), Float(j) + 0.5, Float(k) + 1),
                SCNVector3(Float(i) + 1, Float(j) + 0.5, Float(k) + 1)
            ]

            var faceVertices: [Int: Int32] = [:]
            
            for face in lookupTable[index] {
                for vertex in face {
                    if vertex == -1 { break }
                    let idx = vertex - 1
                    if faceVertices[idx] == nil {
                        faceVertices[idx] = Int32(vertices.count)
                        vertices.append(e[idx])
                    }
                }
            }

            for face in lookupTable[index] {
                if face.contains(-1) { break }
                indices.append(faceVertices[face[0] - 1]!)
                indices.append(faceVertices[face[1] - 1]!)
                indices.append(faceVertices[face[2] - 1]!)
            }
        }
    }
    
    let geometry = SCNGeometry(
        sources: [SCNGeometrySource(vertices: vertices)],
        elements: [SCNGeometryElement(indices: indices, primitiveType: .triangles)]
    )
    
    return SCNNode(geometry: geometry)
}

func convertTo3DArray(voxelArray: MDLVoxelArray) -> [[[Int]]] {
    let extent = voxelArray.boundingBox
    let sizeX = Int(abs(extent.maxBounds.x - extent.minBounds.x) * 2)
    let sizeY = Int(abs(extent.maxBounds.y - extent.minBounds.y) * 2)
    let sizeZ = Int(abs(extent.maxBounds.z - extent.minBounds.z) * 2)
    
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


let lookupTable: [[[Int]]] = [
    [],
    [[1, 9, 4]],
    [[1, 2, 10]],
    [[2, 9, 4], [10, 9, 2]],
    [[2, 3, 12]],
    [[1, 9, 4], [2, 3, 12]],
    [[10, 3, 12], [1, 3, 10]],
    [[3, 9, 4], [3, 12, 9], [12, 10, 9]],
    [[4, 11, 3]],
    [[1, 11, 3], [9, 11, 1]],
    [[2, 10, 1], [3, 4, 11]],
    [[2, 11, 3], [2, 10, 11], [10, 9, 11]],
    [[4, 12, 2], [11, 12, 4]],
    [[1, 12, 2], [1, 9, 12], [9, 11, 12]],
    [[4, 10, 1], [4, 11, 10], [11, 12, 10]],
    [[10, 9, 12], [12, 9, 11]],
    [[5, 8, 9]],
    [[5, 4, 1], [8, 4, 5]],
    [[1, 2, 10], [9, 5, 8]],
    [[5, 2, 10], [5, 8, 2], [8, 4, 2]],
    [[2, 3, 12], [9, 5, 8]],
    [[4, 5, 8], [4, 1, 5], [2, 3, 12]],
    [[10, 3, 12], [10, 1, 3], [9, 5, 8]],
    [[3, 12, 10], [3, 10, 8], [3, 8, 4], [8, 10, 5]],
    [[9, 5, 8], [4, 11, 3]],
    [[11, 5, 8], [11, 3, 5], [3, 1, 5]],
    [[10, 1, 2], [9, 5, 8], [3, 4, 11]],
    [[5, 8, 11], [10, 5, 11], [10, 11, 3], [10, 3, 2]],
    [[4, 12, 2], [4, 11, 12], [8, 9, 5]],
    [[2, 11, 12], [2, 5, 11], [2, 1, 5], [8, 11, 5]],
    [[5, 8, 9], [10, 1, 11], [10, 11, 12], [11, 1, 4]],
    [[5, 8, 11], [5, 11, 10], [10, 11, 12]],
    [[10, 6, 5]],
    [[10, 6, 5], [1, 9, 4]],
    [[1, 6, 5], [2, 6, 1]],
    [[9, 6, 5], [9, 4, 6], [4, 2, 6]],
    [[2, 3, 12], [10, 6, 5]],
    [[4, 1, 9], [2, 3, 12], [5, 10, 6]],
    [[6, 3, 12], [6, 5, 3], [5, 1, 3]],
    [[3, 12, 6], [4, 3, 6], [4, 6, 5], [4, 5, 9]],
    [[10, 6, 5], [3, 4, 11]],
    [[1, 11, 3], [1, 9, 11], [5, 10, 6]],
    [[1, 6, 5], [1, 2, 6], [3, 4, 11]],
    [[3, 2, 6], [3, 6, 9], [3, 9, 11], [5, 9, 6]],
    [[12, 4, 11], [12, 2, 4], [10, 6, 5]],
    [[5, 10, 6], [1, 9, 2], [9, 12, 2], [9, 11, 12]],
    [[6, 5, 1], [6, 1, 11], [6, 11, 12], [11, 1, 4]],
    [[6, 5, 9], [6, 9, 12], [12, 9, 11]],
    [[10, 8, 9], [6, 8, 10]],
    [[10, 4, 1], [10, 6, 4], [6, 8, 4]],
    [[1, 8, 9], [1, 2, 8], [2, 6, 8]],
    [[2, 6, 4], [4, 6, 8]],
    [[10, 8, 9], [10, 6, 8], [12, 2, 3]],
    [[12, 2, 3], [10, 6, 1], [6, 4, 1], [6, 8, 4]],
    [[9, 1, 3], [9, 3, 6], [9, 6, 8], [12, 6, 3]],
    [[3, 12, 6], [3, 6, 4], [4, 6, 8]],
    [[8, 10, 6], [8, 9, 10], [4, 11, 3]],
    [[10, 6, 8], [10, 8, 3], [10, 3, 1], [3, 8, 11]],
    [[3, 4, 11], [1, 2, 9], [2, 8, 9], [2, 6, 8]],
    [[11, 3, 2], [11, 2, 8], [8, 2, 6]],
    [[10, 6, 9], [9, 6, 8], [12, 2, 4], [12, 4, 11]],
    [[6, 8, 11], [6, 11, 12], [2, 1, 10]],
    [[11, 12, 6], [11, 6, 8], [9, 1, 4]],
    [[11, 12, 6], [8, 11, 6]],
    [[12, 7, 6]],
    [[1, 9, 4], [6, 12, 7]],
    [[10, 1, 2], [6, 12, 7]],
    [[2, 9, 4], [2, 10, 9], [6, 12, 7]],
    [[2, 7, 6], [3, 7, 2]],
    [[2, 7, 6], [2, 3, 7], [4, 1, 9]],
    [[10, 7, 6], [10, 1, 7], [1, 3, 7]],
    [[6, 10, 9], [6, 9, 3], [6, 3, 7], [4, 3, 9]],
    [[3, 4, 11], [12, 7, 6]],
    [[11, 1, 9], [11, 3, 1], [12, 7, 6]],
    [[1, 2, 10], [3, 4, 11], [6, 12, 7]],
    [[6, 12, 7], [2, 10, 3], [10, 11, 3], [10, 9, 11]],
    [[7, 4, 11], [7, 6, 4], [6, 2, 4]],
    [[1, 9, 11], [1, 11, 6], [1, 6, 2], [6, 11, 7]],
    [[4, 11, 7], [1, 4, 7], [1, 7, 6], [1, 6, 10]],
    [[7, 6, 10], [7, 10, 11], [11, 10, 9]],
    [[6, 12, 7], [5, 8, 9]],
    [[5, 4, 1], [5, 8, 4], [7, 6, 12]],
    [[2, 10, 1], [6, 12, 7], [9, 5, 8]],
    [[12, 7, 6], [2, 10, 8], [2, 8, 4], [8, 10, 5]],
    [[7, 2, 3], [7, 6, 2], [5, 8, 9]],
    [[2, 3, 6], [6, 3, 7], [4, 1, 5], [4, 5, 8]],
    [[9, 5, 8], [10, 1, 6], [1, 7, 6], [1, 3, 7]],
    [[8, 4, 3], [8, 3, 7], [6, 10, 5]],
    [[4, 11, 3], [8, 9, 5], [12, 7, 6]],
    [[6, 12, 7], [5, 8, 3], [5, 3, 1], [3, 8, 11]],
    [[1, 2, 10], [5, 8, 9], [3, 4, 11], [6, 12, 7]],
    [[10, 5, 6], [12, 3, 2], [8, 11, 7]],
    [[9, 5, 8], [4, 11, 6], [4, 6, 2], [6, 11, 7]],
    [[6, 2, 1], [6, 1, 5], [8, 11, 7]],
    [[1, 4, 9], [5, 6, 10], [11, 7, 8]],
    [[5, 6, 10], [8, 11, 7]],
    [[12, 5, 10], [7, 5, 12]],
    [[5, 12, 7], [5, 10, 12], [1, 9, 4]],
    [[12, 1, 2], [12, 7, 1], [7, 5, 1]],
    [[9, 4, 2], [9, 2, 7], [9, 7, 5], [7, 2, 12]],
    [[2, 5, 10], [2, 3, 5], [3, 7, 5]],
    [[4, 1, 9], [2, 3, 10], [3, 5, 10], [3, 7, 5]],
    [[1, 3, 5], [5, 3, 7]],
    [[9, 4, 3], [9, 3, 5], [5, 3, 7]],
    [[12, 5, 10], [12, 7, 5], [11, 3, 4]],
    [[1, 9, 3], [3, 9, 11], [5, 10, 12], [5, 12, 7]],
    [[4, 11, 3], [1, 2, 7], [1, 7, 5], [7, 2, 12]],
    [[7, 5, 9], [7, 9, 11], [3, 2, 12]],
    [[10, 7, 5], [10, 4, 7], [10, 2, 4], [11, 7, 4]],
    [[9, 11, 7], [9, 7, 5], [10, 2, 1]],
    [[4, 11, 7], [4, 7, 1], [1, 7, 5]],
    [[7, 5, 9], [11, 7, 9]],
    [[8, 12, 7], [8, 9, 12], [9, 10, 12]],
    [[1, 8, 4], [1, 12, 8], [1, 10, 12], [7, 8, 12]],
    [[12, 7, 8], [2, 12, 8], [2, 8, 9], [2, 9, 1]],
    [[12, 7, 8], [12, 8, 2], [2, 8, 4]],
    [[2, 3, 7], [2, 7, 9], [2, 9, 10], [9, 7, 8]],
    [[3, 7, 8], [3, 8, 4], [1, 10, 2]],
    [[8, 9, 1], [8, 1, 7], [7, 1, 3]],
    [[8, 4, 3], [7, 8, 3]],
    [[3, 4, 11], [12, 7, 9], [12, 9, 10], [9, 7, 8]],
    [[3, 1, 10], [3, 10, 12], [7, 8, 11]],
    [[2, 12, 3], [4, 9, 1], [7, 8, 11]],
    [[12, 3, 2], [7, 8, 11]],
    [[9, 10, 2], [9, 2, 4], [11, 7, 8]],
    [[1, 10, 2], [11, 7, 8]],
    [[4, 9, 1], [11, 7, 8]],
    [[8, 11, 7]],
    [[8, 7, 11]],
    [[4, 1, 9], [11, 8, 7]],
    [[1, 2, 10], [11, 8, 7]],
    [[9, 2, 10], [9, 4, 2], [11, 8, 7]],
    [[12, 2, 3], [7, 11, 8]],
    [[2, 3, 12], [4, 1, 9], [7, 11, 8]],
    [[3, 10, 1], [3, 12, 10], [7, 11, 8]],
    [[3, 11, 4], [12, 9, 7], [12, 10, 9], [9, 8, 7]],
    [[8, 3, 4], [7, 3, 8]],
    [[8, 1, 9], [8, 7, 1], [7, 3, 1]],
    [[3, 8, 7], [3, 4, 8], [1, 2, 10]],
    [[2, 7, 3], [2, 9, 7], [2, 10, 9], [9, 8, 7]],
    [[12, 8, 7], [12, 2, 8], [2, 4, 8]],
    [[12, 8, 7], [2, 8, 12], [2, 9, 8], [2, 1, 9]],
    [[1, 4, 8], [1, 8, 12], [1, 12, 10], [7, 12, 8]],
    [[8, 7, 12], [8, 12, 9], [9, 12, 10]],
    [[7, 9, 5], [11, 9, 7]],
    [[4, 7, 11], [4, 1, 7], [1, 5, 7]],
    [[9, 7, 11], [9, 5, 7], [10, 1, 2]],
    [[10, 5, 7], [10, 7, 4], [10, 4, 2], [11, 4, 7]],
    [[7, 9, 5], [7, 11, 9], [3, 12, 2]],
    [[4, 3, 11], [1, 7, 2], [1, 5, 7], [7, 12, 2]],
    [[1, 3, 9], [3, 11, 9], [5, 12, 10], [5, 7, 12]],
    [[12, 10, 5], [12, 5, 7], [11, 4, 3]],
    [[9, 3, 4], [9, 5, 3], [5, 7, 3]],
    [[1, 5, 3], [5, 7, 3]],
    [[4, 9, 1], [2, 10, 3], [3, 10, 5], [3, 5, 7]],
    [[2, 10, 5], [2, 5, 3], [3, 5, 7]],
    [[9, 2, 4], [9, 7, 2], [9, 5, 7], [7, 12, 2]],
    [[12, 2, 1], [12, 1, 7], [7, 1, 5]],
    [[5, 7, 12], [5, 12, 10], [1, 4, 9]],
    [[12, 10, 5], [7, 12, 5]],
    [[5, 10, 6], [8, 7, 11]],
    [[1, 9, 4], [5, 10, 6], [11, 8, 7]],
    [[6, 1, 2], [6, 5, 1], [8, 7, 11]],
    [[9, 8, 5], [4, 6, 11], [4, 2, 6], [6, 7, 11]],
    [[10, 6, 5], [12, 2, 3], [8, 7, 11]],
    [[1, 10, 2], [5, 9, 8], [3, 11, 4], [6, 7, 12]],
    [[6, 7, 12], [5, 3, 8], [5, 1, 3], [3, 11, 8]],
    [[4, 3, 11], [8, 5, 9], [12, 6, 7]],
    [[8, 3, 4], [8, 7, 3], [6, 5, 10]],
    [[9, 8, 5], [10, 6, 1], [1, 6, 7], [1, 7, 3]],
    [[2, 6, 3], [6, 7, 3], [4, 5, 1], [4, 8, 5]],
    [[7, 3, 2], [7, 2, 6], [5, 9, 8]],
    [[12, 6, 7], [2, 8, 10], [2, 4, 8], [8, 5, 10]],
    [[2, 1, 10], [6, 7, 12], [9, 8, 5]],
    [[5, 1, 4], [5, 4, 8], [7, 12, 6]],
    [[6, 7, 12], [5, 9, 8]],
    [[7, 10, 6], [7, 11, 10], [11, 9, 10]],
    [[4, 7, 11], [1, 7, 4], [1, 6, 7], [1, 10, 6]],
    [[1, 11, 9], [1, 6, 11], [1, 2, 6], [6, 7, 11]],
    [[7, 11, 4], [7, 4, 6], [6, 4, 2]],
    [[6, 7, 12], [2, 3, 10], [10, 3, 11], [10, 11, 9]],
    [[1, 10, 2], [3, 11, 4], [6, 7, 12]],
    [[11, 9, 1], [11, 1, 3], [12, 6, 7]],
    [[3, 11, 4], [12, 6, 7]],
    [[6, 9, 10], [6, 3, 9], [6, 7, 3], [4, 9, 3]],
    [[10, 6, 7], [10, 7, 1], [1, 7, 3]],
    [[2, 6, 7], [2, 7, 3], [4, 9, 1]],
    [[2, 6, 7], [3, 2, 7]],
    [[2, 4, 9], [2, 9, 10], [6, 7, 12]],
    [[10, 2, 1], [6, 7, 12]],
    [[1, 4, 9], [6, 7, 12]],
    [[12, 6, 7]],
    [[11, 6, 12], [8, 6, 11]],
    [[11, 6, 12], [11, 8, 6], [9, 4, 1]],
    [[6, 11, 8], [6, 12, 11], [2, 10, 1]],
    [[10, 9, 6], [9, 8, 6], [12, 4, 2], [12, 11, 4]],
    [[11, 2, 3], [11, 8, 2], [8, 6, 2]],
    [[3, 11, 4], [1, 9, 2], [2, 9, 8], [2, 8, 6]],
    [[10, 8, 6], [10, 3, 8], [10, 1, 3], [3, 11, 8]],
    [[8, 6, 10], [8, 10, 9], [4, 3, 11]],
    [[3, 6, 12], [3, 4, 6], [4, 8, 6]],
    [[9, 3, 1], [9, 6, 3], [9, 8, 6], [12, 3, 6]],
    [[12, 3, 2], [10, 1, 6], [6, 1, 4], [6, 4, 8]],
    [[10, 9, 8], [10, 8, 6], [12, 3, 2]],
    [[2, 4, 6], [4, 8, 6]],
    [[1, 9, 8], [1, 8, 2], [2, 8, 6]],
    [[10, 1, 4], [10, 4, 6], [6, 4, 8]],
    [[10, 9, 8], [6, 10, 8]],
    [[6, 9, 5], [6, 12, 9], [12, 11, 9]],
    [[6, 1, 5], [6, 11, 1], [6, 12, 11], [11, 4, 1]],
    [[5, 6, 10], [1, 2, 9], [9, 2, 12], [9, 12, 11]],
    [[12, 11, 4], [12, 4, 2], [10, 5, 6]],
    [[3, 6, 2], [3, 9, 6], [3, 11, 9], [5, 6, 9]],
    [[1, 5, 6], [1, 6, 2], [3, 11, 4]],
    [[1, 3, 11], [1, 11, 9], [5, 6, 10]],
    [[10, 5, 6], [3, 11, 4]],
    [[3, 6, 12], [4, 6, 3], [4, 5, 6], [4, 9, 5]],
    [[6, 12, 3], [6, 3, 5], [5, 3, 1]],
    [[4, 9, 1], [2, 12, 3], [5, 6, 10]],
    [[2, 12, 3], [10, 5, 6]],
    [[9, 5, 6], [9, 6, 4], [4, 6, 2]],
    [[1, 5, 6], [2, 1, 6]],
    [[10, 5, 6], [1, 4, 9]],
    [[10, 5, 6]],
    [[5, 11, 8], [5, 10, 11], [10, 12, 11]],
    [[5, 9, 8], [10, 11, 1], [10, 12, 11], [11, 4, 1]],
    [[2, 12, 11], [2, 11, 5], [2, 5, 1], [8, 5, 11]],
    [[4, 2, 12], [4, 12, 11], [8, 5, 9]],
    [[5, 11, 8], [10, 11, 5], [10, 3, 11], [10, 2, 3]],
    [[10, 2, 1], [9, 8, 5], [3, 11, 4]],
    [[11, 8, 5], [11, 5, 3], [3, 5, 1]],
    [[9, 8, 5], [4, 3, 11]],
    [[3, 10, 12], [3, 8, 10], [3, 4, 8], [8, 5, 10]],
    [[10, 12, 3], [10, 3, 1], [9, 8, 5]],
    [[4, 8, 5], [4, 5, 1], [2, 12, 3]],
    [[2, 12, 3], [9, 8, 5]],
    [[5, 10, 2], [5, 2, 8], [8, 2, 4]],
    [[1, 10, 2], [9, 8, 5]],
    [[5, 1, 4], [8, 5, 4]],
    [[5, 9, 8]],
    [[10, 12, 9], [12, 11, 9]],
    [[4, 1, 10], [4, 10, 11], [11, 10, 12]],
    [[1, 2, 12], [1, 12, 9], [9, 12, 11]],
    [[4, 2, 12], [11, 4, 12]],
    [[2, 3, 11], [2, 11, 10], [10, 11, 9]],
    [[2, 1, 10], [3, 11, 4]],
    [[1, 3, 11], [9, 1, 11]],
    [[4, 3, 11]],
    [[3, 4, 9], [3, 9, 12], [12, 9, 10]],
    [[10, 12, 3], [1, 10, 3]],
    [[1, 4, 9], [2, 12, 3]],
    [[2, 12, 3]],
    [[2, 4, 9], [10, 2, 9]],
    [[1, 10, 2]],
    [[1, 4, 9]],
    []
    ]
