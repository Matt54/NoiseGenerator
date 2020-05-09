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
                    HStack(spacing: geometry.size.width * 0.01){
                        
                        AudioSourceView()
                            .frame(width:geometry.size.width * 0.3,
                                   height: geometry.size.width * 0.3 * (250/280))
                        
                        AudioEffectView()
                            .frame(width:geometry.size.width * 0.3,
                                   height: geometry.size.width * 0.3 * (250/280))
                        
                        ModulationSourceView()
                            .frame(width:geometry.size.width * 0.3,
                                   height: geometry.size.width * 0.3 * (250/280))
                        
                        //Master Volume Control
                        VolumeControl(volume: self.$noise.outputAmplitude,
                                      amplitudeControl: self.$noise.masterAmplitude,
                                      isRightHanded: .constant(true),
                                      numberOfRects: .constant(20))
                            .frame(width:geometry.size.width * 0.03,
                                   height: geometry.size.height * 0.5)
                        
                    }
                }

                // OVERLAYED SCREENS GO HERE
                if(self.noise.selectedScreen == .addEffect){
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
        .previewLayout(.fixed(width: 568, height: 320))
        //.previewLayout(.fixed(width: 2688, height: 1242))
    }
}
