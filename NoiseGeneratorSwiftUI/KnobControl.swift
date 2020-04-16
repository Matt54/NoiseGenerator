import SwiftUI

struct KnobControl: View {
    //@ObservedObject var knobModel = KnobControlModel()
    
    @Binding var percentRotated: Double// = 1.0
    @Binding var realModValue: Double// = 1.0
    
    var body: some View {
        GeometryReader{ geometry in
            ZStack{
                Circle()
                /*
                Arc(startAngle: .constant(130 * .pi / 180),
                    endAngle: .constant( (270.0 * 1.0 + 140.0) * .pi / 180.0),
                    lineWidth: geometry.size.width * 0.025,
                    center: CGPoint(x: geometry.size.width/2, y: geometry.size.height/2),
                    radius: geometry.size.width/2 - geometry.size.width/40 * 0.5)
                */

                Arc(startAngle: .constant((270.0 * self.realModValue + 130) * .pi / 180),
                    //startAngle: .constant(135 * .pi / 180),
                    endAngle: .constant( (270.0 * self.realModValue + 140.0) * .pi / 180.0),
                    lineWidth: geometry.size.width * 0.05,
                    center: CGPoint(x: geometry.size.width/2, y: geometry.size.height/2),
                    radius: geometry.size.width / 2 - geometry.size.width * 0.05 * 0.5)
                    .fill(Color.yellow)
                
                Knob(percentRotated: self.$percentRotated)
                    .frame(width:geometry.size.width * 0.9)
                }
            .frame(width:geometry.size.width)
        }
    }
}

/*
final class KnobControlModel : ObservableObject{
    @Published var percentRotated = 1.0
    @Published var realModValue = 1.0
    init(){
    }
}
 */

struct Arc : Shape
{
@Binding var startAngle: Double
@Binding var endAngle: Double

var lineWidth: CGFloat
var center: CGPoint
var radius: CGFloat
    func path(in rect: CGRect) -> Path
    {
        var path = Path()

        let cgPath = CGMutablePath()
        cgPath.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: radius, startAngle: CGFloat(startAngle), endAngle: CGFloat(endAngle), clockwise: false)

        path = Path(cgPath)

        return path.strokedPath(.init(lineWidth: lineWidth, lineCap: .butt))
    }
}

struct KnobControl_Previews: PreviewProvider {
    static var previews: some View {
        KnobControl(percentRotated: .constant(0.5), realModValue: .constant(0.5))
    }
}
