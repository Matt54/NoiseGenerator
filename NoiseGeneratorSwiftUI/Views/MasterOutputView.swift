import SwiftUI

struct MasterOutputView: View {
    
    @EnvironmentObject var noise: NoiseModel
    
    var body: some View {
        GeometryReader
        { geometryOut in
            VStack(spacing: 0){
            GeometryReader
            { geometryMiddle in
                
            GeometryReader{ geometry in
                VStack(spacing: 0){
                    /*
                    HStack{
                        VolumeComplete(amplitude: self.$noise.outputAmplitudeLeft,
                                       volumeControl: self.$noise.masterVolume,
                                   isRightHanded: .constant(true),
                                   numberOfRects: .constant(10),
                                   title: "OUT")
                        .padding(geometry.size.width * 0.01)
                        .frame(width:geometry.size.width * 0.2)
                        
                    }
                    .frame(width:geometry.size.width,
                           height: geometry.size.height * 0.85)
                    */
                    // Title Bar
                    TitleBar(title: .constant("Master Volume"),
                             isBypassed: self.$noise.masterBypass)
                        .frame(height:geometry.size.height * 0.15)
                    
                    
                }
                }
                    .padding(geometryMiddle.size.height * 0.02)
                    .border(Color.black, width: geometryMiddle.size.height * 0.02)
                }
            
                VStack(spacing: 0){
                    Color.clear
                }
                .frame(height:geometryOut.size.height * 0.15)
            }
        }
    }
}

struct MasterOutputView_Previews: PreviewProvider {
    static var previews: some View {
        MasterOutputView().environmentObject(NoiseModel.shared)
        .previewLayout(.fixed(width: 500, height: 300))
    }
}
