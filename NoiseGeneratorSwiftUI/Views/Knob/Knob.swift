import SwiftUI

struct Knob: View {
    
    @Binding var percentRotated: Double
    
    var startAngle: Double = -135.0;
    var endAngle: Double = 135.0;
    
    var sensitivity: Double = 2.5;
    var range: Double = 270.0;
    
    @State var currentAngle: Double = -135.0; //frame width
    @State var h: CGFloat = 0; //frame height
    
    @State var deltaX: Double = 0.0
    @State var deltaY: Double = 0.0
    
    @State var currentX: CGFloat = 0.0
    @State var currentY: CGFloat = 0.0
    
    var body: some View {
        GeometryReader{ geometry in
            ZStack{
                
                    //Border
                    Circle()
                        .strokeBorder(Color.init(red: 0.4, green: 0.4, blue: 0.4), lineWidth: 20)
                        .frame(width:geometry.size.width)
                
                    //Stationary Gradient
                    Circle()
                        .fill(LinearGradient(Color.darkEnd, Color.darkStart))
                        .shadow(color: Color.darkEnd, radius: 1, x: 1, y: 1)
                        .shadow(color: Color.darkStart, radius: 1, x: -1, y: -1)
                        .frame(width:geometry.size.width * 0.90)
                
                    //Rotating Entity (fill is almost completely transparent - but still rotates)
                    Circle()
                        .fill(Color(red: 0.2, green: 0.2, blue: 0.2, opacity: 0.01))
                        .onAppear{
                            self.currentAngle = self.percentRotated * self.range + self.startAngle
                        }
                        .frame(width:geometry.size.width * 0.90)
                
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(LinearGradient(Color.white, Color.offWhite))
                                .shadow(color: Color.darkEnd, radius: 2, x: 2, y: 2)
                                .shadow(color: Color.darkStart, radius: 2, x: -2, y: -2)
                                .frame(width:geometry.size.width * 0.04,
                                       height: geometry.size.width * 0.42)
                                .offset(y: -1 * geometry.size.width * 0.24)
                            
                        )
                            
                        .rotationEffect(
                            .degrees(
                                self.currentAngle
                            )
                        )
                //User touches the circle and drags it to a new location
                .gesture(DragGesture()
                    
                    // event fires when there is drag translation
                    .onChanged{
                        value in //Value stores event details (value inputted)
                        
                        if (self.currentX != 0.0 && self.currentY != 0.0){
                            self.deltaX = Double(self.currentX - value.location.x)
                            self.deltaY = Double(self.currentY - value.location.y)
                        }
                        self.currentX = value.location.x
                        self.currentY = value.location.y
                        
                        self.currentAngle = self.currentAngle + self.deltaY * self.sensitivity
                        self.currentAngle = self.currentAngle - self.deltaX * self.sensitivity
                        
                        if( self.currentAngle > self.endAngle){
                            self.currentAngle = self.endAngle
                        }
                        else if(self.currentAngle < self.startAngle){
                            self.currentAngle = self.startAngle
                        }
                        
                        self.percentRotated = (self.currentAngle + self.endAngle) / self.range
                    }
                .onEnded{
                    value in //Value stores event details (value inputted)
                    self.currentX = 0.0
                    self.currentY = 0.0
                    }
                )
            }
        }
    }
}

struct Knob_Previews: PreviewProvider {
    static var previews: some View {
        Knob(percentRotated: .constant(0.5))
        .previewLayout(.fixed(width: 400, height: 450))
    }
}
