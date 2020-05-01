import SwiftUI

struct TriangleDrag: View {
    @Binding var lVal: Double
    @Binding var tVal: Double
    @Binding var rVal: Double
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var body: some View {
        GeometryReader{ geometry in
            VStack{
                Text("Pink: \(String(format: "%.0f",(self.tVal*100)))%")
                .modifier(SmallBoldTextModifier())
                ZStack{
                    Triangle()
                        .fill(Color.clear)
                        .frame(width:geometry.size.width * 0.7,
                               height: geometry.size.width * 0.7 * 0.866)
                        .offset(y: -geometry.size.width * 0.01)
                        //.shadow(color: Color.BlackWhiteColor(for: self.colorScheme), radius:30)
                    TriangleControl(lVal: self.$lVal,
                                    tVal: self.$tVal,
                                    rVal: self.$rVal,
                                    circleFactor: 8)
                        .frame(width: geometry.size.width * 0.8, height: geometry.size.width * 0.8 * 0.866)
                }
                HStack{
                    //Spacer()

                    VStack (alignment: .leading) {
                        Text("White:")
                            .modifier(SmallBoldTextModifier())
                        Text("\(String(format: "%.0f",(self.lVal*100)))%")
                            .modifier(SmallBoldTextModifier())
                    }
                    
                        
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Brownian:")
                        .modifier(SmallBoldTextModifier())
                        Text("\(String(format: "%.0f",(self.rVal*100)))%")
                        .modifier(SmallBoldTextModifier())
                    }
                    //Spacer()
                }
                .frame(width: geometry.size.width * 0.8)
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

struct SmallBoldTextModifier : ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 12, weight: .heavy, design: .default))
    }
}
