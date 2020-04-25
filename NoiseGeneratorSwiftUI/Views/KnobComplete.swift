import SwiftUI
import Combine

struct KnobComplete: View {
    
    //TODO: Add binding to the noise.shared color (set by modulation being selected [or not] )
    
    @Binding var knobModel : KnobCompleteModel
    @State var knobModColor: Color
    
    var body: some View {
        GeometryReader{ geometry in
            ZStack{
                
                //modulation background
                Arc(startAngle: .constant(130 * .pi / 180),
                    endAngle: .constant( (270.0 * 1.0 + 140.0) * .pi / 180.0),
                    lineWidth: geometry.size.width * 0.05,
                    center: CGPoint(x: geometry.size.width/2, y: geometry.size.height/2),
                    radius: geometry.size.width/2 - geometry.size.width * 0.05 * 0.5)
                    .fill(Color.init(red: 0.5, green: 0.5, blue: 0.5))
                
                //modulation background border
                Arc(startAngle: .constant(130 * .pi / 180),
                    endAngle: .constant( (270.0 * 1.0 + 140.0) * .pi / 180.0),
                    lineWidth: geometry.size.width * 0.05,
                    center: CGPoint(x: geometry.size.width/2, y: geometry.size.height/2),
                    radius: geometry.size.width/2 - geometry.size.width * 0.05 * 0.5)
                    .stroke(Color.init(red: 0.2, green: 0.2, blue: 0.2),
                            lineWidth: geometry.size.width * 0.005)
                
                //modulation
                if(self.knobModel.modSelected)
                {
                    Arc(startAngle: .constant((270.0 * self.knobModel.percentRotated + 130) * .pi / 180),
                        endAngle: .constant((270 * self.knobModel.realModulationRange + 270.0 * self.knobModel.percentRotated + 140.0) * .pi / 180.0),
                        lineWidth: geometry.size.width * 0.05,
                        center: CGPoint(x: geometry.size.width/2, y: geometry.size.height/2),
                        radius: geometry.size.width/2 - geometry.size.width * 0.05 * 0.5)
                        .fill(self.knobModColor)
                }
                
                KnobControl(percentRotated: self.$knobModel.percentRotated, realModValue: self.$knobModel.realModValue, knobModColor: self.knobModColor)
                    .frame(width:geometry.size.width * 0.9)
                }
        }
    }
}

struct KnobComplete_Previews: PreviewProvider {
    static var previews: some View {
        KnobComplete(knobModel: .constant(KnobCompleteModel()), knobModColor: Color.yellow)
    }
}
