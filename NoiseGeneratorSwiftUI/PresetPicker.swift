import SwiftUI

struct PresetPicker: View {
    
    @State var title = "EFFECT TITLE"
    @State var showPresets = false
    
    @Binding var isBypassed : Bool
    @Binding var presetIndex : Int
    @Binding var knobModel : KnobCompleteModel
    @Binding var presets: [String]
    
    
    var body: some View {
        GeometryReader{ geometry in
            
        VStack{
            if(self.showPresets)
            {
            ScrollView(.vertical, showsIndicators: false){
                VStack {
                    ForEach(0 ..< self.presets.count){ n in
                        Button(action: {
                            self.presetIndex = n
                            self.showPresets.toggle()
                        }, label: {
                            Text(self.presets[n])
                                .font(.system(size: 20))
                                .bold()
                                .foregroundColor(Color.white)
                        })
                        .padding()
                        .frame(minWidth: 0,maxWidth: .infinity, maxHeight: 40)
                        .background(Color.gray)
                        .border(Color.white, width: 1)
                    }
                }
            }
            }
            else{
                ZStack
                {
                    VStack {
                        HStack {
                            Button(action: {self.isBypassed.toggle()} ){
                                if(!self.isBypassed){
                                Circle()
                                    .fill(Color.init(red: 0.2, green: 0.2, blue: 0.2))
                                    .frame(width:geometry.size.width * 0.09,
                                           height:geometry.size.width * 0.09)
                                    .overlay(
                                    Image(systemName: "power")
                                        .font(.system(size: 18))
                                        .foregroundColor(Color.yellow)
                                    )
                                }
                                else{
                                    Circle()
                                    .fill(Color.init(red: 0.2, green: 0.2, blue: 0.2))
                                    .frame(width:geometry.size.width * 0.09,
                                           height:geometry.size.width * 0.09)
                                    .overlay(
                                    Image(systemName: "power")
                                        .font(.system(size: 18))
                                        .foregroundColor(Color.gray)
                                    )
                                }
                            }
                            Spacer()
                        }
                        Spacer()
                    }
                    .padding(5)
                VStack{
                Spacer()
                VStack {
                    Text(self.knobModel.display)
                        .font(.system(size: 14))
                    KnobComplete(knobModel: self.$knobModel)
                        .frame(maxWidth:geometry.size.width * 0.3)
                        .frame(maxHeight:geometry.size.width * 0.3)
                    Text(self.knobModel.name)
                        .font(.system(size: 14))
                        .bold()
                        .foregroundColor(Color.black)
                    
                }
                .frame(width:geometry.size.width * 0.35)
                Spacer()
                HStack {
                    Text(self.title)
                        .font(.system(size: 16))
                        .bold()
                        .foregroundColor(Color.white)
                }
                .frame(minWidth: 0,maxWidth: .infinity,minHeight: 30)
                .background(Color.init(red: 0.2, green: 0.2, blue: 0.2))
                HStack {
                    Spacer()
                    Button(action: {
                        if(self.presetIndex > 0)
                        {
                            self.presetIndex = self.presetIndex - 1
                        }
                    }){
                        
                        Text("Prev.")
                    }
                    .frame(minWidth: 50)
                    Spacer()
                    Button(action: {
                        self.showPresets.toggle()
                    }, label: {
                        Text(self.presets[self.presetIndex])
                            .font(.system(size: 16))
                            .bold()
                            .foregroundColor(Color.white)
                    })
                    .frame(minWidth: 0,maxWidth: .infinity)
                    Spacer()
                    Button(action: {
                        if(self.presetIndex < self.presets.count - 1)
                        {
                            self.presetIndex = self.presetIndex + 1
                        }
                    }, label: {
                        Text("Next")
                    })
                    .frame(minWidth: 50)
                    //.frame(minWidth: 0,maxWidth: 40)
                    Spacer()
                }
                .frame(minHeight: 30)
                .background(Color.gray)
                
                    }
            }
            }
            }
            .padding(5)
            .border(Color.black, width: 5)
            
        }
    }
}

struct PresetPicker_Previews: PreviewProvider {
    static var previews: some View {
        PresetPicker(isBypassed: .constant(false),
                     presetIndex: .constant(0),
            knobModel: .constant(KnobCompleteModel()),
                     presets: .constant(["Preset 1", "Preset 2", "Preset 3",
                                        "Preset 4", "Preset 5", "Preset 6"]))
        .previewLayout(.fixed(width: 280, height: 220))
    }
}

struct Preset: Identifiable {
    var id = UUID()
    var name: String
}
