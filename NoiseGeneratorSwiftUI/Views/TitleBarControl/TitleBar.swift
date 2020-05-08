import SwiftUI

struct TitleBar: View {
    @Binding var title: String
    @Binding var isBypassed: Bool
    
    var body: some View {
        GeometryReader
        { geometry in
            ZStack
                {
                    Rectangle()
                        .fill(LinearGradient(Color.darkStart,Color.darkGray))
                    Text(self.title)
                        .bold()
                        .textStyle(ShrinkTextStyle())
                        .foregroundColor(Color.white)
                        .frame(width: geometry.size.width * 0.6)
                    
                    // Power Button
                    VStack(alignment: .leading) {
                        //Spacer()
                        HStack {
                            
                            Button(action: {self.isBypassed.toggle()}){
                                if(!self.isBypassed){
                                    ZStack{
                                            Circle()
                                                .fill(Color.init(red: 0.0, green: 0.0, blue: 0.0))
                                                .frame(width: geometry.size.height * 0.8,
                                                       height:geometry.size.height * 0.8)
                                           Image(systemName: "power")
                                                .resizable()
                                                .frame(width: geometry.size.height * 0.6,
                                                    height:geometry.size.height * 0.6)
                                                .foregroundColor(Color.yellow)
                                        }
                                    .padding(geometry.size.height * 0.1)
                                    /*
                                    Circle()
                                        .fill(Color.init(red: 0.0, green: 0.0, blue: 0.0))
                                        .frame(height:geometry.size.height * 0.9)
                                        .overlay(
                                        Image(systemName: "power")
                                            //.font(.system(size: 18))
                                            .foregroundColor(Color.yellow)
                                        )
                                    */
                                    }
                                else{
                                    ZStack{
                                        Circle()
                                            .fill(Color.init(red: 0.0, green: 0.0, blue: 0.0))
                                            .frame(width: geometry.size.height * 0.7,
                                                   height:geometry.size.height * 0.7)
                                       Image(systemName: "power")
                                            .resizable()
                                            .frame(width: geometry.size.height * 0.5,
                                                height:geometry.size.height * 0.5)
                                            .foregroundColor(Color.gray)
                                    }
                                .padding(geometry.size.height * 0.15)
                                    
                                }
                            }
                            /*
                            PowerButton(isBypassed: self.$isBypassed)
                                .padding(.leading, 5)
                            */
                            Spacer()
                        }
                        //.frame(height:geometry.size.height)
                        //Spacer()
                    }
                    //.frame(height:geometry.size.height)
                }
        }
    }
}

struct TitleBar_Previews: PreviewProvider {
    static var previews: some View {
        TitleBar(title: .constant("Block Title"), isBypassed: .constant(true))
        .previewLayout(.fixed(width: 150, height: 20))
    }
}
