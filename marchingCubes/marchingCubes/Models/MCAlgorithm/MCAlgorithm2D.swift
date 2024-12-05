//
//  MCAlgorithm2D.swift
//  marchingCubes
//
//  Created by Mingxin Hou on 11/9/24.
//

import SceneKit

// Class implementing the 2D Marching Cubes algorithm
class MarchingCubes2D {
    var colorScheme: ColorScheme
    var scale: Float = 0.85 // Scale factor for geometry
    
    init(colorScheme: ColorScheme) {
        self.colorScheme = colorScheme
    }
    
    // Main function to perform the 2D Marching Cubes algorithm on the input data
    func marchingCubes2D(data: [[Int]]) -> SCNNode {
        let parentNode = SCNNode() // Create a parent node to hold all generated nodes
        let xDim = data.count - 1
        let yDim = data[0].count - 1
        
        for i in 0..<xDim {
            for j in 0..<yDim {
                var vertices: [SCNVector3] = []
                var indices: [Int32] = []
                // Retrieve the values of the corners of the current cell
                let a = data[i][j]
                let b = data[i+1][j]
                let c = data[i+1][j+1]
                let d = data[i][j+1]
                
                // Define the vertices of the cell
                let v1 = SCNVector3(Float(i), 0,  Float(j))
                let v2 = SCNVector3(Float(i+1), 0,  Float(j))
                let v3 = SCNVector3(Float(i+1), 0,  Float(j+1))
                let v4 = SCNVector3(Float(i), 0,  Float(j+1))
                
                //            parentNode.addChildNode(createBall(at: v1, radius: 0.05, color: UIColor.red))
                //            parentNode.addChildNode(createBall(at: v2, radius: 0.05, color: UIColor.green))
                //            parentNode.addChildNode(createBall(at: v3, radius: 0.05, color: UIColor.blue))
                //            parentNode.addChildNode(createBall(at: v4, radius: 0.05, color: UIColor.yellow))
                
                // Determine the case
                if (a + b + c + d == 4){
                    let node = get0_1(vertices: &vertices, indices: &indices,
                                       v1: v1, v2: v2, v3: v3, v4: v4)
                    parentNode.addChildNode(node)
                }
                else if (a + b + c + d == 3){
                    if (a == 0) {
                        let node = get1_1(vertices: &vertices, indices: &indices,
                                          v1: v1, v2: v2, v3: v3, v4: v4)
                        parentNode.addChildNode(node)
                    }
                    else if (b == 0) {
                        let node = get1_1(vertices: &vertices, indices: &indices,
                                          v1: v2, v2: v1, v3: v4, v4: v3)
                        parentNode.addChildNode(node)
                    }
                    else if (c == 0) {
                        let node = get1_1(vertices: &vertices, indices: &indices,
                                          v1: v3, v2: v2, v3: v1, v4: v4)
                        parentNode.addChildNode(node)
                    }
                    else if (d == 0) {
                        let node = get1_1(vertices: &vertices, indices: &indices,
                                          v1: v4, v2: v3, v3: v2, v4: v1)
                        parentNode.addChildNode(node)
                    }
                }
                else if (a + b + c + d == 2){
                    if (a + b == 2) {
                        let node = get2_2(vertices: &vertices, indices: &indices,
                                             v1: v1, v2: v2, v3: v3, v4: v4)
                        parentNode.addChildNode(node)
                    }
                    else if (b + c == 2) {
                        let node = get2_2(vertices: &vertices, indices: &indices,
                                             v1: v2, v2: v3, v3: v4, v4: v1)
                        parentNode.addChildNode(node)
                    }
                    else if (c + d == 2) {
                        let node = get2_2(vertices: &vertices, indices: &indices,
                                             v1: v3, v2: v4, v3: v1, v4: v2)
                        parentNode.addChildNode(node)
                    }
                    else if (d + a == 2) {
                        let node = get2_2(vertices: &vertices, indices: &indices,
                                             v1: v4, v2: v1, v3: v2, v4: v3)
                        parentNode.addChildNode(node)
                    }
                    else if (a + c == 2) {
                        let node = get2_1(vertices: &vertices, indices: &indices,
                                             v1: v2, v2: v3, v3: v4, v4: v1)
                        parentNode.addChildNode(node)
                    }
                    else if (b + d == 2) {
                        let node = get2_1(vertices: &vertices, indices: &indices,
                                             v1: v1, v2: v2, v3: v3, v4: v4)
                        parentNode.addChildNode(node)
                    }
                }
                else if (a + b + c + d == 1) {
                    if (a == 1) {
                        let node = get3_1(vertices: &vertices, indices: &indices,
                                             v1: v1, v2: v2, v3: v3, v4: v4)
                        parentNode.addChildNode(node)
                    }
                    else if (b == 1) {
                        let node = get3_1(vertices: &vertices, indices: &indices,
                                             v1: v2, v2: v3, v3: v4, v4: v1)
                        parentNode.addChildNode(node)
                    }
                    else if (c == 1) {
                        let node = get3_1(vertices: &vertices, indices: &indices,
                                             v1: v3, v2: v4, v3: v1, v4: v2)
                        parentNode.addChildNode(node)
                    }
                    else if (d == 1) {
                        let node = get3_1(vertices: &vertices, indices: &indices,
                                             v1: v4, v2: v1, v3: v2, v4: v3)
                        parentNode.addChildNode(node)
                    }
                }
            }
        }
        
        return parentNode
    }
    
