//
//  MCAlgorithm.swift
//  marchingCubes
//
//  Created by Mingxin Hou on 10/31/24.
//

import SceneKit

func marchingCubes(data: [[[Int]]]) -> SCNNode {
    var vertices: [SCNVector3] = []
    var indices: [Int32] = []

    let xDim = data.count - 1
    let yDim = data[0].count - 1
    let zDim = data[0][0].count - 1
//    print(xDim, yDim, zDim)

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
