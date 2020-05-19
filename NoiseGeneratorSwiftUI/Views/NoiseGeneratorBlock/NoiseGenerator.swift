import SwiftUI

struct NoiseGenerator: View {
    @Binding var noiseSource: NoiseSource
    
    var body: some View {
        GeometryReader
        { geometryOut in
            GeometryReader
            { geometry in
                VStack(spacing: 0){
                    HStack(spacing: 0){
                        TriangleDrag(lVal: self.$noiseSource.whiteVal,
                                     tVal: self.$noiseSource.pinkVal,
                                     rVal: self.$noiseSource.brownVal)
                            .aspectRatio(1.0, contentMode: .fit)
                            .frame(width: geometry.size.width * 0.8,
                                   height: geometry.size.height * 0.8)
                        
                        VolumeComplete(amplitude: self.$noiseSource.volumeMixer.amplitude,
                                    volumeControl: self.$noiseSource.volumeMixer.volumeControl,
                                    isRightHanded: self.$noiseSource.volumeMixer.isRightHanded,
                                    numberOfRects: self.$noiseSource.volumeMixer.numberOfRects,
                                    title: self.noiseSource.volumeMixer.name)
                            .padding(geometry.size.width * 0.05)
                            .frame(width: geometry.size.width * 0.2,height:geometry.size.height * 0.85)
                    }
                    
                    TitleBar(title: .constant("Noise Generator"), isBypassed: self.$noiseSource.isBypassed)
                        .frame(height:geometry.size.height * 0.15)
                }
                .background(LinearGradient(Color.white, Color.lightGray))
            }
            .padding(geometryOut.size.height * 0.02)
            .border(Color.black, width: geometryOut.size.height * 0.02)
            
        }
    }
}

struct NoiseGenerator_Previews: PreviewProvider {
    static var previews: some View {
        NoiseGenerator(noiseSource: .constant(NoiseSource()))
        .previewLayout(.fixed(width: 250, height: 250))
    }
}
