import SwiftUI

struct TriangleControl: View {
    
    @Binding var lVal: Double
    @Binding var tVal: Double
    @Binding var rVal: Double

    //Convenient variables
    @State var w: CGFloat = 0; //frame width
    @State var h: CGFloat = 0; //frame height
    
    //Position of Circle (coordinates within the frame)
    @State var xPos: CGFloat = 0 //x coordinate
    @State var yPos: CGFloat = 0 //y coordinate
    
    //Maximum angle of the circle in radians
    @State var theta: CGFloat = 0
    
    //Reduces circle size by factor of the overall width/height
    //Higher number = smaller circle
    @State var circleFactor: CGFloat = 8
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    var body: some View {
        
        //GeometryReader provides information about the frame
        //This allows for calculated properties based on the overall frame size
        GeometryReader{ geometry in
            
            // Overlays views on top of each other
            ZStack{
                Rectangle()
                    .fill(Color.clear)
                Triangle()
                    .fill(Color.WhiteBlackColor(for: self.colorScheme))
                    .shadow(color: Color.BlackWhiteColor(for: self.colorScheme), radius: 10)

                Circle()
                    .fill(Color.BlackWhiteColor(for: self.colorScheme))
                    .shadow(color: Color.BlackWhiteColor(for: self.colorScheme),radius: 8)
                    
                    // Get the initial properties of the frame
                    // and the layout of our shapes within
                    .onAppear{
                        self.w = geometry.size.width
                        self.h = geometry.size.height
                        self.theta = atan(self.h / (self.w/2) )
                        
                        // set initial coordinates for the circle
                        self.xPos = self.w / 2
                        self.yPos = self.h / 2
                        
                        let lDist = sqrt(pow(self.xPos - 0,2) + pow(self.yPos - self.h,2))
                        self.lVal = Double(1 - lDist / self.h);
                        
                        let rDist = sqrt(pow(self.xPos - self.w,2) + pow(self.yPos - self.h,2))
                        self.rVal = Double(1 - rDist / self.h);

                        let tDist = sqrt(pow(self.xPos - (self.w / 2),2) + pow(self.yPos - 0,2))
                        self.tVal = Double(1 - tDist / self.h);
                        
                    }
                    
                    //Set size of circle relative to the frame
                    .frame(width: geometry.size.width / self.circleFactor,
                           height: geometry.size.height / self.circleFactor)
                    
                    //Position will move with state variables
                    .position(x: self.xPos, y: self.yPos)
                    
                    //User touches the circle and drags it to a new location
                    .gesture(DragGesture()
                        
                        // event fires when there is drag translation
                        .onChanged{
                            value in //Value stores event details (value inputted)
                            
                            
                            var x = value.location.x //real x location of touch
                            
                            //if we are over halfway across the view, calculate x from the middle.
                            // We do this for our angle calculation
                            if(x > self.w * 0.5)
                            {
                                x = self.w - value.location.x
                            }

                            //inverted y location of touch (canvas starts at top)
                            let y = self.h - value.location.y
                            
                            //angle of triangle
                            let angle = atan(y/x);
                            
                            //Check that we are inside our bounds
                            // - can't leave botton
                            // - can't leave left or right
                            if( (self.h > value.location.y) &&
                                (0 < value.location.x) && (value.location.x < self.w) )
                            {
                                //Check if we exceeded our max angle
                                if (angle < self.theta)
                                {
                                    self.xPos = value.location.x //set x to touch
                                    self.yPos = value.location.y //set y to touch
                                }
                                    
                                //If exceeded angle, y location is calculated to be on the edge of the triangle
                                else
                                {
                                    self.xPos = value.location.x //set x to touch
                                    self.yPos = self.h - x * tan(self.theta)
                                }
                            }
                            //This logic lets the circle still move its x location while dragging below the frame
                            else{
                                
                                self.yPos = self.h //Set y to bottom of triangle
                                
                                // restrict x to the left and right bounds
                                if((0 < value.location.x) && (value.location.x < self.w))
                                {
                                    self.xPos = value.location.x
                                }
                            }
                            
                            let lDist = sqrt(pow(self.xPos - 0,2) + pow(self.yPos - self.h,2))
                            self.lVal = Double(1 - lDist / self.h);
                            if(self.lVal < 0) {self.lVal = 0}
                            
                            let rDist = sqrt(pow(self.xPos - self.w,2) + pow(self.yPos - self.h,2))
                            self.rVal = Double(1 - rDist / self.h);
                            if(self.rVal < 0) {self.rVal = 0}

                            let tDist = sqrt(pow(self.xPos - (self.w / 2),2) + pow(self.yPos - 0,2))
                            self.tVal = Double(1 - tDist / self.h);
                            if(self.tVal < 0) {self.tVal = 0}

                        }//.onChanged
                    )//.gesture
            } //Zstack
        } //Geometry reader
    }//Body
}//Struct

struct Triangle: InsettableShape {
    var insetAmount: CGFloat = 0
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY + insetAmount))
        path.addLine(to: CGPoint(x: rect.minX + insetAmount, y: rect.maxY - insetAmount))
        path.addLine(to: CGPoint(x: rect.maxX - insetAmount, y: rect.maxY - insetAmount))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY + insetAmount))
        return path
    }
    
    func inset(by amount: CGFloat) -> some InsettableShape {
        var arc = self
        arc.insetAmount += amount
        return arc
    }
    
}

struct TriangleControl_Previews: PreviewProvider {
    
    static var previews: some View {
        Group{
            TriangleControl(lVal: .constant(0.0),
                            tVal: .constant(0.0),
                            rVal: .constant(0.0))
                .previewLayout(.fixed(width: 500, height: 433))
                .background(Color.white)
        }
    }
}
