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

public struct ListTextStyle: ViewModifier {
    public func body(content: Content) -> some View { content
            .font(.system(size: 50))
            .minimumScaleFactor(0.01)
            .lineLimit(1)
            //.multilineTextAlignment(.leading)
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
