import SwiftUI
import Combine

//import AudioKit
//import AudioKitUI
import CoreAudioKit

struct ContentView: View {
    @EnvironmentObject var noise: NoiseModel
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var body: some View {
        GeometryReader{ geometryOuter in
            
        HStack(spacing: 0){
            
            Rectangle()
            .frame(width: geometryOuter.size.height * 0.08)
            
            VStack(spacing: 0){
                    
                
            
        GeometryReader{ geometry in
            ZStack{
                
                Color(red: 0.2, green: 0.2, blue: 0.2, opacity: 0.01)
                    .onTapGesture {
                        UIApplication.shared.endEditing()
                    }
                
                VStack(spacing: 0){
                    
                    MainHeader()
                    .frame(height: geometry.size.height * 0.1)

                    HStack(spacing: geometry.size.width * 0){
                        
                        AudioSourceView()
                            .frame(width:geometry.size.width * (1/3),
                                   height: geometry.size.height * 0.6)
                        
                        AudioEffectView()
                            .frame(width:geometry.size.width * (1/3),
                                   height: geometry.size.height * 0.6)
                        
                        ModulationSourceView()
                            .frame(width:geometry.size.width * (1/3),
                                   height: geometry.size.height * 0.6)
                        
                    }
                    
                    KeyBoard()
                        .frame(width: geometry.size.width,
                               height: geometry.size.height * 0.3)
                    /*
                    HStack(spacing: geometry.size.width * 0){
                        Color.blue
                    }
                    */
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
                
                if(self.noise.selectedScreen == .bluetoothMIDI){
                    BluetoothMidiView()
                }
                
            }
        }
            Rectangle()
                .frame(height: geometryOuter.size.height * 0.05)
        }
            Rectangle()
            .frame(width: geometryOuter.size.height * 0.1)
        }
            
        //.padding(geometryOuter.size.height * 0.08)
        //.border(Color.black, width: geometryOuter.size.height * 0.08)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(NoiseModel.shared)
        .previewLayout(.fixed(width: 568, height: 320)) //This one looks like a phone
        //.previewLayout(.fixed(width: 2688, height: 1242))
    }
}

/*
struct BluetoothMIDIPopup: UIViewControllerRepresentable {
    typealias UIViewControllerType = AKBTMIDICentralViewController
    
    func makeUIViewController(context: Context) -> AKBTMIDICentralViewController {
        let view = AKBTMIDICentralViewController()
        return view
    }
    
    func updateUIViewController(_ uiViewController: AKBTMIDICentralViewController, context: Context) {
    }
}

class AKBTMIDICentralViewController: CABTMIDICentralViewController {
    var uiViewController: UIViewController?

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                            target: self,
                                                            action: #selector(doneAction))
    }

    @objc public func doneAction() {
        uiViewController?.dismiss(animated: true, completion: nil)
    }
}
*/
