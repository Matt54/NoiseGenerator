import SwiftUI

struct InputDeviceRow: View {
    
    var deviceID: String
    var description: String
    
    var body: some View {
        GeometryReader{ geometry in
        ZStack(alignment: .leading){
            Color.init(red: 0.9, green: 0.9, blue: 0.9)
            ZStack{
                HStack{
                    
                    Image(systemName: "mic.circle.fill")
                        .resizable()
                        .aspectRatio(1.0, contentMode: .fit)
                        .frame(height: geometry.size.height * 0.8)
                        //.padding(.trailing, geometry.size.width * 0.05)
                        .foregroundColor(Color.black)
                    
                    Spacer()
                }
                    
                VStack(alignment: .center, spacing: 0) {
                    Text(self.deviceID)
                        //.font(.headline)
                        .fontWeight(.bold)
                        .textStyle(ShrinkTextStyle())
                        .frame(height: geometry.size.height * 0.4)
                        .foregroundColor(Color.black)
                        //.fontWeight(.bold)
                        .lineLimit(2)
                        .padding(.bottom, geometry.size.height * 0.05)
                    
                    Text(self.description)
                        .textStyle(ShrinkTextStyle())
                        .frame(height: geometry.size.height * 0.25)
                        .foregroundColor(Color.black)
                }
                .frame(height: geometry.size.height * 0.8)
                
                //Spacer()
            }
            .padding(geometry.size.height * 0.1)
        }
        .frame(width: geometry.size.width)
        .clipShape(RoundedRectangle(cornerRadius: geometry.size.height * 0.2))
    }
    }
}

struct InputDeviceRow_Previews: PreviewProvider {
    static var previews: some View {
        InputDeviceRow(deviceID: "Built-In Microphone Bottom",
                       description: "<Device: iPhone Microphone (Built-In Microphone Bottom)>")
        //.previewLayout(.fixed(width: 568, height: 320))
        .previewLayout(.fixed(width: 700, height: 100))
    }
}
