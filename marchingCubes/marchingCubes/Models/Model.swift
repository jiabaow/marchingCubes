//
//  Model.swift
//  marchingCubes
//
//  Created by Charles Weng on 10/27/24.
//

import Foundation

protocol Model {
    var id: UUID { get set }
    var title: String { get set }
    var image: String { get set }
}
