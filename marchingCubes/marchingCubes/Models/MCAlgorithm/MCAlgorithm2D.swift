//
//  MCAlgorithm2D.swift
//  marchingCubes
//
//  Created by Mingxin Hou on 11/9/24.
//

import SceneKit

// Class implementing the 2D Marching Cubes algorithm
class MarchingCubes2D {
    var scale: Float = 0.8 // Scale factor for geometry
    
    // Main function to perform the 2D Marching Cubes algorithm on the input data
    func marchingCubes2D(data: [[Int]]) -> SCNNode {
        let parentNode = SCNNode() // Create a parent node to hold all generated nodes
        let xDim = data.count - 1
        let yDim = data[0].count - 1
        var vertices: [SCNVector3] = []
        var indices: [Int32] = []
        
        for i in 0..<xDim {
            for j in 0..<yDim {
                
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
                    let node = getBlue(vertices: &vertices, indices: &indices,
                                       v1: v1, v2: v2, v3: v3, v4: v4)
                    parentNode.addChildNode(node)
                }
                else if (a + b + c + d == 3){
                    if (a == 0) {
                        let node = getRed(vertices: &vertices, indices: &indices,
                                          v1: v1, v2: v2, v3: v3, v4: v4)
                        parentNode.addChildNode(node)
                    }
                    else if (b == 0) {
                        let node = getRed(vertices: &vertices, indices: &indices,
                                          v1: v2, v2: v1, v3: v4, v4: v3)
                        parentNode.addChildNode(node)
                    }
                    else if (c == 0) {
                        let node = getRed(vertices: &vertices, indices: &indices,
                                          v1: v3, v2: v2, v3: v1, v4: v4)
                        parentNode.addChildNode(node)
                    }
                    else if (d == 0) {
                        let node = getRed(vertices: &vertices, indices: &indices,
                                          v1: v4, v2: v3, v3: v2, v4: v1)
                        parentNode.addChildNode(node)
                    }
                }
                else if (a + b + c + d == 2){
                    if (a + b == 2) {
                        let node = getOrange(vertices: &vertices, indices: &indices,
                                             v1: v1, v2: v2, v3: v3, v4: v4)
                        parentNode.addChildNode(node)
                    }
                    else if (b + c == 2) {
                        let node = getOrange(vertices: &vertices, indices: &indices,
                                             v1: v2, v2: v3, v3: v4, v4: v1)
                        parentNode.addChildNode(node)
                    }
                    else if (c + d == 2) {
                        let node = getOrange(vertices: &vertices, indices: &indices,
                                             v1: v3, v2: v4, v3: v1, v4: v2)
                        parentNode.addChildNode(node)
                    }
                    else if (d + a == 2) {
                        let node = getOrange(vertices: &vertices, indices: &indices,
                                             v1: v4, v2: v1, v3: v2, v4: v3)
                        parentNode.addChildNode(node)
                    }
                    else if (a + c == 2) {
                        let node = getPurple(vertices: &vertices, indices: &indices,
                                             v1: v2, v2: v3, v3: v4, v4: v1)
                        parentNode.addChildNode(node)
                    }
                    else if (b + d == 2) {
                        let node = getPurple(vertices: &vertices, indices: &indices,
                                             v1: v1, v2: v2, v3: v3, v4: v4)
                        parentNode.addChildNode(node)
                    }
                }
                else if (a + b + c + d == 1) {
                    if (a == 1) {
                        let node = getYellow(vertices: &vertices, indices: &indices,
                                             v1: v1, v2: v2, v3: v3, v4: v4)
                        parentNode.addChildNode(node)
                    }
                    else if (b == 1) {
                        let node = getYellow(vertices: &vertices, indices: &indices,
                                             v1: v2, v2: v3, v3: v4, v4: v1)
                        parentNode.addChildNode(node)
                    }
                    else if (c == 1) {
                        let node = getYellow(vertices: &vertices, indices: &indices,
                                             v1: v3, v2: v4, v3: v1, v4: v2)
                        parentNode.addChildNode(node)
                    }
                    else if (d == 1) {
                        let node = getYellow(vertices: &vertices, indices: &indices,
                                             v1: v4, v2: v1, v3: v2, v4: v3)
                        parentNode.addChildNode(node)
                    }
                }
                
                vertices.removeAll()
                indices.removeAll()
            }
        }
        
