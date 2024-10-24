//
//  MyModel.swift
//  marchingCubes
//
//  Created by 温嘉宝 on 22.10.2024.
//

import SwiftData
import Foundation

@Model
class MyModel: Identifiable, Decodable {
    var id: UUID
    var title: String

    init(id: UUID = UUID(), title: String) {
        self.id = id
        self.title = title
    }

    // Custom initializer for Decodable
    enum CodingKeys: String, CodingKey {
        case id
        case title
    }

    // Implementing the required initializer for Decodable
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode the properties
        let idString = try container.decode(String.self, forKey: .id)
        guard let id = UUID(uuidString: idString) else {
            throw DecodingError.dataCorruptedError(forKey: .id, in: container, debugDescription: "Invalid UUID format")
        }

        let title = try container.decode(String.self, forKey: .title)

        self.init(id: id, title: title)
    }
}
