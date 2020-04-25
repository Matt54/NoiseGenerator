import SwiftUI

struct AddEffectForm: View {

    @EnvironmentObject var noise: NoiseModel
    
    var body: some View {
        NavigationView {
            Form {
                ForEach(noise.listedEffects , id: \.id){ i in
                    Button(action: {
                        print("You pressed: " + String(i.id))
                        self.noise.addingEffects = false
                        self.noise.createNewEffect(pos: self.noise.allControlEffects.count, effectNumber: i.id)
                    })
                    {
                        HStack {
                            i.symbol
                            Text(" - " + i.display)
                        }
                    }
                }
                Button(action: {self.noise.addingEffects = false})
                {
                    HStack {
                        Image(systemName: "x.circle")
                        Text(" - " + "CANCEL")
                    }
                }
            }.navigationBarTitle(Text("Add Effect"))
        }
    }
}

struct AddEffectForm_Previews: PreviewProvider {
    static var previews: some View {
        AddEffectForm().environmentObject(NoiseModel.shared)
    }
}
