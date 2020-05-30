import SwiftUI

struct TwoControlTemplate: View {
    @Binding var twoControlAudioEffect: TwoControlAudioEffect
    @Binding var knobModColor: Color
    @Binding var specialSelection: SpecialSelection

    //@Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var body: some View
    {
        GeometryReader
        { geometryOut in
            GeometryReader
            { geometry in
                //Entire View
                VStack(spacing: 0)
                {
                    //Controls - Volumes and Knobs
                    HStack(spacing: 0)
                    {
                        if(self.twoControlAudioEffect.selectedBlockDisplay == .volume){
                            //Input Volume
                            VStack{
                                VolumeComplete(volumeMixer: self.$twoControlAudioEffect.inputVolumeMixer)
                                    .padding(geometry.size.width * 0.05)
                                    .frame(width: geometry.size.width * 0.2,height:geometry.size.height * 0.85)
                            }
                            .frame(width:geometry.size.width * 0.2)
                            
                            OutputPlotView(inputNode: self.$twoControlAudioEffect.dummyMixer)
                                .frame(width:geometry.size.width * 0.6,
                                       height: geometry.size.height * 0.6)

                        
                            //Output Volume
                            VStack{
                                VolumeComplete(volumeMixer: self.$twoControlAudioEffect.outputVolumeMixer)
                                    .padding(geometry.size.width * 0.05)
                                    .frame(width: geometry.size.width * 0.2,height:geometry.size.height * 0.85)
                                
                            }
                            .frame(width:geometry.size.width * 0.2)
                        }
                            
                        if(self.twoControlAudioEffect.selectedBlockDisplay == .controls){
                            // Knobs
                            HStack(spacing: 0){
                                
                                //Knob 1
                                VStack(spacing: 0)
                                {
                                    // Text - Value Display
                                    Text(self.twoControlAudioEffect.control1.display)
                                        .textStyle(ShrinkTextStyle())
                                        .frame(width: geometry.size.width * 0.3,
                                               height: geometry.size.height * 0.1)
                                        .scaledToFit()
                                    
                                    // Knob Controller
                                    KnobComplete(knobModel: self.$twoControlAudioEffect.control1,
                                                 knobModColor: self.$knobModColor,
                                                 specialSelection: self.$specialSelection)
                                        .frame(width:geometry.size.width * 0.25, height:geometry.size.width * 0.25)
                                        .padding(.vertical, geometry.size.height * 0.05)
                                        
                                    // Text - Parameter
                                    Text(self.twoControlAudioEffect.control1.name)
                                        .bold()
                                        .textStyle(ShrinkTextStyle())
                                        .frame(width: geometry.size.width * 0.3, height: geometry.size.height * 0.1)
                                    
                                }
                                .padding(geometry.size.width * 0.05)
                                .frame(height: geometry.size.height * 0.85)
                                
                                //Knob 2
                                VStack(spacing: 0)
                                {
                                    // Text - Value Display
                                    Text(self.twoControlAudioEffect.control2.display)
                                        .textStyle(ShrinkTextStyle())
                                        .frame(width: geometry.size.width * 0.3, height: geometry.size.height * 0.1)
                                    
                                    // Knob Controller
                                    KnobComplete(knobModel: self.$twoControlAudioEffect.control2,
                                                 knobModColor: self.$knobModColor,
                                                 specialSelection: self.$specialSelection)
                                        .frame(width:geometry.size.width * 0.25, height:geometry.size.width * 0.25)
                                        .padding(.vertical, geometry.size.height * 0.05)
                                    
                                    // Text - Parameter
                                    Text(self.twoControlAudioEffect.control2.name)
                                        .bold()
                                        .textStyle(ShrinkTextStyle())
                                        .frame(width: geometry.size.width * 0.3, height: geometry.size.height * 0.1)
                                    
                                }//VStack - Knob 2
                                .padding(geometry.size.width * 0.05)
                                .frame(height: geometry.size.height * 0.85)
                                
                            }// HStack - Knobs
                        }
                        
                    }
                    
                    // Title Bar
                    EffectTitleBar(title: self.$twoControlAudioEffect.name,
                                       selectedBlockDisplay: self.$twoControlAudioEffect.selectedBlockDisplay)
                    .frame(height:geometry.size.height * 0.15)
                    
                    /*
                    TitleBar(title: self.$twoControlAudioEffect.name, isBypassed: self.$twoControlAudioEffect.isBypassed)
                        .frame(height:geometry.size.height * 0.15)
                    */

                }// VStack - Entire View
                .background(LinearGradient(Color.white, Color.lightGray))
                
            }// georeader - inner
            //.padding(geometryOut.size.height * 0.0)
            //.border(Color.BlackWhiteColor(for: self.colorScheme), width: geometryOut.size.height * 0.0)
        }// outer georeader (so we can make the border)
    }//view
}//struct



struct TwoControlTemplate_Previews: PreviewProvider {
    static var previews: some View {
        TwoControlTemplate(twoControlAudioEffect: .constant(MoogLadderAudioEffect(pos: 1)),
                           knobModColor: .constant(Color.yellow),
                           specialSelection: .constant(SpecialSelection.none))

        .previewLayout(.fixed(width: 500, height: 300))
    }
}
