import SwiftUI

struct AddInputDeviceForm: View {
    
    @EnvironmentObject var noise: NoiseModel
    
    var body: some View {
        GeometryReader{ geometry in
        VStack(spacing: 0){
            ZStack{
                HStack{
                    
                    Button(action: {
                        print("cancel pressed")
                        self.noise.selectedScreen = SelectedScreen.main
                        
                    })
                    {
                        Text("Cancel")
                        .textStyle(ShrinkTextStyle())
                        .frame(width: geometry.size.width * 0.15,
                        height: geometry.size.height * 0.1,
                        alignment: .leading)
                    }
                    Spacer()
                }
                .padding(.leading, geometry.size.width * 0.015)
                
                Text("Add Audio Input")
                    .fontWeight(.bold)
                    .textStyle(ShrinkTextStyle())
                    .frame(width: geometry.size.width * 0.3,
                           height: geometry.size.height * 0.1)
            }
            .frame(width: geometry.size.width,
                   height: geometry.size.height * 0.1)
            
        ScrollView {
            VStack(spacing: geometry.size.height * 0.05){
                ForEach(self.noise.availableInputSources , id: \.id){ i in
                    Button(action: {
                        print("You pressed: " + String(i.id))
                        self.noise.selectedScreen = SelectedScreen.main
                        self.noise.createMicrophoneInput(id: i.id)
                    })
                    {
                        InputDeviceRow(deviceID: i.device.deviceID,
                                       description: i.device.description)
                                        .frame(height: geometry.size.height * 0.25)
                    }
                    .padding(.horizontal, geometry.size.width * 0.01)
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.top)
        .background(Color.white)
        }
    }
}

struct AddInputDeviceForm_Previews: PreviewProvider {
    static var previews: some View {
        AddInputDeviceForm().environmentObject(NoiseModel.shared)
        .previewLayout(.fixed(width: 568, height: 320))
    }
}
