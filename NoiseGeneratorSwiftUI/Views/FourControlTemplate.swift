import SwiftUI

struct FourControlTemplate: View {
    @State var title = "EFFECT TITLE"
    @Binding var isBypassed : Bool
    @Binding var knobModel1 : KnobCompleteModel
    @Binding var knobModel2 : KnobCompleteModel
    @Binding var knobModel3 : KnobCompleteModel
    @Binding var knobModel4 : KnobCompleteModel
    @State var knobModColor: Color
    
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
                            Text(self.knobModel1.display)
                                .font(.system(size: 14))
                            KnobComplete(knobModel: self.$knobModel1, knobModColor: self.knobModColor)
                                .frame(minWidth:geometry.size.width * 0.175,                  maxWidth:geometry.size.width * 0.175,
                                       minHeight:geometry.size.width * 0.175,
                                       maxHeight: geometry.size.width * 0.175)
                            Text(self.knobModel1.name)
                                .font(.system(size: 14))
                                .bold()
                                //.foregroundColor(Color.black)
                            }
                            .frame(width:geometry.size.width * 0.2)
                        
                        //Knob 2
                        Spacer()
                        VStack
                            {
                            Text(self.knobModel2.display)
                                .font(.system(size: 14))
                            KnobComplete(knobModel: self.$knobModel2, knobModColor: self.knobModColor)
                                .frame(minWidth:geometry.size.width * 0.175,                  maxWidth:geometry.size.width * 0.175,
                                minHeight:geometry.size.width * 0.175,
                                maxHeight: geometry.size.width * 0.175)
                            Text(self.knobModel2.name)
                                .font(.system(size: 14))
                                .bold()
                                //.foregroundColor(Color.black)
                            }
                            .frame(width:geometry.size.width * 0.2)
                            
                        //Knob 3
                        Spacer()
                        VStack
                            {
                            Text(self.knobModel3.display)
                                .font(.system(size: 14))
                            KnobComplete(knobModel: self.$knobModel3, knobModColor: self.knobModColor)
                                .frame(minWidth:geometry.size.width * 0.175,                  maxWidth:geometry.size.width * 0.175,
                                minHeight:geometry.size.width * 0.175,
                                maxHeight: geometry.size.width * 0.175)
                            Text(self.knobModel3.name)
                                .font(.system(size: 14))
                                .bold()
                                //.foregroundColor(Color.black)
                            }
                            .frame(width:geometry.size.width * 0.2)
                            
                        //Knob 4
                        Spacer()
                        VStack
                            {

                            Text(self.knobModel4.display)
                                .font(.system(size: 14))
                                KnobComplete(knobModel: self.$knobModel4, knobModColor: self.knobModColor)
                                .frame(minWidth:geometry.size.width * 0.175,                  maxWidth:geometry.size.width * 0.175,
                                minHeight:geometry.size.width * 0.175,
                                maxHeight: geometry.size.width * 0.175)
                            Text(self.knobModel4.name)
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
                    .padding(5)
                    //.padding(EdgeInsets(top: 8, leading: 5, bottom: 0, trailing: 0))
                    
                    }//zstack
            }//georeader
            .padding(5)
            .border(Color.BlackWhiteColor(for: self.colorScheme), width: 5)
        }//view
    }//struct

struct FourControlTemplate_Previews: PreviewProvider {
    static var previews: some View {
        FourControlTemplate(isBypassed: .constant(false),
                            knobModel1: .constant(KnobCompleteModel()),
                            knobModel2: .constant(KnobCompleteModel()),
                            knobModel3: .constant(KnobCompleteModel()),
                            knobModel4: .constant(KnobCompleteModel()),
                            knobModColor: Color.yellow)
        .previewLayout(.fixed(width: 380, height: 170))
    }
}
