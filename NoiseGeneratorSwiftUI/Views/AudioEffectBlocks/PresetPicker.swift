import SwiftUI

struct PresetPicker: View {
    
    @Binding var oneControlEffect : OneControlWithPresetsAudioEffect
    @Binding var knobModColor: Color
    @Binding var modulationBeingAssigned: Bool
    
    
    @State var showPresets = false
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var body: some View {
        GeometryReader{ geometry in
            
        VStack{
            if(self.showPresets)
            {
            ScrollView(.vertical, showsIndicators: false){
                VStack {
                    ForEach(0 ..< self.oneControlEffect.presets.count){ n in
                        Button(action: {
                            self.oneControlEffect.presetIndex = n
                            self.showPresets.toggle()
                        }, label: {
                            Text(self.oneControlEffect.presets[n])
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

                VStack{
                    HStack {
                        
                        Button(action: {
                            if(self.oneControlEffect.presetIndex > 0)
                            {
                                self.oneControlEffect.presetIndex = self.oneControlEffect.presetIndex - 1
                            }
                        }){
                            
                            //Text("Prev.")
                            Image(systemName: "arrowtriangle.left.fill")
                                .font(.system(size: 16))
                                .foregroundColor(Color.white)
                        }
                        .frame(minWidth: 50)
                        Spacer()
                        Button(action: {
                            self.showPresets.toggle()
                        }, label: {
                            Text(self.oneControlEffect.presets[self.oneControlEffect.presetIndex])
                                .font(.system(size: 16))
                                .bold()
                                .foregroundColor(Color.white)
                        })
                        .frame(minWidth: 0,maxWidth: .infinity)
                        Spacer()
                        Button(action: {
                            if(self.oneControlEffect.presetIndex < self.oneControlEffect.presets.count - 1)
                            {
                                self.oneControlEffect.presetIndex = self.oneControlEffect.presetIndex + 1
                            }
                        }, label: {
                            //Text("Next")
                            Image(systemName: "arrowtriangle.right.fill")
                                .font(.system(size: 16))
                                .foregroundColor(Color.white)
                        })
                        .frame(minWidth: 50)
                        //.frame(minWidth: 0,maxWidth: 40)
                    }
                    .frame(minHeight: 30)
                    .background(Color.init(red: 0.2, green: 0.2, blue: 0.2))
                    
                    //Knob
                    Spacer()
                    VStack {
                        Text(self.oneControlEffect.control1.display)
                            .font(.system(size: 14))
                        KnobComplete(knobModel: self.$oneControlEffect.control1,
                                     knobModColor: self.$knobModColor,
                                     modulationBeingAssigned: self.$modulationBeingAssigned,
                                     modulationBeingDeleted: .constant(false))
                            .frame(minWidth:geometry.size.width * 0.275,                           maxWidth:geometry.size.width * 0.275,
                                   minHeight:geometry.size.width * 0.275,
                                   maxHeight: geometry.size.width * 0.275)
                        Text(self.oneControlEffect.control1.name)
                            .font(.system(size: 14))
                            .bold()
                        //.foregroundColor(Color.black)
                        }
                        .frame(width:geometry.size.width * 0.35)
                        Spacer()
                    
                
                    HStack {
                        Text(self.oneControlEffect.name)
                            .font(.system(size: 16))
                            .bold()
                            .foregroundColor(Color.white)
                    }
                        .frame(minWidth: 0,maxWidth: .infinity, minHeight: geometry.size.height * 0.11 + 10)
                        .background(Color.init(red: 0.2, green: 0.2, blue: 0.2))
                    
                
                
                    }
                    
                    // Power Button
                    VStack {
                        Spacer()
                        HStack {
                            Button(action: {self.oneControlEffect.isBypassed.toggle()}){
                                if(!self.oneControlEffect.isBypassed){
                                Circle()
                                    .fill(Color.init(red: 0.0, green: 0.0, blue: 0.0))
                                    .frame(width:geometry.size.height * 0.11,
                                           height:geometry.size.height * 0.11)
                                    .overlay(
                                    Image(systemName: "power")
                                        .font(.system(size: 18))
                                        .foregroundColor(Color.yellow)
                                    )
                                }
                                else{
                                    Circle()
                                    .fill(Color.init(red: 0.0, green: 0.0, blue: 0.0))
                                    .frame(width:geometry.size.height * 0.11,
                                           height:geometry.size.height * 0.11)
                                    .overlay(
                                    Image(systemName: "power")
                                        .font(.system(size: 18))
                                        .foregroundColor(Color.gray)
                                    )
                                }
                            }
                            Spacer()
                        }
                        
                    }
                    .padding(EdgeInsets(top: 0, leading: 3, bottom: 6, trailing: 0))
                    
            }
            }
            }
            .padding(5)
            .border(Color.BlackWhiteColor(for: self.colorScheme), width: 5)
            
        }
    }
}

struct PresetPicker_Previews: PreviewProvider {
    static var previews: some View {
        PresetPicker(oneControlEffect: .constant(OneControlWithPresetsAudioEffect()),
                     knobModColor: .constant(Color.yellow),
                     modulationBeingAssigned: .constant(false))
        .previewLayout(.fixed(width: 280, height: 220))
    }
}

struct Preset: Identifiable {
    var id = UUID()
    var name: String
}
