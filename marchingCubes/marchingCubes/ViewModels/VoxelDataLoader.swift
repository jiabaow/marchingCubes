//
//  VoxelDataViewModel.swift
//  marchingCubes
//


import Foundation
import SceneKit

class VoxelDataLoader: ObservableObject {
    @Published var voxelData: [[[Int]]] = []
    @Published var numLayer: Int = 0
    @Published var isLoading: Bool = true
    @Published var isActive: Bool = false
    @Published var scnNodesByLayer: [Int: [SCNNode?]] = [:]
    var layerCaseCounts: [Int: [String: Int]] = [:]
    var cumulativeCaseCounts: [String: Int] = [:]
    var colorScheme: ColorScheme = .scheme1

    func loadVoxelData(filename: String, divisions: Int, colorScheme: ColorScheme) {
        self.colorScheme = colorScheme
        let baseFilename = (filename as NSString).deletingPathExtension
        let jsonFilename = "\(baseFilename)_\(divisions)_voxel_data.json"
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(jsonFilename)
        
        print("jsonFilename is: ", jsonFilename)
        
        // Check if the JSON file exists
        if FileManager.default.fileExists(atPath: fileURL.path) {
            print("JSON file exists. Loading voxel data.")
            do {
                let data = try Data(contentsOf: fileURL)
                if let loadedVoxelData = deserializeVoxelData(from: data) {
                    // Use the loaded voxel data
                    self.voxelData = loadedVoxelData
                    self.numLayer = loadedVoxelData[0].count - 1
                    self.loadSCNNodesForAllLayers()
                    self.isLoading = false
                    return
                }
            } catch {
                print("Error loading voxel data from JSON file: \(error)")
            }
        }
        print("Not cached, need to voxelize the model")
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let (loadedVoxelData, loadedNumLayer) = self.loadVoxelDataHelper(filename: filename, divisions: divisions) else {
                print("Failed to load voxel data.")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            
            DispatchQueue.main.async {
                self.voxelData = loadedVoxelData
                self.numLayer = loadedNumLayer
                self.loadSCNNodesForAllLayers()
                self.isLoading = false
                
                if let jsonData = self.serializeVoxelData(voxelData: loadedVoxelData) {
                    self.saveVoxelDataToFile(data: jsonData, fileURL: fileURL)
                    print("Cached voxel data")
                }
            }
        }
    }
    
    
    func loadVoxelData2(filename: String, divisions: Int) {
        let jsonFilename = filename.replacingOccurrences(of: ".obj", with: "_voxel_data.json")
//        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(jsonFilename)
        let fileURL = get3DModelURL(filename: filename)!
        
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
            guard let (loadedVoxelData, loadedNumLayer) = self.loadVoxelDataHelper(filename: filename, divisions: divisions) else {
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
                
                if let jsonData = self.serializeVoxelData(voxelData: loadedVoxelData) {
                    self.saveVoxelDataToFile(data: jsonData, fileURL: fileURL)
                    print("cached Voxel data")
                }
            }
        }
    }
    
    private func loadSCNNodesForAllLayers() {
        for layer in 0...numLayer {
            let isTopLayer = (layer == numLayer)
            let nodes = loadSCNNodesByLayer(numLayer: layer + 1, voxelData: voxelData, isTopLayer: isTopLayer, cumulativeCaseCounts: &cumulativeCaseCounts)
            scnNodesByLayer[layer] = nodes
        }
        let fullNode = loadSCNNodesByLayer(numLayer: numLayer + 1, voxelData: voxelData, isTopLayer: false, cumulativeCaseCounts: &cumulativeCaseCounts)
        scnNodesByLayer[0] = fullNode
    }
    
    private func loadSCNNodesByLayer(numLayer: Int, voxelData: [[[Int]]], isTopLayer: Bool, cumulativeCaseCounts: inout [String: Int]) -> [SCNNode?] {
        var res: [SCNNode?] = []
    
        let algo = MarchingCubesAlgo()
        let layeredData = getLayeredData(data: voxelData, numLayer: numLayer)
        let mcNode2 = algo.marchingCubesV2(data: layeredData)
        res.append(mcNode2)
        
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

        if !isTopLayer {
            let algo2d = MarchingCubes2D(colorScheme: colorScheme)
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
    func saveVoxelDataToFile(data: Data, fileURL: URL) {
        do {
            try data.write(to: fileURL)
            print("Voxel data saved.")
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
    
    // Helper function to load and voxelize the model
     func loadVoxelDataHelper(filename: String, divisions: Int) -> ([[[Int]]], Int)? {
         var voxArray: MDLVoxelArray? = nil
         if let fileURL = get3DModelURL(filename: filename) {
             guard let obj = loadObjAsset(filename: fileURL),
                   let voxarr = voxelize(asset: obj, divisions: Int32(divisions)) else {
                 print("Failed to load or voxelize the model.")
                 return nil
             }
             voxArray = voxarr
         } else {
             guard let obj = loadOBJ(filename: filename),
                   let voxarr = voxelize(asset: obj, divisions: Int32(divisions)) else {
                 print("Failed to load or voxelize the model.")
                 return nil
             }
             voxArray = voxarr
         }
         let voxelGrid = convertTo3DArray(voxelArray: voxArray!)
         let voxelData = getAllLayers(data: voxelGrid)
         let numLayer = voxelData[0].count - 1
         return (voxelData, numLayer)
     }
}
