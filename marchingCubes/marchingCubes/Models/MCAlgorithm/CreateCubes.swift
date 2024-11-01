//
//  CreateCubes.swift
//  marchingCubes
//
//  Created by Mingxin Hou on 10/31/24.
//

import SceneKit

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
        
}

func getMC1_1N(vertices: inout [SCNVector3], indices: inout [Int32],
               v1: SCNVector3, v2: SCNVector3, v3: SCNVector3, v4: SCNVector3) {
    vertices += [v1, v2, v3, v4]
    indices += [
        0, 1, 2,  // Triangle 1
        0, 1, 3,  // Triangle 2
        0, 2, 3,  // Triangle 3
        1, 2, 3   // Triangle 4
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
        1, 3, 4,
        5, 7, 10,
        5, 8, 10,
        4, 7, 10,
        4, 9, 10,
        6, 8, 10,
        6, 9, 10
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
}

func getMC2_1N(vertices: inout [SCNVector3], indices: inout [Int32],
               v1: SCNVector3, v2: SCNVector3, v3: SCNVector3,
              v4: SCNVector3, v5: SCNVector3, v6: SCNVector3,
              v7: SCNVector3, v8: SCNVector3) {
    vertices += [v1, v1, v2, v3, v4, v5, v6, v7, v8,
    (v1 + v3) / 2, (v1 + v4) / 2, (v1 + v5) / 2,
    (v2 + v3) / 2, (v2 + v4) / 2, (v2 + v6) / 2]
    
    indices += [
        9, 10, 11,
        1, 9, 10,
        1, 9, 11,
        1, 10, 11,
        12, 13, 14,
        2, 12, 13,
        2, 12, 14,
        2, 13, 14
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
}
