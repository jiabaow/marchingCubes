//
//  MarchingCubesColors.swift
//  marchingCubes
//
//  Created by Charles Weng on 11/26/24.
//

import Foundation
import SwiftUI
import UIKit

extension Color {
    static let primaryBlue = Color(red: 90 / 255, green: 103 / 255, blue: 216 / 255)
}

extension UIColor {
    static let lightPurple = UIColor(red: 229 / 255, green: 230 / 255, blue: 246 / 255, alpha: 1.0)
    static let darkGray = UIColor(red: 50/255.0, green: 50/255.0, blue: 50/255.0, alpha: 1.0)
    static let lighterLightGray = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
    static let darkerLightGray = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
    static let cubitBlue = UIColor(red: 79/255, green: 151/255, blue: 211/255, alpha: 1.0)
    static let cubitRed = UIColor(red: 225/255, green: 82/255, blue: 75/255, alpha: 1.0)
    static let cubitPurple = UIColor(red: 123/255, green: 0/255, blue: 255/255, alpha: 1.0)
    static let cubitOrange = UIColor(red: 247/255, green: 164/255, blue: 116/255, alpha: 1.0)
    static let cubitYellow = UIColor(red: 254/255, green: 223/255, blue: 111/255, alpha: 1.0)
    static let cubitPink = UIColor(red: 255/255, green: 123/255, blue: 255/255, alpha: 1.0)
    static let cubitLightBlue = UIColor(red: 0/255, green: 123/255, blue: 255/255, alpha: 1.0)
    static let cubitMagenta = UIColor(red: 255/255, green: 0/255, blue: 255/255, alpha: 1.0)
    static let cubitDarkBlue = UIColor(red: 0/255, green: 0/255, blue: 255/255, alpha: 1.0)
    static let primaryBlue = UIColor(red: 90 / 255, green: 103 / 255, blue: 216 / 255, alpha: 1.0)
}

enum ColorScheme: String, CaseIterable, Hashable {
    case scheme1
    case scheme2
    
}
