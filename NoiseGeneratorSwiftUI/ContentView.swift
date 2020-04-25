import SwiftUI
import Combine

struct ContentView: View {
    @EnvironmentObject var noise: NoiseModel
    
    //@State var addEffectPopup = false
    
    var body: some View {
        ZStack{
        VStack{
            VStack {
                HStack {
                    Button(action: noise.toggleSound) {
                        if(noise.isPlaying){
                            Image(systemName: "stop.circle")
                                .font(.system(size: 26))
                        }
                        else{
                            Image(systemName: "play.circle")
                                .font(.system(size: 26))
                        }
                        Spacer()
                    }
                }
            }
            HStack {
                Spacer()
                TriangleDrag(lVal: $noise.whiteVal,
                            tVal: $noise.pinkVal,
                            rVal: $noise.brownVal)
                    .frame(width:250, height: 250)
                Spacer()
            }
            
            
            // Add All Two Knob Effect Controls
            ForEach(noise.twoControlEffects.indices, id: \.self){ i in
                VStack{
                    if(self.noise.twoControlEffects[i].isDisplayed){
                    Spacer()
                    TwoControlTemplate(title: self.noise.twoControlEffects[i].name,
                      isBypassed: self.$noise.twoControlEffects[i].isBypassed,
                      knobModel1: self.$noise.twoControlEffects[i].control1,
                      knobModel2: self.$noise.twoControlEffects[i].control2)
                        .frame(width: 280, height: 180)
                    }
                }
            }

            
            // Add All Four Knob Effect Controls
            ForEach(noise.fourControlEffects.indices, id: \.self){ i in
                VStack{
                if(self.noise.fourControlEffects[i].isDisplayed){
                    Spacer()
                    FourControlTemplate(title: self.noise.fourControlEffects[i].name,
                      isBypassed: self.$noise.fourControlEffects[i].isBypassed,
                      knobModel1: self.$noise.fourControlEffects[i].control1,
                      knobModel2: self.$noise.fourControlEffects[i].control2,
                      knobModel3: self.$noise.fourControlEffects[i].control3,
                      knobModel4: self.$noise.fourControlEffects[i].control4)
                        .frame(width: 400, height: 180)
                }
                }
            }
            
            // Add All One Knob With Presets Effect Controls
            ForEach(noise.oneControlWithPresetsEffects.indices, id: \.self){ i in
                VStack{
                if(self.noise.oneControlWithPresetsEffects[i].isDisplayed){
                    Spacer()
                    PresetPicker(title: self.noise.oneControlWithPresetsEffects[i].name,
                    isBypassed: self.$noise.oneControlWithPresetsEffects[i].isBypassed,
                    presetIndex: self.$noise.oneControlWithPresetsEffects[i].presetIndex,
                    knobModel: self.$noise.oneControlWithPresetsEffects[i].control1,
                    presets: self.$noise.oneControlWithPresetsEffects[i].presets)
                        .frame(width: 280, height: 220)
                }
                }
            }
            
            // Add All Modulations
            ForEach(noise.modulations.indices, id: \.self){ i in
                VStack{
                    if(self.noise.modulations[i].isDisplayed){
                    Spacer()
                    ModulationView(title: self.noise.modulations[i].name,
                      isBypassed: self.$noise.modulations[i].isBypassed,
                      knobModel1: self.$noise.modulations[i].timingControl)
                        .frame(width: 280, height: 180)
                    }
                }
            }
            
            
            Spacer()
            Spacer()
            
            // Bottom Display Toggle Buttons
            HStack {
                
                Spacer()
                
                ForEach(noise.modulations , id: \.id){ mod in
                    Button(action: {
                        self.noise.objectWillChange.send()
                        mod.toggleDisplayed()
                    }){
                        if(mod.isDisplayed){
                            Image(systemName: "m.circle.fill")
                                .font(.system(size: 26))
                        }
                        else{
                            Image(systemName: "m.circle")
                                .font(.system(size: 26))
                        }
                    }
                }
                
                Spacer()
                
                Button(action:{self.noise.addingEffects = true}){
                    Image(systemName: "plus.circle")
                        .font(.system(size: 26))
                }
                
                /*
                ForEach(noise.allControlEffects.indices) { i in
                Button(action: {
                    self.noise.objectWillChange.send()
                    self.noise.allControlEffects[i].toggleDisplayed()
                }){
                    if(self.noise.allControlEffects[i].isDisplayed){
                        self.noise.allControlEffects[i].displayOnImage
                            .font(.system(size: 26))
                    }
                    else{
                        self.noise.allControlEffects[i].displayOffImage
                            .font(.system(size: 26))
                    }
                }
                }
                */
                
                ForEach(noise.allControlEffects , id: \.id){ effect in
                    Button(action: {
                        self.noise.objectWillChange.send()
                        effect.toggleDisplayed()
                    }){
                        if(effect.isDisplayed){
                            effect.displayOnImage
                                .font(.system(size: 26))
                        }
                        else{
                            effect.displayOffImage
                                .font(.system(size: 26))
                        }
                    }
                }
                
                Spacer()
                
            }
            
        }
        .padding(.leading,30)
        .padding(.trailing,30)
        .padding(.bottom,10)
            
            if(noise.addingEffects){
                AddEffectForm(noise: _noise)
            }
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(NoiseModel.shared)
    }
}
