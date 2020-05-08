import SwiftUI
import Combine

struct ContentView: View {
    @EnvironmentObject var noise: NoiseModel
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var body: some View {
        GeometryReader{ geometryOuter in
        GeometryReader{ geometry in
            ZStack{
                VStack{
                    HStack(spacing:0){
                        
                        // Noise Generator
                        NoiseGenerator(whiteVal: self.$noise.whiteVal,
                                       pinkVal: self.$noise.pinkVal,
                                       brownVal: self.$noise.brownVal,
                                       volumeControl: self.$noise.noiseVolume,
                                       amplitude: self.$noise.noiseAmplitude,
                                       isBypassed: self.$noise.isNoiseBypassed)
                            .frame(width:geometry.size.width * 0.3,
                                   height: geometry.size.width * 0.3 * (250/280))
                            .padding()

                    
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
                                        .frame(width:geometry.size.width * 0.3,
                                               height: geometry.size.width * 0.3 * (180/280))
                                }
                            }
                            .padding()
                        }
                    
                        // Add All Four Knob Effect Controls
                        ForEach(self.noise.fourControlEffects.indices, id: \.self){ i in
                            VStack{
                                if(self.noise.fourControlEffects[i].isDisplayed){
                                    Spacer()
                                    FourControlTemplate(title: self.noise.fourControlEffects[i].name,
                                      isBypassed: self.$noise.fourControlEffects[i].isBypassed,
                                      knobModel1: self.$noise.fourControlEffects[i].control1,
                                      knobModel2: self.$noise.fourControlEffects[i].control2,
                                      knobModel3: self.$noise.fourControlEffects[i].control3,
                                      knobModel4: self.$noise.fourControlEffects[i].control4,
                                      knobModColor: self.$noise.knobModColor,
                                      modulationBeingAssigned: self.$noise.modulationBeingAssigned)
                                        .frame(width: 400, height: 180)
                                }
                            }
                        }
                    
                        // Add All One Knob With Presets Effect Controls
                        ForEach(self.noise.oneControlWithPresetsEffects.indices, id: \.self){ i in
                            VStack{
                                if(self.noise.oneControlWithPresetsEffects[i].isDisplayed){
                                    Spacer()
                                    PresetPicker(title: self.noise.oneControlWithPresetsEffects[i].name,
                                    isBypassed: self.$noise.oneControlWithPresetsEffects[i].isBypassed,
                                    presetIndex: self.$noise.oneControlWithPresetsEffects[i].presetIndex,
                                    knobModel: self.$noise.oneControlWithPresetsEffects[i].control1,
                                    presets: self.$noise.oneControlWithPresetsEffects[i].presets,
                                    knobModColor: self.$noise.knobModColor,
                                    modulationBeingAssigned: self.$noise.modulationBeingAssigned)
                                        .frame(width: 280, height: 220)
                                }
                            }
                        }
                        
                        /*
                        PatternGraph(pattern: self.$noise.modulations[0].pattern)
                            .frame(width:200, height: 200)
                            .border(Color.black, width: 2)
                            .padding(50)
                        */
                    
                        // Add All Modulations
                        ForEach(self.noise.modulations.indices, id: \.self){ i in
                            VStack{
                                if(self.noise.modulations[i].isDisplayed){
                                ModulationView(title: self.noise.modulations[i].name,
                                  isBypassed: self.$noise.modulations[i].isBypassed,
                                  knobModel1: self.$noise.modulations[i].timingControl,
                                  knobModColor: self.noise.knobModColor,
                                  isConnectingModulation: self.$noise.modulationBeingAssigned,
                                  isDeletingModulation: self.$noise.modulationBeingDeleted,
                                  pattern: self.$noise.modulations[i].pattern)
                                    .frame(width:geometry.size.width * 0.3,
                                           height: geometry.size.width * 0.3 * (180/280))
                                }
                            }
                        }
                        
                        //Master Volume Control
                        VolumeControl(volume: self.$noise.outputAmplitude,
                                      amplitudeControl: self.$noise.masterAmplitude,
                                      isRightHanded: .constant(true),
                                      numberOfRects: .constant(20))
                            .frame(width:geometry.size.width * 0.03,
                                   height: geometry.size.height * 0.5)
                        
                    }
                
                    // Bottom Display Toggle Buttons
                    HStack {
                        
                        Spacer()
                        
                        ForEach(self.noise.modulations , id: \.id){ mod in
                            Button(action: {
                                self.noise.objectWillChange.send()
                                mod.toggleDisplayed()
                            }){
                                if(mod.isDisplayed){
                                    Image(systemName: "m.circle.fill")
                                        .foregroundColor(mod.modulationColor)
                                        .font(.system(size: 26))
                                    
                                }
                                else{
                                    Image(systemName: "m.circle")
                                        .foregroundColor(mod.modulationColor)
                                        .font(.system(size: 26))
                                }
                            }
                        }
                        
                        Spacer()
                        
                        
                        ForEach(self.noise.allControlEffects , id: \.id){ effect in
                            effect.displayImage
                                .font(.system(size: 26))
                                .onTapGesture(count: 1) {
                                    self.noise.objectWillChange.send()
                                    effect.toggleDisplayed()
                                }
                                .onLongPressGesture(minimumDuration: 0.5) {
                                    print("Long Press")
                                }
                        }
                        Button(action:{
                            self.noise.addingEffects = true
                        }){
                            Image(systemName: "plus.circle")
                                .font(.system(size: 26))
                                .foregroundColor(Color.black)
                        }
                        Spacer()
                    }
                    .frame(height: geometry.size.height * 0.2)
                    
                    
                    
                }
                .padding(.leading,30)
                .padding(.trailing,30)
                .padding(.bottom,10)
                

                // OVERLAYED SCREENS GO HERE
                if(self.noise.addingEffects){
                    //AddEffectForm(noise: _noise)
                    AddEffectForm()
                        .animation(.easeInOut(duration: 0.5))
                }
            
            }
        }
            .padding(geometryOuter.size.height * 0.08)
            .border(Color.BlackWhiteColor(for: self.colorScheme), width: geometryOuter.size.height * 0.08)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(NoiseModel.shared)
        //.previewLayout(.fixed(width: 568, height: 320))
        .previewLayout(.fixed(width: 2688, height: 1242))
    }
}
