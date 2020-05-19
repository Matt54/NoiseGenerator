import SwiftUI

struct ModulationView: View {

    @Binding var modulation: Modulation
    
    @Binding var knobModColor: Color
    @Binding var specialSelection: SpecialSelection
    
    @Binding var pattern: Pattern
    @Binding var screen: SelectedScreen

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
                            
                            Button(action: {
                                if(self.specialSelection == .none){
                                    self.specialSelection = .assignModulation
                                }
                                else{
                                    self.specialSelection = .none
                                }
                                
                            }){
                                ZStack{
                                    Rectangle()
                                        .fill(LinearGradient(Color.darkEnd, Color.darkStart))
                                        .cornerRadius(geometry.size.height * 0.05)
                                        .padding(geometry.size.height * 0.03)
                                        Text("ASSIGN")
                                            .bold()
                                            .textStyle(ShrinkTextStyle())
                                            .foregroundColor(Color.white)
                                            .padding(geometry.size.height * 0.04)
                                }
                                .frame(width: geometry.size.width * 0.35,
                                       height:geometry.size.height * 0.2)
                            }
                            
                            Button(action: {
                                //self.isDeletingModulation.toggle()
                                if(self.specialSelection == .none){
                                    self.specialSelection = .deleteModulation
                                }
                                else{
                                    self.specialSelection = .none
                                }
                            }){
                                ZStack{
                                    Rectangle()
                                        .fill(LinearGradient(Color.darkEnd, Color.darkStart))
                                        .cornerRadius(geometry.size.height * 0.05)
                                        .padding(geometry.size.height * 0.03)
                                    Text("REMOVE")
                                        .bold()
                                        .textStyle(ShrinkTextStyle())
                                        .foregroundColor(Color.white)
                                        .padding(geometry.size.height * 0.04)
                                }
                                .frame(width: geometry.size.width * 0.35,
                                       height:geometry.size.height * 0.2)
                            }
                            
                            
                            HStack(spacing: 0){
                                
                                Button(action: {
                                    self.modulation.isTriggerOnly = !self.modulation.isTriggerOnly
                                }){
                                    ZStack{
                                        Rectangle()
                                            .fill(LinearGradient(Color.darkEnd, Color.darkStart))
                                            .cornerRadius(geometry.size.height * 0.05)
                                            .padding(geometry.size.height * 0.03)
                                        if(self.modulation.isTriggerOnly){
                                            Image(systemName: "arrow.up.right.circle.fill")
                                                .resizable()
                                                .padding(geometry.size.height * 0.06)
                                                .foregroundColor(Color.white)
                                        }
                                        else{
                                            Image(systemName: "arrow.up.right.circle")
                                            .resizable()
                                            .padding(geometry.size.height * 0.05)
                                            .foregroundColor(Color.white)
                                        }
                                    }
                                }
                                .aspectRatio(1.0, contentMode: .fit)
                                .frame(width: geometry.size.height * 0.2)
                                
                                Button(action: {
                                    self.modulation.isTempoSynced = !self.modulation.isTempoSynced
                                }){
                                    ZStack{
                                        Rectangle()
                                            .fill(LinearGradient(Color.darkEnd, Color.darkStart))
                                            .cornerRadius(geometry.size.height * 0.05)
                                            .padding(geometry.size.height * 0.03)
                                        if(self.modulation.isTempoSynced){
                                            Image(systemName: "music.note")
                                                .resizable()
                                                .padding(geometry.size.height * 0.06)
                                                .foregroundColor(Color.white)
                                        }
                                        else{
                                            Image(systemName: "clock")
                                            .resizable()
                                            .padding(geometry.size.height * 0.05)
                                            .foregroundColor(Color.white)
                                        }
                                    }
                                }
                                .aspectRatio(1.0, contentMode: .fit)
                                .frame(width: geometry.size.height * 0.2)
                            
                            }
                        }
                        .frame(width: geometry.size.width * 0.35,
                               height: geometry.size.height * 0.85)
                        
                        
                    //Knob 1
                        VStack(spacing: 0)
                        {
                            Text(self.modulation.timingControl.display)
                            .textStyle(ShrinkTextStyle())
                            .frame(width: geometry.size.width * 0.3, height: geometry.size.height * 0.1)
                            
                            // Knob Controller
                            KnobComplete(knobModel: self.$modulation.timingControl,
                                         knobModColor: self.$knobModColor,
                                         specialSelection: self.$specialSelection)
                                .frame(width:geometry.size.width * 0.25, height:geometry.size.width * 0.25)
                                .padding(.vertical, geometry.size.height * 0.05)
                            
                            Text(self.modulation.timingControl.name)
                                .bold()
                                .textStyle(ShrinkTextStyle())
                                .frame(width: geometry.size.width * 0.3, height: geometry.size.height * 0.1)
                        }
                    .frame(width: geometry.size.width * 0.35,
                           height: geometry.size.height * 0.85)
                        
                        VStack(spacing: 0){
                            
                            Text("Pattern View")
                                .textStyle(ShrinkTextStyle())
                            
                            Button(action: {
                                self.screen = SelectedScreen.adjustPattern
                            }){
                                //Text("Click Me")
                                MiniPattern(pattern: self.$pattern)
                                    .padding(geometry.size.width * 0.02)
                                    .border(Color.black,
                                            width: geometry.size.width * 0.01)
                                    .frame(width: geometry.size.width * 0.25,
                                           height: geometry.size.width * 0.25)
                            }
                            
                            Text("Tap To Adjust")
                                .textStyle(ShrinkTextStyle())
                            
                        }
                        .frame(width: geometry.size.width * 0.25,
                               height: geometry.size.height * 0.85)
                    }
                    
                    // Title Bar
                    TitleBar(title: self.$modulation.name, isBypassed: self.$modulation.isBypassed)
                        .frame(height:geometry.size.height * 0.15)
                }
                .background(LinearGradient(Color.white, Color.lightGray))
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
        ModulationView(modulation: .constant(Modulation(tempo: Tempo(bpm: 120))),
        knobModColor: .constant(Color.yellow),
        specialSelection: .constant(SpecialSelection.none),
        pattern: .constant(Pattern(color: Color.yellow)),
        screen: .constant(SelectedScreen.main))
        .previewLayout(.fixed(width: 300, height: 250))
    }
}

