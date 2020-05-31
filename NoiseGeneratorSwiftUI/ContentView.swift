import SwiftUI
import Combine

//This is the root view controller of the application
struct ContentView: View {
    @EnvironmentObject var noise: Conductor
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var body: some View {
        
        //Reads overall device geometry
        GeometryReader{ geometryOuter in
            
            //Allows for left and right padding
            HStack(spacing: 0){
                
                //Left Padding
                Rectangle().frame(width: geometryOuter.size.width * self.noise.deviceLayout.padLeft)
                
                //Allows for top and bottom padding
                VStack(spacing: 0){
                    
                    //Top Padding
                    Rectangle().frame(height: geometryOuter.size.height * self.noise.deviceLayout.padTop)
            
                    //Reads geometry for Application UI
                    // - without considering padding (or the keyboard adjustment)
                    GeometryReader{ geometry in
                        
                        //Allows for popup screens
                        ZStack{
                
                            // This allows for clickoff event to end editing (dismiss keyboard)
                            Color(red: 0.2, green: 0.2, blue: 0.2, opacity: 0.01)
                                .onTapGesture { UIApplication.shared.endEditing() }
                
                            //UI Build top-down
                            VStack(spacing: 0){
                    
                                MainHeader().frame(height: geometry.size.height * 0.1 - self.noise.deviceLayout.keyboardAdjust * 1/6)
                    
                                MainBlocks().frame(height: geometry.size.height * 0.6 - self.noise.deviceLayout.keyboardAdjust * 5/6)
                        
                                HeaderKeyboard().frame(height: geometry.size.height * 0.075)
                                
                                KeyBoard().frame(height: geometry.size.height * 0.225 + self.noise.deviceLayout.keyboardAdjust)

                            }

                            // ------------------------
                            // OVERLAYED SCREENS GO HERE
                            if(self.noise.selectedScreen == .addEffect){
                                AddEffectForm()
                                    .animation(.easeInOut(duration: 0.5))
                            }
                            else if(self.noise.selectedScreen == .addSource){
                                SourceCategoriesForm()
                                    .animation(.easeInOut(duration: 0.5))
                            }
                            else if(self.noise.selectedScreen == .addInstrument){
                                AddInstrumentForm()
                                    .animation(.easeInOut(duration: 0.5))
                            }
                            else if(self.noise.selectedScreen == .addMicrophoneInput){
                                AddInputDeviceForm()
                                    .animation(.easeInOut(duration: 0.5))
                            }
                            else if(self.noise.selectedScreen == .addOscillator){
                                AddOscillatorForm()
                                    .animation(.easeInOut(duration: 0.5))
                            }
                            else if(self.noise.selectedScreen == .adjustPattern){
                                PatternAdjust(pattern: self.$noise.selectedPattern,
                                              screen:  self.$noise.selectedScreen)
                            }
                            else if(self.noise.selectedScreen == .bluetoothMIDI){
                                BluetoothMidiView()
                            }
                            // ------------------------
                            
                        }//ZStack
                        
                    }//application UI geometry proxy
                    
                    //Bottom padding
                    Rectangle().frame(height: geometryOuter.size.height * self.noise.deviceLayout.padBottom)
                    
                }//padding vbox
                
                //Right padding
                Rectangle().frame(width: geometryOuter.size.width * self.noise.deviceLayout.padRight)
                
            }//padding hbox
            
        }//outer geometry proxy
        .edgesIgnoringSafeArea(.all)
    
    }//body

}//struct

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(Conductor.shared)
        .previewLayout(.fixed(width: 812, height: 375)) //Landscape iPhone XS
        //.previewLayout(.fixed(width: 2688, height: 1242))
    }
}
