import SwiftUI

struct ModulationView: View {
    @State var title = "EFFECT TITLE"
    @Binding var isBypassed : Bool
    @Binding var knobModel1 : KnobCompleteModel
    @State var knobModColor: Color
    @Binding var isConnectingModulation: Bool
    @Binding var isDeletingModulation: Bool
    @Binding var pattern: Pattern

    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var body: some View
    {
    GeometryReader
    { geometryOuter in
    GeometryReader
        { geometry in
        ZStack
            {
            //Everything else
            VStack(spacing: 0)
                {
                HStack(spacing: 0)
                    {
                        
                        VStack(spacing: 0){
                            
                            Text("Add/Remove")
                                .textStyle(ShrinkTextStyle())
                            .frame(width: geometry.size.width * 0.35,
                                   height: geometry.size.height * 0.20)
                            
                            HStack(){
                                
                                Button(action: {
                                    self.isConnectingModulation.toggle()
                                }){
                                    VStack{
                                        if(self.isConnectingModulation){
                                            Image(systemName: "plus.rectangle.fill")
                                                .resizable()
                                                .frame(width: geometry.size.width * 0.15,
                                                       height:geometry.size.height * 0.2)
                                                .foregroundColor(self.knobModColor)
                                        }
                                        else{
                                            Image(systemName: "plus.rectangle")
                                                .resizable()
                                                .frame(width: geometry.size.width * 0.15,
                                                       height:geometry.size.height * 0.2)
                                                .foregroundColor(self.knobModColor)
                                        }
                                    }
                                }
                                Button(action: {
                                    self.isDeletingModulation.toggle()
                                }){
                                    VStack{
                                        if(self.isDeletingModulation){
                                            Image(systemName: "minus.rectangle.fill")
                                                .resizable()
                                                .frame(width: geometry.size.width * 0.15,
                                                       height:geometry.size.height * 0.2)
                                                .foregroundColor(self.knobModColor)
                                        }
                                        else{
                                            Image(systemName: "minus.rectangle")
                                                .resizable()
                                                .frame(width: geometry.size.width * 0.15,
                                                       height:geometry.size.height * 0.2)
                                                .foregroundColor(self.knobModColor)
                                            
                                        }
                                    }
                                }
                            }
                            
                            Text("Modulation")
                                .textStyle(ShrinkTextStyle())
                            .frame(width: geometry.size.width * 0.30,
                                   height: geometry.size.height * 0.20)
                            
                        }
                        .frame(width: geometry.size.width * 0.35,
                               height: geometry.size.height * 0.85)
                        
                    //Knob 1
                        VStack(spacing: 0)
                        {
                            Text(self.knobModel1.display)
                            .textStyle(ShrinkTextStyle())
                            .frame(width: geometry.size.width * 0.3, height: geometry.size.height * 0.1)
                            
                            // Knob Controller
                            KnobComplete(knobModel: self.$knobModel1,
                                         knobModColor: self.$knobModColor,
                                         modulationBeingAssigned: .constant(false),
                                         modulationBeingDeleted: .constant(false))
                                .frame(width:geometry.size.width * 0.25, height:geometry.size.width * 0.25)
                                .padding(.vertical, geometry.size.height * 0.05)
                            
                            Text(self.knobModel1.name)
                                .bold()
                                .textStyle(ShrinkTextStyle())
                                .frame(width: geometry.size.width * 0.3, height: geometry.size.height * 0.1)
                        }
                    .frame(width: geometry.size.width * 0.35,
                           height: geometry.size.height * 0.85)
                        
                        VStack{
                            PatternGraph(pattern: self.$pattern)
                                .frame(width: geometry.size.width * 0.25,
                                       height: geometry.size.width * 0.25)
                        }
                        .frame(width: geometry.size.width * 0.25,
                               height: geometry.size.height * 0.85)
                    }
                    
                    // Title Bar
                    TitleBar(title: self.$title, isBypassed: self.$isBypassed)
                        .frame(height:geometry.size.height * 0.15)
                }

                }//zstack
        }//georeader
        .padding(geometryOuter.size.height * 0.02)
        .border(Color.BlackWhiteColor(for: self.colorScheme),
                width: geometryOuter.size.height * 0.02)
        }
        
    }//view
}//struct

struct ModulationView_Previews: PreviewProvider {
    static var previews: some View {
        ModulationView(isBypassed: .constant(false),
        knobModel1: .constant(KnobCompleteModel()),
        knobModColor: Color.yellow,
        isConnectingModulation: .constant(false),
        isDeletingModulation: .constant(false),
        pattern: .constant(Pattern()))
        .previewLayout(.fixed(width: 300, height: 180))
    }
}

