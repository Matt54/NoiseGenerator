import SwiftUI

struct NoiseGenerator: View {
    @Binding var whiteVal: Double
    @Binding var pinkVal: Double
    @Binding var brownVal: Double
    
    @Binding var volumeControl: Double
    @Binding var amplitude: Double
    
    @Binding var isBypassed: Bool
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var body: some View {
        GeometryReader
        { geometryOut in
            GeometryReader
            { geometry in
                VStack(spacing: 0){
                    HStack(spacing: 0){
                        TriangleDrag(lVal: self.$whiteVal,
                                     tVal: self.$pinkVal,
                                     rVal: self.$brownVal)
                            .aspectRatio(1.0, contentMode: .fit)
                            /*
                            .frame(width: geometry.size.height * 0.65,
                                   height: geometry.size.height * 0.65)
                            */
                        
                        VolumeComplete(amplitude: self.$amplitude,
                                       volumeControl: self.$volumeControl,
                                       isRightHanded: .constant(true),
                                       numberOfRects: .constant(10),
                                       title: "VOL")
                            .padding(geometry.size.width * 0.08)
                            .frame(width: geometry.size.width * 0.27,height:geometry.size.height * 0.8)
                    }
                    TitleBar(title: .constant("Noise Generator"), isBypassed: self.$isBypassed)
                        .frame(height:geometry.size.height * 0.15)
                }
            }
            .padding(geometryOut.size.height * 0.02)
            .border(Color.BlackWhiteColor(for: self.colorScheme), width: geometryOut.size.height * 0.02)
        }
    }
}

struct NoiseGenerator_Previews: PreviewProvider {
    static var previews: some View {
        NoiseGenerator(whiteVal: .constant(1.0),pinkVal: .constant(0.0),brownVal: .constant(0.0), volumeControl: .constant(1.0), amplitude: .constant(0.5), isBypassed: .constant(false))
        .previewLayout(.fixed(width: 250, height: 150))
    }
}
