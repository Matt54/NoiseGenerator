import SwiftUI

struct SlidingTriangle: View {
    @Binding var amplitudeControl: Double
    @Binding var isRightHanded: Bool
    
    var body: some View {
        GeometryReader
        { geometry in
            VStack(spacing: 0){
                if(self.isRightHanded){
                    Triangle()
                    .frame(height: geometry.size.width)
                    .rotationEffect(.degrees(-90))
                    .offset(y: (-1 * CGFloat(self.amplitudeControl) * (geometry.size.height - geometry.size.width)) )
                }
                else{
                    Triangle()
                    .frame(height: geometry.size.width)
                    .rotationEffect(.degrees(90))
                    .offset(y: (-1 * CGFloat(self.amplitudeControl) * (geometry.size.height - geometry.size.width)) )
                }
            }
            .frame(height: geometry.size.height ,alignment: Alignment.bottomLeading)
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged({ value in
                    // min(max(0,x),1) prevents values above 1 and below 0
                    self.amplitudeControl = Double(min(max(0, 1.0 - Float(value.location.y / geometry.size.height)), 1))
            }))
        }
    }
}

struct SlidingTriangle_Previews: PreviewProvider {
    static var previews: some View {
        SlidingTriangle(amplitudeControl: .constant(0.5), isRightHanded: .constant(false))
            .previewLayout(.fixed(width: 30, height: 400))
    }
}
