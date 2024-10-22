//
//  MyViewModel.swift
//  marchingCubes
//
//  Created by 温嘉宝 on 22.10.2024.
//

import Foundation

class MyViewModel: ObservableObject {
    @Published var models: [MyModel] = []
    
    init() {
        fetchData()
    }
    
    func fetchData() {
        models = [
            MyModel(title: "Item 1", description: "Description for item 1"),
            MyModel(title: "Item 2", description: "Description for item 2")
        ]
    }
}
