//
//  MCAlgorithmV2.swift
//  marchingCubes
//
//  Created by Mingxin Hou on 10/23/24.
//

import SceneKit

func marchingCubesV2(data: [[[Int]]]) -> SCNNode {
    let parentNode = SCNNode() // Create a parent node to hold all generated nodes

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
                
                // Create a material and make it double-sided
                let material = SCNMaterial()
                material.isDoubleSided = true
//                material.diffuse.contents = UIColor.green
                
                // vertices
                let v_b4 = SCNVector3(Float(i), Float(j), Float(k))
                let v_b3 = SCNVector3(Float(i) + 1, Float(j), Float(k))
                let v_a3 = SCNVector3(Float(i) + 1, Float(j), Float(k) + 1)
                let v_a4 = SCNVector3(Float(i), Float(j), Float(k) + 1)
                let v_b1 = SCNVector3(Float(i), Float(j) + 1, Float(k))
                let v_b2 = SCNVector3(Float(i) + 1, Float(j) + 1, Float(k))
                let v_a2 = SCNVector3(Float(i) + 1, Float(j) + 1, Float(k) + 1)
                let v_a1 = SCNVector3(Float(i), Float(j) + 1, Float(k) + 1)
                // midpoint of vertices
                let v_a1_a2 = (v_a1 + v_a2) / 2
                let v_a2_a3 = (v_a3 + v_a2) / 2
                let v_a3_a4 = (v_a4 + v_a3) / 2
                let v_a1_a4 = (v_a1 + v_a4) / 2
                let v_b1_b2 = (v_b2 + v_b1) / 2
                let v_b2_b3 = (v_b3 + v_b2) / 2
                let v_b3_b4 = (v_b4 + v_b3) / 2
                let v_b1_b4 = (v_b1 + v_b4) / 2
                let v_a1_b1 = (v_a1 + v_b1) / 2
                let v_a2_b2 = (v_a2 + v_b2) / 2
                let v_a3_b3 = (v_a3 + v_b3) / 2
                let v_a4_b4 = (v_a4 + v_b4) / 2
                
                var vertices: [SCNVector3] = []
                var indices: [Int32] = []
                    
//                    if ((a1 + a2 + a3 + a4 + b1 + b2 + b3 + b4) != 6) {
//                        continue
//                    }
                    
                if ((a1 + a2 + a3 + a4 + b1 + b2 + b3 + b4) == 8) {
                    getMC0_1(vertices: &vertices, indices: &indices, v1: v_a1, v2: v_a2,
                             v3: v_a3, v4: v_a4, v5: v_b1, v6: v_b2, v7: v_b3, v8: v_b4)
                }
                else if ((a1 + a2 + a3 + a4 + b1 + b2 + b3 + b4) == 1) {
                    if (b4 == 1) {
                        getMC1_1N(vertices: &vertices, indices: &indices,
                                  v1: v_b4, v2: v_b3_b4, v3: v_b1_b4, v4: v_a4_b4)
                    }
                    else if (b3 == 1) {
                        getMC1_1N(vertices: &vertices, indices: &indices,
                                  v1: v_b3, v2: v_b3_b4, v3: v_b2_b3, v4: v_a3_b3)
//                            applyMirrorSymmetry(to: &vertices, along: "x", through: SCNVector3(Float(i) + 0.5, Float(j), Float(k)))
                    }
                    else if (b2 == 1) {
                        getMC1_1N(vertices: &vertices, indices: &indices,
                                  v1: v_b2, v2: v_b1_b2, v3: v_b2_b3, v4: v_a2_b2)
//                            applyMirrorSymmetry(to: &vertices, along: "y", through: vertices[2])
//                            applyMirrorSymmetry(to: &vertices, along: "x", through: vertices[3])
                    }
                    else if (b1 == 1) {
                        getMC1_1N(vertices: &vertices, indices: &indices,
                                  v1: v_b1, v2: v_b1_b4, v3: v_b1_b2, v4: v_a1_b1)
//                            applyMirrorSymmetry(to: &vertices, along: "y", through: SCNVector3(Float(i), Float(j) + 0.5, Float(k)))
                    }
                    else if (a4 == 1) {
                        getMC1_1N(vertices: &vertices, indices: &indices,
                                  v1: v_a4, v2: v_a4_b4, v3: v_a1_a4, v4: v_a3_a4)
//                            applyMirrorSymmetry(to: &vertices, along: "z", through: SCNVector3(Float(i), Float(j), Float(k) + 0.5))
                    }
                    else if (a3 == 1) {
                        getMC1_1N(vertices: &vertices, indices: &indices,
                                  v1: v_a3, v2: v_a3_b3, v3: v_a3_a4, v4: v_a2_a3)
//                            applyMirrorSymmetry(to: &vertices, along: "x", through: vertices[3])
//                            applyMirrorSymmetry(to: &vertices, along: "z", through: vertices[1])

                    }
                    else if (a2 == 1) {
                        getMC1_1N(vertices: &vertices, indices: &indices,
                                  v1: v_a2, v2: v_a2_b2, v3: v_a1_a2, v4: v_a2_a3)
//                            applyMirrorSymmetry(to: &vertices, along: "x", through: vertices[3])
//                            applyMirrorSymmetry(to: &vertices, along: "z", through: vertices[1])
//                            applyMirrorSymmetry(to: &vertices, along: "y", through: vertices[2])

                    }
                    else if (a1 == 1) {
                        getMC1_1N(vertices: &vertices, indices: &indices,
                                  v1: v_a1, v2: v_a1_b1, v3: v_a1_a2, v4: v_a1_a4)
//                            applyMirrorSymmetry(to: &vertices, along: "z", through: vertices[1])
//                            applyMirrorSymmetry(to: &vertices, along: "y", through: vertices[2])
                    }
                }
                else if (a1 + a2 + a3 + a4 + b1 + b2 + b3 + b4 == 7){
                    if (b4 == 0) {
                        getMC1_1(vertices: &vertices, indices: &indices,
                                 v1: v_a4_b4, v2: v_b3_b4, v3: v_b1_b4,
                                 v4: v_a4, v5: v_b3, v6: v_b1, v7: v_a3,
                                 v8: v_b2, v9: v_a1, v10: v_a2)
                    }
                    else if (b3 == 0){
                        getMC1_1(vertices: &vertices, indices: &indices,
                                 v1: v_a3_b3, v2: v_b2_b3, v3: v_b3_b4,
                                 v4: v_a3, v5: v_b2, v6: v_b4, v7: v_a2,
                                 v8: v_b1, v9: v_a4, v10: v_a1)
                    }
                    else if (b2 == 0) {
                        getMC1_1(vertices: &vertices, indices: &indices,
                                 v1: v_a2_b2, v2: v_b1_b2, v3: v_b2_b3,
                                 v4: v_a2, v5: v_b1, v6: v_b3, v7: v_a1,
                                 v8: v_b4, v9: v_a3, v10: v_a4)
                    }
                    else if (b1 == 0) {
                        getMC1_1(vertices: &vertices, indices: &indices,
                                 v1: v_a1_b1, v2: v_b1_b4, v3: v_b1_b2,
                                 v4: v_a1, v5: v_b4, v6: v_b2, v7: v_a4,
                                 v8: v_b3, v9: v_a2, v10: v_a3)
                    }
                    else if (a1 == 0) {
                        getMC1_1(vertices: &vertices, indices: &indices,
                                 v1: v_a1_b1, v2: v_a1_a2, v3: v_a1_a4,
                                 v4: v_b1, v5: v_a2, v6: v_a4, v7: v_b2,
                                 v8: v_a3, v9: v_b4, v10: v_b3)
                    }
                    else if (a2 == 0) {
                        getMC1_1(vertices: &vertices, indices: &indices,
                                 v1: v_a2_b2, v2: v_a2_a3, v3: v_a1_a2,
                                 v4: v_b2, v5: v_a3, v6: v_a1, v7: v_b3,
                                 v8: v_a4, v9: v_b1, v10: v_b4)
                    }
                    else if (a3 == 0) {
                        getMC1_1(vertices: &vertices, indices: &indices,
                                 v1: v_a3_b3, v2: v_a3_a4, v3: v_a2_a3,
                                 v4: v_b3, v5: v_a4, v6: v_a2, v7: v_b4,
                                 v8: v_a1, v9: v_b2, v10: v_b1)
                    }
                    else if (a4 == 0) {
                        getMC1_1(vertices: &vertices, indices: &indices,
                                 v1: v_a4_b4, v2: v_a1_a4, v3: v_a3_a4,
                                 v4: v_b4, v5: v_a1, v6: v_a3, v7: v_b1,
                                 v8: v_a2, v9: v_b3, v10: v_b2)
                    }
                }
                else if (a1 + a2 + a3 + a4 + b1 + b2 + b3 + b4 == 6){
                    if (a2 == 0 && b1 == 0) {
                        getMC2_1(vertices: &vertices, indices: &indices, v1: v_a2, v2: v_b1,
                                 v3: v_a1, v4: v_b2, v5: v_a3, v6: v_b4, v7: v_a4, v8: v_b3)
                    }
                    else if (b1 == 0 && a4 == 0) {
                        getMC2_1(vertices: &vertices, indices: &indices, v1: v_a4, v2: v_b1,
                                 v3: v_a1, v4: v_b4, v5: v_a3, v6: v_b2, v7: v_a2, v8: v_b3)
                    }
                    else if (a3 == 0 && b4 == 0) {
                        getMC2_1(vertices: &vertices, indices: &indices, v1: v_a3, v2: v_b4,
                                 v3: v_a4, v4: v_b3, v5: v_a2, v6: v_b1, v7: v_a1, v8: v_b2)
                    }
                    else if (b3 == 0 && a2 == 0) {
                        getMC2_1(vertices: &vertices, indices: &indices, v1: v_a2, v2: v_b3,
                                 v3: v_a3, v4: v_b2, v5: v_a1, v6: v_b4, v7: v_a4, v8: v_b1)
                    }
                    else if (a1 == 0 && b2 == 0) {
                        getMC2_1(vertices: &vertices, indices: &indices, v1: v_a1, v2: v_b2,
                                 v3: v_a2, v4: v_b1, v5: v_a4, v6: v_b3, v7: v_a3, v8: v_b4)
                    }
                    else if (a1 == 0 && a3 == 0) {
                        getMC2_1(vertices: &vertices, indices: &indices, v1: v_a1, v2: v_a3,
                                 v3: v_a2, v4: v_a4, v5: v_b1, v6: v_b3, v7: v_b2, v8: v_b4)
                    }
                    else if (a2 == 0 && a4 == 0) {
                        getMC2_1(vertices: &vertices, indices: &indices, v1: v_a2, v2: v_a4,
                                 v3: v_a1, v4: v_a3, v5: v_b2, v6: v_b4, v7: v_b1, v8: v_b3)
                    }
                    else if (b2 == 0 && b4 == 0) {
                        getMC2_1(vertices: &vertices, indices: &indices, v1: v_b2, v2: v_b4,
                                 v3: v_b1, v4: v_b3, v5: v_a2, v6: v_a4, v7: v_a1, v8: v_a3)
                    }
                    else if (b1 == 0 && b3 == 0) {
                        getMC2_1(vertices: &vertices, indices: &indices, v1: v_b1, v2: v_b3,
                                 v3: v_b2, v4: v_b4, v5: v_a1, v6: v_a3, v7: v_a2, v8: v_a4)
                    }
                    else if (a1 == 0 && b4 == 0) {
                        getMC2_1(vertices: &vertices, indices: &indices, v1: v_a1, v2: v_b4,
                                 v3: v_b1, v4: v_a4, v5: v_a2, v6: v_b3, v7: v_b2, v8: v_a3)
                    }
                    else if (a4 == 0 && b3 == 0) {
                        getMC2_1(vertices: &vertices, indices: &indices, v1: v_a1, v2: v_a3,
                                 v3: v_a2, v4: v_a4, v5: v_b1, v6: v_b3, v7: v_b2, v8: v_b4)
                    }
                    else if (a4 == 0 && b3 == 0) {
                        getMC2_1(vertices: &vertices, indices: &indices, v1: v_a4, v2: v_b3,
                                 v3: v_b4, v4: v_a3, v5: v_a1, v6: v_b2, v7: v_b1, v8: v_a2)
                    }
                    else if (b2 == 0 && a3 == 0) {
                        getMC2_1(vertices: &vertices, indices: &indices, v1: v_a3, v2: v_b2,
                                 v3: v_a2, v4: v_b3, v5: v_a4, v6: v_b1, v7: v_a1, v8: v_b4)
                    }
                }
                else if (a1 + a2 + a3 + a4 + b1 + b2 + b3 + b4 == 2){
                    if (a2 == 1 && b1 == 1) {
                        getMC2_1N(vertices: &vertices, indices: &indices, v1: v_a2, v2: v_b1,
                                 v3: v_a1, v4: v_b2, v5: v_a3, v6: v_b4, v7: v_a4, v8: v_b3)
                    }
                    else if (b1 == 1 && a4 == 1) {
                        getMC2_1N(vertices: &vertices, indices: &indices, v1: v_a4, v2: v_b1,
                                 v3: v_a1, v4: v_b4, v5: v_a3, v6: v_b2, v7: v_a2, v8: v_b3)
                    }
                    else if (a3 == 1 && b4 == 1) {
                        getMC2_1N(vertices: &vertices, indices: &indices, v1: v_a3, v2: v_b4,
                                 v3: v_a4, v4: v_b3, v5: v_a2, v6: v_b1, v7: v_a1, v8: v_b2)
                    }
                    else if (b3 == 1 && a2 == 1) {
                        getMC2_1N(vertices: &vertices, indices: &indices, v1: v_a2, v2: v_b3,
                                 v3: v_a3, v4: v_b2, v5: v_a1, v6: v_b4, v7: v_a4, v8: v_b1)
                    }
                    else if (a1 == 1 && b2 == 1) {
                        getMC2_1N(vertices: &vertices, indices: &indices, v1: v_a1, v2: v_b2,
                                 v3: v_a2, v4: v_b1, v5: v_a4, v6: v_b3, v7: v_a3, v8: v_b4)
                    }
                    else if (a1 == 1 && a3 == 1) {
                        getMC2_1N(vertices: &vertices, indices: &indices, v1: v_a1, v2: v_a3,
                                 v3: v_a2, v4: v_a4, v5: v_b1, v6: v_b3, v7: v_b2, v8: v_b4)
                    }
                    else if (a2 == 1 && a4 == 1) {
                        getMC2_1N(vertices: &vertices, indices: &indices, v1: v_a2, v2: v_a4,
                                 v3: v_a1, v4: v_a3, v5: v_b2, v6: v_b4, v7: v_b1, v8: v_b3)
                    }
                    else if (b2 == 1 && b4 == 1) {
                        getMC2_1N(vertices: &vertices, indices: &indices, v1: v_b2, v2: v_b4,
                                 v3: v_b1, v4: v_b3, v5: v_a2, v6: v_a4, v7: v_a1, v8: v_a3)
                    }
                    else if (b1 == 1 && b3 == 1) {
                        getMC2_1N(vertices: &vertices, indices: &indices, v1: v_b1, v2: v_b3,
                                 v3: v_b2, v4: v_b4, v5: v_a1, v6: v_a3, v7: v_a2, v8: v_a4)
                    }
                    else if (a1 == 1 && b4 == 1) {
                        getMC2_1N(vertices: &vertices, indices: &indices, v1: v_a1, v2: v_b4,
                                 v3: v_b1, v4: v_a4, v5: v_a2, v6: v_b3, v7: v_b2, v8: v_a3)
                    }
                    else if (a4 == 1 && b3 == 1) {
                        getMC2_1N(vertices: &vertices, indices: &indices, v1: v_a1, v2: v_a3,
                                 v3: v_a2, v4: v_a4, v5: v_b1, v6: v_b3, v7: v_b2, v8: v_b4)
                    }
                    else if (a4 == 1 && b3 == 1) {
                        getMC2_1N(vertices: &vertices, indices: &indices, v1: v_a4, v2: v_b3,
                                 v3: v_b4, v4: v_a3, v5: v_a1, v6: v_b2, v7: v_b1, v8: v_a2)
                    }
                    else if (b2 == 1 && a3 == 1) {
                        getMC2_1N(vertices: &vertices, indices: &indices, v1: v_a3, v2: v_b2,
                                 v3: v_a2, v4: v_b3, v5: v_a4, v6: v_b1, v7: v_a1, v8: v_b4)
                    }
                }
                    
                if (vertices.count != 0 && indices.count != 0) {
                    // Create geometry source
                    let vertexSource = SCNGeometrySource(vertices: vertices)
                    
                    // Create geometry element
                    let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
                    
                    // Create geometry
                    let geometry = SCNGeometry(sources: [vertexSource], elements: [element])
                    
                    // Assign the material to the geometry
                    geometry.materials = [material]
                    
                    // Use the geometry in a node
                    let node = SCNNode(geometry: geometry)
                    
                    parentNode.addChildNode(node)
                }
            }
        }
    }
    
    return parentNode // Return the parent node containing all child nodes
}
