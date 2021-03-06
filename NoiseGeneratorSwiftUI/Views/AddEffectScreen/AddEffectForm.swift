import SwiftUI

struct AddEffectForm: View {

    @EnvironmentObject var noise: Conductor
    
    init(){
        UITableView.appearance().backgroundColor = UIColor.systemBackground
        UITableView.appearance().separatorColor = UIColor.systemBackground
    }
    
    var body: some View {
        GeometryReader{ geometry in
        VStack(spacing: 0){
            ZStack{
                HStack{
                    
                    Button(action: {
                        print("cancel pressed")
                        self.noise.selectedScreen = SelectedScreen.main
                        
                    })
                    {
                        Text("Cancel")
                        .textStyle(ShrinkTextStyle())
                        .frame(width: geometry.size.width * 0.15,
                        height: geometry.size.height * 0.1,
                        alignment: .leading)
                    }
                    Spacer()
                }
                .padding(.leading, geometry.size.width * 0.015)
                
                Text("Add Audio Effect")
                    //.font(.title)
                    .fontWeight(.bold)
                    .textStyle(ShrinkTextStyle())
                    .frame(width: geometry.size.width * 0.3,
                           height: geometry.size.height * 0.1)
            }
            .frame(width: geometry.size.width,
                   height: geometry.size.height * 0.175)
            
        ScrollView {
            VStack(spacing: geometry.size.height * 0.05){
                ForEach(self.noise.listedEffects , id: \.id){ i in
                    Button(action: {
                        print("You pressed: " + String(i.id))
                        self.noise.selectedScreen = SelectedScreen.main
                        self.noise.createNewEffect(pos: self.noise.allControlEffects.count, effectNumber: i.id)
                    })
                    {
                        EffectRow(title: i.display,
                                  image: i.symbol,
                                  description: i.description,
                                  parameters: i.parameters)
                        .frame(height: geometry.size.height * 0.225)
                    }
                    .padding(.horizontal, geometry.size.width * 0.02)
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.top)
        .background(Color.white)
        }
    }
}

struct AddEffectForm_Previews: PreviewProvider {
    static var previews: some View {
        AddEffectForm().environmentObject(Conductor.shared)
        //.previewLayout(.fixed(width: 2688, height: 1242))
        .previewLayout(.fixed(width: 700, height: 375))
    }
}
