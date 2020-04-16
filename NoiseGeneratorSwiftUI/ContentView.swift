import SwiftUI
import Combine

struct ContentView: View {
    @EnvironmentObject var noise: NoiseModel
    
    var body: some View {
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
            ForEach(noise.twoControlEffects.indices){ i in
                Spacer()
                VStack{
                if(self.noise.twoControlEffects[i].isDisplayed){
                    TwoControlTemplate(title: self.noise.twoControlEffects[i].name,
                      isBypassed: self.$noise.twoControlEffects[i].isBypassed,
                      knobModel1: self.$noise.twoControlEffects[i].control1,
                      knobModel2: self.$noise.twoControlEffects[i].control2)
                        .frame(width: 280, height: 180)
                }
                }
            }
            
            // Add All One Knob With Presets Effect Controls
            ForEach(noise.oneControlWithPresetsEffects.indices){ i in
                Spacer()
                VStack{
                if(self.noise.oneControlWithPresetsEffects[i].isDisplayed){
                    PresetPicker(title: self.noise.oneControlWithPresetsEffects[i].name,
                    isBypassed: self.$noise.oneControlWithPresetsEffects[i].isBypassed,
                    presetIndex: self.$noise.oneControlWithPresetsEffects[i].presetIndex,
                    knobModel: self.$noise.oneControlWithPresetsEffects[i].control1,
                    presets: self.$noise.oneControlWithPresetsEffects[i].presets)
                        .frame(width: 280, height: 220)
                }
                }
            }
            
            Spacer()
            
            // Bottom Display Toggle Buttons
            HStack {
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
            }
            
        }
        .padding(.leading,30)
        .padding(.trailing,30)
        .padding(.bottom,10)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(NoiseModel.shared)
    }
}
