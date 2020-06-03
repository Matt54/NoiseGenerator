import SwiftUI

struct FourControlTemplate: View {
    
    @Binding var fourControlEffect : FourControlAudioEffect
    @Binding var knobModColor: Color
    //@Binding var modulationBeingAssigned: Bool
    @Binding var specialSelection: SpecialSelection
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var body: some View
        {
        GeometryReader
            { geometry in
                //Everything else
                VStack(spacing: 0)
                    {
                    HStack(spacing: 0){
                        
                        if(self.fourControlEffect.selectedBlockDisplay == .volume){
                            //Input Volume
                            VStack{
                                VolumeComplete(volumeMixer: self.$fourControlEffect.inputVolumeMixer)
                                    .padding(geometry.size.width * 0.05)
                                    .frame(width: geometry.size.width * 0.2,height:geometry.size.height * 0.85)
                            }
                            .frame(width:geometry.size.width * 0.2)
                            
                            OutputPlotView(inputNode: self.$fourControlEffect.dummyMixer)
                                .frame(width:geometry.size.width * 0.6,
                                       height: geometry.size.height * 0.6)

                        
                            //Output Volume
                            VStack{
                                VolumeComplete(volumeMixer: self.$fourControlEffect.outputVolumeMixer)
                                    .padding(geometry.size.width * 0.05)
                                    .frame(width: geometry.size.width * 0.2,height:geometry.size.height * 0.85)
                                
                            }
                            .frame(width:geometry.size.width * 0.2)
                        }
                        
                    if(self.fourControlEffect.selectedBlockDisplay == .controls){
                    //Knobs
                        HStack(spacing: 0)
                            {
                                
                            //Knob 1
                            VStack(spacing: 0)
                                {
                                    
                                Text(self.fourControlEffect.control1.display)
                                    .textStyle(ShrinkTextStyle())
                                    .frame(width: geometry.size.width * 0.2,
                                           height: geometry.size.height * 0.1)
                                    
                                KnobComplete(knobModel: self.$fourControlEffect.control1,
                                             knobModColor: self.$knobModColor,
                                             specialSelection: self.$specialSelection)
                                    .aspectRatio(1.0, contentMode: .fit)
                                    .frame(width:geometry.size.width * 0.175)
                                    .padding(.vertical, geometry.size.height * 0.05)
                                    
                                Text(self.fourControlEffect.control1.name)
                                    .bold()
                                    .textStyle(ShrinkTextStyle())
                                    .frame(width: geometry.size.width * 0.2,
                                           height: geometry.size.height * 0.1)
                                }
                                .padding(geometry.size.width * 0.025)
                                .frame(height: geometry.size.height * 0.85)
                            
                            //Knob 2
                            VStack(spacing: 0)
                                {
                                    
                                Text(self.fourControlEffect.control2.display)
                                    .textStyle(ShrinkTextStyle())
                                    .frame(width: geometry.size.width * 0.2,
                                           height: geometry.size.height * 0.1)
                                    
                                KnobComplete(knobModel: self.$fourControlEffect.control2,
                                             knobModColor: self.$knobModColor,
                                             specialSelection: self.$specialSelection)
                                    .aspectRatio(1.0, contentMode: .fit)
                                    .frame(width:geometry.size.width * 0.175)
                                    .padding(.vertical, geometry.size.height * 0.05)
                                    
                                Text(self.fourControlEffect.control2.name)
                                    .bold()
                                    .textStyle(ShrinkTextStyle())
                                    .frame(width: geometry.size.width * 0.2,
                                           height: geometry.size.height * 0.1)
                                }
                                .padding(geometry.size.width * 0.025)
                                .frame(height: geometry.size.height * 0.85)
                                
                                
                            //Knob 3
                            VStack(spacing: 0)
                                {
                                    
                                Text(self.fourControlEffect.control3.display)
                                    .textStyle(ShrinkTextStyle())
                                    .frame(width: geometry.size.width * 0.2,
                                           height: geometry.size.height * 0.1)
                                    
                                KnobComplete(knobModel: self.$fourControlEffect.control3,
                                             knobModColor: self.$knobModColor,
                                             specialSelection: self.$specialSelection)
                                    .aspectRatio(1.0, contentMode: .fit)
                                    .frame(width:geometry.size.width * 0.175)
                                    .padding(.vertical, geometry.size.height * 0.05)
                                    
                                Text(self.fourControlEffect.control3.name)
                                    .bold()
                                    .textStyle(ShrinkTextStyle())
                                    .frame(width: geometry.size.width * 0.2,
                                           height: geometry.size.height * 0.1)
                                }
                                .padding(geometry.size.width * 0.025)
                                .frame(height: geometry.size.height * 0.85)
                                
                            //Knob 4
                            VStack(spacing: 0)
                                {
                                    
                                Text(self.fourControlEffect.control4.display)
                                    .textStyle(ShrinkTextStyle())
                                    .frame(width: geometry.size.width * 0.2,
                                           height: geometry.size.height * 0.1)
                                    
                                KnobComplete(knobModel: self.$fourControlEffect.control4,
                                             knobModColor: self.$knobModColor,
                                             specialSelection: self.$specialSelection)
                                    .aspectRatio(1.0, contentMode: .fit)
                                    .frame(width:geometry.size.width * 0.175)
                                    .padding(.vertical, geometry.size.height * 0.05)
                                    
                                Text(self.fourControlEffect.control4.name)
                                    .bold()
                                    .textStyle(ShrinkTextStyle())
                                    .frame(width: geometry.size.width * 0.2,
                                           height: geometry.size.height * 0.1)
                                }
                                .padding(geometry.size.width * 0.025)
                                .frame(height: geometry.size.height * 0.85)
                                
                            }
                        }
                    }
                    .frame(height:geometry.size.height * 0.85)
                        
                        
                    EffectTitleBar(title: self.$fourControlEffect.name,
                                   selectedBlockDisplay: self.$fourControlEffect.selectedBlockDisplay,
                                   isBypassed: self.$fourControlEffect.isBypassed)
                    .frame(height:geometry.size.height * 0.15)
                        
                        
                }//VStack
                .background(LinearGradient(Color.white, Color.lightGray))
                        
            }//georeader
        }//view
    }//struct

struct FourControlTemplate_Previews: PreviewProvider {
    static var previews: some View {
        FourControlTemplate(fourControlEffect: .constant(AppleDelayAudioEffect(pos: 1)),
                            knobModColor: .constant(Color.yellow),
                            specialSelection: .constant(SpecialSelection.none))
        .previewLayout(.fixed(width: 500, height: 300))
    }
}
