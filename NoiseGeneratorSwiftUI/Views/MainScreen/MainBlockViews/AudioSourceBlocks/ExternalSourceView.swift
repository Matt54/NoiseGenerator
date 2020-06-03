import SwiftUI

struct ExternalSourceView: View {
    
    @Binding var microphoneSource: MicrophoneSource
   
    var body: some View {
    GeometryReader
        { geometryOut in
            GeometryReader
            { geometry in
                
                VStack(spacing: 0){
                    
                    HStack(spacing: 0){
                        if(self.microphoneSource.selectedBlockDisplay == .volume){
                            OutputPlotView(inputNode: self.$microphoneSource.volumeMixer.input)
                            //Rectangle()
                                .frame(width: geometry.size.width * 0.7, height: geometry.size.height * 0.85)
                                
                            VolumeComplete(volumeMixer: self.$microphoneSource.volumeMixer)
                                .padding(geometry.size.width * 0.05)
                                .frame(width: geometry.size.width * 0.2)
                        }
                    }
                    .frame(height: geometry.size.height * 0.85)
                    
                    /*
                    VolumeComplete(volumeMixer: self.$microphoneSource.volumeMixer)
                        .padding(geometry.size.width * 0.08)
                        .frame(width: geometry.size.width * 0.27,
                               height:geometry.size.height * 0.85)
                    */
                    
                    InputTitleBar(title: self.$microphoneSource.name, selectedBlockDisplay: self.$microphoneSource.selectedBlockDisplay,
                                  isBypassed: self.$microphoneSource.isBypassed)
                        .frame(height:geometry.size.height * 0.15)
                    
                }
                .background(LinearGradient(Color.white, Color.lightGray))
                
                
            }
            .padding(geometryOut.size.height * 0.0)
            .border(Color.black, width: geometryOut.size.height * 0.0)
        }
    }
}

struct ExternalSourceView_Previews: PreviewProvider {
    static var previews: some View {
        ExternalSourceView(microphoneSource: .constant(MicrophoneSource()))
        .previewLayout(.fixed(width: 250, height: 150))
    }
}
