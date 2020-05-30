import SwiftUI

struct EffectRow: View {
    
    var title: String
    var image: Image
    var description: String
    var parameters: [String]
    
    var body: some View {
        GeometryReader{ geometry in
            ZStack(){
                Color.init(red: 0.9, green: 0.9, blue: 0.9)
                
                ZStack(){
                    
                    HStack{
                    self.image
                        .resizable()
                        .aspectRatio(1.0, contentMode: .fit)
                        .frame(height: geometry.size.height * 0.8)
                        .padding(.trailing, geometry.size.width * 0.05)
                        .foregroundColor(Color.black)
                        
                        Spacer()
                    }
                    
                    VStack(alignment: .center,spacing: 0) {
                        Text(self.title)
                            .fontWeight(.heavy)
                            .textStyle(ShrinkTextStyle())
                            .frame(height: geometry.size.height * 0.35)
                            .foregroundColor(Color.black)
                        
                        
                        Text(self.description)
                            //.kerning(0)
                            //.tracking(0)
                            .textStyle(ListTextStyle())
                            .frame(height: geometry.size.height * 0.25)
                            .foregroundColor(Color.black)
                            
                        
                        HStack {
                            ForEach(self.parameters, id: \.self) { parameter in
                                ZStack {
                                    Text(parameter)
                                        .textStyle(ShrinkTextStyle())
                                        .lineLimit(1)
                                        .foregroundColor(.white)
                                        
                                        .frame(height: geometry.size.height * 0.2)
                                        .padding(geometry.size.height * 0.02)
                                        
                                        .background(Color.green)
                                        .cornerRadius(geometry.size.height * 0.02)
                                }
                            }
                            .padding(.vertical, geometry.size.height * 0.05)
                        }
                    }
                    .frame(height: geometry.size.height * 0.84)
                    Spacer()
                }
                .padding(geometry.size.height * 0.1)
            }
            .frame(width: geometry.size.width)
            .clipShape(RoundedRectangle(cornerRadius: geometry.size.height * 0.2))
        }
    }
}

struct EffectRow_Previews: PreviewProvider {
    static var previews: some View {
        EffectRow(title: "Moog Filter",
                  image: Image(systemName: "l.circle.fill"),
                  description: "Digital Implementation of a Moog Ladder Filter.",
                  parameters: ["Cutoff","Resonance"])
        //.previewLayout(.fixed(width: 2688, height: 600))
        .previewLayout(.fixed(width: 812, height: 50))
    }
}

struct CategoryPill: View {
    var categoryName: String
    var fontSize: CGFloat = 12.0
    
    var body: some View {
        ZStack {
            Text(categoryName)
                .font(.system(size: fontSize, weight: .regular))
                .lineLimit(1)
                .foregroundColor(.white)
                .padding(5)
                .background(Color.green)
                .cornerRadius(5)
        }
    }
}
