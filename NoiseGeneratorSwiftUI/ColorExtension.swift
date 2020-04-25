import Foundation
import SwiftUI

public extension Color {
    static let whiteColor = Color(white: 1.0)
    static let blackColor = Color(white: 0.0)
    static func BlackWhiteColor(for colorScheme: ColorScheme) -> Color {
        if colorScheme == .dark {
            return whiteColor
        } else {
            return blackColor
        }
    }
    static func WhiteBlackColor(for colorScheme: ColorScheme) -> Color {
        if colorScheme == .dark {
            return blackColor
        } else {
            return whiteColor
            
        }
    }
}
