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
    
    @State var isTargeted = false
    
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
                Spacer()
                HStack(spacing: 0)
                    {
                    //Spacer()
                        
                    //Input Volume
                        //VStack(spacing: 5)
                        /*
                        VStack(alignment: .trailing, spacing: 5)
                        {
                            Text(String(format: "%.1f", self.inputVolume))
                                .font(.system(size: 12))
                                .padding(.trailing, 2)
                            VolumeControl(volume: self.$inputAmplitude, amplitudeControl: self.$inputVolume, isRightHanded: .constant(false), numberOfRects: .constant(10))
                            Text("IN")
                                .font(.system(size: 12))
                                .bold()
                                .padding(.trailing, 4)
                        }
                        
                        */
                        VolumeComplete(volume: self.$inputAmplitude, amplitudeControl: self.$inputVolume, isRightHanded: .constant(false), numberOfRects: .constant(10),title: "IN")
                        .frame(width: 30)
                        .padding(.horizontal, 7)
                        
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
                            //.foregroundColor(Color.black)
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
                            //.foregroundColor(Color.black)
                        }
                        .frame(width:geometry.size.width * 0.25)
                    Spacer()
                        
                    //Output Volume
                        
                        //VStack(spacing: 5)
                        /*
                        VStack(alignment: .leading, spacing: 5)
                        {
                            Text(String(format: "%.1f", self.outputVolume))
                                .font(.system(size: 12))
                                .padding(.leading, 2)
                            VolumeControl(volume: self.$outputAmplitude, amplitudeControl: self.$outputVolume, isRightHanded: .constant(true), numberOfRects: .constant(10))
                            Text("OUT")
                                .font(.system(size: 12))
                                .bold()
                        }
                        */
                        VolumeComplete(volume: self.$outputAmplitude, amplitudeControl: self.$outputVolume, isRightHanded: .constant(true), numberOfRects: .constant(10),title: "OUT")
                        .frame(width: 30)
                        .padding(.horizontal, 7)
                        
                    //Spacer()
                        
                    }
                    
                    //Buttom Bar
                    Spacer()
                    HStack
                        {
                        Text(self.title)
                            .font(.system(size: 16))
                            .bold()
                            .foregroundColor(Color.white)
                        }
                        .frame(minWidth: 0,maxWidth: .infinity, minHeight: geometry.size.height * 0.15 + 10)
                        .background(Color.init(red: 0.2, green: 0.2, blue: 0.2))
                    }
                
                // Power Button
                VStack {
                    Spacer()
                    HStack {
                        Button(action: {self.isBypassed.toggle()}){
                            if(!self.isBypassed){
                            Circle()
                                .fill(Color.init(red: 0.0, green: 0.0, blue: 0.0))
                                .frame(width:geometry.size.height * 0.15,
                                       height:geometry.size.height * 0.15)
                                .overlay(
                                Image(systemName: "power")
                                    .font(.system(size: 18))
                                    .foregroundColor(Color.yellow)
                                )
                            }
                            else{
                                Circle()
                                .fill(Color.init(red: 0.0, green: 0.0, blue: 0.0))
                                .frame(width:geometry.size.height * 0.15,
                                       height:geometry.size.height * 0.15)
                                .overlay(
                                Image(systemName: "power")
                                    .font(.system(size: 18))
                                    .foregroundColor(Color.gray)
                                )
                            }
                        }
                        Spacer()
                    }
                    
                }
                .padding(EdgeInsets(top: 0, leading: 5, bottom: 5, trailing: 0))
                //.padding(EdgeInsets(top: 8, leading: 5, bottom: 0, trailing: 0))
                
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
