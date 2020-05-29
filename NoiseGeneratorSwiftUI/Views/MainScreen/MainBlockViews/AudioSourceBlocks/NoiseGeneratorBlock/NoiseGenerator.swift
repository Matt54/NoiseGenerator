import SwiftUI

struct NoiseGenerator: View {
    @Binding var noiseSource: NoiseSource
    
    var body: some View {
        GeometryReader
        { geometryOut in
            GeometryReader
            { geometry in
                VStack(spacing: 0){
                    
                    if(self.noiseSource.selectedBlockDisplay == .adsr){
                        VStack(spacing: geometry.size.height * 0.02){
                            Text("ADSR Volume Envelope")
                                .bold()
                                .textStyle(ShrinkTextStyle())
                                .frame(height: geometry.size.height * 0.1)
                            
                            ADSR(attack: self.$noiseSource.attackDisplay,
                                 decay: self.$noiseSource.decay,
                                 sustain: self.$noiseSource.sustain,
                                 release: self.$noiseSource.releaseDisplay)
                            .clipShape(Rectangle())
                            .padding(geometry.size.height * 0.01)
                            .border(Color.black, width: geometry.size.height * 0.01)
                            .frame(width: geometry.size.width * 0.85,
                                   height: geometry.size.height * 0.4)

                            HStack(spacing: geometry.size.height * 0.05){
                            
                                KnobVerticalStack(knobModel: self.$noiseSource.attackControl,
                                                  removeValue: true)
                                KnobVerticalStack(knobModel: self.$noiseSource.decayControl,
                                removeValue: true)
                                KnobVerticalStack(knobModel: self.$noiseSource.sustainControl,
                                removeValue: true)
                                KnobVerticalStack(knobModel: self.$noiseSource.releaseControl,
                                removeValue: true)
                                }
                        }
                        .padding(geometry.size.height * 0.05)
                    }
                    
                    if(self.noiseSource.selectedBlockDisplay == .volume){
                        HStack(spacing: 0){
                            TriangleDrag(lVal: self.$noiseSource.whiteVal,
                                         tVal: self.$noiseSource.pinkVal,
                                         rVal: self.$noiseSource.brownVal)
                                .aspectRatio(1.0, contentMode: .fit)
                                .frame(width: geometry.size.width * 0.8,
                                       height: geometry.size.height * 0.8)
                            
                            VolumeComplete(volumeMixer: self.$noiseSource.volumeMixer)
                                .padding(geometry.size.width * 0.05)
                                .frame(width: geometry.size.width * 0.2,height:geometry.size.height * 0.85)
                        }
                    }
                    
                    NoiseTitleBar(title: self.$noiseSource.name,
                                       selectedBlockDisplay: self.$noiseSource.selectedBlockDisplay)
                    .frame(height:geometry.size.height * 0.15)
                    
                    /*
                    TitleBar(title: .constant("Noise Generator"), isBypassed: self.$noiseSource.isBypassed)
                        .frame(height:geometry.size.height * 0.15)
                    */
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
