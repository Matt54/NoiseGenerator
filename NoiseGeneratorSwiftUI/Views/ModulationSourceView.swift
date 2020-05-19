import SwiftUI

struct ModulationSourceView: View {
    
    @EnvironmentObject var noise: NoiseModel
    
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
                        
                    
                    ZStack{
                        LinearGradient(Color.darkStart,Color.darkGray)
                        HStack(spacing: 0){
                        ForEach(self.noise.modulations , id: \.id){ mod in
                            Button(action: {
                                self.noise.objectWillChange.send()
                                mod.toggleDisplayed()
                            }){
                                if(mod.isDisplayed){
                                    Image(systemName: "m.circle.fill")
                                        .resizable()
                                        .padding(geometry.size.height * 0.01)
                                        .frame(width: geometry.size.height * 0.1,
                                               height: geometry.size.height * 0.1)
                                        //.foregroundColor(mod.modulationColor)
                                        .foregroundColor(Color.white)
                                }
                                else{
                                    Image(systemName: "m.circle")
                                        .resizable()
                                        .padding(geometry.size.height * 0.01)
                                        .frame(width: geometry.size.height * 0.1,
                                               height: geometry.size.height * 0.1)
                                        //.foregroundColor(mod.modulationColor)
                                        .foregroundColor(Color.white)
                                }
                            }
                        }
                        Button(action:{
                            print("Let's create a new modulation source!")
                        }){
                            Image(systemName: "plus.circle")
                                .resizable()
                                .padding(geometry.size.height * 0.01)
                                .frame(width: geometry.size.height * 0.1,
                                       height: geometry.size.height * 0.1)
                                .foregroundColor(Color.white)
                        }
                        Spacer()
                        }
                    }
                }
                .padding(geometry.size.height * 0.02)
                .border(Color.black, width: geometry.size.height * 0.02)
                .frame(height: geometry.size.height * 0.22)
            
                // Add All Modulations
                ForEach(self.noise.modulations.indices, id: \.self){ i in
                    VStack(spacing: 0){
                        if(self.noise.modulations[i].isDisplayed){
                        ModulationView(modulation: self.$noise.modulations[i],
                          knobModColor: self.$noise.knobModColor,
                          specialSelection: self.$noise.specialSelection,
                          //isConnectingModulation: self.$noise.modulationBeingAssigned,
                          //isDeletingModulation: self.$noise.modulationBeingDeleted,
                          pattern: self.$noise.modulations[i].pattern,
                          screen: self.$noise.selectedScreen)
                        }
                    }
                }

                //Add Modulation Display Buttons
                /*
                ZStack{
                    Color.white
                    //Rectangle().fill(LinearGradient(Color.darkStart,Color.darkGray))
                    HStack(spacing: 0){
                    ForEach(self.noise.modulations , id: \.id){ mod in
                        Button(action: {
                            self.noise.objectWillChange.send()
                            mod.toggleDisplayed()
                        }){
                            if(mod.isDisplayed){
                                Image(systemName: "m.circle.fill")
                                    .resizable()
                                    .padding(geometry.size.height * 0.01)
                                    .frame(width: geometry.size.height * 0.1,
                                           height: geometry.size.height * 0.1)
                                    //.foregroundColor(mod.modulationColor)
                                    .foregroundColor(Color.black)
                            }
                            else{
                                Image(systemName: "m.circle")
                                    .resizable()
                                    .padding(geometry.size.height * 0.01)
                                    .frame(width: geometry.size.height * 0.1,
                                           height: geometry.size.height * 0.1)
                                    //.foregroundColor(mod.modulationColor)
                                    .foregroundColor(Color.black)
                            }
                        }
                    }
                    Button(action:{
                        print("Let's create a new modulation source!")
                    }){
                        Image(systemName: "plus.circle")
                            .resizable()
                            .padding(geometry.size.height * 0.01)
                            .frame(width: geometry.size.height * 0.1,
                                   height: geometry.size.height * 0.1)
                            .foregroundColor(Color.black)
                    }
                    Spacer()
                    }
                    
                }
                .padding(geometry.size.height * 0.02)
                .border(Color.black, width: geometry.size.height * 0.02)
                .frame(height: geometry.size.height * 0.15)
                */
 
            }
        }
    }
}

struct ModulationSourceView_Previews: PreviewProvider {
    static var previews: some View {
        ModulationSourceView().environmentObject(NoiseModel.shared)
            .previewLayout(.fixed(width: 568, height: 568))
    }
}
