import SwiftUI

struct TitleBar: View {
    @Binding var title: String
    @Binding var isBypassed: Bool
    
    var body: some View {
        GeometryReader
        { geometry in
        ZStack{
            Rectangle()
                .fill(LinearGradient(Color.darkStart,Color.darkGray))
            Text(self.title)
                .font(.system(size: 16))
                .bold()
                .foregroundColor(Color.white)
            
            // Power Button
            VStack(alignment: .leading) {
                
                HStack {
                    PowerButton(isBypassed: self.$isBypassed)
                        .padding(.leading, 5)
                    Spacer()
                }
            }
            }
        }
    }
}

struct TitleBar_Previews: PreviewProvider {
    static var previews: some View {
        TitleBar(title: .constant("Block Title"), isBypassed: .constant(true))
        .previewLayout(.fixed(width: 300, height: 40))
    }
}
