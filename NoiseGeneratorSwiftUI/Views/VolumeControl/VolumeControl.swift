import SwiftUI

struct VolumeControl: View {
    @Binding var volume: Double
    @Binding var amplitudeControl: Double
    @Binding var isRightHanded: Bool
    @Binding var numberOfRects: Int
    var spacing: CGFloat = 4
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                if(!self.isRightHanded){
                    VStack(spacing: 0) {
                        SlidingTriangle(volumeControl: self.$amplitudeControl,
                                        isRightHanded: self.$isRightHanded)
                    }
                    .frame(width: geometry.size.width * 0.5)
                }
                VStack(spacing: 0) {
                    
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: (geometry.size.width * 0.25 - geometry.size.height / CGFloat(self.numberOfRects) * 0.25))
                    
                    VolumeDisplay(volume: self.$volume,
                                  numberOfRects: .constant(self.numberOfRects))
                    
                    Rectangle()
                    .fill(Color.clear)
                        .frame(height: (geometry.size.width * 0.25 - geometry.size.height / CGFloat(self.numberOfRects) * 0.25 * 2))
                    
                }
                if(self.isRightHanded){
                    VStack(spacing: 0) {
                        SlidingTriangle(volumeControl: self.$amplitudeControl,
                                        isRightHanded: self.$isRightHanded)
                    }
                    .frame(width: geometry.size.width * 0.5)
                }
            }
        }
        //,amplitudeControl: .constant(1.0))
    }
}

struct VolumeControl_Previews: PreviewProvider {
    static var previews: some View {
        VolumeControl(volume: .constant(1.0),amplitudeControl: .constant(1.0), isRightHanded: .constant(false), numberOfRects: .constant(30))
        .previewLayout(.fixed(width: 30, height: 200))
    }
}
