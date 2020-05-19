import SwiftUI

struct ExternalSourceView: View {
    
    @Binding var microphoneSource: MicrophoneSource
   
    var body: some View {
    GeometryReader
        { geometryOut in
            GeometryReader
            { geometry in
                VStack(spacing: 0){
                    VolumeComplete(volumeMixer: self.$microphoneSource.volumeMixer)
                        .padding(geometry.size.width * 0.08)
                        .frame(width: geometry.size.width * 0.27,
                               height:geometry.size.height * 0.85)
                    TitleBar(title: self.$microphoneSource.name, isBypassed: self.$microphoneSource.isBypassed)
                        .frame(height:geometry.size.height * 0.15)
                }
                .background(LinearGradient(Color.white, Color.lightGray))
            }
            .padding(geometryOut.size.height * 0.02)
            .border(Color.black, width: geometryOut.size.height * 0.02)
        }
    }
}

struct ExternalSourceView_Previews: PreviewProvider {
    static var previews: some View {
        ExternalSourceView(microphoneSource: .constant(MicrophoneSource()))
        .previewLayout(.fixed(width: 250, height: 150))
    }
}
