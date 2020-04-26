import SwiftUI

struct ModulationView: View {
    @State var title = "EFFECT TITLE"
    @Binding var isBypassed : Bool
    @Binding var knobModel1 : KnobCompleteModel
    @State var knobModColor: Color
    @Binding var isConnectingModulation: Bool

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
                        
                    Spacer()
                        
                    Button(action: {
                        self.isConnectingModulation.toggle()
                    }){
                        Image(systemName: "plus.rectangle.fill")
                            .foregroundColor(self.knobModColor)
                            .font(.system(size: 36))
                    }
                        
                    //Knob 1
                    Spacer()
                    VStack
                        {
                        Text(self.knobModel1.display)
                            .font(.system(size: 14))
                            KnobComplete(knobModel: self.$knobModel1, knobModColor: self.$knobModColor, modulationBeingAssigned: .constant(false))
                            .frame(minWidth:geometry.size.width * 0.275,                           maxWidth:geometry.size.width * 0.275,
                                   minHeight:geometry.size.width * 0.275,
                                   maxHeight: geometry.size.width * 0.275)
                            .overlay(
                                Color.clear
                                    .onAppear{
                                        print("Hello World")
                                }
                            )
                            
                        Text(self.knobModel1.name)
                            .font(.system(size: 14))
                            .bold()
                            //.foregroundColor(Color.black)
                        }
                        .frame(width:geometry.size.width * 0.35)
                        
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
                .padding(EdgeInsets(top: 0, leading: 3, bottom: 6, trailing: 0))
                //.padding(EdgeInsets(top: 8, leading: 5, bottom: 0, trailing: 0))
                
                }//zstack
        }//georeader
        .padding(5)
        .border(Color.BlackWhiteColor(for: self.colorScheme), width: 5)
    }//view
}//struct

struct ModulationView_Previews: PreviewProvider {
    static var previews: some View {
        ModulationView(isBypassed: .constant(false),
        knobModel1: .constant(KnobCompleteModel()),
        knobModColor: Color.yellow,
        isConnectingModulation: .constant(false))
        .previewLayout(.fixed(width: 280, height: 180))
    }
}