    // + - +
    // |   |
    // + - +
    // Generate geometry for a fully filled cell (case: all corners filled)
    func get0_1(vertices: inout [SCNVector3], indices: inout [Int32], v1: SCNVector3, v2: SCNVector3,
                 v3: SCNVector3, v4: SCNVector3) -> SCNNode {
        let scaled_v1 = v1 * scale + v3 * (1 - scale)
        let scaled_v2 = v2 * scale + v4 * (1 - scale)
        let scaled_v3 = v3 * scale + v1 * (1 - scale)
        let scaled_v4 = v4 * scale + v2 * (1 - scale)
        let v5 = scaled_v4 * 0.2 + scaled_v1 * 0.8
        let v6 = scaled_v2 * 0.2 + scaled_v1 * 0.8
        let v7 = scaled_v3 * 0.2 + scaled_v1 * 0.8
        let (v8, v9, v10) = calculateCircle(v1: v5, v2: v6, v3: v7, v4: scaled_v1)
        let v11 = scaled_v1 * 0.2 + scaled_v2 * 0.8
        let v12 = scaled_v3 * 0.2 + scaled_v2 * 0.8
        let v13 = scaled_v4 * 0.2 + scaled_v2 * 0.8
        let (v14, v15, v16) = calculateCircle(v1: v11, v2: v12, v3: v13, v4: scaled_v2)
        let v17 = scaled_v2 * 0.2 + scaled_v3 * 0.8
        let v18 = scaled_v4 * 0.2 + scaled_v3 * 0.8
        let v19 = scaled_v1 * 0.2 + scaled_v3 * 0.8
        let (v20, v21, v22) = calculateCircle(v1: v17, v2: v18, v3: v19, v4: scaled_v3)
        let v23 = scaled_v3 * 0.2 + scaled_v4 * 0.8
        let v24 = scaled_v1 * 0.2 + scaled_v4 * 0.8
        let v25 = scaled_v2 * 0.2 + scaled_v4 * 0.8
        let (v26, v27, v28) = calculateCircle(v1: v23, v2: v24, v3: v25, v4: scaled_v4)
        vertices += [v1, scaled_v1, scaled_v2, scaled_v3, scaled_v4,
        v5, v6, v7, v8, v9, v10,
        v11, v12, v13, v14, v15,
        v16, v17, v18, v19, v20,
        v21, v22, v23, v24, v25,
        v26, v27, v28]
        indices += [5, 12, 17,
                    5, 17, 24,
                    6, 7, 11,
                    7, 11, 13,
                    18, 19, 23,
                    19, 23, 25,
                    7, 5, 8,
                    7, 8, 9,
                    7, 9, 10,
                    7, 10, 6,
                    13, 11, 14,
                    13, 14, 15,
                    13, 15, 16,
                    13, 16, 12,
                    19, 17, 20,
                    19, 20, 21,
                    19, 21, 22,
                    19, 22, 18,
                    25, 23, 26,
                    25, 26, 27,
                    25, 27, 28,
                    25, 28, 24
        ]
        
        let vertexSource = SCNGeometrySource(vertices: vertices)
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        let geometry = SCNGeometry(sources: [vertexSource], elements: [element])
        let material = SCNMaterial()
        material.isDoubleSided = true
        if (colorScheme == .scheme1) {
            material.diffuse.contents = UIColor.cubitBlue
        }
        else if (colorScheme == .scheme2) {
            material.diffuse.contents = UIColor.cubitDarkBlue
        }
        geometry.materials = [material]
        let node = SCNNode(geometry: geometry)
        
        return node
    }
    
