import SwiftUI

struct ExternalSourceView: View {
    
    @Binding var volumeControl: Double
    @Binding var amplitude: Double
    @Binding var isBypassed: Bool
    @Binding var title: String
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
   
    var body: some View {
    GeometryReader
        { geometryOut in
            GeometryReader
            { geometry in
                VStack(spacing: 0){
                    VolumeComplete(amplitude: self.$amplitude,
                                   volumeControl: self.$volumeControl,
                                   isRightHanded: .constant(true),
                                   numberOfRects: .constant(10),
                                   title: "VOL")
                        .padding(geometry.size.width * 0.08)
                        .frame(width: geometry.size.width * 0.27,
                               height:geometry.size.height * 0.85)
                    TitleBar(title: self.$title, isBypassed: self.$isBypassed)
                        .frame(height:geometry.size.height * 0.15)
                }
                .background(LinearGradient(Color.white, Color.lightGray))
            }
            .padding(geometryOut.size.height * 0.02)
            .border(Color.BlackWhiteColor(for: self.colorScheme), width: geometryOut.size.height * 0.02)
        }
    }
}

struct ExternalSourceView_Previews: PreviewProvider {
    static var previews: some View {
        ExternalSourceView(volumeControl: .constant(1.0),
                           amplitude: .constant(0.5),
                           isBypassed: .constant(false),
                           title: .constant("deviceID"))
        .previewLayout(.fixed(width: 250, height: 150))
    }
}
