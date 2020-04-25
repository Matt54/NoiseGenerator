import SwiftUI

struct TriangleDrag: View {
    @Binding var lVal: Double
    @Binding var tVal: Double
    @Binding var rVal: Double
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var body: some View {
        GeometryReader{ geometry in
            VStack{
                Text("Pink Noise: \(String(format: "%.0f",(self.tVal*100)))%")
                ZStack{
                    Triangle()
                        .fill(Color.clear)
                        .frame(width:geometry.size.width * 0.7,
                               height: geometry.size.width * 0.7 * 0.866)
                        .offset(y: -geometry.size.width * 0.01)
                        .shadow(color: Color.BlackWhiteColor(for: self.colorScheme), radius:30)
                    TriangleControl(lVal: self.$lVal,
                                    tVal: self.$tVal,
                                    rVal: self.$rVal,
                                    circleFactor: 8)
                        .frame(width: geometry.size.width * 0.6, height: geometry.size.width * 0.6 * 0.866)
                }
                HStack{
                    Spacer()

                    VStack (alignment: .leading) {
                        Text("White Noise:")
                        Text("\(String(format: "%.0f",(self.lVal*100)))%")
                    }
                    
                        
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Brown Noise:")
                        Text("\(String(format: "%.0f",(self.rVal*100)))%")
                    }
                    Spacer()
                }
            }
        }
    }
}

struct TriangleDrag_Previews: PreviewProvider {
    static var previews: some View {
        TriangleDrag(lVal: .constant(1.0),
                     tVal: .constant(0.0),
                     rVal: .constant(0.0))
        .previewLayout(.fixed(width: 300, height: 300))
    }
}