    // Generate geometry for a cell with three filled corners (case: one corner empty)
    func get1_1(vertices: inout [SCNVector3], indices: inout [Int32], v1: SCNVector3, v2: SCNVector3,
                v3: SCNVector3, v4: SCNVector3) -> SCNNode {
        let scaled_v1 = v1 * scale + v3 * (1 - scale)
        let scaled_v2 = v2 * scale + v4 * (1 - scale)
        let scaled_v3 = v3 * scale + v1 * (1 - scale)
        let scaled_v4 = v4 * scale + v2 * (1 - scale)

        let v11 = scaled_v1 * 0.2 + scaled_v2 * 0.8
        let v12 = scaled_v3 * 0.2 + scaled_v2 * 0.8
        let v13 = scaled_v4 * 0.2 + scaled_v2 * 0.8
        let (v14, v15, v16) = calculateCircle(v1: v11, v2: v12, v3: v13, v4: scaled_v2)
        let v17 = scaled_v2 * 0.2 + scaled_v3 * 0.8
        let v18 = scaled_v4 * 0.2 + scaled_v3 * 0.8
        let v19 = scaled_v1 * 0.2 + scaled_v3 * 0.8
        let (v20, v21, v22) = calculateCircle(v1: v17, v2: v18, v3: v19, v4: scaled_v3)
        let v23 = scaled_v3 * 0.2 + scaled_v4 * 0.8
        let v24 = scaled_v1 * 0.2 + scaled_v4 * 0.8
        let v25 = scaled_v2 * 0.2 + scaled_v4 * 0.8
        let (v26, v27, v28) = calculateCircle(v1: v23, v2: v24, v3: v25, v4: scaled_v4)
        vertices += [v1, scaled_v1, scaled_v2, scaled_v3, scaled_v4,
                     (scaled_v1 + scaled_v2) / 2, (scaled_v1 + scaled_v4) / 2,
        v1, v1, v1, v1,
        v11, v12, v13, v14, v15,
        v16, v17, v18, v19, v20,
        v21, v22, v23, v24, v25,
        v26, v27, v28]

        indices += [
            5, 6, 19,
            6, 24, 25,
            6, 19, 25,
            5, 11, 13,
            5, 13, 19,
            12, 17, 19,
            12, 13, 19,
            18, 19, 25,
            18, 23, 25,
            13, 11, 14,
            13, 14, 15,
            13, 15, 16,
            13, 16, 12,
            19, 17, 20,
            19, 20, 21,
            19, 21, 22,
            19, 22, 18,
            25, 23, 26,
            25, 26, 27,
            25, 27, 28,
            25, 28, 24
        ]
        
        let vertexSource = SCNGeometrySource(vertices: vertices)
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        let geometry = SCNGeometry(sources: [vertexSource], elements: [element])
        let material = SCNMaterial()
        material.isDoubleSided = true
        if (colorScheme == .scheme1) {
            material.diffuse.contents = UIColor.cubitRed
        }
        else if (colorScheme == .scheme2) {
            material.diffuse.contents = UIColor.cubitPurple
        }
        geometry.materials = [material]
        let node = SCNNode(geometry: geometry)
        
        return node
    }
    
