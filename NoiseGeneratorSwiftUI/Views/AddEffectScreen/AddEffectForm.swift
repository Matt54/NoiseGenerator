import SwiftUI

struct AddEffectForm: View {

    @EnvironmentObject var noise: NoiseModel
    
    init(){
        UITableView.appearance().backgroundColor = UIColor.systemBackground
        UITableView.appearance().separatorColor = UIColor.systemBackground
    }
    
    var body: some View {
        VStack(spacing: 0){
            ZStack{
                HStack{
                    
                    Button(action: {
                        print("cancel pressed")
                        self.noise.addingEffects = false
                        
                    })
                    {
                        Text("Cancel")
                    }
                    Spacer()
                }
                .padding(.leading, 10)
                
                Text("Add Audio Effect")
                    .font(.title)
                .fontWeight(.bold)
            }
            .padding(.top, 50)
            
        ScrollView {
            VStack(spacing: 20){
                ForEach(noise.listedEffects , id: \.id){ i in
                    Button(action: {
                        print("You pressed: " + String(i.id))
                        self.noise.addingEffects = false
                        self.noise.createNewEffect(pos: self.noise.allControlEffects.count, effectNumber: i.id)
                    })
                    {
                        EffectRow(title: i.display,
                                  image: i.symbol,
                                  description: i.description,
                                  parameters: i.parameters)
                    }
                    .padding(.horizontal, 20)
                    }
                }
            }
            .padding(.top, 10)
        }
        .edgesIgnoringSafeArea(.top)
        .background(Color.white)
    }
}

struct AddEffectForm_Previews: PreviewProvider {
    static var previews: some View {
        AddEffectForm().environmentObject(NoiseModel.shared)
    }
}
