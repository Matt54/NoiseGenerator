import SwiftUI

struct ModulationSourceView: View {
    
    @EnvironmentObject var noise: NoiseModel
    
    var body: some View {
        GeometryReader{ geometry in
        VStack{
        
        // Add All Modulations
        ForEach(self.noise.modulations.indices, id: \.self){ i in
            VStack(spacing: 0){
                if(self.noise.modulations[i].isDisplayed){
                ModulationView(title: self.noise.modulations[i].name,
                  isBypassed: self.$noise.modulations[i].isBypassed,
                  knobModel1: self.$noise.modulations[i].timingControl,
                  knobModColor: self.noise.knobModColor,
                  isConnectingModulation: self.$noise.modulationBeingAssigned,
                  isDeletingModulation: self.$noise.modulationBeingDeleted,
                  pattern: self.$noise.modulations[i].pattern)
                }
            }
        }
            
            
            HStack{
                ForEach(self.noise.modulations , id: \.id){ mod in
                    Button(action: {
                        self.noise.objectWillChange.send()
                        mod.toggleDisplayed()
                    }){
                        if(mod.isDisplayed){
                            Image(systemName: "m.circle.fill")
                                .resizable()
                                .frame(width: geometry.size.height * 0.1,
                                       height: geometry.size.height * 0.1)
                                .foregroundColor(mod.modulationColor)
                            
                        }
                        else{
                            Image(systemName: "m.circle")
                                .resizable()
                                .frame(width: geometry.size.height * 0.1,
                                       height: geometry.size.height * 0.1)
                                .foregroundColor(mod.modulationColor)
                        }
                    }
                }
                Button(action:{
                    print("Let's create a new modulation source!")
                }){
                    Image(systemName: "plus.circle")
                        .resizable()
                        .frame(width: geometry.size.height * 0.1,
                               height: geometry.size.height * 0.1)
                        .foregroundColor(Color.black)
                }
                Spacer()
            }
            .frame(height: geometry.size.height * 0.2)
            }
        }
    }
}

struct ModulationSourceView_Previews: PreviewProvider {
    static var previews: some View {
        ModulationSourceView().environmentObject(NoiseModel.shared)
    }
}
