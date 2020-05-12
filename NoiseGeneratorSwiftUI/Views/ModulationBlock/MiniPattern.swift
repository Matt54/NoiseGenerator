import SwiftUI

struct MiniPattern: View {
    
    @Binding var pattern: Pattern
    
    var body: some View {
        GeometryReader
        { geometry in
            
            ZStack{
                
                Color.white
                
                //Draw the Area Under the curve
                VStack{
                    Path{ path in
                        
                        //Start at first Point
                        path.move(to: CGPoint(x: 0,
                                              y: self.pattern.points[0].coordinate.y * geometry.size.height))
                        
                        // Curve Line through the interior Points
                        self.pattern.points.forEach{

                            if($0.controlPoint1 != nil){
                                path.addCurve(
                                    to: .init(
                                        x: $0.coordinate.x * geometry.size.width,
                                        y: $0.coordinate.y * geometry.size.height)
                                    ,
                                    control1: .init(
                                        x: $0.controlPoint1!.coordinate.x * geometry.size.width,
                                        y: $0.controlPoint1!.coordinate.y * geometry.size.height)
                                    ,
                                    control2: .init(
                                        x: $0.controlPoint2!.coordinate.x * geometry.size.width,
                                        y: $0.controlPoint2!.coordinate.y * geometry.size.height)
                                    )
                            }
                            
                        }

                        //To bottom right
                        path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height))
                        
                        //To bottom Left
                        path.addLine(to: CGPoint(x: 0, y: geometry.size.height))
                        
                        //To first point
                        path.move(to: CGPoint(x: 0,
                                              y: self.pattern.points[0].coordinate.y * geometry.size.height))
                    }
                    .fill(Color(red: 0.2, green: 0.2, blue: 0.2, opacity: 0.5))
                }
                
                //Draw the Area Under the curve
                /*
                VStack{
                    Path{ path in
                        
                        //Start at first Point
                        path.move(to: CGPoint(x: 0,
                                              y: self.pattern.points[0].coordinate.y * geometry.size.height))
                        
                        // Curve Line through the interior Points
                        self.pattern.points.forEach{

                            if($0.controlPoint1 != nil){
                                path.addCurve(
                                    to: .init(
                                        x: $0.coordinate.x * geometry.size.width,
                                        y: $0.coordinate.y * geometry.size.height)
                                    ,
                                    control1: .init(
                                        x: $0.controlPoint1!.coordinate.x * geometry.size.width,
                                        y: $0.controlPoint1!.coordinate.y * geometry.size.height)
                                    ,
                                    control2: .init(
                                        x: $0.controlPoint2!.coordinate.x * geometry.size.width,
                                        y: $0.controlPoint2!.coordinate.y * geometry.size.height)
                                    )
                            }
                            
                        }
                        
                        path.move(to: CGPoint(x: self.pattern.displayValuePoint.x * geometry.size.width,
                        y: self.pattern.displayValuePoint.y * geometry.size.height) )
                        path.addLine(to: CGPoint(x: self.pattern.displayValuePoint.x * geometry.size.width,
                                                 y: geometry.size.height))
                        
                        //To bottom Left
                        path.addLine(to: CGPoint(x: 0, y: geometry.size.height))
                        
                        //To first point
                        path.move(to: CGPoint(x: 0,
                                              y: self.pattern.points[0].coordinate.y * geometry.size.height))
                    }
                    .fill(Color(red: 0.2, green: 0.2, blue: 0.2, opacity: 1.0))
                }
                */
                
                VStack{
                    Path{ path in
                        path.move(to: CGPoint(x: self.pattern.displayValuePoint.x * geometry.size.width,
                        y: self.pattern.displayValuePoint.y * geometry.size.height) )
                        path.addLine(to: CGPoint(x: self.pattern.displayValuePoint.x * geometry.size.width,
                                                 y: geometry.size.height))
                    }
                    .stroke()
                }
                
                
            }
        }
    }
}

struct MiniPattern_Previews: PreviewProvider {
    static var previews: some View {
        MiniPattern(pattern: .constant(Pattern(color: Color.green)))
        .previewLayout(.fixed(width: 300, height: 300))
    }
}
