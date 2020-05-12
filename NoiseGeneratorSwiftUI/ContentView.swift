import SwiftUI
import Combine

struct ContentView: View {
    @EnvironmentObject var noise: NoiseModel
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var body: some View {
        GeometryReader{ geometryOuter in
        GeometryReader{ geometry in
            ZStack{
                VStack(spacing: 0){
                    
                    MainHeader()
                    
                    HStack(spacing: geometry.size.width * 0){
                        
                        AudioSourceView()
                            .frame(width:geometry.size.width * (1/3),
                                   height: geometry.size.height * 0.8)
                        
                        AudioEffectView()
                            .frame(width:geometry.size.width * (1/3),
                                   height: geometry.size.height * 0.8)
                        
                        ModulationSourceView()
                            .frame(width:geometry.size.width * (1/3),
                                   height: geometry.size.height * 0.8)
                        
                    }
                    
                    HStack(spacing: geometry.size.width * 0){
                        Color.blue
                    }
                }

                // OVERLAYED SCREENS GO HERE
                if(self.noise.selectedScreen == .addEffect){
                    //AddEffectForm(noise: _noise)
                    AddEffectForm()
                        .animation(.easeInOut(duration: 0.5))
                }
                
                // OVERLAYED SCREENS GO HERE
                if(self.noise.selectedScreen == .addMicrophoneInput){
                    //AddEffectForm(noise: _noise)
                    AddInputDeviceForm()
                        .animation(.easeInOut(duration: 0.5))
                }
                
                if(self.noise.selectedScreen == .adjustPattern){
                    PatternAdjust(pattern: self.$noise.selectedPattern,
                                  screen:  self.$noise.selectedScreen)
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
        .previewLayout(.fixed(width: 568, height: 320))
        //.previewLayout(.fixed(width: 2688, height: 1242))
    }
}
