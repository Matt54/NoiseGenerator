import SwiftUI

struct PatternGraph: View {

    @Binding var pattern: Pattern
    
    @State var touchPoint = CGPoint(x: 0, y: 0)
    @State var touchState = TouchState.none

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
                            
                            /*
                            path.addLine(
                                to: .init(
                                    x: $0.coordinate.x * geometry.size.width,
                                    y: $0.coordinate.y * geometry.size.height)
                                )
                            */
                            if($0.controlPoint1 != nil){
                                /*
                                path.addQuadCurve(
                                    to: .init(
                                        x: $0.coordinate.x * geometry.size.width,
                                        y: $0.coordinate.y * geometry.size.height)
                                    ,
                                    control: .init(
                                        x: $0.controlPoint!.coordinate.x * geometry.size.width,
                                        y: $0.controlPoint!.coordinate.y * geometry.size.height)
                                    )
                                */
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
                    .fill(Color.gray)
                }
                
                //Draw All Points
                ForEach(self.pattern.points){ p in
                    Circle()
                        .fill(Color.black)
                        .frame(width: geometry.size.width * 0.05)
                        .position(CGPoint(x: p.coordinate.x * geometry.size.width, y: p.coordinate.y * geometry.size.height))
                }
                
                //Draw All Intersection Points
                ForEach(self.pattern.points){ p in
                    VStack{
                        if(p.intersectionPoint != nil){
                            Circle()
                                .fill(Color.green)
                                .frame(width: geometry.size.width * 0.025)
                                .position(CGPoint(x: p.intersectionPoint!.coordinate.x * geometry.size.width, y: p.intersectionPoint!.coordinate.y * geometry.size.height))
                        }
                    }
                }
                
                //Draw All Points
                ForEach(self.pattern.controlPoints){ p in
                    Circle()
                        .fill(Color.red)
                        .frame(width: geometry.size.width * 0.025)
                        .position(CGPoint(x: p.coordinate.x * geometry.size.width, y: p.coordinate.y * geometry.size.height))
                }
                
                //Draw Display Value Point
                Circle()
                    .fill(Color.green)
                    .frame(width: geometry.size.width * 0.05)
                    .position(CGPoint(x: self.pattern.displayValuePoint.x * geometry.size.width,
                                      y: self.pattern.displayValuePoint.y * geometry.size.height))
                
                
                /*
                VStack{
                    Group{
                        self.pattern.points.forEach{
                            Circle()
                                .fill(Color.black)
                                .frame(width: geometry.size.width * 0.05)
                                .position(CGPoint(x: $0.coordinate.x * geometry.size.width, y: $0.coordinate.y * geometry.size.height))
                        }
                    }
                }
                */
                
                //Draw All Control Points
                ForEach(self.pattern.intersectionPoints){ p in
                    Circle()
                        .fill(Color.black)
                        .frame(width: geometry.size.width * 0.025)
                        .position(CGPoint(x: p.coordinate.x * geometry.size.width, y: p.coordinate.y * geometry.size.height))
                }
                
                
                //Draw something to show selected point
                if(self.pattern.selectedPoint != nil){
                    Circle()
                        .fill(Color(red: 0.0, green: 0.0, blue: 0.0, opacity: 0.2))
                        .frame(width: geometry.size.width * 0.1)
                        .position(CGPoint(x: (self.pattern.selectedPoint?.coordinate.x)! * geometry.size.width, y: (self.pattern.selectedPoint?.coordinate.y)! * geometry.size.height))
                }
                
            }
            .gesture(
                DragGesture(minimumDistance: 0.0)
                    .onChanged({ (touch) in
                        self.touchState = (self.touchState == .none || self.touchState == .ended) ? .began : .moved
                        self.touchPoint = touch.location
                        self.pattern.analyzeTouch(graphCoordinate: self.touchPoint,
                                                  graphSize: geometry.size,
                                                  touchState: self.touchState)
                    })
                    .onEnded({ (touch) in
                        self.touchPoint = touch.location
                        self.touchState = .ended
                        print(self.touchState)
                        self.pattern.analyzeTouch(graphCoordinate: self.touchPoint,
                                                  graphSize: geometry.size,
                                                  touchState: self.touchState)
                    })
                    .simultaneously(with: LongPressGesture(minimumDuration: 0.75, maximumDistance: geometry.size.width * 0.05)
                        .onEnded({ (touch) in
                            print("Long Press:")
                            print(touch)
                            self.pattern.deleteCheck()
                        })
                        
                )
            )
        }
    }
}

struct PatternGraph_Previews: PreviewProvider {
    static var previews: some View {
        PatternGraph(pattern: .constant(Pattern()))
        .previewLayout(.fixed(width: 300, height: 300))
    }
}

public enum TouchState {
    case none, began, moved, ended
    var name: String {
        return "\(self)"
    }
}
