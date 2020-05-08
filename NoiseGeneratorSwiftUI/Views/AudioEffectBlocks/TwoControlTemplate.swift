import SwiftUI

struct TwoControlTemplate: View {
    @State var title = "EFFECT TITLE"
    @Binding var isBypassed : Bool
    @Binding var knobModel1 : KnobCompleteModel
    @Binding var knobModel2 : KnobCompleteModel
    @Binding var knobModColor: Color
    @Binding var modulationBeingAssigned: Bool
    @Binding var modulationBeingDeleted: Bool
    
    @Binding var inputAmplitude: Double
    @Binding var inputVolume: Double
    @Binding var outputAmplitude: Double
    @Binding var outputVolume: Double

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
                            VolumeComplete(amplitude: self.$inputAmplitude,
                                           volumeControl: self.$inputVolume,
                                           isRightHanded: .constant(false),
                                           numberOfRects: .constant(10),
                                           title: "IN")
                                .padding(geometry.size.width * 0.01)
                                .frame(width:geometry.size.width * 0.1)
                        }
                        .frame(width:geometry.size.width * 0.15)
                            
                        // Knobs
                        HStack(spacing: 0){
                            
                            //Knob 1
                            VStack(spacing: 0)
                            {
                                // Text - Value Display
                                Text(self.knobModel1.display)
                                    .textStyle(ShrinkTextStyle())
                                    .frame(width: geometry.size.width * 0.3, height: geometry.size.height * 0.1)
                                
                                // Knob Controller
                                KnobComplete(knobModel: self.$knobModel1,
                                             knobModColor: self.$knobModColor,
                                             modulationBeingAssigned: self.$modulationBeingAssigned,
                                             modulationBeingDeleted: self.$modulationBeingDeleted)
                                    .frame(width:geometry.size.width * 0.25, height:geometry.size.width * 0.25)
                                    .padding(.vertical, geometry.size.height * 0.05)
                                    
                                // Text - Parameter
                                Text(self.knobModel1.name)
                                    .bold()
                                    .textStyle(ShrinkTextStyle())
                                    .frame(width: geometry.size.width * 0.3, height: geometry.size.height * 0.1)
                                
                            }
                            .padding(geometry.size.width * 0.05)
                            .frame(width:geometry.size.width * 0.35, height: geometry.size.height * 0.85)
                            
                            //Knob 2
                            VStack(spacing: 0)
                            {
                                
                                // Text - Value Display
                                Text(self.knobModel2.display)
                                    .textStyle(ShrinkTextStyle())
                                    .frame(width: geometry.size.width * 0.3, height: geometry.size.height * 0.1)
                                
                                // Knob Controller
                                KnobComplete(knobModel: self.$knobModel2,
                                             knobModColor: self.$knobModColor,
                                             modulationBeingAssigned: self.$modulationBeingAssigned,
                                             modulationBeingDeleted: self.$modulationBeingDeleted)
                                    .frame(width:geometry.size.width * 0.25, height:geometry.size.width * 0.25)
                                    .padding(.vertical, geometry.size.height * 0.05)
                                
                                // Text - Parameter
                                Text(self.knobModel2.name)
                                    .bold()
                                    .textStyle(ShrinkTextStyle())
                                    .frame(width: geometry.size.width * 0.3, height: geometry.size.height * 0.1)
                                
                            }//VStack - Knob 2
                            .padding(geometry.size.width * 0.05)
                            .frame(width:geometry.size.width * 0.35, height: geometry.size.height * 0.85)
                            
                        }// HStack - Knobs

                        //Output Volume
                        VStack{
                            VolumeComplete(amplitude: self.$outputAmplitude,
                                           volumeControl: self.$outputVolume,
                                           isRightHanded: .constant(true),
                                           numberOfRects: .constant(10),
                                           title: "OUT")
                                .padding(geometry.size.width * 0.01)
                                .frame(width:geometry.size.width * 0.1)
                        }
                        .frame(width:geometry.size.width * 0.15)
                    }
                    
                    // Title Bar
                    TitleBar(title: self.$title, isBypassed: self.$isBypassed)
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
        TwoControlTemplate(isBypassed: .constant(false),
                           knobModel1: .constant(KnobCompleteModel()),
                           knobModel2: .constant(KnobCompleteModel()),
                           knobModColor: .constant(Color.yellow),
                           modulationBeingAssigned: .constant(false),
                           modulationBeingDeleted: .constant(false),
                           inputAmplitude: .constant(1.0),
                           inputVolume: .constant(0.8999999),
                           outputAmplitude: .constant(0.0),
                           outputVolume: .constant(0.5))
        .previewLayout(.fixed(width: 300, height: 180))
    }
}
