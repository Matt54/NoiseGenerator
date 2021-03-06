import Foundation
import SwiftUI


// This allows us to define our own Color to reuse
public extension Color {
    
    static let almostWhite = Color(red: 250 / 255, green: 250 / 255, blue: 252 / 255)
    
    static let offWhite = Color(red: 225 / 255, green: 225 / 255, blue: 235 / 255)
    
    static let offBlack = Color(red: (255-225) / 255, green: (255-225) / 255, blue: (255-235) / 255)
    
    static let lightGray = Color.init(red: 0.85, green: 0.85, blue: 0.9)
    static let darkGray = Color.init(red: 0.2, green: 0.2, blue: 0.2)
    
    static let lightWood = Color.init(red: 92 / 100, green: 80 / 100, blue: 64 / 100)
    static let darkWood = Color.init(red: 84 / 100, green: 68 / 100, blue: 48 / 100)
    
    static let darkStart = Color(red: 50 / 255, green: 60 / 255, blue: 65 / 255)
    static let darkEnd = Color(red: 25 / 255, green: 25 / 255, blue: 30 / 255)
    
    static let lightStart = Color(red: 160 / 255, green: 160 / 255, blue: 240 / 255)
    static let lightEnd = Color(red: 230 / 255, green: 180 / 255, blue: 220 / 255)
    
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
