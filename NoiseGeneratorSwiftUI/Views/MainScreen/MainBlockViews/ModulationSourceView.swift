import SwiftUI

struct ModulationSourceView: View {
    
    @EnvironmentObject var noise: Conductor
    
    var body: some View {
        GeometryReader{ geometry in
            VStack(spacing: 0){
                
                /*
                ZStack{
                    Rectangle()
                    .fill(LinearGradient(Color.darkStart,Color.darkGray))
                        Text("MODULATIONS")
                            .bold()
                            .textStyle(ShrinkTextStyle())
                            .foregroundColor(Color.white)
                }
                .padding(geometry.size.height * 0.02)
                .border(Color.black, width: geometry.size.height * 0.02)
                .frame(height: geometry.size.height * 0.1)
                */
                
                VStack(spacing: 0){
                    ZStack{
                        Rectangle()
                            .fill(LinearGradient(Color.darkStart,Color.darkGray))
                        Text("MODULATIONS")
                            .bold()
                            .textStyle(ShrinkTextStyle())
                            .foregroundColor(Color.white)
                    }
                    .frame(height: geometry.size.height * 0.08)
                    
                    Divider()
                        
                    /*
                    ZStack{
                        LinearGradient(Color.darkStart,Color.darkGray)
                        
                        HStack(spacing: 0){
                        ForEach(self.noise.allControlEffects , id: \.id){ effect in
                            
                            VStack{
                                if(effect.isDisplayed){
                                    effect.displayImage
                                        .resizable()
                                        .padding(geometry.size.height * 0.02)
                                        .foregroundColor(Color.yellow)
                                }
                                else{
                                    effect.displayImage
                                        .resizable()
                                        .padding(geometry.size.height * 0.025)
                                        .foregroundColor(Color.white)
                                }
                            }
                                    .frame(width: geometry.size.height * 0.14,
                                           height: geometry.size.height * 0.14)
                                    .onTapGesture(count: 1) {
                                        self.noise.objectWillChange.send()
                                        self.noise.hideEffects()
                                        effect.isDisplayed = true
                                    }
                            }
                        
                        Button(action:{
                            
                            //This prevents crash from volume screen graph
                            self.noise.changeEffectsDisplay()
                            
                            self.noise.selectedScreen = SelectedScreen.addEffect
                        }){
                            Image(systemName: "plus.circle")
                                .resizable()
                                .padding(geometry.size.height * 0.025)
                                .frame(width: geometry.size.height * 0.14,
                                       height: geometry.size.height * 0.14)
                                .foregroundColor(Color.white)
                        }
                        Spacer()
                        }
                        .padding(.leading, geometry.size.height * 0.025)
                    }
                    
                    */
                    
                    ZStack{
                        LinearGradient(Color.darkStart,Color.darkGray)
                        HStack(spacing: 0){
                        ForEach(self.noise.modulations , id: \.id){ mod in
                            
                            /*
                            Button(action: {
                                
                                self.noise.objectWillChange.send()
                                self.noise.hideModulations()
                                mod.isDisplayed = true
                                
                            }){
                                */
                                VStack{
                                    if(mod.isDisplayed){
                                        Image(systemName: "m.circle.fill")
                                            .resizable()
                                            .padding(geometry.size.height * 0.02)
                                            //.frame(width: geometry.size.height * 0.1,
                                                   //height: geometry.size.height * 0.1)
                                            .foregroundColor(mod.modulationColor)
                                            //.foregroundColor(Color.white)
                                    }
                                    else{
                                        Image(systemName: "m.circle")
                                            .resizable()
                                            .padding(geometry.size.height * 0.025)
                                            //.frame(width: geometry.size.height * 0.1,
                                                   //height: geometry.size.height * 0.1)
                                            .foregroundColor(mod.modulationColor)
                                            //.foregroundColor(Color.white)
                                    }
                                }
                            .frame(width: geometry.size.height * 0.14,
                                   height: geometry.size.height * 0.14)
                            .onTapGesture(count: 1) {
                                self.noise.objectWillChange.send()
                                self.noise.hideModulations()
                                mod.isDisplayed = true
                            }
                                
                            
                        }
                        Button(action:{
                            print("Let's create a new modulation source!")
                            self.noise.createNewModulation()
                        }){
                            Image(systemName: "plus.circle")
                                .resizable()
                                .padding(geometry.size.height * 0.025)
                                .frame(width: geometry.size.height * 0.14,
                                       height: geometry.size.height * 0.14)
                                .foregroundColor(Color.white)
                        }
                        Spacer()
                        }
                        .padding(.leading, geometry.size.height * 0.025)
                    }
                }
                .frame(height: geometry.size.height * 0.22)
            
                // Add All Modulations
                ForEach(self.noise.modulations.indices, id: \.self){ i in
                    VStack(spacing: 0){
                        if(self.noise.modulations[i].isDisplayed){
                        ModulationView(modulation: self.$noise.modulations[i],
                          knobModColor: self.$noise.knobModColor,
                          specialSelection: self.$noise.specialSelection,
                          pattern: self.$noise.modulations[i].pattern,
                          screen: self.$noise.selectedScreen)
                        }
                    }
                }
 
            }
            .padding(geometry.size.height * 0.0)
            .border(Color.black, width: geometry.size.height * 0.0)
        }
    }
}

struct ModulationSourceView_Previews: PreviewProvider {
    static var previews: some View {
        ModulationSourceView().environmentObject(Conductor.shared)
            .previewLayout(.fixed(width: 568, height: 568))
    }
}