    // Generate geometry for a cell with two diagonally filled corners (case: opposite corners filled)
    func get2_1(vertices: inout [SCNVector3], indices: inout [Int32], v1: SCNVector3, v2: SCNVector3,
                   v3: SCNVector3, v4: SCNVector3) -> SCNNode {
        let scaled_v1 = v1 * scale + v3 * (1 - scale)
        let scaled_v2 = v2 * scale + v4 * (1 - scale)
        let scaled_v3 = v3 * scale + v1 * (1 - scale)
        let scaled_v4 = v4 * scale + v2 * (1 - scale)
        let v9 = scaled_v1 * 0.15 + scaled_v2 * 0.85
        let v10 = scaled_v3 * 0.15 + scaled_v2 * 0.85
        let v11 = scaled_v4 * 0.15 + scaled_v2 * 0.85
        let (v12, v13, v14) = calculateCircle(v1: v9, v2: v10, v3: v11, v4: scaled_v2)
        let v15 = scaled_v3 * 0.15 + scaled_v4 * 0.85
        let v16 = scaled_v1 * 0.15 + scaled_v4 * 0.85
        let v17 = scaled_v2 * 0.15 + scaled_v4 * 0.85
        let (v18, v19, v20) = calculateCircle(v1: v15, v2: v16, v3: v17, v4: scaled_v4)

        vertices += [ v1, scaled_v1, scaled_v2, scaled_v3, scaled_v4,
                      (scaled_v1 + scaled_v2) / 2, (scaled_v2 + scaled_v3) / 2,
                      (scaled_v3 + scaled_v4) / 2, (scaled_v1 + scaled_v4) / 2,
                      v9, v10, v11, v12, v13, v14, v15,
                      v16, v17, v18, v19, v20]
        indices += [
            11, 9, 12,
            11, 12, 13,
            11, 13, 14,
            11, 14, 10,
            17, 15, 18,
            17, 18, 19,
            17, 19, 20,
            17, 20, 16,
            7, 15, 17,
            6, 7, 17,
            6, 10, 17,
            10, 11, 17,
            9, 11, 17,
            5, 9, 17,
            5, 8, 17,
            8, 16, 17,
        ]
        
        let vertexSource = SCNGeometrySource(vertices: vertices)
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        let geometry = SCNGeometry(sources: [vertexSource], elements: [element])
        let material = SCNMaterial()
        material.isDoubleSided = true
        if (colorScheme == .scheme1) {
            material.diffuse.contents = UIColor.cubitPurple
        }
        else if (colorScheme == .scheme2) {
            material.diffuse.contents = UIColor.cubitMagenta
        }
        geometry.materials = [material]
        let node = SCNNode(geometry: geometry)
        
        return node
    }
    
