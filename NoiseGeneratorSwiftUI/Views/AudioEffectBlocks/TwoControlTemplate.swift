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
    
    //@State var isTargeted = false
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var body: some View
    {
    GeometryReader
        { geometry in
        ZStack
            {
            //Everything else
            VStack(spacing: 0)
                {
                //Spacer()
                HStack(spacing: 0)
                    {
                    //Input Volume
                    ZStack{
                        //LinearGradient(Color.white, Color.darkStart)
                        //.frame(maxWidth:geometry.size.width * 0.15,
                        //minHeight:geometry.size.width * 0.25)
                        VolumeComplete(amplitude: self.$inputAmplitude, volumeControl: self.$inputVolume, isRightHanded: .constant(false), numberOfRects: .constant(10),title: "IN")
                        .frame(width: 30)
                        .padding(7)
                    }
                        
                    //Knob 1
                    Spacer()
                    VStack
                        {
                        Text(self.knobModel1.display)
                            .font(.system(size: 12))
                            KnobComplete(knobModel: self.$knobModel1, knobModColor: self.$knobModColor, modulationBeingAssigned: self.$modulationBeingAssigned, modulationBeingDeleted: self.$modulationBeingDeleted)
                            .frame(minWidth:geometry.size.width * 0.25,                       maxWidth:geometry.size.width * 0.25,
                                   minHeight:geometry.size.width * 0.25,
                                   maxHeight: geometry.size.width * 0.25)
                            .overlay(
                                Color.clear
                                    .onAppear{
                                        print("Hello World")
                                }
                            )
                            
                        Text(self.knobModel1.name)
                            .font(.system(size: 12))
                            .bold()
                        }
                        .frame(width:geometry.size.width * 0.25)
                        
                    //Knob 2
                    Spacer()
                    VStack
                        {
                        Text(self.knobModel2.display)
                            .font(.system(size: 12))
                        KnobComplete(knobModel: self.$knobModel2, knobModColor: self.$knobModColor, modulationBeingAssigned: self.$modulationBeingAssigned, modulationBeingDeleted: self.$modulationBeingDeleted)
                            .frame(minWidth:geometry.size.width * 0.25,                           maxWidth:geometry.size.width * 0.25,
                                    minHeight:geometry.size.width * 0.25,
                                    maxHeight: geometry.size.width * 0.25)
                        Text(self.knobModel2.name)
                            .font(.system(size: 12))
                            .bold()
                        }
                        .frame(width:geometry.size.width * 0.25)
                    Spacer()
                        
                    //Output Volume
                        ZStack{
                        //LinearGradient(Color.white, Color.darkStart)
                        //.frame(maxWidth:geometry.size.width * 0.15,
                        //minHeight:geometry.size.width * 0.25)
                        VolumeComplete(amplitude: self.$outputAmplitude, volumeControl: self.$outputVolume, isRightHanded: .constant(true), numberOfRects: .constant(10),title: "OUT")
                        .frame(width: 30)
                        .padding(7)
                        }
                    }
                    
                    TitleBar(title: self.$title, isBypassed: self.$isBypassed)
                        .frame(height:geometry.size.height * 0.2)
                    
                    //Buttom Bar
                    //Spacer()
                    /*
                    HStack
                        {
                        Text(self.title)
                            .font(.system(size: 16))
                            .bold()
                            .foregroundColor(Color.white)
                        }
                        .frame(minWidth: 0,maxWidth: .infinity, minHeight: geometry.size.height * 0.15 + 10)
                        .background(LinearGradient(Color.darkStart,Color.darkGray))
                    */
                    
                    
                    }//VStack
                    .background(LinearGradient(Color.white, Color.lightGray))
                
                    // Power Button
                    /*
                    VStack(alignment: .leading) {
                        Spacer()
                        HStack {
                            PowerButton(isBypassed: self.$isBypassed)
                                .frame(width:geometry.size.height * 0.15, height:geometry.size.height * 0.15)
                            Spacer()
                        }
                    }
                    .padding(EdgeInsets(top: 0, leading: 5, bottom: 5, trailing: 0))
                    */
                }//zstack
        }//georeader
        .padding(5)
        .border(Color.BlackWhiteColor(for: self.colorScheme), width: 5)
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
