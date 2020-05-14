import SwiftUI

struct AudioSourceView: View {
    
    @EnvironmentObject var noise: NoiseModel
    
    var body: some View {
        GeometryReader{ geometry in
        VStack(spacing: 0){
            
            ZStack{
                Rectangle()
                .fill(LinearGradient(Color.darkStart,Color.darkGray))
                    Text("AUDIO SOURCES")
                        .bold()
                        .textStyle(ShrinkTextStyle())
                        .foregroundColor(Color.white)
            }
            .padding(geometry.size.height * 0.02)
            .border(Color.black, width: geometry.size.height * 0.02)
            .frame(height: geometry.size.height * 0.1)
            
        
            VStack(spacing: 0){
                ForEach(self.noise.noiseControlSources.indices, id: \.self){ i in
                    VStack(spacing: 0){
                        if(self.noise.noiseControlSources[i].isDisplayed){
                            NoiseGenerator(whiteVal: self.$noise.noiseControlSources[i].whiteVal,
                                       pinkVal: self.$noise.noiseControlSources[i].pinkVal,
                                       brownVal: self.$noise.noiseControlSources[i].brownVal,
                                       volumeControl: self.$noise.noiseControlSources[i].outputVolume,
                                       amplitude: self.$noise.noiseControlSources[i].outputAmplitude,
                                       isBypassed: self.$noise.noiseControlSources[i].isBypassed)
                        }
                    }
                }
                
                ForEach(self.noise.microphoneSources.indices, id: \.self){ i in
                    VStack(spacing: 0){
                        if(self.noise.microphoneSources[i].isDisplayed){
                            ExternalSourceView(volumeControl: self.$noise.microphoneSources[i].outputVolume,
                                       amplitude: self.$noise.microphoneSources[i].outputAmplitude,
                                       isBypassed: self.$noise.microphoneSources[i].isBypassed,
                                       title: self.$noise.microphoneSources[i].name)
                        }
                    }
                }
            }
            /*
            .frame(width: geometry.size.width,
                   height: geometry.size.height * 0.85)
            */

            
            
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
