//
//  MCAlgorithmV2.swift
//  marchingCubes
//
//  Created by Mingxin Hou on 10/23/24.
//

import SceneKit

class MarchingCubesAlgo {
    var indices4Lines: [Int32] = []
    
    func marchingCubesV2(data: [[[Int]]]) -> SCNNode {
        let parentNode = SCNNode() // Create a parent node to hold all generated nodes
        print(data)
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
//                    material.transparency = 0.7
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
                    
//                    if (a1 + a2 + a3 + a4 + b1 + b2 + b3 + b4 > 0) {
//                        print(i, j, k)
//                    }
//                    if (j != 15 && j != 16){
//                        continue
//                    }
//                    if (a1 == 1) {
//                        parentNode.addChildNode(createBall(at: v_a1, radius: 0.05, color: UIColor.red))
//                    }
//                    if (a2 == 1) {
//                        parentNode.addChildNode(createBall(at: v_a2, radius: 0.05, color: UIColor.green))
//                    }
//                    if (a3 == 1) {
//                        parentNode.addChildNode(createBall(at: v_a3, radius: 0.05, color: UIColor.blue))
//                    }
//                    if (a4 == 1) {
//                        parentNode.addChildNode(createBall(at: v_a4, radius: 0.05, color: UIColor.yellow))
//                    }
//                    if (b1 == 1) {
//                        parentNode.addChildNode(createBall(at: v_b1, radius: 0.05, color: UIColor.cyan))
//                    }
//                    if (b2 == 1) {
//                        parentNode.addChildNode(createBall(at: v_b2, radius: 0.05, color: UIColor.magenta))
//                    }
//                    if (b3 == 1) {
//                        parentNode.addChildNode(createBall(at: v_b3, radius: 0.05, color: UIColor.orange))
//                    }
//                    if (b4 == 1){
//                        parentNode.addChildNode(createBall(at: v_b4, radius: 0.05, color: UIColor.purple))
//                    }
                    
                    
                    var vertices: [SCNVector3] = []
                    var indices: [Int32] = []
                    
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
                        }
                        else if (b2 == 1) {
                            getMC1_1N(vertices: &vertices, indices: &indices,
                                      v1: v_b2, v2: v_b1_b2, v3: v_b2_b3, v4: v_a2_b2)
                        }
                        else if (b1 == 1) {
                            getMC1_1N(vertices: &vertices, indices: &indices,
                                      v1: v_b1, v2: v_b1_b4, v3: v_b1_b2, v4: v_a1_b1)
                        }
                        else if (a4 == 1) {
                            getMC1_1N(vertices: &vertices, indices: &indices,
                                      v1: v_a4, v2: v_a4_b4, v3: v_a1_a4, v4: v_a3_a4)
                        }
                        else if (a3 == 1) {
                            getMC1_1N(vertices: &vertices, indices: &indices,
                                      v1: v_a3, v2: v_a3_b3, v3: v_a3_a4, v4: v_a2_a3)
                        }
                        else if (a2 == 1) {
                            getMC1_1N(vertices: &vertices, indices: &indices,
                                      v1: v_a2, v2: v_a2_b2, v3: v_a1_a2, v4: v_a2_a3)
                        }
                        else if (a1 == 1) {
                            getMC1_1N(vertices: &vertices, indices: &indices,
                                      v1: v_a1, v2: v_a1_b1, v3: v_a1_a2, v4: v_a1_a4)
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
                        else if (b3 == 0 && b4 == 0) {
                            getMC2_2(vertices: &vertices, indices: &indices, v1: v_b4, v2: v_b3,
                                     v3: v_a4, v4: v_a3, v5: v_a1, v6: v_a2, v7: v_b1, v8: v_b2)
                        }
                        else if (b3 == 0 && b2 == 0) {
                            getMC2_2(vertices: &vertices, indices: &indices, v1: v_b3, v2: v_b2,
                                     v3: v_a3, v4: v_a2, v5: v_a4, v6: v_a1, v7: v_b4, v8: v_b1)
                        }
                        else if (b2 == 0 && b1 == 0) {
                            getMC2_2(vertices: &vertices, indices: &indices, v1: v_b2, v2: v_b1,
                                     v3: v_a2, v4: v_a1, v5: v_a3, v6: v_a4, v7: v_b3, v8: v_b4)
                        }
                        else if (b4 == 0 && b1 == 0) {
                            getMC2_2(vertices: &vertices, indices: &indices, v1: v_b1, v2: v_b4,
                                     v3: v_a1, v4: v_a4, v5: v_a2, v6: v_a3, v7: v_b2, v8: v_b3)
                        }
                        else if (a2 == 0 && a1 == 0) {
                            getMC2_2(vertices: &vertices, indices: &indices, v1: v_a2, v2: v_a1,
                                     v3: v_a3, v4: v_a4, v5: v_b3, v6: v_b4, v7: v_b2, v8: v_b1)
                        }
                        else if (a2 == 0 && a3 == 0) {
                            getMC2_2(vertices: &vertices, indices: &indices, v1: v_a3, v2: v_a2,
                                     v3: v_a4, v4: v_a1, v5: v_b4, v6: v_b1, v7: v_b3, v8: v_b2)
                        }
                        else if (a4 == 0 && a3 == 0) {
                            getMC2_2(vertices: &vertices, indices: &indices, v1: v_a4, v2: v_a3,
                                     v3: v_a1, v4: v_a2, v5: v_b1, v6: v_b2, v7: v_b4, v8: v_b3)
                        }
                        else if (a4 == 0 && a1 == 0) {
                            getMC2_2(vertices: &vertices, indices: &indices, v1: v_a1, v2: v_a4,
                                     v3: v_a2, v4: v_a3, v5: v_b2, v6: v_b3, v7: v_b1, v8: v_b4)
                        }
                        else if (b1 == 0 && a1 == 0) {
                            getMC2_2(vertices: &vertices, indices: &indices, v1: v_a1, v2: v_b1,
                                     v3: v_a4, v4: v_b4, v5: v_a3, v6: v_b3, v7: v_a2, v8: v_b2)
                        }
                        else if (b2 == 0 && a2 == 0) {
                            getMC2_2(vertices: &vertices, indices: &indices, v1: v_a2, v2: v_b2,
                                     v3: v_a1, v4: v_b1, v5: v_a4, v6: v_b4, v7: v_a3, v8: v_b3)
                        }
                        else if (b3 == 0 && a3 == 0) {
                            getMC2_2(vertices: &vertices, indices: &indices, v1: v_a3, v2: v_b3,
                                     v3: v_a2, v4: v_b2, v5: v_a1, v6: v_b1, v7: v_a4, v8: v_b4)
                        }
                        else if (b4 == 0 && a4 == 0) {
                            getMC2_2(vertices: &vertices, indices: &indices, v1: v_a4, v2: v_b4,
                                     v3: v_a3, v4: v_b3, v5: v_a2, v6: v_b2, v7: v_a1, v8: v_b1)
                        }
                        else if (a1 == 0 && b3 == 0) {
                            getMC2_3(vertices: &vertices, indices: &indices, v1: v_a1, v2: v_b3,
                                     v3: v_a2, v4: v_b2, v5: v_b1, v6: v_b4, v7: v_a4, v8: v_a3)
                        }
                        else if (a2 == 0 && b4 == 0) {
                            getMC2_3(vertices: &vertices, indices: &indices, v1: v_a2, v2: v_b4,
                                     v3: v_a3, v4: v_b3, v5: v_b2, v6: v_b1, v7: v_a1, v8: v_a4)
                        }
                        else if (a3 == 0 && b1 == 0) {
                            getMC2_3(vertices: &vertices, indices: &indices, v1: v_a3, v2: v_b1,
                                     v3: v_a2, v4: v_b2, v5: v_b1, v6: v_b4, v7: v_a4, v8: v_a3)
                        }
                        else if (a4 == 0 && b2 == 0) {
                            getMC2_3(vertices: &vertices, indices: &indices, v1: v_a4, v2: v_b2,
                                     v3: v_a1, v4: v_b1, v5: v_b4, v6: v_b3, v7: v_a3, v8: v_a2)
                        }
                    }
                    else if (a1 + a2 + a3 + a4 + b1 + b2 + b3 + b4 == 5){
                        // MC3_1
                        if (a2 == 0 && a3 == 0 && b1 == 0){
                            getMC3_1(vertices: &vertices, indices: &indices, v1: v_a3, v2: v_a2,
                                     v3: v_b1, v4: v_b4, v5: v_b3, v6: v_b2, v7: v_a4, v8: v_a1)
                        }
                        else if (a2 == 0 && a3 == 0 && b4 == 0){
                            getMC3_1(vertices: &vertices, indices: &indices, v1: v_a2, v2: v_a3,
                                     v3: v_b4, v4: v_b1, v5: v_b2, v6: v_b3, v7: v_a1, v8: v_a4)
                        }
                        else if (a2 == 0 && a1 == 0 && b4 == 0){
                            getMC3_1(vertices: &vertices, indices: &indices, v1: v_a2, v2: v_a1,
                                     v3: v_b4, v4: v_b3, v5: v_b2, v6: v_b1, v7: v_a3, v8: v_a4)
                        }
                        else if (a2 == 0 && a1 == 0 && b3 == 0){
                            getMC3_1(vertices: &vertices, indices: &indices, v1: v_a1, v2: v_a2,
                                     v3: v_b3, v4: v_b4, v5: v_b1, v6: v_b2, v7: v_a4, v8: v_a3)
                        }
                        else if (a4 == 0 && a1 == 0 && b3 == 0){
                            getMC3_1(vertices: &vertices, indices: &indices, v1: v_a1, v2: v_a4,
                                     v3: v_b3, v4: v_b2, v5: v_b1, v6: v_b4, v7: v_a2, v8: v_a3)
                        }
                        else if (a4 == 0 && a1 == 0 && b2 == 0){
                            getMC3_1(vertices: &vertices, indices: &indices, v1: v_a4, v2: v_a1,
                                     v3: v_b2, v4: v_b3, v5: v_b4, v6: v_b1, v7: v_a3, v8: v_a2)
                        }
                        else if (a4 == 0 && a3 == 0 && b2 == 0){
                            getMC3_1(vertices: &vertices, indices: &indices, v1: v_a4, v2: v_a3,
                                     v3: v_b2, v4: v_b1, v5: v_b4, v6: v_b3, v7: v_a1, v8: v_a2)
                        }
                        else if (a4 == 0 && a3 == 0 && b1 == 0){
                            getMC3_1(vertices: &vertices, indices: &indices, v1: v_a3, v2: v_a4,
                                     v3: v_b1, v4: v_b2, v5: v_b3, v6: v_b4, v7: v_a2, v8: v_a1)
                        }
                        else if (b1 == 0 && b4 == 0 && a2 == 0){
                            getMC3_1(vertices: &vertices, indices: &indices, v1: v_b4, v2: v_b1,
                                     v3: v_a2, v4: v_a3, v5: v_a4, v6: v_a1, v7: v_b3, v8: v_b2)
                        }
                        else if (b1 == 0 && b4 == 0 && a3 == 0){
                            getMC3_1(vertices: &vertices, indices: &indices, v1: v_b1, v2: v_b4,
                                     v3: v_a3, v4: v_a2, v5: v_a1, v6: v_a4, v7: v_b2, v8: v_b3)
                        }
                        else if (b1 == 0 && b2 == 0 && a3 == 0){
                            getMC3_1(vertices: &vertices, indices: &indices, v1: v_b1, v2: v_b2,
                                     v3: v_a3, v4: v_a4, v5: v_a1, v6: v_a2, v7: v_b4, v8: v_b3)
                        }
                        else if (b1 == 0 && b2 == 0 && a4 == 0){
                            getMC3_1(vertices: &vertices, indices: &indices, v1: v_b2, v2: v_b1,
                                     v3: v_a4, v4: v_a3, v5: v_a2, v6: v_a1, v7: v_b3, v8: v_b4)
                        }
                        else if (b3 == 0 && b2 == 0 && a4 == 0){
                            getMC3_1(vertices: &vertices, indices: &indices, v1: v_b2, v2: v_b3,
                                     v3: v_a4, v4: v_a1, v5: v_a2, v6: v_a3, v7: v_b1, v8: v_b4)
                        }
                        else if (b3 == 0 && b2 == 0 && a1 == 0){
                            getMC3_1(vertices: &vertices, indices: &indices, v1: v_b3, v2: v_b2,
                                     v3: v_a1, v4: v_a4, v5: v_a3, v6: v_a2, v7: v_b4, v8: v_b1)
                        }
                        else if (b3 == 0 && b4 == 0 && a1 == 0){
                            getMC3_1(vertices: &vertices, indices: &indices, v1: v_b3, v2: v_b4,
                                     v3: v_a1, v4: v_a2, v5: v_a3, v6: v_a4, v7: v_b2, v8: v_b1)
                        }
                        else if (b3 == 0 && b4 == 0 && a2 == 0){
                            getMC3_1(vertices: &vertices, indices: &indices, v1: v_b4, v2: v_b3,
                                     v3: v_a2, v4: v_a1, v5: v_a4, v6: v_a3, v7: v_b1, v8: v_b2)
                        }
                        else if (a1 == 0 && b1 == 0 && b3 == 0){
                            getMC3_1(vertices: &vertices, indices: &indices, v1: v_a1, v2: v_b1,
                                     v3: v_b3, v4: v_a3, v5: v_a2, v6: v_b2, v7: v_a4, v8: v_b4)
                        }
                        else if (a1 == 0 && b1 == 0 && a3 == 0){
                            getMC3_1(vertices: &vertices, indices: &indices, v1: v_b1, v2: v_a1,
                                     v3: v_a3, v4: v_b3, v5: v_b2, v6: v_a2, v7: v_b4, v8: v_a4)
                        }
                        else if (a2 == 0 && b2 == 0 && b4 == 0){
                            getMC3_1(vertices: &vertices, indices: &indices, v1: v_a2, v2: v_b2,
                                     v3: v_b4, v4: v_a4, v5: v_a3, v6: v_b3, v7: v_a1, v8: v_b1)
                        }
                        else if (a2 == 0 && b2 == 0 && a4 == 0){
                            getMC3_1(vertices: &vertices, indices: &indices, v1: v_b2, v2: v_a2,
                                     v3: v_a4, v4: v_b4, v5: v_b3, v6: v_a3, v7: v_b1, v8: v_a1)
                        }
                        else if (a3 == 0 && b3 == 0 && b1 == 0){
                            getMC3_1(vertices: &vertices, indices: &indices, v1: v_a3, v2: v_b3,
                                     v3: v_b1, v4: v_a1, v5: v_a4, v6: v_b4, v7: v_a2, v8: v_b2)
                        }
                        else if (a3 == 0 && b3 == 0 && a1 == 0){
                            getMC3_1(vertices: &vertices, indices: &indices, v1: v_b3, v2: v_a3,
                                     v3: v_a1, v4: v_b1, v5: v_b4, v6: v_a4, v7: v_b2, v8: v_a2)
                        }
                        else if (a4 == 0 && b4 == 0 && b2 == 0){
                            getMC3_1(vertices: &vertices, indices: &indices, v1: v_a4, v2: v_b4,
                                     v3: v_b2, v4: v_a2, v5: v_a1, v6: v_b1, v7: v_a3, v8: v_b3)
                        }
                        else if (a4 == 0 && b4 == 0 && a2 == 0){
                            getMC3_1(vertices: &vertices, indices: &indices, v1: v_b4, v2: v_a4,
                                     v3: v_a2, v4: v_b2, v5: v_b1, v6: v_a1, v7: v_b3, v8: v_a3)
                        }
                        // MC3_3
                        else if (a1 == 0 && a3 == 0 && b4 == 0){
                            getMC3_3(vertices: &vertices, indices: &indices, v1: v_a4, v2: v_a1,
                                     v3: v_a3, v4: v_b4, v5: v_a2, v6: v_b3, v7: v_b1, v8: v_b2)
                        }
                        else if (a1 == 0 && a3 == 0 && b2 == 0){
                            getMC3_3(vertices: &vertices, indices: &indices, v1: v_a2, v2: v_a1,
                                     v3: v_b2, v4: v_a3, v5: v_b1, v6: v_b3, v7: v_a4, v8: v_b4)
                        }
                        else if (a2 == 0 && a4 == 0 && b3 == 0){
                            getMC3_3(vertices: &vertices, indices: &indices, v1: v_a3, v2: v_a4,
                                     v3: v_a2, v4: v_b3, v5: v_a1, v6: v_b2, v7: v_b4, v8: v_b1)
                        }
                        else if (a2 == 0 && a4 == 0 && b1 == 0){
                            getMC3_3(vertices: &vertices, indices: &indices, v1: v_a1, v2: v_a2,
                                     v3: v_a4, v4: v_b1, v5: v_a3, v6: v_b4, v7: v_b2, v8: v_b3)
                        }
                        else if (b1 == 0 && b3 == 0 && a4 == 0){
                            getMC3_3(vertices: &vertices, indices: &indices, v1: v_b4, v2: v_b3,
                                     v3: v_b1, v4: v_a4, v5: v_b2, v6: v_a1, v7: v_a3, v8: v_a2)
                        }
                        else if (b1 == 0 && b3 == 0 && a2 == 0){
                            getMC3_3(vertices: &vertices, indices: &indices, v1: v_b2, v2: v_b1,
                                     v3: v_b3, v4: v_a2, v5: v_b4, v6: v_a3, v7: v_a1, v8: v_a4)
                        }
                        else if (b2 == 0 && b4 == 0 && a1 == 0){
                            getMC3_3(vertices: &vertices, indices: &indices, v1: v_b1, v2: v_b4,
                                     v3: v_b2, v4: v_a1, v5: v_b3, v6: v_a2, v7: v_a4, v8: v_a3)
                        }
                        else if (b2 == 0 && b4 == 0 && a3 == 0){
                            getMC3_3(vertices: &vertices, indices: &indices, v1: v_b3, v2: v_b2,
                                     v3: v_b4, v4: v_a3, v5: v_b1, v6: v_a4, v7: v_a2, v8: v_a1)
                        }
                        // MC3_4
                        else if (a2 == 0 && a3 == 0 && a4 == 0){
                            getMC3_4(vertices: &vertices, indices: &indices, v1: v_a1, v2: v_a4,
                                     v3: v_a3, v4: v_a2, v5: v_b1, v6: v_b4, v7: v_b3, v8: v_b2)
                        }
                        else if (a2 == 0 && a3 == 0 && a1 == 0){
                            getMC3_4(vertices: &vertices, indices: &indices, v1: v_a4, v2: v_a3,
                                     v3: v_a2, v4: v_a1, v5: v_b4, v6: v_b3, v7: v_b2, v8: v_b1)
                        }
                        else if (a2 == 0 && a1 == 0 && a4 == 0){
                            getMC3_4(vertices: &vertices, indices: &indices, v1: v_a3, v2: v_a2,
                                     v3: v_a1, v4: v_a4, v5: v_b3, v6: v_b2, v7: v_b1, v8: v_b4)
                        }
                        else if (a2 == 0 && a3 == 0 && a4 == 0){
                            getMC3_4(vertices: &vertices, indices: &indices, v1: v_a2, v2: v_a1,
                                     v3: v_a4, v4: v_a3, v5: v_b2, v6: v_b1, v7: v_b4, v8: v_b3)
                        }
                        else if (b2 == 0 && b3 == 0 && b4 == 0){
                            getMC3_4(vertices: &vertices, indices: &indices, v1: v_b1, v2: v_b2,
                                     v3: v_b3, v4: v_b4, v5: v_a1, v6: v_a2, v7: v_a3, v8: v_a4)
                        }
                        else if (b2 == 0 && b3 == 0 && b1 == 0){
                            getMC3_4(vertices: &vertices, indices: &indices, v1: v_b4, v2: v_b1,
                                     v3: v_b2, v4: v_b3, v5: v_a4, v6: v_a1, v7: v_a2, v8: v_a3)
                        }
                        else if (b3 == 0 && b4 == 0 && b1 == 0){
                            getMC3_4(vertices: &vertices, indices: &indices, v1: v_b2, v2: v_b3,
                                     v3: v_b4, v4: v_b1, v5: v_a2, v6: v_a3, v7: v_a4, v8: v_a1)
                        }
                        else if (b2 == 0 && b4 == 0 && b1 == 0){
                            getMC3_4(vertices: &vertices, indices: &indices, v1: v_b3, v2: v_b4,
                                     v3: v_b1, v4: v_b2, v5: v_a3, v6: v_a4, v7: v_a1, v8: v_a2)
                        }
                        else if (a1 == 0 && b4 == 0 && b1 == 0){
                            getMC3_4(vertices: &vertices, indices: &indices, v1: v_a4, v2: v_a1,
                                     v3: v_b1, v4: v_b4, v5: v_a3, v6: v_a2, v7: v_b2, v8: v_b3)
                        }
                        else if (a1 == 0 && b1 == 0 && a4 == 0){
                            getMC3_4(vertices: &vertices, indices: &indices, v1: v_b4, v2: v_a4,
                                     v3: v_a1, v4: v_b1, v5: v_b3, v6: v_a3, v7: v_a2, v8: v_b2)
                        }
                        else if (a1 == 0 && b4 == 0 && a4 == 0){
                            getMC3_4(vertices: &vertices, indices: &indices, v1: v_b1, v2: v_b4,
                                     v3: v_a4, v4: v_a1, v5: v_b2, v6: v_b3, v7: v_a3, v8: v_a2)
                        }
                        else if (b4 == 0 && b1 == 0 && a4 == 0){
                            getMC3_4(vertices: &vertices, indices: &indices, v1: v_a1, v2: v_b1,
                                     v3: v_b4, v4: v_a4, v5: v_a2, v6: v_b2, v7: v_b3, v8: v_a3)
                        }
                        else if (a1 == 0 && a2 == 0 && b2 == 0){
                            getMC3_4(vertices: &vertices, indices: &indices, v1: v_b1, v2: v_a1,
                                     v3: v_a2, v4: v_b2, v5: v_b4, v6: v_a4, v7: v_a3, v8: v_b3)
                        }
                        else if (a1 == 0 && a2 == 0 && b1 == 0){
                            getMC3_4(vertices: &vertices, indices: &indices, v1: v_b2, v2: v_b1,
                                     v3: v_a1, v4: v_a2, v5: v_b3, v6: v_b4, v7: v_a4, v8: v_a3)
                        }
                        else if (a1 == 0 && b1 == 0 && b2 == 0){
                            getMC3_4(vertices: &vertices, indices: &indices, v1: v_a2, v2: v_b2,
                                     v3: v_b1, v4: v_a1, v5: v_a3, v6: v_b3, v7: v_b4, v8: v_a4)
                        }
                        else if (b1 == 0 && a2 == 0 && b2 == 0){
                            getMC3_4(vertices: &vertices, indices: &indices, v1: v_a1, v2: v_a2,
                                     v3: v_b2, v4: v_b1, v5: v_a4, v6: v_a3, v7: v_b3, v8: v_b4)
                        }
                        else if (a3 == 0 && a2 == 0 && b3 == 0){
                            getMC3_4(vertices: &vertices, indices: &indices, v1: v_b2, v2: v_a2,
                                     v3: v_a3, v4: v_b3, v5: v_b1, v6: v_a1, v7: v_a4, v8: v_b4)
                        }
                        else if (a3 == 0 && a2 == 0 && b2 == 0){
                            getMC3_4(vertices: &vertices, indices: &indices, v1: v_b3, v2: v_b2,
                                     v3: v_a2, v4: v_a3, v5: v_b4, v6: v_b1, v7: v_a1, v8: v_a4)
                        }
                        else if (b3 == 0 && a2 == 0 && b2 == 0){
                            getMC3_4(vertices: &vertices, indices: &indices, v1: v_a3, v2: v_b3,
                                     v3: v_b2, v4: v_a2, v5: v_a4, v6: v_b4, v7: v_b1, v8: v_a1)
                        }
                        else if (a3 == 0 && b2 == 0 && b3 == 0){
                            getMC3_4(vertices: &vertices, indices: &indices, v1: v_a2, v2: v_a3,
                                     v3: v_b3, v4: v_b2, v5: v_a1, v6: v_a4, v7: v_b4, v8: v_b1)
                        }
                        else if (a3 == 0 && a4 == 0 && b4 == 0){
                            getMC3_4(vertices: &vertices, indices: &indices, v1: v_b3, v2: v_a3,
                                     v3: v_a4, v4: v_b4, v5: v_b2, v6: v_a2, v7: v_a1, v8: v_b1)
                        }
                        else if (a3 == 0 && a4 == 0 && b3 == 0){
                            getMC3_4(vertices: &vertices, indices: &indices, v1: v_b4, v2: v_b3,
                                     v3: v_a3, v4: v_a4, v5: v_b1, v6: v_b2, v7: v_a2, v8: v_a1)
                        }
                        else if (a3 == 0 && b4 == 0 && b3 == 0){
                            getMC3_4(vertices: &vertices, indices: &indices, v1: v_a4, v2: v_b4,
                                     v3: v_b3, v4: v_a3, v5: v_a1, v6: v_b1, v7: v_b2, v8: v_a2)
                        }
                        else if (a4 == 0 && b4 == 0 && b3 == 0){
                            getMC3_4(vertices: &vertices, indices: &indices, v1: v_a3, v2: v_a4,
                                     v3: v_b4, v4: v_b3, v5: v_a2, v6: v_a1, v7: v_b1, v8: v_b2)
                        }
                    }
                    else if (a1 + a2 + a3 + a4 + b1 + b2 + b3 + b4 == 3){
                        // MC3_1N
                        if (a2 == 1 && a3 == 1 && b1 == 1){
                            getMC3_1N(vertices: &vertices, indices: &indices, v1: v_a3, v2: v_a2,
                                      v3: v_b1, v4: v_b4, v5: v_b3, v6: v_b2, v7: v_a4, v8: v_a1)
                        }
                        else if (a2 == 1 && a3 == 1 && b4 == 1){
                            getMC3_1N(vertices: &vertices, indices: &indices, v1: v_a2, v2: v_a3,
                                      v3: v_b4, v4: v_b1, v5: v_b2, v6: v_b3, v7: v_a1, v8: v_a4)
                        }
                        else if (a2 == 1 && a1 == 1 && b4 == 1){
                            getMC3_1N(vertices: &vertices, indices: &indices, v1: v_a2, v2: v_a1,
                                      v3: v_b4, v4: v_b3, v5: v_b2, v6: v_b1, v7: v_a3, v8: v_a4)
                        }
                        else if (a2 == 1 && a1 == 1 && b3 == 1){
                            getMC3_1N(vertices: &vertices, indices: &indices, v1: v_a1, v2: v_a2,
                                      v3: v_b3, v4: v_b4, v5: v_b1, v6: v_b2, v7: v_a4, v8: v_a3)
                        }
                        else if (a4 == 1 && a1 == 1 && b3 == 1){
                            getMC3_1N(vertices: &vertices, indices: &indices, v1: v_a1, v2: v_a4,
                                      v3: v_b3, v4: v_b2, v5: v_b1, v6: v_b4, v7: v_a2, v8: v_a3)
                        }
                        else if (a4 == 1 && a1 == 1 && b2 == 1){
                            getMC3_1N(vertices: &vertices, indices: &indices, v1: v_a4, v2: v_a1,
                                      v3: v_b2, v4: v_b3, v5: v_b4, v6: v_b1, v7: v_a3, v8: v_a2)
                        }
                        else if (a4 == 1 && a3 == 1 && b2 == 1){
                            getMC3_1N(vertices: &vertices, indices: &indices, v1: v_a4, v2: v_a3,
                                      v3: v_b2, v4: v_b1, v5: v_b4, v6: v_b3, v7: v_a1, v8: v_a2)
                        }
                        else if (a4 == 1 && a3 == 1 && b1 == 1){
                            getMC3_1N(vertices: &vertices, indices: &indices, v1: v_a3, v2: v_a4,
                                      v3: v_b1, v4: v_b2, v5: v_b3, v6: v_b4, v7: v_a2, v8: v_a1)
                        }
                        else if (b1 == 1 && b4 == 1 && a2 == 1){
                            getMC3_1N(vertices: &vertices, indices: &indices, v1: v_b4, v2: v_b1,
                                      v3: v_a2, v4: v_a3, v5: v_a4, v6: v_a1, v7: v_b3, v8: v_b2)
                        }
                        else if (b1 == 1 && b4 == 1 && a3 == 1){
                            getMC3_1N(vertices: &vertices, indices: &indices, v1: v_b1, v2: v_b4,
                                      v3: v_a3, v4: v_a2, v5: v_a1, v6: v_a4, v7: v_b2, v8: v_b3)
                        }
                        else if (b1 == 1 && b2 == 1 && a3 == 1){
                            getMC3_1N(vertices: &vertices, indices: &indices, v1: v_b1, v2: v_b2,
                                      v3: v_a3, v4: v_a4, v5: v_a1, v6: v_a2, v7: v_b4, v8: v_b3)
                        }
                        else if (b1 == 1 && b2 == 1 && a4 == 1){
                            getMC3_1N(vertices: &vertices, indices: &indices, v1: v_b2, v2: v_b1,
                                      v3: v_a4, v4: v_a3, v5: v_a2, v6: v_a1, v7: v_b3, v8: v_b4)
                        }
                        else if (b3 == 1 && b2 == 1 && a4 == 1){
                            getMC3_1N(vertices: &vertices, indices: &indices, v1: v_b2, v2: v_b3,
                                      v3: v_a4, v4: v_a1, v5: v_a2, v6: v_a3, v7: v_b1, v8: v_b4)
                        }
                        else if (b3 == 1 && b2 == 1 && a1 == 1){
                            getMC3_1N(vertices: &vertices, indices: &indices, v1: v_b3, v2: v_b2,
                                      v3: v_a1, v4: v_a4, v5: v_a3, v6: v_a2, v7: v_b4, v8: v_b1)
                        }
                        else if (b3 == 1 && b4 == 1 && a1 == 1){
                            getMC3_1N(vertices: &vertices, indices: &indices, v1: v_b3, v2: v_b4,
                                      v3: v_a1, v4: v_a2, v5: v_a3, v6: v_a4, v7: v_b2, v8: v_b1)
                        }
                        else if (b3 == 1 && b4 == 1 && a2 == 1){
                            getMC3_1N(vertices: &vertices, indices: &indices, v1: v_b4, v2: v_b3,
                                      v3: v_a2, v4: v_a1, v5: v_a4, v6: v_a3, v7: v_b1, v8: v_b2)
                        }
                        else if (a1 == 1 && b1 == 1 && b3 == 1){
                            getMC3_1N(vertices: &vertices, indices: &indices, v1: v_a1, v2: v_b1,
                                      v3: v_b3, v4: v_a3, v5: v_a2, v6: v_b2, v7: v_a4, v8: v_b4)
                        }
                        else if (a1 == 1 && b1 == 1 && a3 == 1){
                            getMC3_1N(vertices: &vertices, indices: &indices, v1: v_b1, v2: v_a1,
                                      v3: v_a3, v4: v_b3, v5: v_b2, v6: v_a2, v7: v_b4, v8: v_a4)
                        }
                        else if (a2 == 1 && b2 == 1 && b4 == 1){
                            getMC3_1N(vertices: &vertices, indices: &indices, v1: v_a2, v2: v_b2,
                                      v3: v_b4, v4: v_a4, v5: v_a3, v6: v_b3, v7: v_a1, v8: v_b1)
                        }
                        else if (a2 == 1 && b2 == 1 && a4 == 1){
                            getMC3_1N(vertices: &vertices, indices: &indices, v1: v_b2, v2: v_a2,
                                      v3: v_a4, v4: v_b4, v5: v_b3, v6: v_a3, v7: v_b1, v8: v_a1)
                        }
                        else if (a3 == 1 && b3 == 1 && b1 == 1){
                            getMC3_1N(vertices: &vertices, indices: &indices, v1: v_a3, v2: v_b3,
                                      v3: v_b1, v4: v_a1, v5: v_a4, v6: v_b4, v7: v_a2, v8: v_b2)
                        }
                        else if (a3 == 1 && b3 == 1 && a1 == 1){
                            getMC3_1N(vertices: &vertices, indices: &indices, v1: v_b3, v2: v_a3,
                                      v3: v_a1, v4: v_b1, v5: v_b4, v6: v_a4, v7: v_b2, v8: v_a2)
                        }
                        else if (a4 == 1 && b4 == 1 && b2 == 1){
                            getMC3_1N(vertices: &vertices, indices: &indices, v1: v_a4, v2: v_b4,
                                      v3: v_b2, v4: v_a2, v5: v_a1, v6: v_b1, v7: v_a3, v8: v_b3)
                        }
                        else if (a4 == 1 && b4 == 1 && a2 == 1){
                            getMC3_1N(vertices: &vertices, indices: &indices, v1: v_b4, v2: v_a4,
                                      v3: v_a2, v4: v_b2, v5: v_b1, v6: v_a1, v7: v_b3, v8: v_a3)
                        }
                        // MC3_4N
                        else if (a2 == 1 && a3 == 1 && a4 == 1){
                            getMC3_4N(vertices: &vertices, indices: &indices, v1: v_a1, v2: v_a4,
                                      v3: v_a3, v4: v_a2, v5: v_b1, v6: v_b4, v7: v_b3, v8: v_b2)
                        }
                        else if (a2 == 1 && a3 == 1 && a1 == 1){
                            getMC3_4N(vertices: &vertices, indices: &indices, v1: v_a4, v2: v_a3,
                                      v3: v_a2, v4: v_a1, v5: v_b4, v6: v_b3, v7: v_b2, v8: v_b1)
                        }
                        else if (a2 == 1 && a1 == 1 && a4 == 1){
                            getMC3_4N(vertices: &vertices, indices: &indices, v1: v_a3, v2: v_a2,
                                      v3: v_a1, v4: v_a4, v5: v_b3, v6: v_b2, v7: v_b1, v8: v_b4)
                        }
                        else if (a2 == 1 && a3 == 1 && a4 == 1){
                            getMC3_4N(vertices: &vertices, indices: &indices, v1: v_a2, v2: v_a1,
                                      v3: v_a4, v4: v_a3, v5: v_b2, v6: v_b1, v7: v_b4, v8: v_b3)
                        }
                        else if (b2 == 1 && b3 == 1 && b4 == 1){
                            getMC3_4N(vertices: &vertices, indices: &indices, v1: v_b1, v2: v_b2,
                                      v3: v_b3, v4: v_b4, v5: v_a1, v6: v_a2, v7: v_a3, v8: v_a4)
                        }
                        else if (b2 == 1 && b3 == 1 && b1 == 1){
                            getMC3_4N(vertices: &vertices, indices: &indices, v1: v_b4, v2: v_b1,
                                      v3: v_b2, v4: v_b3, v5: v_a4, v6: v_a1, v7: v_a2, v8: v_a3)
                        }
                        else if (b3 == 1 && b4 == 1 && b1 == 1){
                            getMC3_4N(vertices: &vertices, indices: &indices, v1: v_b2, v2: v_b3,
                                      v3: v_b4, v4: v_b1, v5: v_a2, v6: v_a3, v7: v_a4, v8: v_a1)
                        }
                        else if (b2 == 1 && b4 == 1 && b1 == 1){
                            getMC3_4N(vertices: &vertices, indices: &indices, v1: v_b3, v2: v_b4,
                                      v3: v_b1, v4: v_b2, v5: v_a3, v6: v_a4, v7: v_a1, v8: v_a2)
                        }
                        else if (a1 == 1 && b4 == 1 && b1 == 1){
                            getMC3_4N(vertices: &vertices, indices: &indices, v1: v_a4, v2: v_a1,
                                      v3: v_b1, v4: v_b4, v5: v_a3, v6: v_a2, v7: v_b2, v8: v_b3)
                        }
                        else if (a1 == 1 && b1 == 1 && a4 == 1){
                            getMC3_4N(vertices: &vertices, indices: &indices, v1: v_b4, v2: v_a4,
                                      v3: v_a1, v4: v_b1, v5: v_b3, v6: v_a3, v7: v_a2, v8: v_b2)
                        }
                        else if (a1 == 1 && b4 == 1 && a4 == 1){
                            getMC3_4N(vertices: &vertices, indices: &indices, v1: v_b1, v2: v_b4,
                                      v3: v_a4, v4: v_a1, v5: v_b2, v6: v_b3, v7: v_a3, v8: v_a2)
                        }
                        else if (b4 == 1 && b1 == 1 && a4 == 1){
                            getMC3_4N(vertices: &vertices, indices: &indices, v1: v_a1, v2: v_b1,
                                      v3: v_b4, v4: v_a4, v5: v_a2, v6: v_b2, v7: v_b3, v8: v_a3)
                        }
                        else if (a1 == 1 && a2 == 1 && b2 == 1){
                            getMC3_4N(vertices: &vertices, indices: &indices, v1: v_b1, v2: v_a1,
                                      v3: v_a2, v4: v_b2, v5: v_b4, v6: v_a4, v7: v_a3, v8: v_b3)
                        }
                        else if (a1 == 1 && a2 == 1 && b1 == 1){
                            getMC3_4N(vertices: &vertices, indices: &indices, v1: v_b2, v2: v_b1,
                                      v3: v_a1, v4: v_a2, v5: v_b3, v6: v_b4, v7: v_a4, v8: v_a3)
                        }
                        else if (a1 == 1 && b1 == 1 && b2 == 1){
                            getMC3_4N(vertices: &vertices, indices: &indices, v1: v_a2, v2: v_b2,
                                      v3: v_b1, v4: v_a1, v5: v_a3, v6: v_b3, v7: v_b4, v8: v_a4)
                        }
                        else if (b1 == 1 && a2 == 1 && b2 == 1){
                            getMC3_4N(vertices: &vertices, indices: &indices, v1: v_a1, v2: v_a2,
                                      v3: v_b2, v4: v_b1, v5: v_a4, v6: v_a3, v7: v_b3, v8: v_b4)
                        }
                        else if (a3 == 1 && a2 == 1 && b3 == 1){
                            getMC3_4N(vertices: &vertices, indices: &indices, v1: v_b2, v2: v_a2,
                                      v3: v_a3, v4: v_b3, v5: v_b1, v6: v_a1, v7: v_a4, v8: v_b4)
                        }
                        else if (a3 == 1 && a2 == 1 && b2 == 1){
                            getMC3_4N(vertices: &vertices, indices: &indices, v1: v_b3, v2: v_b2,
                                      v3: v_a2, v4: v_a3, v5: v_b4, v6: v_b1, v7: v_a1, v8: v_a4)
                        }
                        else if (b3 == 1 && a2 == 1 && b2 == 1){
                            getMC3_4N(vertices: &vertices, indices: &indices, v1: v_a3, v2: v_b3,
                                      v3: v_b2, v4: v_a2, v5: v_a4, v6: v_b4, v7: v_b1, v8: v_a1)
                        }
                        else if (a3 == 1 && b2 == 1 && b3 == 1){
                            getMC3_4N(vertices: &vertices, indices: &indices, v1: v_a2, v2: v_a3,
                                      v3: v_b3, v4: v_b2, v5: v_a1, v6: v_a4, v7: v_b4, v8: v_b1)
                        }
                        else if (a3 == 1 && a4 == 1 && b4 == 1){
                            getMC3_4N(vertices: &vertices, indices: &indices, v1: v_b3, v2: v_a3,
                                      v3: v_a4, v4: v_b4, v5: v_b2, v6: v_a2, v7: v_a1, v8: v_b1)
                        }
                        else if (a3 == 1 && a4 == 1 && b3 == 1){
                            getMC3_4N(vertices: &vertices, indices: &indices, v1: v_b4, v2: v_b3,
                                      v3: v_a3, v4: v_a4, v5: v_b1, v6: v_b2, v7: v_a2, v8: v_a1)
                        }
                        else if (a3 == 1 && b4 == 1 && b3 == 1){
                            getMC3_4N(vertices: &vertices, indices: &indices, v1: v_a4, v2: v_b4,
                                      v3: v_b3, v4: v_a3, v5: v_a1, v6: v_b1, v7: v_b2, v8: v_a2)
                        }
                        else if (a4 == 1 && b4 == 1 && b3 == 1){
                            getMC3_4N(vertices: &vertices, indices: &indices, v1: v_a3, v2: v_a4,
                                      v3: v_b4, v4: v_b3, v5: v_a2, v6: v_a1, v7: v_b1, v8: v_b2)
                        }
                    }
                    else if (a1 + a2 + a3 + a4 + b1 + b2 + b3 + b4 == 4) {
                        if (a1 == 1 && a3 == 1 && b2 == 1 && b4 == 1) {
                            getMC4_1(vertices: &vertices, indices: &indices, v1: v_a2, v2: v_a3, v3: v_a4, v4: v_a1, v5: v_b2, v6: v_b3, v7: v_b4, v8: v_b1)
                        }
                        else if (a2 == 1 && a4 == 1 && b1 == 1 && b3 == 1) {
                            getMC4_1(vertices: &vertices, indices: &indices, v1: v_a1, v2: v_a2, v3: v_a3, v4: v_a4, v5: v_b1, v6: v_b2, v7: v_b3, v8: v_b4)
                        }
                        else if (a1 == 1 && a2 == 1 && a3 == 1 && b4 == 1) {
                            getMC4_2(vertices: &vertices, indices: &indices, v1: v_a2, v2: v_a3, v3: v_a4, v4: v_a1, v5: v_b2, v6: v_b3, v7: v_b4, v8: v_b1)
                        }
                        else if (a1 == 1 && a2 == 1 && a4 == 1 && b3 == 1) {
                            getMC4_2(vertices: &vertices, indices: &indices, v1: v_a1, v2: v_a2, v3: v_a3, v4: v_a4, v5: v_b1, v6: v_b2, v7: v_b3, v8: v_b4)
                        }
                        else if (a1 == 1 && a3 == 1 && a4 == 1 && b2 == 1) {
                            getMC4_2(vertices: &vertices, indices: &indices, v1: v_a4, v2: v_a1, v3: v_a2, v4: v_a3, v5: v_b4, v6: v_b1, v7: v_b2, v8: v_b3)
                        }
                        else if (a2 == 1 && a3 == 1 && a3 == 1 && b1 == 1) {
                            getMC4_2(vertices: &vertices, indices: &indices, v1: v_a3, v2: v_a4, v3: v_a1, v4: v_a2, v5: v_b3, v6: v_b4, v7: v_b1, v8: v_b2)
                        }
                        else if (a2 == 1 && b2 == 1 && b3 == 1 && a4 == 1) {
                            getMC4_2(vertices: &vertices, indices: &indices, v1: v_b2, v2: v_b3, v3: v_a3, v4: v_a2, v5: v_b1, v6: v_b4, v7: v_a4, v8: v_a1)
                        }
                        else if (a1 == 1 && a3 == 1 && b1 == 1 && b2 == 1) {
                            getMC4_2(vertices: &vertices, indices: &indices, v1: v_b1, v2: v_b2, v3: v_a2, v4: v_a1, v5: v_b4, v6: v_b3, v7: v_a3, v8: v_a4)
                        }
                        else if (a2 == 1 && a4 == 1 && b1 == 1 && b4 == 1) {
                            getMC4_2(vertices: &vertices, indices: &indices, v1: v_b4, v2: v_b1, v3: v_a1, v4: v_a4, v5: v_b3, v6: v_b2, v7: v_a2, v8: v_a3)
                        }
                        else if (a1 == 1 && a3 == 1 && b3 == 1 && b4 == 1) {
                            getMC4_2(vertices: &vertices, indices: &indices, v1: v_b3, v2: v_b4, v3: v_a4, v4: v_a3, v5: v_b2, v6: v_b1, v7: v_a1, v8: v_a2)
                        }
                        else if (a3 == 1 && b1 == 1 && b2 == 1 && b4 == 1) {
                            getMC4_2(vertices: &vertices, indices: &indices, v1: v_b1, v2: v_b4, v3: v_b3, v4: v_b2, v5: v_a1, v6: v_a4, v7: v_a3, v8: v_a2)
                        }
                        else if (a2 == 1 && b1 == 1 && b3 == 1 && b4 == 1) {
                            getMC4_2(vertices: &vertices, indices: &indices, v1: v_b4, v2: v_b3, v3: v_b2, v4: v_b1, v5: v_a4, v6: v_a3, v7: v_a2, v8: v_a1)
                        }
                        else if (a1 == 1 && b2 == 1 && b3 == 1 && b4 == 1) {
                            getMC4_2(vertices: &vertices, indices: &indices, v1: v_b3, v2: v_b2, v3: v_b1, v4: v_b4, v5: v_a3, v6: v_a2, v7: v_a1, v8: v_a4)
                        }
                        else if (a4 == 1 && b1 == 1 && b2 == 1 && b3 == 1) {
                            getMC4_2(vertices: &vertices, indices: &indices, v1: v_b2, v2: v_b1, v3: v_b4, v4: v_b3, v5: v_a2, v6: v_a1, v7: v_a4, v8: v_a3)
                        }
                        else if (a1 == 1 && a4 == 1 && b1 == 1 && b3 == 1) {
                            getMC4_2(vertices: &vertices, indices: &indices, v1: v_a1, v2: v_a4, v3: v_b4, v4: v_b1, v5: v_a2, v6: v_a3, v7: v_b3, v8: v_b2)
                        }
                        else if (a3 == 1 && a4 == 1 && b2 == 1 && b4 == 1) {
                            getMC4_2(vertices: &vertices, indices: &indices, v1: v_a4, v2: v_a3, v3: v_b3, v4: v_b4, v5: v_a1, v6: v_a2, v7: v_b2, v8: v_b1)
                        }
                        else if (a2 == 1 && a3 == 1 && b1 == 1 && b3 == 1) {
                            getMC4_2(vertices: &vertices, indices: &indices, v1: v_a3, v2: v_a2, v3: v_b2, v4: v_b3, v5: v_a4, v6: v_a1, v7: v_b1, v8: v_b4)
                        }
                        else if (a1 == 1 && a2 == 1 && b2 == 1 && b4 == 1) {
                            getMC4_2(vertices: &vertices, indices: &indices, v1: v_a2, v2: v_a1, v3: v_b1, v4: v_b2, v5: v_a3, v6: v_a4, v7: v_b4, v8: v_b3)
                        }
                        else if (a3 == 1 && a4 == 1 && b1 == 1 && b3 == 1) {
                            getMC4_2(vertices: &vertices, indices: &indices, v1: v_a3, v2: v_b3, v3: v_b4, v4: v_a4, v5: v_a2, v6: v_b2, v7: v_b1, v8: v_a1)
                        }
                        else if (a2 == 1 && a3 == 1 && b2 == 1 && b4 == 1) {
                            getMC4_2(vertices: &vertices, indices: &indices, v1: v_a2, v2: v_b2, v3: v_b3, v4: v_a3, v5: v_a1, v6: v_b1, v7: v_b4, v8: v_a4)
                        }
                        else if (a1 == 1 && a2 == 1 && b1 == 1 && b3 == 1) {
                            getMC4_2(vertices: &vertices, indices: &indices, v1: v_a1, v2: v_b1, v3: v_b2, v4: v_a2, v5: v_a4, v6: v_b4, v7: v_b3, v8: v_a3)
                        }
                        else if (a1 == 1 && a4 == 1 && b2 == 1 && b4 == 1) {
                            getMC4_2(vertices: &vertices, indices: &indices, v1: v_a4, v2: v_b4, v3: v_b1, v4: v_a1, v5: v_a3, v6: v_b3, v7: v_b2, v8: v_a2)
                        }
                        else if (a2 == 1 && a4 == 1 && b1 == 1 && b2 == 1) {
                            getMC4_2(vertices: &vertices, indices: &indices, v1: v_b2, v2: v_a2, v3: v_a1, v4: v_b1, v5: v_b3, v6: v_a3, v7: v_a4, v8: v_b4)
                        }
                        else if (a1 == 1 && a3 == 1 && b1 == 1 && b4 == 1) {
                            getMC4_2(vertices: &vertices, indices: &indices, v1: v_b1, v2: v_a1, v3: v_a4, v4: v_b4, v5: v_b2, v6: v_a2, v7: v_a3, v8: v_b3)
                        }
                        else if (a2 == 1 && a4 == 1 && b3 == 1 && b4 == 1) {
                            getMC4_2(vertices: &vertices, indices: &indices, v1: v_b4, v2: v_a4, v3: v_a3, v4: v_b3, v5: v_b1, v6: v_a1, v7: v_a2, v8: v_b2)
                        }
                        else if (a1 == 1 && a3 == 1 && b2 == 1 && b3 == 1) {
                            getMC4_2(vertices: &vertices, indices: &indices, v1: v_b3, v2: v_a3, v3: v_a2, v4: v_b2, v5: v_b4, v6: v_a4, v7: v_a1, v8: v_b1)
                        }
                        else if (a3 == 1 && a4 == 1 && b1 == 1 && b2 == 1) {
                            getMC4_3(vertices: &vertices, indices: &indices, v1: v_a1, v2: v_a2, v3: v_a3, v4: v_a4, v5: v_b1, v6: v_b2, v7: v_b3, v8: v_b4)
                        }
                        else if (a2 == 1 && a3 == 1 && b1 == 1 && b4 == 1) {
                            getMC4_3(vertices: &vertices, indices: &indices, v1: v_a4, v2: v_a1, v3: v_a2, v4: v_a3, v5: v_b4, v6: v_b1, v7: v_b2, v8: v_b3)
                        }
                        else if (a1 == 1 && a2 == 1 && b3 == 1 && b4 == 1) {
                            getMC4_3(vertices: &vertices, indices: &indices, v1: v_a3, v2: v_a4, v3: v_a1, v4: v_a2, v5: v_b3, v6: v_b4, v7: v_b1, v8: v_b2)
                        }
                        else if (a1 == 1 && a4 == 1 && b2 == 1 && b3 == 1) {
                            getMC4_3(vertices: &vertices, indices: &indices, v1: v_a2, v2: v_a3, v3: v_a4, v4: v_a1, v5: v_b2, v6: v_b3, v7: v_b4, v8: v_b1)
                        }
                        else if (a1 == 1 && a3 == 1 && b1 == 1 && b3 == 1) {
                            getMC4_3(vertices: &vertices, indices: &indices, v1: v_a2, v2: v_b2, v3: v_b3, v4: v_a3, v5: v_a1, v6: v_b1, v7: v_b4, v8: v_a4)
                        }
                        else if (a2 == 1 && a4 == 1 && b2 == 1 && b4 == 1) {
                            getMC4_3(vertices: &vertices, indices: &indices, v1: v_a1, v2: v_b1, v3: v_b2, v4: v_a2, v5: v_a4, v6: v_b4, v7: v_b3, v8: v_a3)
                        }
                        else if (a1 == 1 && a2 == 1 && a3 == 1 && a4 == 1) {
                            getMC4_4(vertices: &vertices, indices: &indices, v1: v_a1, v2: v_a2, v3: v_a3, v4: v_a4, v5: v_b1, v6: v_b2, v7: v_b3, v8: v_b4)
                        }
                        else if (a1 == 1 && a2 == 1 && b1 == 1 && b2 == 1) {
                            getMC4_4(vertices: &vertices, indices: &indices, v1: v_a1, v2: v_b1, v3: v_b2, v4: v_a2, v5: v_a4, v6: v_b4, v7: v_b3, v8: v_a3)
                        }
                        else if (a1 == 1 && a4 == 1 && b1 == 1 && b4 == 1) {
                            getMC4_4(vertices: &vertices, indices: &indices, v1: v_a1, v2: v_a4, v3: v_b4, v4: v_b1, v5: v_a2, v6: v_a3, v7: v_b3, v8: v_b2)
                        }
                        else if (a2 == 1 && a3 == 1 && b2 == 1 && b3 == 1) {
                            getMC4_4(vertices: &vertices, indices: &indices, v1: v_a3, v2: v_a2, v3: v_b2, v4: v_b3, v5: v_a4, v6: v_a1, v7: v_b1, v8: v_b4)
                        }
                        else if (a3 == 1 && a4 == 1 && b3 == 1 && b4 == 1) {
                            getMC4_4(vertices: &vertices, indices: &indices, v1: v_a4, v2: v_a3, v3: v_b3, v4: v_b4, v5: v_a1, v6: v_a2, v7: v_b2, v8: v_b1)
                        }
                        else if (b1 == 1 && b2 == 1 && b3 == 1 && b4 == 1) {
                            getMC4_4(vertices: &vertices, indices: &indices, v1: v_b1, v2: v_b4, v3: v_b3, v4: v_b2, v5: v_a1, v6: v_a4, v7: v_a3, v8: v_a2)
                        }
                        else if (a2 == 1 && a3 == 1 && a4 == 1 && b3 == 1) {
                            getMC4_5(vertices: &vertices, indices: &indices, v1: v_a4, v2: v_a1, v3: v_a2, v4: v_a3, v5: v_b4, v6: v_b1, v7: v_b2, v8: v_b3)
                        }
                        else if (a1 == 1 && a2 == 1 && a3 == 1 && b2 == 1) {
                            getMC4_5(vertices: &vertices, indices: &indices, v1: v_a3, v2: v_a4, v3: v_a1, v4: v_a2, v5: v_b3, v6: v_b4, v7: v_b1, v8: v_b2)
                        }
                        else if (a1 == 1 && a2 == 1 && a4 == 1 && b1 == 1) {
                            getMC4_5(vertices: &vertices, indices: &indices, v1: v_a2, v2: v_a3, v3: v_a4, v4: v_a1, v5: v_b2, v6: v_b3, v7: v_b4, v8: v_b1)
                        }
                        else if (a1 == 1 && a3 == 1 && a4 == 1 && b4 == 1) {
                            getMC4_5(vertices: &vertices, indices: &indices, v1: v_a1, v2: v_a2, v3: v_a3, v4: v_a4, v5: v_b1, v6: v_b2, v7: v_b3, v8: v_b4)
                        }
                        else if (a3 == 1 && b2 == 1 && b3 == 1 && b4 == 1) {
                            getMC4_5(vertices: &vertices, indices: &indices, v1: v_b2, v2: v_b1, v3: v_b4, v4: v_b3, v5: v_a2, v6: v_a1, v7: v_a4, v8: v_a3)
                        }
                        else if (a2 == 1 && b1 == 1 && b2 == 1 && b3 == 1) {
                            getMC4_5(vertices: &vertices, indices: &indices, v1: v_b1, v2: v_b4, v3: v_b3, v4: v_b2, v5: v_a1, v6: v_a4, v7: v_a3, v8: v_a2)
                        }
                        else if (a1 == 1 && b1 == 1 && b2 == 1 && b4 == 1) {
                            getMC4_5(vertices: &vertices, indices: &indices, v1: v_b4, v2: v_b3, v3: v_b2, v4: v_b1, v5: v_a4, v6: v_a3, v7: v_a2, v8: v_a1)
                        }
                        else if (a4 == 1 && b1 == 1 && b3 == 1 && b4 == 1) {
                            getMC4_5(vertices: &vertices, indices: &indices, v1: v_b3, v2: v_b2, v3: v_b1, v4: v_b4, v5: v_a3, v6: v_a2, v7: v_a1, v8: v_a4)
                        }
                        else if (a1 == 1 && a3 == 1 && a4 == 1 && b3 == 1) {
                            getMC4_6(vertices: &vertices, indices: &indices, v1: v_a1, v2: v_a2, v3: v_a3, v4: v_a4, v5: v_b1, v6: v_b2, v7: v_b3, v8: v_b4)
                        }
                        else if (a2 == 1 && a3 == 1 && a4 == 1 && b2 == 1) {
                            getMC4_6(vertices: &vertices, indices: &indices, v1: v_a4, v2: v_a1, v3: v_a2, v4: v_a3, v5: v_b4, v6: v_b1, v7: v_b2, v8: v_b3)
                        }
                        else if (a1 == 1 && a2 == 1 && a3 == 1 && b1 == 1) {
                            getMC4_6(vertices: &vertices, indices: &indices, v1: v_a3, v2: v_a4, v3: v_a1, v4: v_a2, v5: v_b3, v6: v_b4, v7: v_b1, v8: v_b2)
                        }
                        else if (a1 == 1 && a2 == 1 && a4 == 1 && b4 == 1) {
                            getMC4_6(vertices: &vertices, indices: &indices, v1: v_a2, v2: v_a3, v3: v_a4, v4: v_a1, v5: v_b2, v6: v_b3, v7: v_b4, v8: v_b1)
                        }
                        else if (a2 == 1 && a3 == 1 && b3 == 1 && b4 == 1) {
                            getMC4_6(vertices: &vertices, indices: &indices, v1: v_a2, v2: v_b2, v3: v_b3, v4: v_a3, v5: v_a1, v6: v_b1, v7: v_b4, v8: v_a4)
                        }
                        else if (a1 == 1 && a2 == 1 && b2 == 1 && b3 == 1) {
                            getMC4_6(vertices: &vertices, indices: &indices, v1: v_a1, v2: v_b1, v3: v_b2, v4: v_a2, v5: v_a4, v6: v_b4, v7: v_b3, v8: v_a3)
                        }
                        else if (a1 == 1 && a4 == 1 && b1 == 1 && b2 == 1) {
                            getMC4_6(vertices: &vertices, indices: &indices, v1: v_b2, v2: v_a2, v3: v_a1, v4: v_b1, v5: v_b3, v6: v_a3, v7: v_a4, v8: v_b4)
                        }
                        else if (a3 == 1 && a4 == 1 && b1 == 1 && b4 == 1) {
                            getMC4_6(vertices: &vertices, indices: &indices, v1: v_b1, v2: v_a1, v3: v_a4, v4: v_b4, v5: v_b2, v6: v_a2, v7: v_a3, v8: v_b3)
                        }
                        else if (a4 == 1 && b2 == 1 && b3 == 1 && b4 == 1) {
                            getMC4_6(vertices: &vertices, indices: &indices, v1: v_b2, v2: v_b1, v3: v_b4, v4: v_b3, v5: v_a2, v6: v_a1, v7: v_a4, v8: v_a3)
                        }
                        else if (a3 == 1 && b1 == 1 && b2 == 1 && b3 == 1) {
                            getMC4_6(vertices: &vertices, indices: &indices, v1: v_b1, v2: v_b4, v3: v_b3, v4: v_b2, v5: v_a1, v6: v_a4, v7: v_a3, v8: v_a2)
                        }
                        else if (a2 == 1 && b1 == 1 && b2 == 1 && b4 == 1) {
                            getMC4_6(vertices: &vertices, indices: &indices, v1: v_b4, v2: v_b3, v3: v_b2, v4: v_b1, v5: v_a4, v6: v_a3, v7: v_a2, v8: v_a1)
                        }
                        else if (a1 == 1 && b1 == 1 && b3 == 1 && b4 == 1) {
                            getMC4_6(vertices: &vertices, indices: &indices, v1: v_b3, v2: v_b2, v3: v_b1, v4: v_b4, v5: v_a3, v6: v_a2, v7: v_a1, v8: v_a4)
                        }
                        else if (a2 == 1 && a3 == 1 && a4 == 1 && b4 == 1) {
                            getMC4_7(vertices: &vertices, indices: &indices, v1: v_a1, v2: v_a2, v3: v_a3, v4: v_a4, v5: v_b1, v6: v_b2, v7: v_b3, v8: v_b4)
                        }
                        else if (a1 == 1 && a2 == 1 && a3 == 1 && b3 == 1) {
                            getMC4_7(vertices: &vertices, indices: &indices, v1: v_a4, v2: v_a1, v3: v_a2, v4: v_a3, v5: v_b4, v6: v_b1, v7: v_b2, v8: v_b3)
                        }
                        else if (a1 == 1 && a2 == 1 && a4 == 1 && b2 == 1) {
                            getMC4_7(vertices: &vertices, indices: &indices, v1: v_a3, v2: v_a4, v3: v_a1, v4: v_a2, v5: v_b3, v6: v_b4, v7: v_b1, v8: v_b2)
                        }
                        else if (a1 == 1 && a3 == 1 && a4 == 1 && b1 == 1) {
                            getMC4_7(vertices: &vertices, indices: &indices, v1: v_a2, v2: v_a3, v3: v_a4, v4: v_a1, v5: v_b2, v6: v_b3, v7: v_b4, v8: v_b1)
                        }
                        else if (a3 == 1 && a4 == 1 && b2 == 1 && b3 == 1) {
                            getMC4_7(vertices: &vertices, indices: &indices, v1: v_b4, v2: v_a4, v3: v_a3, v4: v_b3, v5: v_b1, v6: v_a1, v7: v_a2, v8: v_b2)
                        }
                        else if (a2 == 1 && a3 == 1 && b1 == 1 && b2 == 1) {
                            getMC4_7(vertices: &vertices, indices: &indices, v1: v_b3, v2: v_a3, v3: v_a2, v4: v_b2, v5: v_b4, v6: v_a4, v7: v_a1, v8: v_b1)
                        }
                        else if (a1 == 1 && a2 == 1 && b1 == 1 && b4 == 1) {
                            getMC4_7(vertices: &vertices, indices: &indices, v1: v_b2, v2: v_a2, v3: v_a1, v4: v_b1, v5: v_b3, v6: v_a3, v7: v_a4, v8: v_b4)
                        }
                        else if (a1 == 1 && a4 == 1 && b3 == 1 && b4 == 1) {
                            getMC4_7(vertices: &vertices, indices: &indices, v1: v_a3, v2: v_b3, v3: v_b4, v4: v_a4, v5: v_a2, v6: v_b2, v7: v_b1, v8: v_a1)
                        }
                        else if (a3 == 1 && b1 == 1 && b3 == 1 && b4 == 1) {
                            getMC4_7(vertices: &vertices, indices: &indices, v1: v_b2, v2: v_b1, v3: v_b4, v4: v_b3, v5: v_a2, v6: v_a1, v7: v_a4, v8: v_a3)
                        }
                        else if (a2 == 1 && b2 == 1 && b3 == 1 && b4 == 1) {
                            getMC4_7(vertices: &vertices, indices: &indices, v1: v_b1, v2: v_b4, v3: v_b3, v4: v_b2, v5: v_a1, v6: v_a4, v7: v_a3, v8: v_a2)
                        }
                        else if (a1 == 1 && b1 == 1 && b2 == 1 && b3 == 1) {
                            getMC4_7(vertices: &vertices, indices: &indices, v1: v_b4, v2: v_b3, v3: v_b2, v4: v_b1, v5: v_a4, v6: v_a3, v7: v_a2, v8: v_a1)
                        }
                        else if (a4 == 1 && b1 == 1 && b2 == 1 && b4 == 1) {
                            getMC4_7(vertices: &vertices, indices: &indices, v1: v_b3, v2: v_b2, v3: v_b1, v4: v_b4, v5: v_a3, v6: v_a2, v7: v_a1, v8: v_a4)
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
                        else if (b3 == 1 && b4 == 1) {
                            getMC2_2N(vertices: &vertices, indices: &indices, v1: v_b4, v2: v_b3,
                                      v3: v_a4, v4: v_a3, v5: v_a1, v6: v_a2, v7: v_b1, v8: v_b2)
                        }
                        else if (b3 == 1 && b2 == 1) {
                            getMC2_2N(vertices: &vertices, indices: &indices, v1: v_b3, v2: v_b2,
                                      v3: v_a3, v4: v_a2, v5: v_a4, v6: v_a1, v7: v_b4, v8: v_b1)
                        }
                        else if (b2 == 1 && b1 == 1) {
                            getMC2_2N(vertices: &vertices, indices: &indices, v1: v_b2, v2: v_b1,
                                      v3: v_a2, v4: v_a1, v5: v_a3, v6: v_a4, v7: v_b3, v8: v_b4)
                        }
                        else if (b4 == 1 && b1 == 1) {
                            getMC2_2N(vertices: &vertices, indices: &indices, v1: v_b1, v2: v_b4,
                                      v3: v_a1, v4: v_a4, v5: v_a2, v6: v_a3, v7: v_b2, v8: v_b3)
                        }
                        else if (a2 == 1 && a1 == 1) {
                            getMC2_2N(vertices: &vertices, indices: &indices, v1: v_a2, v2: v_a1,
                                      v3: v_a3, v4: v_a4, v5: v_b3, v6: v_b4, v7: v_b2, v8: v_b1)
                        }
                        else if (a2 == 1 && a3 == 1) {
                            getMC2_2N(vertices: &vertices, indices: &indices, v1: v_a3, v2: v_a2,
                                      v3: v_a4, v4: v_a1, v5: v_b4, v6: v_b1, v7: v_b3, v8: v_b2)
                        }
                        else if (a4 == 1 && a3 == 1) {
                            getMC2_2N(vertices: &vertices, indices: &indices, v1: v_a4, v2: v_a3,
                                      v3: v_a1, v4: v_a2, v5: v_b1, v6: v_b2, v7: v_b4, v8: v_b3)
                        }
                        else if (a4 == 1 && a1 == 1) {
                            getMC2_2N(vertices: &vertices, indices: &indices, v1: v_a1, v2: v_a4,
                                      v3: v_a2, v4: v_a3, v5: v_b2, v6: v_b3, v7: v_b1, v8: v_b4)
                        }
                        else if (b1 == 1 && a1 == 1) {
                            getMC2_2N(vertices: &vertices, indices: &indices, v1: v_a1, v2: v_b1,
                                      v3: v_a4, v4: v_b4, v5: v_a3, v6: v_b3, v7: v_a2, v8: v_b2)
                        }
                        else if (b2 == 1 && a2 == 1) {
                            getMC2_2N(vertices: &vertices, indices: &indices, v1: v_a2, v2: v_b2,
                                      v3: v_a1, v4: v_b1, v5: v_a4, v6: v_b4, v7: v_a3, v8: v_b3)
                        }
                        else if (b3 == 1 && a3 == 1) {
                            getMC2_2N(vertices: &vertices, indices: &indices, v1: v_a3, v2: v_b3,
                                      v3: v_a2, v4: v_b2, v5: v_a1, v6: v_b1, v7: v_a4, v8: v_b4)
                        }
                        else if (b4 == 1 && a4 == 1) {
                            getMC2_2N(vertices: &vertices, indices: &indices, v1: v_a4, v2: v_b4,
                                      v3: v_a3, v4: v_b3, v5: v_a2, v6: v_b2, v7: v_a1, v8: v_b1)
                        }
                        else if (a1 == 1 && b3 == 1) {
                            getMC2_3N(vertices: &vertices, indices: &indices, v1: v_a1, v2: v_b3,
                                      v3: v_a2, v4: v_b2, v5: v_b1, v6: v_b4, v7: v_a4, v8: v_a3)
                        }
                        else if (a2 == 1 && b4 == 1) {
                            getMC2_3N(vertices: &vertices, indices: &indices, v1: v_a2, v2: v_b4,
                                      v3: v_a3, v4: v_b3, v5: v_b2, v6: v_b1, v7: v_a1, v8: v_a4)
                        }
                        else if (a3 == 1 && b1 == 1) {
                            getMC2_3N(vertices: &vertices, indices: &indices, v1: v_a3, v2: v_b1,
                                      v3: v_a2, v4: v_b2, v5: v_b1, v6: v_b4, v7: v_a4, v8: v_a3)
                        }
                        else if (a4 == 1 && b2 == 1) {
                            getMC2_3N(vertices: &vertices, indices: &indices, v1: v_a4, v2: v_b2,
                                      v3: v_a1, v4: v_b1, v5: v_b4, v6: v_b3, v7: v_a3, v8: v_a2)
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
                        
                        let element4Lines = SCNGeometryElement(indices: indices4Lines, primitiveType: .line)
                        let geometry4Lines = SCNGeometry(sources: [vertexSource], elements: [element4Lines])
                        let material4Lines = SCNMaterial()
                            material4Lines.diffuse.contents = UIColor.black
                        geometry4Lines.materials = [material4Lines]
                        let node4Lines = SCNNode(geometry: geometry4Lines)
                        parentNode.addChildNode(node4Lines)
                    }
                    indices.removeAll()
                    vertices.removeAll()
                    indices4Lines.removeAll()
                } // for k...
            } // for j...
        } // for i
        
        return parentNode // Return the parent node containing all child nodes
    }
    
    
    func getMC0_1(vertices: inout [SCNVector3], indices: inout [Int32],
                  v1: SCNVector3, v2: SCNVector3, v3: SCNVector3, v4: SCNVector3,
                  v5: SCNVector3, v6: SCNVector3, v7: SCNVector3, v8: SCNVector3) {
        vertices += [v1, v1, v2, v3, v4, v5, v6, v7, v8]
        indices += [
            1, 2, 3,
            1, 3, 4,
            1, 4, 8,
            1, 5, 8,
            3, 4, 8,
            3, 7, 8,
            2, 3, 7,
            2, 6, 7,
            2, 1, 5,
            2, 5, 6,
            5, 6, 7,
            5, 8, 7,
        ]
        indices4Lines += [
            1, 2,
            2, 3,
            3, 4,
            4, 1,
            5, 6,
            6, 7,
            7, 8,
            8, 5,
            1, 5,
            2, 6,
            3, 7,
            4, 8,
        ]
    }

    func getMC1_1N(vertices: inout [SCNVector3], indices: inout [Int32],
                   v1: SCNVector3, v2: SCNVector3, v3: SCNVector3, v4: SCNVector3) {
        vertices += [v1, v2, v3, v4]
        indices += [
            0, 1, 2,
            0, 1, 3,
            0, 2, 3,
            1, 2, 3
        ]
        indices4Lines += [
            0, 1,
            0, 2,
            0, 3,
            1, 2,
            1, 3,
            2, 3,
        ]
    }

    func getMC1_1(vertices: inout [SCNVector3], indices: inout [Int32],
                   v1: SCNVector3, v2: SCNVector3, v3: SCNVector3,
                  v4: SCNVector3, v5: SCNVector3, v6: SCNVector3,
                  v7: SCNVector3, v8: SCNVector3, v9: SCNVector3, v10: SCNVector3) {
        vertices += [v1, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10]
        indices += [
            1, 2, 3,
            4, 5, 7,
            1, 4, 5,
            1, 5, 2,
            5, 6, 8,
            2, 5, 6,
            2, 3, 6,
            4, 6, 9,
            1, 4, 6,
            1, 3, 6,
            5, 7, 10,
            5, 8, 10,
            4, 7, 10,
            4, 9, 10,
            6, 8, 10,
            6, 9, 10
        ]
        indices4Lines += [
            1, 2,
            1, 3,
            2, 3,
            1, 4,
            2, 5,
            3, 6,
            4, 9,
            6, 9,
            4, 7,
            5, 7,
            5, 8,
            6, 8,
            8, 10,
            7, 10,
            9, 10,
        ]
    }

    func getMC2_1(vertices: inout [SCNVector3], indices: inout [Int32],
                   v1: SCNVector3, v2: SCNVector3, v3: SCNVector3,
                  v4: SCNVector3, v5: SCNVector3, v6: SCNVector3,
                  v7: SCNVector3, v8: SCNVector3) {
        vertices += [v1, v1, v2, v3, v4, v5, v6, v7, v8,
        (v1 + v3) / 2, (v1 + v4) / 2, (v1 + v5) / 2,
        (v2 + v3) / 2, (v2 + v4) / 2, (v2 + v6) / 2]
        
        indices += [
            9, 10, 11,
            12, 13, 14,
            3, 9, 12,
            4, 10, 13,
            9, 10, 12,
            10, 12, 13,
            3, 5, 7,
            3, 5, 9,
            5, 9, 11,
            4, 5, 8,
            4, 5, 11,
            4, 10, 11,
            4, 6, 8,
            4, 6, 13,
            6, 13, 14,
            3, 6, 7,
            3, 6, 12,
            6, 12, 14,
            5, 6, 7,
            5, 6, 8
        ]
        indices4Lines += [
            9, 10,
            10, 11,
            9, 11,
            12, 13,
            13, 14,
            14, 12,
            4, 10,
            4, 13,
            3, 9,
            3, 12,
            4, 8,
            5, 8,
            5, 11,
            5, 7,
            7, 3,
            6, 7,
            6, 8,
            6, 14,
            
        ]
    }

    func getMC2_1N(vertices: inout [SCNVector3], indices: inout [Int32],
                   v1: SCNVector3, v2: SCNVector3, v3: SCNVector3,
                  v4: SCNVector3, v5: SCNVector3, v6: SCNVector3,
                  v7: SCNVector3, v8: SCNVector3) {
        vertices += [v1, v1, v2, v3, v4, v5, v6, v7, v8,
        (v1 + v3) / 2, (v1 + v4) / 2, (v1 + v5) / 2,
        (v2 + v3) / 2, (v2 + v4) / 2, (v2 + v6) / 2]
        
        indices += [
            1, 9, 11,
            1, 10, 11,
            1, 9, 10,
            2, 12, 13,
            9, 10, 13,
            9, 12, 13,
            2, 12, 14,
            2, 13, 14,
            10, 13, 14,
            10, 11, 14,
            9, 12, 14,
            9, 11, 14
       ]
        indices4Lines += [
            1, 11,
            1, 9,
            1, 10,
            9, 11,
            10, 11,
            9, 12,
            10, 13,
            2, 12,
            2, 13,
            2, 14,
            12, 14,
            13, 14,
            11, 14,
        ]
    }

    func getMC2_2(vertices: inout [SCNVector3], indices: inout [Int32],
                   v1: SCNVector3, v2: SCNVector3, v3: SCNVector3,
                  v4: SCNVector3, v5: SCNVector3, v6: SCNVector3,
                  v7: SCNVector3, v8: SCNVector3) {
        vertices += [v1, v1, v2, v3, v4, v5, v6, v7, v8,
        (v1 + v7) / 2, (v1 + v3) / 2, (v2 + v8) / 2, (v2 + v4) / 2]
        
        indices += [
            9, 10, 11,
            10, 11, 12,
            3, 4, 12,
            3, 10, 12,
            7, 8, 11,
            7, 9, 11,
            3, 5, 7,
            3, 7, 9,
            3, 10, 9,
            4, 6, 8,
            4, 8, 11,
            4, 12, 11,
            5, 6, 8,
            5, 7, 8,
            3, 5, 6,
            3, 4, 6
        ]
        indices4Lines += [
            9, 10,
            9, 11,
            10, 12,
            11, 12,
            10, 3,
            3, 5,
            5, 7,
            7, 9,
            12, 4,
            4, 6,
            6, 8,
            8, 11,
            3, 4,
            5, 6,
            7, 8,
        ]
    }

    func getMC2_2N(vertices: inout [SCNVector3], indices: inout [Int32],
                   v1: SCNVector3, v2: SCNVector3, v3: SCNVector3,
                  v4: SCNVector3, v5: SCNVector3, v6: SCNVector3,
                  v7: SCNVector3, v8: SCNVector3) {
        vertices += [v1, v1, v2, v3, v4, v5, v6, v7, v8,
        (v1 + v7) / 2, (v1 + v3) / 2, (v2 + v8) / 2, (v2 + v4) / 2]
        
        indices += [
            9, 10, 11,
            10, 11, 12,
            1, 9, 10,
            2, 11, 12,
            1, 2, 10,
            2, 10, 12,
            1, 2, 9,
            2, 9, 11
        ]
        indices4Lines += [
            1, 2,
            1, 9,
            1, 10,
            9, 10,
            10, 12,
            9, 11,
            2, 11,
            2, 12,
            11, 12,
        ]
    }

    func getMC2_3(vertices: inout [SCNVector3], indices: inout [Int32],
                   v1: SCNVector3, v2: SCNVector3, v3: SCNVector3,
                  v4: SCNVector3, v5: SCNVector3, v6: SCNVector3,
                  v7: SCNVector3, v8: SCNVector3) {
        vertices += [v1, v1, v2, v3, v4, v5, v6, v7, v8,
        (v1 + v3) / 2, (v1 + v5) / 2, (v1 + v7) / 2,
        (v2 + v4) / 2, (v2 + v6) / 2, (v2 + v8) / 2]
        
        indices += [
            9, 10, 11,
            12, 13, 14,
            3, 4, 5,
            3, 9, 10,
            3, 5, 10,
            3, 4, 8,
            4, 8, 14,
            4, 12, 14,
            3, 7, 8,
            3, 7, 11,
            3, 9, 11,
            5, 6, 7,
            5, 7, 11,
            5, 10, 11,
            6, 7, 8,
            6, 8, 14,
            6, 13, 14,
            4, 5, 6,
            4, 6, 13,
            4, 12, 13
        ]
        indices4Lines += [
            12, 13,
            13, 14,
            12, 14,
            8, 14,
            4, 12,
            6, 13,
            3, 4,
            3, 8,
            6, 7,
            7, 8,
            4, 5,
            5, 6,
            5, 10,
            3, 9,
            7, 11,
            9, 10,
            10, 11,
            9, 11,
        ]
    }

    func getMC2_3N(vertices: inout [SCNVector3], indices: inout [Int32],
                   v1: SCNVector3, v2: SCNVector3, v3: SCNVector3,
                  v4: SCNVector3, v5: SCNVector3, v6: SCNVector3,
                  v7: SCNVector3, v8: SCNVector3) {
        vertices += [v1, v1, v2, v3, v4, v5, v6, v7, v8,
        (v1 + v3) / 2, (v1 + v5) / 2, (v1 + v7) / 2,
        (v2 + v4) / 2, (v2 + v6) / 2, (v2 + v8) / 2]
        
        indices += [
            9, 10, 11,
            1, 9, 10,
            1, 9, 11,
            1, 10, 11,
            12, 13, 14,
            2, 12, 14,
            2, 12, 13,
            2, 13, 14
        ]
        indices4Lines += [
            1, 9,
            1, 10,
            1, 11,
            9, 10,
            9, 11,
            10, 11,
            2, 13,
            2, 14,
            2, 12,
            12, 13,
            13, 14,
            12, 14,
        ]
    }

    func getMC3_1(vertices: inout [SCNVector3], indices: inout [Int32],
                   v1: SCNVector3, v2: SCNVector3, v3: SCNVector3,
                  v4: SCNVector3, v5: SCNVector3, v6: SCNVector3,
                  v7: SCNVector3, v8: SCNVector3) {
        vertices += [v1, v1, v2, v3, v4, v5, v6, v7, v8,
        (v1 + v5) / 2, (v1 + v7) / 2, (v2 + v8) / 2,
        (v2 + v6) / 2, (v3 + v6) / 2, (v3 + v8) / 2,
        (v3 + v4) / 2]
        
        indices += [
            9, 10, 11,
            9, 11, 12,
            13, 14, 15,
            5, 9, 12,
            5, 6, 12,
            7, 10, 11,
            7, 8, 11,
            6, 12, 13,
            8, 11, 14,
            11, 12, 13,
            11, 14, 13,
            4, 5, 6,
            4, 6, 13,
            4, 15, 13,
            4, 7, 8,
            4, 8, 14,
            4, 15, 14,
            4, 5, 7,
            5, 9, 10,
            5, 7, 10
        ]
        indices4Lines += [
            9, 10,
            10, 11,
            11, 12,
            9, 12,
            13, 14,
            14, 15,
            13, 15,
            6, 12,
            6, 13,
            8, 11,
            8, 14,
            5, 9,
            7, 10,
            5, 6,
            7, 8,
            4, 15,
            4, 5,
            4, 7
        ]
    }

    func getMC3_1N(vertices: inout [SCNVector3], indices: inout [Int32],
                   v1: SCNVector3, v2: SCNVector3, v3: SCNVector3,
                  v4: SCNVector3, v5: SCNVector3, v6: SCNVector3,
                  v7: SCNVector3, v8: SCNVector3) {
        vertices += [v1, v1, v2, v3, v4, v5, v6, v7, v8,
        (v1 + v5) / 2, (v1 + v7) / 2, (v2 + v8) / 2,
        (v2 + v6) / 2, (v3 + v6) / 2, (v3 + v8) / 2,
        (v3 + v4) / 2, (v1 + v3) / 2]
        
        indices += [
            1, 9, 10,
            1, 2, 10,
            2, 10, 11,
            1, 2, 12,
            1, 9, 12,
            2, 11, 12,
            3, 13, 14,
            11, 12, 13,
            11, 13, 14,
            3, 13, 15,
            3, 14, 15,
            9, 10, 16,
            10, 11, 16,
            9, 12, 16,
            12, 13, 15,
            12, 16, 15,
            11, 14, 15,
            11, 16, 15
        ]
        indices4Lines += [
            1, 10,
            1, 9,
            9, 10,
            1, 2,
            10, 11,
            9, 12,
            2, 12,
            2, 11,
            12, 13,
            11, 14,
            3, 13,
            3, 14,
            15, 13,
            14, 15,
            15, 16,
            9, 16,
            10, 16,
            12, 16,
            11, 16
        ]
    }

    func getMC3_3(vertices: inout [SCNVector3], indices: inout [Int32],
                   v1: SCNVector3, v2: SCNVector3, v3: SCNVector3,
                  v4: SCNVector3, v5: SCNVector3, v6: SCNVector3,
                  v7: SCNVector3, v8: SCNVector3) {
        vertices += [v1, v1, v2, v3, v4, v5, v6, v7, v8,
        (v2 + v5) / 2, (v1 + v2) / 2, (v2 + v7) / 2,
        (v7 + v4) / 2, (v4 + v1) / 2, (v4 + v6) / 2,
        (v3 + v6) / 2, (v3 + v1) / 2, (v3 + v5) / 2]
        
        indices += [
            9, 10, 11,
            12, 13, 14,
            15, 16, 17,
            1, 10, 16,
            5, 9, 17,
            9, 10, 16,
            9, 17, 16,
            1, 10, 13,
            7, 11, 12,
            10, 11, 12,
            10, 13, 12,
            1, 13, 16,
            6, 14, 15,
            13, 14, 15,
            13, 16, 15,
            5, 9, 8,
            9, 11, 8,
            11, 7, 8,
            7, 8, 12,
            8, 12, 14,
            6, 8, 14,
            6, 8, 15,
            8, 15, 17,
            5, 8, 17
        ]
        indices4Lines += [
            9, 10,
            10, 11,
            9, 11,
            15, 16,
            16, 17,
            15, 17,
            12, 13,
            13, 14,
            12, 14,
            1, 10,
            1, 13,
            1, 16,
            7, 11,
            7, 12,
            6, 14,
            6, 15,
            5, 9,
            5, 17,
            8, 5,
            8, 6,
            8, 7
        ]
    }

    func getMC3_4(vertices: inout [SCNVector3], indices: inout [Int32],
                   v1: SCNVector3, v2: SCNVector3, v3: SCNVector3,
                  v4: SCNVector3, v5: SCNVector3, v6: SCNVector3,
                  v7: SCNVector3, v8: SCNVector3) {
        vertices += [v1, v1, v2, v3, v4, v5, v6, v7, v8,
        (v1 + v2) / 2, (v1 + v4) / 2, (v2 + v6) / 2,
        (v3 + v7) / 2, (v4 + v8) / 2]
        
        indices += [
            9, 10, 11,
            10, 11, 13,
            11, 12, 13,
            6, 7, 12,
            6, 11, 12,
            7, 8, 13,
            7, 12, 13,
            5, 6, 7,
            5, 8, 7,
            1, 5, 9,
            5, 9, 11,
            5, 6, 11,
            1, 5, 10,
            5, 10, 13,
            5, 8, 13,
            1, 9, 10
        ]
        indices4Lines += [
            1, 9,
            9, 10,
            1, 10,
            9, 11,
            11, 13,
            10, 13,
            11, 12,
            12, 13,
            11, 6,
            7, 12,
            8, 13,
            6, 7,
            7, 8,
            5, 6,
            5, 8,
            1, 5
        ]
    }

    func getMC3_4N(vertices: inout [SCNVector3], indices: inout [Int32],
                   v1: SCNVector3, v2: SCNVector3, v3: SCNVector3,
                  v4: SCNVector3, v5: SCNVector3, v6: SCNVector3,
                  v7: SCNVector3, v8: SCNVector3) {
        vertices += [v1, v1, v2, v3, v4, v5, v6, v7, v8,
        (v1 + v2) / 2, (v1 + v4) / 2, (v2 + v6) / 2,
        (v3 + v7) / 2, (v4 + v8) / 2]
        
        indices += [
            9, 10, 11,
            10, 11, 13,
            11, 12, 13,
            2, 9, 11,
            4, 10, 13,
            3, 4, 13,
            3, 12, 13,
            2, 3, 12,
            2, 11, 12,
            2, 3, 9,
            3, 9, 10,
            3, 4, 10
        ]
        indices4Lines += [
            9, 10,
            2, 3,
            3, 4,
            4, 10,
            4, 13,
            2, 11,
            2, 9,
            9, 11,
            4, 13,
            10, 13,
            3, 12,
            11, 12,
            12, 13,
            11, 13,
        ]
    }
    func getMC4_1(vertices: inout [SCNVector3], indices: inout [Int32],
                   v1: SCNVector3, v2: SCNVector3, v3: SCNVector3,
                  v4: SCNVector3, v5: SCNVector3, v6: SCNVector3,
                   v7: SCNVector3, v8: SCNVector3) {
        vertices += [v1, v1, v2, v3, v4, v5, v6, v7, v8,
                     (v1 + v4) / 2, (v1 + v2) / 2, (v2 + v3) / 2,
                     (v3 + v4) / 2, (v3 + v7) / 2, (v4 + v8) / 2,
                     (v7 + v8) / 2, (v1 + v5) / 2, (v5 + v8) / 2,
                     (v2 + v6) / 2, (v6 + v7) / 2, (v5 + v6) / 2]
        
        indices += [
            9, 10, 16,
            11, 12, 13,
            14, 15, 17,
            18, 19, 20,
            4, 9, 14,
            9, 14, 17,
            9, 16, 17,
            5, 16, 17,
            4, 12, 13,
            4, 7, 13,
            4, 7, 14,
            7, 14, 15,
            2, 10, 11,
            10, 11, 12,
            9, 10, 12,
            4, 9, 12,
            2, 11, 18,
            11, 13, 18,
            13, 18, 19,
            7, 13, 19,
            2, 10, 18,
            10, 16, 18,
            16, 18, 20,
            5, 16, 20,
            5, 17, 20,
            17, 19, 20,
            15, 17, 19,
            7, 15, 19
        ]
        
        indices4Lines += [
                9, 10,
                9, 16,
                10, 16,
                11, 12,
                12, 13,
                11, 13,
                14, 17,
                14, 15,
                15, 17,
                18, 19,
                19, 20,
                18, 20,
                2, 10,
                2, 11,
                4, 9,
                4, 12,
                4, 14,
                2, 18,
                7, 13,
                7, 15,
                7, 19,
                5, 16,
                5, 17,
                5, 20,
            ]
        
    }
    
    func getMC4_2(vertices: inout [SCNVector3], indices: inout [Int32],
                   v1: SCNVector3, v2: SCNVector3, v3: SCNVector3,
                  v4: SCNVector3, v5: SCNVector3, v6: SCNVector3,
                   v7: SCNVector3, v8: SCNVector3) {
        vertices += [v1, v1, v2, v3, v4, v5, v6, v7, v8,
                     (v3 + v4) / 2, (v3 + v2) / 2, (v7 + v3) / 2,
                     (v7 + v8) / 2, (v6 + v7) / 2, (v4 + v8) / 2,
                     (v1 + v5) / 2, (v2 + v6) / 2]
        
        indices += [
            1, 4, 15,
            4, 14, 15,
            1, 2, 16,
            1, 15, 16,
            14, 15, 16,
            9, 10, 11,
            7, 12, 13,
            4, 9, 14,
            9, 11, 14,
            11, 12, 14,
            7, 11, 12,
            2, 10, 16,
            10, 13, 16,
            10, 11, 13,
            7, 11, 13,
            1, 2, 10,
            1, 9, 10,
            1, 4, 9,
            12, 14, 16,
            12, 13, 16
        ]
        
        indices4Lines += [
                9, 10,
                10, 11,
                9, 11,
                1, 4,
                4, 9,
                4, 14,
                1, 2,
                1, 15,
                2, 16,
                2, 10,
                14, 15,
                15, 16,
                14, 16,
                7, 11,
                7, 12,
                7, 13,
                12, 14,
                13, 16,
                12, 13,
            ]
    }
    
    func getMC4_3(vertices: inout [SCNVector3], indices: inout [Int32],
                   v1: SCNVector3, v2: SCNVector3, v3: SCNVector3,
                  v4: SCNVector3, v5: SCNVector3, v6: SCNVector3,
                   v7: SCNVector3, v8: SCNVector3) {
        vertices += [v1, v1, v2, v3, v4, v5, v6, v7, v8,
                     (v3 + v2) / 2, (v1 + v4) / 2, (v2 + v6) / 2,
                     (v1 + v5) / 2, (v3 + v7) / 2, (v4 + v8) / 2,
                     (v8 + v5) / 2, (v7 + v6) / 2]
        
        indices += [
            3, 4, 9,
            4, 9, 10,
            3, 9, 13,
            6, 11, 16,
            9, 11, 16,
            9, 13, 16,
            6, 11, 12,
            5, 6, 12,
            5, 6, 15,
            6, 15, 16,
            3, 4, 13,
            4, 13, 14,
            9, 10, 11,
            10, 11, 12,
            13, 14, 16,
            14, 15, 16,
            4, 10, 14,
            5, 12, 15,
            10, 12, 15,
            10, 14, 15
        ]
        
        indices4Lines += [
                3, 4,
                3, 9,
                9, 10,
                4, 10,
                9, 11,
                11, 12,
                10, 12,
                3, 13,
                4, 14,
                13, 14,
                5, 12,
                5, 15,
                14, 15,
                6, 16,
                16, 13,
                6, 11,
                5, 6,
                15, 16
            ]
    }
    
    func getMC4_4(vertices: inout [SCNVector3], indices: inout [Int32],
                  v1: SCNVector3, v2: SCNVector3, v3: SCNVector3,
                 v4: SCNVector3, v5: SCNVector3, v6: SCNVector3,
                  v7: SCNVector3, v8: SCNVector3) {
        vertices += [v1, v1, v2, v3, v4, v5, v6, v7, v8,
                     (v1 + v5) / 2, (v4 + v8) / 2, (v3 + v7) / 2, (v2 + v6) / 2]
        
        indices += [
            1, 9, 4,
            9, 4, 10,
            4, 10, 3,
            3, 10, 11,
            1, 9, 2,
            2, 12, 9,
            2, 3, 12,
            3, 12, 11,
            1, 2, 3,
            1, 3, 4,
            9, 12, 11,
            11, 9, 10
        ]
        
        indices4Lines += [
            1, 2,
            2, 3,
            3, 4,
            4, 1,
            1, 9,
            4, 10,
            3, 11,
            2, 12,
            9, 10,
            10, 11,
            11, 12,
            12, 9,
        ]
    }
    
    func getMC4_5(vertices: inout [SCNVector3], indices: inout [Int32],
                   v1: SCNVector3, v2: SCNVector3, v3: SCNVector3,
                  v4: SCNVector3, v5: SCNVector3, v6: SCNVector3,
                   v7: SCNVector3, v8: SCNVector3) {
        vertices += [v1, v1, v2, v3, v4, v5, v6, v7, v8,
                     (v1 + v2) / 2, (v2 + v3) / 2, (v3 + v7) / 2,
                     (v7 + v8) / 2, (v5 + v8) / 2, (v1 + v5) / 2]
        
        indices += [
            9, 13, 14,
            9, 12, 13,
            9, 10, 12,
            10, 11, 12,
            3, 10, 11,
            1, 9, 14,
            3, 4, 11,
            4, 11, 12,
            4, 8, 12,
            1, 4, 14,
            4, 13, 14,
            4, 8, 13,
            1, 4, 9,
            4, 9, 10,
            3, 4, 10,
            8, 12, 13
        ]
        
        indices4Lines += [
                4, 1,
                4, 3,
                4, 8,
                9, 10,
                3, 10,
                3, 11,
                11, 12,
                12, 8,
                8, 13,
                13, 14,
                1, 14,
                1, 9,
                10, 11,
                9, 14,
                12, 13,
            ]
    }
    
    func getMC4_6(vertices: inout [SCNVector3], indices: inout [Int32],
                   v1: SCNVector3, v2: SCNVector3, v3: SCNVector3,
                  v4: SCNVector3, v5: SCNVector3, v6: SCNVector3,
                   v7: SCNVector3, v8: SCNVector3) {
        vertices += [v1, v1, v2, v3, v4, v5, v6, v7, v8,
                     (v1 + v2) / 2, (v2 + v3) / 2, (v1 + v5) / 2,
                     (v4 + v8) / 2, (v8 + v7) / 2, (v6 + v7) / 2,
                     (v1 + v7) / 2]
        
        indices += [
            11, 12, 15,
            12, 13, 15,
            13, 14, 15,
            10, 14, 15,
            9, 10, 11,
            10, 11, 15,
            1, 9, 11,
            7, 13, 14,
            3, 7, 14,
            3, 10, 14,
            1, 4, 11,
            4, 11, 12,
            3, 4, 7,
            4, 7, 12,
            7, 12, 13,
            3, 4, 10,
            4, 9, 10,
            1, 4, 9
        ]
        
        indices4Lines += [
                1, 9,
                9, 10,
                3, 10,
                3, 7,
                7, 13,
                12, 13,
                11, 12,
                1, 11,
                4, 1,
                4, 3,
                4, 12,
                9, 11,
                7, 14,
                10, 14,
                13, 14,
                15, 10,
                15, 11,
                15, 12,
                15, 14,
            ]
    }
    
    func getMC4_7(vertices: inout [SCNVector3], indices: inout [Int32],
                   v1: SCNVector3, v2: SCNVector3, v3: SCNVector3,
                  v4: SCNVector3, v5: SCNVector3, v6: SCNVector3,
                   v7: SCNVector3, v8: SCNVector3) {
        vertices += [v1, v1, v2, v3, v4, v5, v6, v7, v8,
                     (v1 + v2) / 2, (v1 + v4) / 2, (v2 + v6) / 2,
                     (v3 + v7) / 2, (v7 + v8) / 2, (v5 + v8) / 2,
                     (v1 + v7) / 2]
        
        indices += [
            4, 10, 14,
            4, 8, 14,
            2, 3, 12,
            2, 11, 12,
            12, 13, 14,
            12, 14, 15,
            10, 14, 15,
            11, 12, 15,
            9, 10, 15,
            9, 11, 15,
            2, 9, 11,
            8, 13, 14,
            3, 4, 12,
            4, 12, 13,
            4, 8, 13,
            2, 3, 9,
            3, 9, 10,
            3, 4, 10
        ]
        
        indices4Lines += [
            3, 2,
            3, 4,
            3, 12,
            2, 9,
            9, 10,
            4, 10,
            4, 8,
            8, 13,
            8, 14,
            12, 13,
            11, 12,
            2, 11,
            9, 11,
            15, 11,
            15, 12,
            15, 10,
            15, 14,
            13, 14,
            10, 14,
        ]
    }
    
    func getMC5_5(vertices: inout [SCNVector3], indices: inout [Int32],
                   v1: SCNVector3, v2: SCNVector3, v3: SCNVector3,
                  v4: SCNVector3, v5: SCNVector3, v6: SCNVector3,
                   v7: SCNVector3, v8: SCNVector3) {
        vertices += [v1, v1, v2, v3, v4, v5, v6, v7, v8,
                     (v1 + v2) / 2, (v2 + v3) / 2, (v3 + v7) / 2,
                     (v7 + v8) / 2, (v5 + v8) / 2, (v1 + v5) / 2,
                    (v4 + v3) / 2, (v4 + v1) / 2, (v4 + v8) / 2]
        
        indices4Lines += [
                15, 16,
                16, 17,
                15, 17,
                1, 16,
                8, 17,
                3, 15,
                9, 10,
                3, 10,
                3, 11,
                11, 12,
                12, 8,
                8, 13,
                13, 14,
                1, 14,
                1, 9,
                10, 11,
                9, 14,
                12, 13,
            ]
    }
}
