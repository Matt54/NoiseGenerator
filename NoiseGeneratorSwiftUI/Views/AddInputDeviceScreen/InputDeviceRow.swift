import SwiftUI

struct InputDeviceRow: View {
    
    var deviceID: String
    var description: String
    
    var body: some View {
        GeometryReader{ geometry in
        ZStack(alignment: .leading){
            Color.init(red: 0.9, green: 0.9, blue: 0.9)
            HStack{
                Image(systemName: "mic.circle.fill")
                    .resizable()
                    .frame(width: geometry.size.height * 0.8,
                           height: geometry.size.height * 0.8,
                           alignment: .center)
                    .padding(.trailing, geometry.size.height * 0.1)
                    .foregroundColor(Color.black)
                    
                VStack(alignment: .center, spacing: 0) {
                    Text(self.deviceID)
                        //.font(.headline)
                        .fontWeight(.bold)
                        .textStyle(ShrinkTextStyle())
                        .frame(height: geometry.size.height * 0.3)
                        .foregroundColor(Color.black)
                        //.fontWeight(.bold)
                        .lineLimit(2)
                        .padding(.bottom, geometry.size.height * 0.05)
                    
                    Text(self.description)
                        .textStyle(ShrinkTextStyle())
                        .frame(height: geometry.size.height * 0.2)
                        .foregroundColor(Color.black)
                }
                .padding(.horizontal, geometry.size.height * 0.1)
            }
            .padding(geometry.size.height * 0.1)
        }
        .clipShape(RoundedRectangle(cornerRadius: geometry.size.height * 0.2))
    }
    }
}

struct InputDeviceRow_Previews: PreviewProvider {
    static var previews: some View {
        InputDeviceRow(deviceID: "Built-In Microphone Bottom",
                       description: "<Device: iPhone Microphone (Built-In Microphone Bottom)>")
        //.previewLayout(.fixed(width: 568, height: 320))
        .previewLayout(.fixed(width: 1250, height: 225))
    }
}
