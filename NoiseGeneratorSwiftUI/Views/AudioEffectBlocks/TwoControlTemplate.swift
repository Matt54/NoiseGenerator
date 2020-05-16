import SwiftUI

struct TwoControlTemplate: View {
    @Binding var twoControlAudioEffect: TwoControlAudioEffect
    @Binding var knobModColor: Color
    @Binding var modulationBeingAssigned: Bool
    @Binding var modulationBeingDeleted: Bool

    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
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
                        //Input Volume
                        VStack{
                            VolumeComplete(amplitude: self.$twoControlAudioEffect.inputAmplitude,
                                           volumeControl: self.$twoControlAudioEffect.inputVolume,
                                           isRightHanded: .constant(false),
                                           numberOfRects: .constant(10),
                                           title: "IN")
                                .padding(geometry.size.width * 0.05)
                                .frame(width: geometry.size.width * 0.2,height:geometry.size.height * 0.85)
                        }
                        .frame(width:geometry.size.width * 0.2)
                            
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
                                             modulationBeingAssigned: self.$modulationBeingAssigned,
                                             modulationBeingDeleted: self.$modulationBeingDeleted)
                                    .frame(width:geometry.size.width * 0.25, height:geometry.size.width * 0.25)
                                    .padding(.vertical, geometry.size.height * 0.05)
                                    
                                // Text - Parameter
                                Text(self.twoControlAudioEffect.control1.name)
                                    .bold()
                                    .textStyle(ShrinkTextStyle())
                                    .frame(width: geometry.size.width * 0.3, height: geometry.size.height * 0.1)
                                
                            }
                            .padding(geometry.size.width * 0.05)
                            .frame(width:geometry.size.width * 0.3, height: geometry.size.height * 0.85)
                            
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
                                             modulationBeingAssigned: self.$modulationBeingAssigned,
                                             modulationBeingDeleted: self.$modulationBeingDeleted)
                                    .frame(width:geometry.size.width * 0.25, height:geometry.size.width * 0.25)
                                    .padding(.vertical, geometry.size.height * 0.05)
                                
                                // Text - Parameter
                                Text(self.twoControlAudioEffect.control2.name)
                                    .bold()
                                    .textStyle(ShrinkTextStyle())
                                    .frame(width: geometry.size.width * 0.3, height: geometry.size.height * 0.1)
                                
                            }//VStack - Knob 2
                            .padding(geometry.size.width * 0.05)
                            .frame(width:geometry.size.width * 0.3,
                                   height: geometry.size.height * 0.85)
                            
                        }// HStack - Knobs

                        //Output Volume
                        VStack{
                            VolumeComplete(amplitude: self.$twoControlAudioEffect.outputAmplitude,
                                           volumeControl: self.$twoControlAudioEffect.outputVolume,
                                           isRightHanded: .constant(true),
                                           numberOfRects: .constant(10),
                                           title: "OUT")
                                //.padding(geometry.size.width * 0.01)
                                //.frame(width:geometry.size.width * 0.1)
                            .padding(geometry.size.width * 0.05)
                            .frame(width: geometry.size.width * 0.2,height:geometry.size.height * 0.85)
                            
                        }
                        .frame(width:geometry.size.width * 0.2)
                    }
                    
                    // Title Bar
                    TitleBar(title: self.$twoControlAudioEffect.name, isBypassed: self.$twoControlAudioEffect.isBypassed)
                        .frame(height:geometry.size.height * 0.15)

                }// VStack - Entire View
                .background(LinearGradient(Color.white, Color.lightGray))
                
            }// georeader - inner
            .padding(geometryOut.size.height * 0.02)
            .border(Color.BlackWhiteColor(for: self.colorScheme), width: geometryOut.size.height * 0.02)
        }// outer georeader (so we can make the border)
    }//view
}//struct



struct TwoControlTemplate_Previews: PreviewProvider {
    static var previews: some View {
        TwoControlTemplate(twoControlAudioEffect: .constant(TwoControlAudioEffect()),
                           knobModColor: .constant(Color.yellow),
                           modulationBeingAssigned: .constant(false),
                           modulationBeingDeleted: .constant(false))
        .previewLayout(.fixed(width: 500, height: 300))
    }
}
