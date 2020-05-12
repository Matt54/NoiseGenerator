import SwiftUI

struct AudioEffectView: View {
    
    @EnvironmentObject var noise: NoiseModel
    
    var body: some View {
        GeometryReader{ geometry in
        VStack(spacing: 0){
            
            
            ZStack{
                Rectangle()
                .fill(LinearGradient(Color.darkStart,Color.darkGray))
                    Text("AUDIO EFFECTS")
                        .bold()
                        .textStyle(ShrinkTextStyle())
                        .foregroundColor(Color.white)
            }
            .padding(geometry.size.height * 0.02)
            .border(Color.black, width: geometry.size.height * 0.02)
            .frame(height: geometry.size.height * 0.15)
            
            
            // Add All Two Knob Effect Controls
            ForEach(self.noise.twoControlEffects.indices, id: \.self){ i in
                VStack(spacing: 0){
                    if(self.noise.twoControlEffects[i].isDisplayed){
                        TwoControlTemplate(title: self.noise.twoControlEffects[i].name,
                                           isBypassed: self.$noise.twoControlEffects[i].isBypassed,
                                           knobModel1: self.$noise.twoControlEffects[i].control1,
                                           knobModel2: self.$noise.twoControlEffects[i].control2,
                                           knobModColor: self.$noise.knobModColor,
                                           modulationBeingAssigned: self.$noise.modulationBeingAssigned,
                                           modulationBeingDeleted: self.$noise.modulationBeingDeleted,
                                           inputAmplitude: self.$noise.twoControlEffects[i].inputAmplitude,
                                           inputVolume: self.$noise.twoControlEffects[i].inputVolume,
                                           outputAmplitude: self.$noise.twoControlEffects[i].outputAmplitude,
                                           outputVolume: self.$noise.twoControlEffects[i].outputVolume)
                            //.frame(width:geometry.size.width * 0.3,height: geometry.size.width * 0.3 * (180/280))
                    }
                }
                //.padding()
            }
        
            // Add All Four Knob Effect Controls
            ForEach(self.noise.fourControlEffects.indices, id: \.self){ i in
                VStack(spacing: 0){
                    if(self.noise.fourControlEffects[i].isDisplayed){
                        //Spacer()
                        FourControlTemplate(title: self.noise.fourControlEffects[i].name,
                          isBypassed: self.$noise.fourControlEffects[i].isBypassed,
                          knobModel1: self.$noise.fourControlEffects[i].control1,
                          knobModel2: self.$noise.fourControlEffects[i].control2,
                          knobModel3: self.$noise.fourControlEffects[i].control3,
                          knobModel4: self.$noise.fourControlEffects[i].control4,
                          knobModColor: self.$noise.knobModColor,
                          modulationBeingAssigned: self.$noise.modulationBeingAssigned)
                            //.frame(width: 400, height: 180)
                    }
                }
            }
        
            // Add All One Knob With Presets Effect Controls
            ForEach(self.noise.oneControlWithPresetsEffects.indices, id: \.self){ i in
                VStack(spacing: 0){
                    if(self.noise.oneControlWithPresetsEffects[i].isDisplayed){
                        //Spacer()
                        PresetPicker(title: self.noise.oneControlWithPresetsEffects[i].name,
                        isBypassed: self.$noise.oneControlWithPresetsEffects[i].isBypassed,
                        presetIndex: self.$noise.oneControlWithPresetsEffects[i].presetIndex,
                        knobModel: self.$noise.oneControlWithPresetsEffects[i].control1,
                        presets: self.$noise.oneControlWithPresetsEffects[i].presets,
                        knobModColor: self.$noise.knobModColor,
                        modulationBeingAssigned: self.$noise.modulationBeingAssigned)
                            //.frame(width: 280, height: 220)
                    }
                }
            }
            
            
            
            ZStack{
                Color.white
                //Rectangle().fill(LinearGradient(Color.darkStart,Color.darkGray))
                HStack(spacing: 0){
                ForEach(self.noise.allControlEffects , id: \.id){ effect in
                        effect.displayImage
                            .resizable()
                            .padding(geometry.size.height * 0.01)
                            .frame(width: geometry.size.height * 0.1,
                                   height: geometry.size.height * 0.1)
                            
                            .onTapGesture(count: 1) {
                                self.noise.objectWillChange.send()
                                //effect.toggleDisplayed()
                                let current = effect.isDisplayed
                                self.noise.hideEffects()
                                effect.isDisplayed = !current
                            }
                            .onLongPressGesture(minimumDuration: 0.5) {
                                print("Long Press")
                            }
                    }
                    Button(action:{
                        self.noise.selectedScreen = SelectedScreen.addEffect
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
            
            }
        }
    }
}

struct AudioEffectView_Previews: PreviewProvider {
    static var previews: some View {
        AudioEffectView().environmentObject(NoiseModel.shared)
    }
}
