import SwiftUI

struct PatternAdjust: View {
    
    @Binding var pattern: Pattern
    @Binding var screen: SelectedScreen
    
    var body: some View {
        GeometryReader
        { geometry in
            VStack(spacing: 0){
                
                PatternGraph(pattern: self.$pattern)
                .padding(geometry.size.height * 0.1)
                .border(Color.black, width: geometry.size.height * 0.02)
                .frame(height:geometry.size.height * 0.85)
                
                HStack{
                    
                    //Back Button
                    Button(action: {
                        self.screen = SelectedScreen.main
                    }){
                        ZStack{
                            Rectangle()
                                .fill(Color.black)
                                .cornerRadius(geometry.size.height * 0.05)
                                .padding(geometry.size.height * 0.03)
                            Text("RETURN")
                                .bold()
                                .textStyle(ShrinkTextStyle())
                                .foregroundColor(Color.white)
                                .padding(geometry.size.height * 0.04)
                        }
                        .frame(width: geometry.size.height * 0.35,
                               height:geometry.size.height * 0.15)
                    }
                    
                    //Save Button
                    Button(action: {
                        print("pattern saved")
                    }){
                        ZStack{
                            Rectangle()
                                .fill(Color.black)
                                .cornerRadius(geometry.size.height * 0.05)
                                .padding(geometry.size.height * 0.03)
                            Text("SAVE")
                                .bold()
                                .textStyle(ShrinkTextStyle())
                                .foregroundColor(Color.white)
                                .padding(geometry.size.height * 0.04)
                        }
                        .frame(width: geometry.size.height * 0.35,
                               height:geometry.size.height * 0.15)
                    }
                    
                    Spacer()
                    
                    //Save Button
                    Button(action: {
                        print("pattern presets selected")
                    }){
                        ZStack{
                            Rectangle()
                                .fill(Color.black)
                                .cornerRadius(geometry.size.height * 0.05)
                                .padding(geometry.size.height * 0.03)
                            Text("PRESETS")
                                .bold()
                                .textStyle(ShrinkTextStyle())
                                .foregroundColor(Color.white)
                                .padding(geometry.size.height * 0.04)
                        }
                        .frame(width: geometry.size.height * 0.35,
                               height:geometry.size.height * 0.15)
                    }
                    
                    Spacer()
                    
                    //Invert Button
                    Button(action: {
                        print("pattern inverted")
                    }){
                        ZStack{
                            Rectangle()
                                .fill(Color.black)
                                .cornerRadius(geometry.size.height * 0.05)
                                .padding(geometry.size.height * 0.03)
                            Image(systemName: "arrow.up.arrow.down")
                                .resizable()
                                .foregroundColor(Color.white)
                                .padding(geometry.size.height * 0.05)
                        }
                        .frame(width: geometry.size.height * 0.15,
                               height:geometry.size.height * 0.15)
                    }
                    
                    //REVERSE Button
                    Button(action: {
                        print("pattern reversed")
                    }){
                        ZStack{
                            Rectangle()
                                .fill(Color.black)
                                .cornerRadius(geometry.size.height * 0.05)
                                //.padding(geometry.size.height * 0.02)
                                .padding(geometry.size.height * 0.03)
                            Image(systemName: "arrow.right.arrow.left")
                                .resizable()
                                .foregroundColor(Color.white)
                                .padding(geometry.size.height * 0.05)
                        }
                        .frame(width: geometry.size.height * 0.15,
                               height:geometry.size.height * 0.15)
                    }
                    
                    
                    
                }
                 .frame(height:geometry.size.height * 0.15)
            }
            .background(Color.white)
        }
    }
}

struct PatternAdjust_Previews: PreviewProvider {
    static var previews: some View {
        PatternAdjust(pattern: .constant(Pattern(color: Color.green)),
                      screen: .constant(SelectedScreen.main))
        .previewLayout(.fixed(width: 568, height: 320))
    }
}
