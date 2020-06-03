import SwiftUI

struct AudioEffectView: View {
    
    @EnvironmentObject var noise: Conductor
    
    var body: some View {
        GeometryReader{ geometry in
        VStack(spacing: 0){
            
            /*
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
            .frame(height: geometry.size.height * 0.1)*/
            
            VStack(spacing: 0){
                
                ZStack{
                    Rectangle()
                        .fill(LinearGradient(Color.darkStart,Color.darkGray))
                    Text("AUDIO EFFECTS")
                        .bold()
                        .textStyle(ShrinkTextStyle())
                        .foregroundColor(Color.white)
                }
                .frame(height: geometry.size.height * 0.08)
                
                Divider()
                
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
            }
            .frame(height: geometry.size.height * 0.22)
            
            /*
            ForEach(self.noise.allControlSources , id: \.id){ source in
                VStack{
                    if(source.isDisplayed){
                        source.displayImage
                            .resizable()
                            .padding(geometry.size.height * 0.02)
                            .foregroundColor(Color.yellow)
                    }
                    else{
                        source.displayImage
                            .resizable()
                            .padding(geometry.size.height * 0.025)
                            .foregroundColor(Color.white)
                    }
                }
                        .frame(width: geometry.size.height * 0.14,
                               height: geometry.size.height * 0.14)
                        .onTapGesture(count: 1) {
                            self.noise.objectWillChange.send()
                            //let current = source.isDisplayed
                            self.noise.hideSources()
                            source.isDisplayed = true//!current
                        }
                }
                
                Button(action:{
                    print("Let's create a new audio source!")
                    self.noise.selectedScreen = SelectedScreen.addSource //SelectedScreen.addMicrophoneInput
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
            */
            
            // Add All Two Knob Effect Controls
            ForEach(self.noise.twoControlEffects.indices, id: \.self){ i in
                VStack(spacing: 0){
                    if(self.noise.twoControlEffects[i].isDisplayed){
                        TwoControlTemplate(twoControlAudioEffect: self.$noise.twoControlEffects[i],
                                           knobModColor: self.$noise.knobModColor,
                                           specialSelection: self.$noise.specialSelection)
                                           //modulationBeingAssigned: self.$noise.modulationBeingAssigned,
                                           //modulationBeingDeleted: self.$noise.modulationBeingDeleted)
                    }
                }
            }
        
            // Add All Four Knob Effect Controls
            ForEach(self.noise.fourControlEffects.indices, id: \.self){ i in
                VStack(spacing: 0){
                    if(self.noise.fourControlEffects[i].isDisplayed){
                        FourControlTemplate(fourControlEffect: self.$noise.fourControlEffects[i],
                                            knobModColor: self.$noise.knobModColor,
                                            specialSelection: self.$noise.specialSelection)
                                            //modulationBeingAssigned: self.$noise.modulationBeingAssigned)
                    }
                }
            }
        
            // Add All One Knob With Presets Effect Controls
            ForEach(self.noise.oneControlWithPresetsEffects.indices, id: \.self){ i in
                VStack(spacing: 0){
                    if(self.noise.oneControlWithPresetsEffects[i].isDisplayed){
                        PresetPicker(oneControlEffect: self.$noise.oneControlWithPresetsEffects[i],
                                     knobModColor: self.$noise.knobModColor,
                                     specialSelection: self.$noise.specialSelection)
                                    // modulationBeingAssigned: self.$noise.modulationBeingAssigned)
                    }
                }
            }
            
            
            /*
            ZStack{
                Color.white
                //Rectangle().fill(LinearGradient(Color.darkStart,Color.darkGray))
                HStack(spacing: 0){
                ForEach(self.noise.allControlEffects , id: \.id){ effect in
                        effect.displayImage
                            .resizable()
                            .padding(geometry.size.height * 0.01)
                            .aspectRatio(1.0, contentMode: .fit)
                            .frame(height: geometry.size.height * 0.1)
                            
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
                            .aspectRatio(1.0, contentMode: .fit)
                            .frame(height: geometry.size.height * 0.1)
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
            .padding(geometry.size.height * 0.0)
            .border(Color.black, width: geometry.size.height * 0.0)
        }
    }
}

struct AudioEffectView_Previews: PreviewProvider {
    static var previews: some View {
        AudioEffectView().environmentObject(Conductor.shared)
        .previewLayout(.fixed(width: 568, height: 568))
    }
}
