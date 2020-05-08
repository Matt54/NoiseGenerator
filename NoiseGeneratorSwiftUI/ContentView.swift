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
                                   height: geometry.size.width * 0.3 * (180/210))
                        
                        ModulationSourceView()
                            .frame(width:geometry.size.width * 0.3,
                                   height: geometry.size.width * 0.3 * (180/280))
                        
                        //Master Volume Control
                        VolumeControl(volume: self.$noise.outputAmplitude,
                                      amplitudeControl: self.$noise.masterAmplitude,
                                      isRightHanded: .constant(true),
                                      numberOfRects: .constant(20))
                            .frame(width:geometry.size.width * 0.03,
                                   height: geometry.size.height * 0.5)
                        
                    }
                
                    /*
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
                    
                    
                    */
                }
                //.padding(.leading,30)
                //.padding(.trailing,30)
                //.padding(.bottom,10)
                

                // OVERLAYED SCREENS GO HERE
                if(self.noise.addingEffects){
                    //AddEffectForm(noise: _noise)
                    AddEffectForm()
                        .animation(.easeInOut(duration: 0.5))
                }
                
                /*
                PatternGraph(pattern: self.$noise.modulations[0].pattern)
                    .frame(width:200, height: 200)
                    .border(Color.black, width: 2)
                    .padding(50)
                */
            
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
