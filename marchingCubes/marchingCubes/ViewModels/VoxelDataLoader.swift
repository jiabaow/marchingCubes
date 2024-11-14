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
            let nodes = MarchingCubesView.loadSCNNodesByLayer(numLayer: layer + 1, voxelData: voxelData, isTopLayer: isTopLayer)
            scnNodesByLayer[layer] = nodes
        }
        let fullNode = MarchingCubesView.loadSCNNodesByLayer(numLayer: numLayer + 1, voxelData: voxelData, isTopLayer: false)
        scnNodesByLayer[0] = fullNode
    }
}
