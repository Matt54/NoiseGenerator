
import SwiftUI

struct VolumeDisplay: View {
    
    @Binding var volume: Double
    @Binding var numberOfRects: Int
    var maxAmplitude = 1.1
    
    var body: some View {
        GeometryReader { geometry in

            VStack(spacing: (geometry.size.height / CGFloat(self.numberOfRects) * 0.25 ) )
            {
            
                // Red Rectangle
                VStack{
                    if( self.volume > 1.0 ){
                        Rectangle()
                            .fill(Color(red: 0.9, green: 0, blue: 0))
                    }
                    else{
                        Rectangle()
                            .fill(Color(red: 0.1, green: 0, blue: 0))
                    }
                }
                
                // Green Rectangles
                ForEach((1...self.numberOfRects).reversed(), id: \.self) {index in
                    VStack{
                        if( self.volume >= (Double(index)/Double(self.numberOfRects)) ){
                            Rectangle()
                                .fill(Color(red: 0, green: 0.6, blue: 0))
                        }
                        else{
                            Rectangle()
                                .fill(Color(red: 0, green: 0.1, blue: 0))
                        }
                    }
                }
            }
        }
    }
}

struct VolumeDisplay_Previews: PreviewProvider {
    static var previews: some View {
        VolumeDisplay(volume: .constant(1.0), numberOfRects: .constant(30) )
            .previewLayout(.fixed(width: 40, height: 500))
    }
}
