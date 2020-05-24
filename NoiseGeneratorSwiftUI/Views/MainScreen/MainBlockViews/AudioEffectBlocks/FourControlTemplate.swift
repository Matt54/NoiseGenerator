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
            ZStack
                {
                //Everything else
                VStack
                    {
                    Spacer()
                    HStack
                        {
                        //Knob 1
                        Spacer()
                        VStack
                            {
                            Text(self.fourControlEffect.control1.display)
                                .font(.system(size: 14))
                                KnobComplete(knobModel: self.$fourControlEffect.control1,
                                             knobModColor: self.$knobModColor,
                                             specialSelection: self.$specialSelection)
                                             //modulationBeingAssigned: self.$modulationBeingAssigned,
                                             //modulationBeingDeleted: .constant(false))
                                .frame(minWidth:geometry.size.width * 0.175,
                                       maxWidth:geometry.size.width * 0.175,
                                       minHeight:geometry.size.width * 0.175,
                                       maxHeight: geometry.size.width * 0.175)
                            Text(self.fourControlEffect.control1.name)
                                .font(.system(size: 14))
                                .bold()
                            }
                            .frame(width:geometry.size.width * 0.2)
                        
                        //Knob 2
                        Spacer()
                        VStack
                            {
                            Text(self.fourControlEffect.control2.display)
                                .font(.system(size: 14))
                            KnobComplete(knobModel: self.$fourControlEffect.control2,
                                         knobModColor: self.$knobModColor,
                                         specialSelection: self.$specialSelection)
                                         //modulationBeingAssigned: self.$modulationBeingAssigned,
                                         //modulationBeingDeleted: .constant(false))
                                .frame(minWidth:geometry.size.width * 0.175,
                                       maxWidth:geometry.size.width * 0.175,
                                       minHeight:geometry.size.width * 0.175,
                                       maxHeight: geometry.size.width * 0.175)
                            Text(self.fourControlEffect.control2.name)
                                .font(.system(size: 14))
                                .bold()
                            }
                            .frame(width:geometry.size.width * 0.2)
                            
                        //Knob 3
                        Spacer()
                        VStack
                            {
                            Text(self.fourControlEffect.control3.display)
                                .font(.system(size: 14))
                            KnobComplete(knobModel: self.$fourControlEffect.control3,
                                         knobModColor: self.$knobModColor,
                                         specialSelection: self.$specialSelection)
                                         //modulationBeingAssigned: self.$modulationBeingAssigned,
                                         //modulationBeingDeleted: .constant(false))
                                .frame(minWidth:geometry.size.width * 0.175,
                                       maxWidth:geometry.size.width * 0.175,
                                       minHeight:geometry.size.width * 0.175,
                                       maxHeight: geometry.size.width * 0.175)
                            Text(self.fourControlEffect.control3.name)
                                .font(.system(size: 14))
                                .bold()
                            }
                            .frame(width:geometry.size.width * 0.2)
                            
                        //Knob 4
                        Spacer()
                        VStack
                            {

                            Text(self.fourControlEffect.control4.display)
                                .font(.system(size: 14))
                                KnobComplete(knobModel: self.$fourControlEffect.control4,
                                             knobModColor: self.$knobModColor,
                                             specialSelection: self.$specialSelection)
                                             //modulationBeingAssigned: self.$modulationBeingAssigned,
                                             //modulationBeingDeleted: .constant(false))
                                .frame(minWidth:geometry.size.width * 0.175,
                                       maxWidth:geometry.size.width * 0.175,
                                       minHeight:geometry.size.width * 0.175,
                                       maxHeight: geometry.size.width * 0.175)
                            Text(self.fourControlEffect.control4.name)
                                .font(.system(size: 14))
                                .bold()
                                //.foregroundColor(Color.black)
                                
                            }
                            .frame(width:geometry.size.width * 0.2)
                        Spacer()
                        }
                        
                        //Buttom Bar
                        Spacer()
                        HStack
                            {
                            Text(self.fourControlEffect.name)
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
                            Button(action: {self.fourControlEffect.isBypassed.toggle()}){
                                if(!self.fourControlEffect.isBypassed){
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
                    .padding(5)
                    
                    }//zstack
            }//georeader
            .padding(5)
            .border(Color.BlackWhiteColor(for: self.colorScheme), width: 5)
        }//view
    }//struct

struct FourControlTemplate_Previews: PreviewProvider {
    static var previews: some View {
        FourControlTemplate(fourControlEffect: .constant(FourControlAudioEffect()),
                            knobModColor: .constant(Color.yellow),
                            specialSelection: .constant(SpecialSelection.none))
                            //modulationBeingAssigned: .constant(false))
        .previewLayout(.fixed(width: 380, height: 170))
    }
}
