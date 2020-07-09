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
        { geometry in
            
            // Whole View
            VStack(spacing: 0){

                if(self.modulation.selectedBlockDisplay == .list){
                    HStack(spacing: 0){
                        
                        //Assign Button
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
                            
                        //Remove Button
                        Button(action: {
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
                                        .accentColor(Color.white)
                                        .padding(geometry.size.height * 0.04)
                                }
                                .frame(width: geometry.size.width * 0.35,
                                       height:geometry.size.height * 0.2)
                        }
                        .disabled(self.modulation.modulationTargets.count < 1)
      
                    }
                    .frame(height: geometry.size.height * 0.85)
                }

                if(self.modulation.selectedBlockDisplay == .controls){
                    //Trigger and Clock BUttons
                    VStack(spacing: 0){
                        
                        //Should be changed to:
                        // - Envelope Toggle
                        // - Retrigger Toggle
                        // - Free Running Toggle
                        
                        Toggle(isOn: self.$modulation.isEnvelopeMode) {
                            Text("Envelope:")
                        }.toggleStyle(CheckboxToggleStyle())
                        .padding(geometry.size.width * 0.05)
                        
                        Toggle(isOn: self.$modulation.isTriggerMode) {
                            Text("Retrigger:")
                        }.toggleStyle(CheckboxToggleStyle())
                        .padding(geometry.size.width * 0.05)
                        
                        Toggle(isOn: self.$modulation.isFreeMode) {
                            Text("Free Mode:")
                        }.toggleStyle(CheckboxToggleStyle())
                        .padding(geometry.size.width * 0.05)
                        
                                /*
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
                        */
                                
                                /*
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
                                */
                            
                            }
                            .padding(geometry.size.width * 0.1)
                            .frame(height: geometry.size.height * 0.85)
                        }
                            
                        //}
                        //.frame(width: geometry.size.width * 0.35, height: geometry.size.height * 0.85)

                        
                        if(self.modulation.selectedBlockDisplay == .pattern){
                            
                            
                        HStack(spacing: 0){
                            
                            //Knob 1
                            VStack(spacing: 0)
                            {
                                
                                Text(self.modulation.timingControl.display)
                                .textStyle(ShrinkTextStyle())
                                .frame(height: geometry.size.height * 0.1)
                                
                                // Knob Controller
                                KnobComplete(knobModel: self.$modulation.timingControl,
                                             knobModColor: self.$knobModColor,
                                             specialSelection: self.$specialSelection)
                                    //.frame(height:geometry.size.width * 0.25)
                                    .padding(.vertical, geometry.size.height * 0.05)

                                
                                Text(self.modulation.timingControl.name)
                                    .bold()
                                    .textStyle(ShrinkTextStyle())
                                    .frame(height: geometry.size.height * 0.1)
                                
                            }
                            .padding(geometry.size.width * 0.1)
                            .frame(width: geometry.size.width * 0.4)
                            
                            VStack(spacing: 0)
                            {
                                Text("Pattern View").textStyle(ShrinkTextStyle())
                                
                                Button(action: {
                                    self.screen = SelectedScreen.adjustPattern
                                }){
                                    //Text("Click Me")
                                    
                                    MiniPattern(pattern: self.$pattern)
                                        .padding(geometry.size.width * 0.01)
                                        .border(Color.black, width: geometry.size.width * 0.01)
                                        .foregroundColor(Color.white)
                                        //.frame(width: geometry.size.width * 0.25,height: geometry.size.width * 0.25)
                                }
                            }
                            .padding(geometry.size.width * 0.1)
                            .frame(width: geometry.size.width * 0.6)
                            //.frame(width: geometry.size.width * 0.25,height: geometry.size.width * 0.25)
                            
                        
                            
                            
                    //.frame(width: geometry.size.width * 0.35,height: geometry.size.height * 0.85)
                        
                        //VStack(spacing: 0){
                            
                            //Text("Pattern View").textStyle(ShrinkTextStyle())
                            
                            
                            //Text("Tap To Adjust").textStyle(ShrinkTextStyle())
                        
                        //}
                        //.frame(width: geometry.size.width * 0.25,height: geometry.size.height * 0.85)
                        }
                        .frame(height: geometry.size.height * 0.85)
                    }
                    //}
                    
                    // Title Bar
                    ModulationTitleBar(title: self.$modulation.name,
                                       selectedBlockDisplay: self.$modulation.selectedBlockDisplay,
                                       isBypassed: self.$modulation.isBypassed)
                    .frame(height:geometry.size.height * 0.15)
                    
                    
                }
                .background(LinearGradient(Color.white, Color.lightGray))
                //}//zstack
        }//georeader
    }//view
}//struct

struct ModulationView_Previews: PreviewProvider {
    static var previews: some View {
        ModulationView(modulation: .constant(Modulation()),//tempo: Tempo(bpm: 120))),
        knobModColor: .constant(Color.yellow),
        specialSelection: .constant(SpecialSelection.none),
        pattern: .constant(Pattern(color: Color.yellow)),
        screen: .constant(SelectedScreen.main))
        .previewLayout(.fixed(width: 300, height: 250))
    }
}


//@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
/*
public protocol ToggleStyle2 {
    associatedtype Body : View

    func makeBody(configuration: Self.Configuration) -> Self.Body

    typealias Configuration = ToggleStyleConfiguration
}
 */

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        return HStack {
            configuration.label
            Spacer()
            Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                .resizable()
                .aspectRatio(1.0, contentMode: .fit)
                //.frame(width: 22, height: 22)
                .onTapGesture { configuration.isOn.toggle() }
        }
    }
}
