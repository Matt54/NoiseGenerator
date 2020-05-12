import SwiftUI

struct GridLines: View {
    
    var numberOfGridLines: Int
    
    var body: some View {
        GeometryReader
        { geometry in
            ZStack{
                
                /*
                Path{ path in
                    
                    path.addLine(to: CGPoint(x: 0,
                    y: 0))
                    path.addLine(to: CGPoint(x: geometry.size.width,
                                             y: 0))
                }
                .stroke()
                */
                
                Group{
                    ForEach((0...self.numberOfGridLines), id: \.self) { i in
                            Path{ path in
                                path.move(to: CGPoint(x: geometry.size.width * (CGFloat(i) / CGFloat(self.numberOfGridLines)),
                                                      y: 0.0))
                                path.addLine(to: CGPoint(x: geometry.size.width * (CGFloat(i) / CGFloat(self.numberOfGridLines)),
                                                         y: geometry.size.height))
                            }
                            .stroke()
                        }
                }
                
                Group{
                    ForEach((0...self.numberOfGridLines), id: \.self) { i in
                            Path{ path in
                                path.move(to: CGPoint(x: 0,
                                                      y: geometry.size.height * (CGFloat(i) / CGFloat(self.numberOfGridLines))))
                                path.addLine(to: CGPoint(x: geometry.size.width,
                                                         y: geometry.size.height * (CGFloat(i) / CGFloat(self.numberOfGridLines))))
                            }
                            .stroke()
                        }
                }
            }
        }
    }
}

struct GridLines_Previews: PreviewProvider {
    static var previews: some View {
        GridLines(numberOfGridLines: 8)
    }
}
