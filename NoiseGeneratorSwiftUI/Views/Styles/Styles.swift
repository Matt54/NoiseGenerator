import Foundation
import SwiftUI

public struct ShrinkTextStyle: ViewModifier {
    public func body(content: Content) -> some View { content
            .font(.system(size: 50))
            .minimumScaleFactor(0.0001)
            .lineLimit(1)
            .scaledToFit()
    }
}

public struct PreFrameTextStyle: ViewModifier {
    public func body(content: Content) -> some View { content
            .font(.system(size: 50))
            .minimumScaleFactor(0.0001)
            .lineLimit(1)
    }
}
