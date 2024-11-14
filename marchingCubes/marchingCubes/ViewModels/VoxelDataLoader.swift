//
//  VoxelDataViewModel.swift
//  marchingCubes
//
//  Created by 温嘉宝 on 13.11.2024.
//

import Foundation
import SceneKit

class VoxelDataLoader: ObservableObject {
    @Published var voxelData: [[[Int]]] = []
    @Published var numLayer: Int = 0
    @Published var isLoading: Bool = true
    @Published var scnNodesByLayer: [Int: [SCNNode?]] = [:]
    
    func loadVoxelData(filename: String, divisions: Int) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let (loadedVoxelData, loadedNumLayer) = MarchingCubesView.loadVoxelData(filename: filename, divisions: divisions) else {
                print("Failed to load voxel data.")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            
            DispatchQueue.main.async {
                self.voxelData = loadedVoxelData
                self.numLayer = loadedNumLayer
                self.isLoading = false
                self.loadSCNNodesForAllLayers()
            }
        }
    }
    
    private func loadSCNNodesForAllLayers() {
        for layer in 0...numLayer {
            let isTopLayer = (layer == numLayer)
            let nodes = loadSCNNodesByLayer(numLayer: layer + 1, voxelData: voxelData, isTopLayer: isTopLayer)
            scnNodesByLayer[layer] = nodes
        }
        let fullNode = loadSCNNodesByLayer(numLayer: numLayer + 1, voxelData: voxelData, isTopLayer: false)
        scnNodesByLayer[0] = fullNode
    }
    
    private func loadSCNNodesByLayer(numLayer: Int, voxelData: [[[Int]]], isTopLayer: Bool) -> [SCNNode?] {
            var res: [SCNNode?] = []
            let algo = MarchingCubesAlgo()
            let layeredData = getLayeredData(data: voxelData, numLayer: numLayer)
            let mcNode2 = algo.marchingCubesV2(data: layeredData)
            res.append(mcNode2)

            if !isTopLayer {
                let algo2d = MarchingCubes2D()
                let colorNode = algo2d.marchingCubes2D(data: get2DDataFromLayer(data: voxelData, numLayer: numLayer - 1))
                colorNode.position.y += Float(numLayer - 1) + 0.01

                res.append(colorNode)
            }
            return res
        }
}
