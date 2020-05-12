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
                .frame(height:geometry.size.height * 0.9)
                
                HStack{
                    Button(action: {
                        self.screen = SelectedScreen.main
                    }){
                        Image(systemName: "return")
                            .resizable()
                            .frame(width:geometry.size.width * 0.1)
                    }
                }
                 .frame(height:geometry.size.height * 0.1)
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
