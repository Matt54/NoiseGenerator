import SwiftUI

struct AudioSourceView: View {
    
    @EnvironmentObject var noise: NoiseModel
    
    var body: some View {
        GeometryReader{ geometry in
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
            
            HStack{
                ForEach(self.noise.allControlSources , id: \.id){ source in
                        source.displayImage
                            .resizable()
                            .frame(width: geometry.size.height * 0.05,
                                   height: geometry.size.height * 0.05)
                            
                            .onTapGesture(count: 1) {
                                self.noise.objectWillChange.send()
                                source.toggleDisplayed()
                            }
                            .onLongPressGesture(minimumDuration: 0.5) {
                                print("Long Press")
                            }
                    }
                    Button(action:{
                        //self.noise.addingEffects = true
                        print("Let's create a new audio source!")
                    }){
                        Image(systemName: "plus.circle")
                            .resizable()
                            .frame(width: geometry.size.height * 0.05,
                                   height: geometry.size.height * 0.05)
                            .foregroundColor(Color.black)
                    }
                    Spacer()
                }
                .frame(height: geometry.size.height * 0.1)
            }
            
        }
    }
}

struct AudioSourceView_Previews: PreviewProvider {
    static var previews: some View {
        AudioSourceView().environmentObject(NoiseModel.shared)
        .previewLayout(.fixed(width: 568, height: 320))
    }
}
