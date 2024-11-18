//
//  VoxelDataViewModel.swift
//  marchingCubes
//


import Foundation
import SceneKit

// VoxelDataLoader is responsible for loading voxel data and managing 3D scene nodes.
class VoxelDataLoader: ObservableObject {

    @Published var voxelData: [[[Int]]] = []
    @Published var numLayer: Int = 0
    @Published var isLoading: Bool = true
    @Published var scnNodesByLayer: [Int: [SCNNode?]] = [:]
    var layerCaseCounts: [Int: [String: Int]] = [:]
    var cumulativeCaseCounts: [String: Int] = [:]

    // Asynchronously loads voxel data from a file
    func loadVoxelData(filename: String, divisions: Int) {
        let jsonFilename = filename.replacingOccurrences(of: ".obj", with: "_voxel_data.json")
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(jsonFilename)
        
        // Check if the JSON file exists
        if FileManager.default.fileExists(atPath: fileURL.path) {
            print("JSON file exists. Loading voxel data from \(fileURL.path).")
            do {
                let data = try Data(contentsOf: fileURL)
                if let loadedVoxelData = deserializeVoxelData(from: data) {
                    // Use the loaded voxel data
                    self.voxelData = loadedVoxelData
                    self.numLayer = loadedVoxelData[0].count - 1
                    self.isLoading = false
                    self.loadSCNNodesForAllLayers()
                    return
                }
            } catch {
                print("Error loading voxel data from JSON file: \(error)")
            }
        }
        print("not cashed, need to voxelize the model")
        
        DispatchQueue.global(qos: .userInitiated).async {
            // Attempt to load voxel data using MarchingCubesView
            guard let (loadedVoxelData, loadedNumLayer) = MarchingCubesView.loadVoxelData(filename: filename, divisions: divisions) else {
                print("Failed to load voxel data.")
                // Update loading state on the main thread
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            
            // Update voxel data and load nodes on the main thread
            DispatchQueue.main.async {
                self.voxelData = loadedVoxelData
                self.numLayer = loadedNumLayer
                self.isLoading = false
                self.loadSCNNodesForAllLayers()
                
                if let jsonData = self.serializeVoxelData(voxelData: loadedVoxelData) {
                    self.saveVoxelDataToFile(data: jsonData, filename: filename)
                    print("cached Voxel data")
                }
            }
        }
    }
    
    // Loads SceneKit nodes for all layers in the voxel data
    private func loadSCNNodesForAllLayers() {
        var cumulativeCaseCounts: [String: Int] = [:] // Tracks cumulative case counts
        
        // Iterate through each layer to load nodes
        for layer in 0...numLayer {
            let isTopLayer = (layer == numLayer)
            let nodes = loadSCNNodesByLayer(numLayer: layer + 1, voxelData: voxelData, isTopLayer: isTopLayer, cumulativeCaseCounts: &cumulativeCaseCounts)
            scnNodesByLayer[layer] = nodes
        }
        // Load full node for the entire data set
        let fullNode = loadSCNNodesByLayer(numLayer: numLayer + 1, voxelData: voxelData, isTopLayer: false, cumulativeCaseCounts: &cumulativeCaseCounts)
        scnNodesByLayer[0] = fullNode
    }
    
    // Loads SceneKit nodes for a specific layer
    private func loadSCNNodesByLayer(numLayer: Int, voxelData: [[[Int]]], isTopLayer: Bool, cumulativeCaseCounts: inout [String: Int]) -> [SCNNode?] {
        var res: [SCNNode?] = []
    
        let algo = MarchingCubesAlgo() // Initialize MarchingCubes algorithm
        let layeredData = getLayeredData(data: voxelData, numLayer: numLayer) // Retrieve data for the current layer
        let mcNode2 = algo.marchingCubesV2(data: layeredData) // Generate 3D node using marching cubes
        res.append(mcNode2)
        
        // Update case counts for the current layer
        if layerCaseCounts[numLayer-1] == nil {
            layerCaseCounts[numLayer-1] = [:]
        }
        
        for (key, count) in algo.caseCounts {
            let previousCount = cumulativeCaseCounts[key] ?? 0
            let layerCount = count - previousCount
            if layerCount > 0 {
                layerCaseCounts[numLayer - 1]?[key] = layerCount
            }
            cumulativeCaseCounts[key] = count
        }

        // If not the top layer, generate a 2D color node
        if !isTopLayer {
            let algo2d = MarchingCubes2D()
            let colorNode = algo2d.marchingCubes2D(data: get2DDataFromLayer(data: voxelData, numLayer: numLayer - 1))
            colorNode.position.y += Float(numLayer - 1) + 0.01

            res.append(colorNode)
        }
        return res
    }
    
    // Serialize the voxel data to JSON
    func serializeVoxelData(voxelData: [[[Int]]]) -> Data? {
        do {
            let jsonData = try JSONEncoder().encode(voxelData)
            return jsonData
        } catch {
            print("Error serializing voxel data: \(error)")
            return nil
        }
    }

    // Save the serialized data to a file
    func saveVoxelDataToFile(data: Data, filename: String) {
        let jsonFilename = filename.replacingOccurrences(of: ".obj", with: "_voxel_data.json")
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(jsonFilename)
        do {
            try data.write(to: fileURL)
            print("Voxel data saved to \(fileURL.path)")
        } catch {
            print("Error saving voxel data to file: \(error)")
        }
    }
    
    func deserializeVoxelData(from data: Data) -> [[[Int]]]? {
        do {
            let decoder = JSONDecoder()
            let voxelData = try decoder.decode([[[Int]]].self, from: data)
            return voxelData
        } catch {
            print("Error decoding voxel data: \(error)")
            return nil
        }
    }
}
