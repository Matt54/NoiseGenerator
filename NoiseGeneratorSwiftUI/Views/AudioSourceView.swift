import SwiftUI

struct AudioSourceView: View {
    
    @EnvironmentObject var noise: NoiseModel
    
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
                            source.displayImage
                                .resizable()
                                .padding(geometry.size.height * 0.01)
                                .frame(width: geometry.size.height * 0.1,
                                       height: geometry.size.height * 0.1)
                                .foregroundColor(Color.white)
                                
                                .onTapGesture(count: 1) {
                                    self.noise.objectWillChange.send()
                                    let current = source.isDisplayed
                                    self.noise.hideSources()
                                    source.isDisplayed = !current
                                }
                                .onLongPressGesture(minimumDuration: 0.5) {
                                    print("Long Press")
                                }
                        }
                        
                        Button(action:{
                            print("Let's create a new audio source!")
                            self.noise.selectedScreen = SelectedScreen.addMicrophoneInput
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

            VStack(spacing: 0){
                
                ForEach(self.noise.oscillatorControlSources.indices, id: \.self){ i in
                    VStack(spacing: 0){
                        if(self.noise.oscillatorControlSources[i].isDisplayed){
                            MorphingOscillatorView(morphingOscillator: self.$noise.oscillatorControlSources[i],
                                                   knobModColor: self.$noise.knobModColor,
                                                   specialSelection: self.$noise.specialSelection)
                                                   //modulationBeingAssigned: self.$noise.modulationBeingAssigned,
                                                   //modulationBeingDeleted: self.$noise.modulationBeingDeleted)
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
            /*
            .frame(width: geometry.size.width,
                   height: geometry.size.height * 0.85)
            */
            
            /*
            ZStack{
                Color.white
                HStack(spacing: 0){
                ForEach(self.noise.allControlSources , id: \.id){ source in
                        source.displayImage
                            .resizable()
                            .padding(geometry.size.height * 0.01)
                            .frame(width: geometry.size.height * 0.1,
                                   height: geometry.size.height * 0.1)
                            
                            .onTapGesture(count: 1) {
                                self.noise.objectWillChange.send()
                                let current = source.isDisplayed
                                self.noise.hideSources()
                                source.isDisplayed = !current
                            }
                            .onLongPressGesture(minimumDuration: 0.5) {
                                print("Long Press")
                            }
                    }
                    Button(action:{
                        print("Let's create a new audio source!")
                        self.noise.selectedScreen = SelectedScreen.addMicrophoneInput
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

struct AudioSourceView_Previews: PreviewProvider {
    static var previews: some View {
        AudioSourceView().environmentObject(NoiseModel.shared)
        //.previewLayout(.fixed(width: 568, height: 320))
        .previewLayout(.fixed(width: 568, height: 568))
    }
}