    // Generate geometry for a cell with two adjacent filled corners (case: adjacent corners filled)
    func get2_2(vertices: inout [SCNVector3], indices: inout [Int32], v1: SCNVector3, v2: SCNVector3,
                   v3: SCNVector3, v4: SCNVector3) -> SCNNode {
        let v_5 = (v1 + v4) / 2
        let v_6 = (v2 + v3) / 2
        
        let scaled_v1 = v1 * scale + v_6 * (1 - scale)
        let scaled_v2 = v2 * scale + v_5 * (1 - scale)
        let scaled_v3 = v3 * scale + v1 * (1 - scale)
        let scaled_v4 = v4 * scale + v2 * (1 - scale)
        let scaled_v6 = v_6 * scale + v1 * (1 - scale)
        let scaled_v5 = v_5 * scale + v2 * (1 - scale)
        
        let v5 = scaled_v4 * 0.15 + scaled_v1 * 0.85
        let v6 = scaled_v2 * 0.15 + scaled_v1 * 0.85
        let v7 = scaled_v3 * 0.15 + scaled_v1 * 0.85
        let (v8, v9, v10) = calculateCircle(v1: v5, v2: v6, v3: v7, v4: scaled_v1)
        let v11 = scaled_v1 * 0.15 + scaled_v2 * 0.85
        let v12 = scaled_v3 * 0.15 + scaled_v2 * 0.85
        let v13 = scaled_v4 * 0.15 + scaled_v2 * 0.85
        let (v14, v15, v16) = calculateCircle(v1: v11, v2: v12, v3: v13, v4: scaled_v2)
        vertices += [ v1, scaled_v1, scaled_v2, v3, v4,
                      v5, v6, v7, v8, v9, v10,
                      v11, v12, v13, v14,v15, v16,
                      scaled_v5, scaled_v6]
        indices += [
            7, 5, 8,
            7, 8, 9,
            7, 9, 10,
            7, 10, 6,
            13, 11, 14,
            13, 14, 15,
            13, 15, 16,
            13, 16, 12,
            19, 17, 20,
            19, 20, 21,
            19, 21, 22,
            19, 22, 18,
            25, 23, 26,
            25, 26, 27,
            25, 27, 28,
            25, 28, 24,
            6, 7, 13,
            6, 11, 13,
            5, 12, 18,
            5, 17, 18,
        ]
        
        let vertexSource = SCNGeometrySource(vertices: vertices)
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        let geometry = SCNGeometry(sources: [vertexSource], elements: [element])
        let material = SCNMaterial()
        material.isDoubleSided = true
        if (colorScheme == .scheme1) {
            material.diffuse.contents = UIColor.cubitOrange
        }
        else if (colorScheme == .scheme2) {
            material.diffuse.contents = UIColor.cubitLightBlue
        }
        geometry.materials = [material]
        let node = SCNNode(geometry: geometry)
        
        return node
    }
    
    // Generate geometry for a cell with one filled corner (case: one corner filled)
    func get3_1(vertices: inout [SCNVector3], indices: inout [Int32], v1: SCNVector3, v2: SCNVector3,
                   v3: SCNVector3, v4: SCNVector3) -> SCNNode {
        let v5 = (v1 + v2) / 2
        let v6 = (v1 + v4) / 2
        let v7 = (v1 + v3) / 2
        
        let scaled_v1 = v1 * scale + v7 * (1 - scale)
        var scaled_v6 = v6 * scale + v5 * (1 - scale)
        var scaled_v5 = v5 * scale + v6 * (1 - scale)
        scaled_v6 = scaled_v6 * scale + scaled_v1 * (1 - scale)
        scaled_v5 = scaled_v5 * scale + scaled_v1 * (1 - scale)
        let v8 = (scaled_v1 * 0.6 + scaled_v6 * 0.4)
        let v9 = (scaled_v1 * 0.6 + scaled_v5 * 0.4)
        let v10 = v8 + v9 - scaled_v1
        let (v11, v12, v13) = calculateCircle(v1: v8, v2: v9, v3: v10, v4: scaled_v1)
        
        vertices += [ v1, scaled_v1, v2, v3, v4,
                      scaled_v5, scaled_v6,
                      v7, v8, v9, v10, v11, v12, v13]
        indices += [
            10, 5, 6,
            6,8, 10,
            5, 9, 10,
            10, 8, 11,
            10, 11, 12,
            10, 12, 13,
            10, 13, 9
        ]
        
        let vertexSource = SCNGeometrySource(vertices: vertices)
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        let geometry = SCNGeometry(sources: [vertexSource], elements: [element])
        let material = SCNMaterial()
        material.isDoubleSided = true
        if (colorScheme == .scheme1) {
            material.diffuse.contents = UIColor.cubitYellow
        }
        else if (colorScheme == .scheme2) {
            material.diffuse.contents = UIColor.cubitPink
        }
        geometry.materials = [material]
        let node = SCNNode(geometry: geometry)
        
        return node
    }
    
    func calculateCircle(v1: SCNVector3, v2: SCNVector3, v3: SCNVector3,
                         v4: SCNVector3) -> (SCNVector3, SCNVector3, SCNVector3) {
        let v5 = v4 * 0.75 + v3 * 0.25
        let v6 = (v5 + v1) / 2
        let v7 = (v5 + v2) / 2
        let v8 = (v1 + v6) / 2
        let v9 = (v6 + v7) / 2
        let v10 = (v7 + v2) / 2
        return (v8, v9, v10)
    }
    
}
