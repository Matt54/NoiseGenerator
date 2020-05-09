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
                HStack(spacing: 0){
                    self.image
                        .resizable()
                        .frame(width: geometry.size.height * 0.7,
                               height: geometry.size.height * 0.7,
                               alignment: .center)
                        .padding(geometry.size.height * 0.15)
                        .foregroundColor(Color.black)
                    VStack(alignment: .leading,spacing: 0) {
                        Text(self.title)
                            .fontWeight(.heavy)
                            .textStyle(ShrinkTextStyle())
                            .frame(height: geometry.size.height * 0.35)
                            .foregroundColor(Color.black)
                        
                        Text(self.description)
                            .textStyle(ShrinkTextStyle())
                            .foregroundColor(Color.black)
                            .padding(.bottom, geometry.size.height * 0.02)
                        
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
                            .padding(.bottom, geometry.size.height * 0.1)
                        }
                    }
                    Spacer()
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
    }
}

struct EffectRow_Previews: PreviewProvider {
    static var previews: some View {
        EffectRow(title: "Flanger",
                  image: Image(systemName: "l.circle.fill"),
                  description: "Swept Comb Filter Effect.",
                  parameters: ["Depth","Feedback","Frequency","Dry/Wet"])
        //.previewLayout(.fixed(width: 2688, height: 600))
        .previewLayout(.fixed(width: 500, height: 90))
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
