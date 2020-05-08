import SwiftUI

struct VolumeComplete: View {
    @Binding var amplitude: Double
    @Binding var volumeControl: Double
    @Binding var isRightHanded: Bool
    @Binding var numberOfRects: Int
    @State var title: String
    
    var body: some View {
        GeometryReader { geometry in
            Group{
                if(!self.isRightHanded){
                    
                    // Entire Control - Volume Bars intentionally have no frame set
                    // The size of the text frame + padding sets the volume bar
                    VStack(alignment: .trailing, spacing: 0)
                    {
                        // Text - Volume Control
                        Text(String(format: "%.1f", self.volumeControl))
                            .textStyle(ShrinkTextStyle())
                            
                            .frame(width: geometry.size.width * 0.7,
                                   height: geometry.size.height * 0.1)
                            .padding(.bottom, geometry.size.height * 0.03)
                        
                        // Control - Volume Bars and Slider
                        VolumeControl(volume: self.$amplitude,
                                      amplitudeControl:self.$volumeControl,
                                      isRightHanded: self.$isRightHanded,
                                      numberOfRects: self.$numberOfRects)
                        
                        // Text - Title
                        Text(self.title)
                            .bold()
                            .textStyle(ShrinkTextStyle())
                            .frame(width: geometry.size.width * 0.7,
                                   height: geometry.size.height * 0.1)
                            .padding(.top, geometry.size.height * 0.03)
                    }
                }
                else{
                    
                    // Entire Control - Volume Bars intentionally have no frame set
                    // The size of the text frame + padding sets the volume bar
                    VStack(alignment: .leading, spacing: 0)
                    {
                        
                        // Text - Volume Control
                        Text(String(format: "%.1f", self.volumeControl))
                            .textStyle(ShrinkTextStyle())
                            .frame(width: geometry.size.width * 0.7,
                                   height: geometry.size.height * 0.1)
                            .padding(.bottom, geometry.size.height * 0.03)
                            
                        // Control - Volume Bars and Slider
                        VolumeControl(volume: self.$amplitude,
                                      amplitudeControl: self.$volumeControl,
                                      isRightHanded: self.$isRightHanded,
                                      numberOfRects: self.$numberOfRects)
                        
                        // Text - Title
                        Text(self.title)
                            .bold()
                            .textStyle(ShrinkTextStyle())
                            .frame(width: geometry.size.width * 0.7,
                                   height: geometry.size.height * 0.1)
                            .padding(.top, geometry.size.height * 0.03)
                    }
                }
            }
        }
    }
}

struct VolumeComplete_Previews: PreviewProvider {
    static var previews: some View {
        VolumeComplete(amplitude: .constant(0.5),volumeControl: .constant(1.0), isRightHanded: .constant(true), numberOfRects: .constant(20), title: "IN")
        .previewLayout(.fixed(width: 40, height: 200))
    }
}