        return parentNode
    }
    
    // + - +
    // |   |
    // + - +
    // Generate geometry for a fully filled cell (case: all corners filled)
    func getBlue(vertices: inout [SCNVector3], indices: inout [Int32], v1: SCNVector3, v2: SCNVector3,
                 v3: SCNVector3, v4: SCNVector3) -> SCNNode {
        let scaled_v1 = v1 * scale + v3 * (1 - scale)
        let scaled_v2 = v2 * scale + v4 * (1 - scale)
        let scaled_v3 = v3 * scale + v1 * (1 - scale)
        let scaled_v4 = v4 * scale + v2 * (1 - scale)
        
        vertices += [v1, scaled_v1, scaled_v2, scaled_v3, scaled_v4]
        indices += [1, 2, 3,
                    1, 3, 4
        ]
        
        let vertexSource = SCNGeometrySource(vertices: vertices)
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        let geometry = SCNGeometry(sources: [vertexSource], elements: [element])
        let material = SCNMaterial()
        material.isDoubleSided = true
        material.diffuse.contents = UIColor(red: 79/255, green: 151/255, blue: 211/255, alpha: 1.0) // (79,151,211)
        geometry.materials = [material]
        let node = SCNNode(geometry: geometry)
        
        return node
    }
    
    // Generate geometry for a cell with three filled corners (case: one corner empty)
    func getRed(vertices: inout [SCNVector3], indices: inout [Int32], v1: SCNVector3, v2: SCNVector3,
                v3: SCNVector3, v4: SCNVector3) -> SCNNode {
        let scaled_v1 = v1 * scale + v3 * (1 - scale)
        let scaled_v2 = v2 * scale + v4 * (1 - scale)
        let scaled_v3 = v3 * scale + v1 * (1 - scale)
        let scaled_v4 = v4 * scale + v2 * (1 - scale)
        
        vertices += [ v1, scaled_v1, scaled_v2, scaled_v3, scaled_v4,
                      (scaled_v1 + scaled_v2) / 2, (scaled_v1 + scaled_v4) / 2]
        indices += [
            2, 3, 5,
            3, 5, 6,
            3, 4, 6,
        ]
        
        let vertexSource = SCNGeometrySource(vertices: vertices)
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        let geometry = SCNGeometry(sources: [vertexSource], elements: [element])
        let material = SCNMaterial()
        material.isDoubleSided = true
        material.diffuse.contents = UIColor(red: 225/255, green: 82/255, blue: 75/255, alpha: 1.0) // (225,82,75)
        geometry.materials = [material]
        let node = SCNNode(geometry: geometry)
        
        return node
    }
    
    // Generate geometry for a cell with two diagonally filled corners (case: opposite corners filled)
    func getPurple(vertices: inout [SCNVector3], indices: inout [Int32], v1: SCNVector3, v2: SCNVector3,
                   v3: SCNVector3, v4: SCNVector3) -> SCNNode {
        let scaled_v1 = v1 * scale + v3 * (1 - scale)
        let scaled_v2 = v2 * scale + v4 * (1 - scale)
        let scaled_v3 = v3 * scale + v1 * (1 - scale)
        let scaled_v4 = v4 * scale + v2 * (1 - scale)
        
        vertices += [ v1, scaled_v1, scaled_v2, scaled_v3, scaled_v4,
                      (scaled_v1 + scaled_v2) / 2, (scaled_v2 + scaled_v3) / 2,
                      (scaled_v3 + scaled_v4) / 2, (scaled_v1 + scaled_v4) / 2]
        indices += [
            2, 5, 8,
            2, 6, 8,
            4, 7, 6,
            4, 8, 6,
        ]
        
        let vertexSource = SCNGeometrySource(vertices: vertices)
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        let geometry = SCNGeometry(sources: [vertexSource], elements: [element])
        let material = SCNMaterial()
        material.isDoubleSided = true
        material.diffuse.contents = UIColor(red: 194/255, green: 178/255, blue: 228/255, alpha: 1.0) // (194,178,228)
        geometry.materials = [material]
        let node = SCNNode(geometry: geometry)
        
        return node
    }
    
    // Generate geometry for a cell with two adjacent filled corners (case: adjacent corners filled)
    func getOrange(vertices: inout [SCNVector3], indices: inout [Int32], v1: SCNVector3, v2: SCNVector3,
                   v3: SCNVector3, v4: SCNVector3) -> SCNNode {
        let v5 = (v1 + v4) / 2
        let v6 = (v2 + v3) / 2
        
        let scaled_v1 = v1 * scale + v6 * (1 - scale)
        let scaled_v2 = v2 * scale + v5 * (1 - scale)
        let scaled_v6 = v6 * scale + v1 * (1 - scale)
        let scaled_v5 = v5 * scale + v2 * (1 - scale)
        
        vertices += [ v1, scaled_v1, scaled_v2, v3, v4,
                      scaled_v5, scaled_v6]
        indices += [
            1, 5, 6,
            1, 2, 6,
        ]
        
        let vertexSource = SCNGeometrySource(vertices: vertices)
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        let geometry = SCNGeometry(sources: [vertexSource], elements: [element])
        let material = SCNMaterial()
        material.isDoubleSided = true
        material.diffuse.contents = UIColor(red: 247/255, green: 164/255, blue: 116/255, alpha: 1.0) // (247,164,116)
        geometry.materials = [material]
        let node = SCNNode(geometry: geometry)
        
        return node
    }
    
    // Generate geometry for a cell with one filled corner (case: one corner filled)
    func getYellow(vertices: inout [SCNVector3], indices: inout [Int32], v1: SCNVector3, v2: SCNVector3,
                   v3: SCNVector3, v4: SCNVector3) -> SCNNode {
        let v5 = (v1 + v2) / 2
        let v6 = (v1 + v4) / 2
        let v7 = (v1 + v3) / 2
        
        let scaled_v1 = v1 * scale + v7 * (1 - scale)
        var scaled_v6 = v6 * scale + v5 * (1 - scale)
        var scaled_v5 = v5 * scale + v6 * (1 - scale)
        scaled_v6 = scaled_v6 * scale + scaled_v1 * (1 - scale)
        scaled_v5 = scaled_v5 * scale + scaled_v1 * (1 - scale)
        
        vertices += [ v1, scaled_v1, v2, v3, v4,
                      scaled_v5, scaled_v6]
        indices += [
            1, 5, 6
        ]
        
        let vertexSource = SCNGeometrySource(vertices: vertices)
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        let geometry = SCNGeometry(sources: [vertexSource], elements: [element])
        let material = SCNMaterial()
        material.isDoubleSided = true
        material.diffuse.contents = UIColor(red: 254/255, green: 223/255, blue: 111/255, alpha: 1.0) // (254,223,111)
        geometry.materials = [material]
        let node = SCNNode(geometry: geometry)
        
        return node
    }
    
}
