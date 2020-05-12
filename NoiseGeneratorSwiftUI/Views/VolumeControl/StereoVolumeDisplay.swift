import SwiftUI


struct StereoVolumeDisplay: View {
    
    @Binding var leftAmplitude: Double
    @Binding var rightAmplitude: Double
    @Binding var numberOfRects: Int
    
    var body: some View {
        GeometryReader
        { geometry in
            HStack(spacing:0){
                
                //Left Amplitude Display
                VolumeDisplay(volume: self.$leftAmplitude,
                              numberOfRects: self.$numberOfRects )
                    .padding(geometry.size.height * 0.02)
                
                //Right Amplitude Display
                VolumeDisplay(volume: self.$rightAmplitude,
                              numberOfRects: self.$numberOfRects )
                    .padding(geometry.size.height * 0.02)
            }
        }
    }
}

struct StereoVolumeDisplay_Previews: PreviewProvider {
    static var previews: some View {
        StereoVolumeDisplay(leftAmplitude: .constant(0.5),
                            rightAmplitude: .constant(0.6),
                            numberOfRects: .constant(30))
    }
}
