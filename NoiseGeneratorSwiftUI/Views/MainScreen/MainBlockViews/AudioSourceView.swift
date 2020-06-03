import SwiftUI

struct AudioSourceView: View {
    
    @EnvironmentObject var noise: Conductor
    
    var body: some View {
        GeometryReader{ geometry in
            VStack(spacing: 0){
                
                VStack(spacing: 0){
                    ZStack{
                        Rectangle()
                            .fill(LinearGradient(Color.darkStart,Color.darkGray))
                        Text("AUDIO SOURCES")
                            .bold()
                            .textStyle(ShrinkTextStyle())
                            .foregroundColor(Color.white)
                    }
                    .frame(height: geometry.size.height * 0.08)
                    
                    Divider()
                    
                    ZStack{
                        LinearGradient(Color.darkStart,Color.darkGray)
                        HStack(spacing: 0){
                            
                            
                            
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
                                    
                                /*
                                    .onTapGesture(count: 2){
                                        source.isBypassed = !source.isBypassed
                                    }
                                */
                                    .onTapGesture(count: 1) {
                                        self.noise.objectWillChange.send()
                                        //let current = source.isDisplayed
                                        self.noise.hideSources()
                                        source.isDisplayed = true//!current
                                    }
                                    
                                
                                    .onLongPressGesture(minimumDuration: 0.1) {
                                        //print("Long Press")
                                        //source.isBypassed = !source.isBypassed
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
                        
                    }
                }
                .padding(geometry.size.height * 0.00)
                .border(Color.black, width: geometry.size.height * 0.00)
                .frame(height: geometry.size.height * 0.22)

                VStack(spacing: 0){
                    
                    ForEach(self.noise.oscillatorControlSources.indices, id: \.self){ i in
                        VStack(spacing: 0){
                            if(self.noise.oscillatorControlSources[i].isDisplayed){
                                MorphingOscillatorView(morphingOscillator: self.$noise.oscillatorControlSources[i])
                            }
                        }
                    }
                    
                    
                    ForEach(self.noise.FMOscillatorControlSources.indices, id: \.self){ i in
                        VStack(spacing: 0){
                            if(self.noise.FMOscillatorControlSources[i].isDisplayed){
                                FMOscillatorView(morphingOscillator: self.$noise.FMOscillatorControlSources[i])
                            }
                        }
                    }
                    
                    
                    ForEach(self.noise.basicSourceControllers.indices, id: \.self){ i in
                        VStack(spacing: 0){
                            if(self.noise.basicSourceControllers[i].isDisplayed){
                                BasicSourceView(adsrAudioSource: self.$noise.basicSourceControllers[i])
                            }
                        }
                    }
                    
                    ForEach(self.noise.noiseControlSources.indices, id: \.self){ i in
                        VStack(spacing: 0){
                            if(self.noise.noiseControlSources[i].isDisplayed){
                                NoiseGenerator(noiseSource: self.$noise.noiseControlSources[i])
                            }
                        }
                    }
                    
                    ForEach(self.noise.microphoneSources.indices, id: \.self){ i in
                        VStack(spacing: 0){
                            if(self.noise.microphoneSources[i].isDisplayed){
                                ExternalSourceView(microphoneSource: self.$noise.microphoneSources[i])
                            }
                        }
                    }
                    
                }
            }
            .padding(geometry.size.height * 0.0)
            .border(Color.black, width: geometry.size.height * 0.0)
        }
    }
}

struct AudioSourceView_Previews: PreviewProvider {
    static var previews: some View {
        AudioSourceView().environmentObject(Conductor.shared)
        //.previewLayout(.fixed(width: 568, height: 320))
        .previewLayout(.fixed(width: 568, height: 568))
    }
}
