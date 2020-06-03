import SwiftUI

struct PresetPicker: View
{
    
    @Binding var oneControlEffect : OneControlWithPresetsAudioEffect
    @Binding var knobModColor: Color
    //@Binding var modulationBeingAssigned: Bool
    @Binding var specialSelection: SpecialSelection
    
    @State var showPresets = false
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var body: some View
    {
    GeometryReader
        { geometry in
        VStack(spacing: 0)
            {
                //Controls - Volumes and Knobs
                HStack(spacing: 0)
                {
                    if(self.oneControlEffect.selectedBlockDisplay == .volume){
                        //Input Volume
                        VStack{
                            VolumeComplete(volumeMixer: self.$oneControlEffect.inputVolumeMixer)
                                .padding(geometry.size.width * 0.05)
                                .frame(width: geometry.size.width * 0.2,height:geometry.size.height * 0.85)
                        }
                        .frame(width:geometry.size.width * 0.2)
                        
                        OutputPlotView(inputNode: self.$oneControlEffect.dummyMixer)
                            .frame(width:geometry.size.width * 0.6,
                                   height: geometry.size.height * 0.6)

                    
                        //Output Volume
                        VStack{
                            VolumeComplete(volumeMixer: self.$oneControlEffect.outputVolumeMixer)
                                .padding(geometry.size.width * 0.05)
                                .frame(width: geometry.size.width * 0.2,height:geometry.size.height * 0.85)
                            
                        }
                        .frame(width:geometry.size.width * 0.2)
                    }
                        
                if(self.oneControlEffect.selectedBlockDisplay == .controls){
                
                
                if(self.showPresets)
                {
                    ScrollView(.vertical, showsIndicators: false)
                    {
                        VStack(spacing: 0)
                            {
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
                else
                {
                    //ZStack
                    //{

                    VStack(spacing: 0)
                        {
                        
                        //Preset selections
                        HStack(spacing: 0) {
                            
                            Button(action: {
                                if(self.oneControlEffect.presetIndex > 0)
                                {
                                    self.oneControlEffect.presetIndex = self.oneControlEffect.presetIndex - 1
                                }
                            }){
                                Image(systemName: "arrowtriangle.left.fill")
                                    .resizable()
                                    .aspectRatio(1.0, contentMode: .fit)
                                    .padding(geometry.size.height * 0.03)
                                    //.font(.system(size: 16))
                                    .foregroundColor(Color.white)
                            }
                            .frame(height: geometry.size.height * 0.15)
                            
                            Button(action: {
                                self.showPresets.toggle()
                            }, label: {
                                Text(self.oneControlEffect.presets[self.oneControlEffect.presetIndex])
                                    .bold()
                                    .foregroundColor(Color.white)
                            })
                            .frame(minWidth: 0,maxWidth: .infinity)
                            
                            //Spacer()
                            
                            Button(action: {
                                if(self.oneControlEffect.presetIndex < self.oneControlEffect.presets.count - 1)
                                {
                                    self.oneControlEffect.presetIndex = self.oneControlEffect.presetIndex + 1
                                }
                            }, label: {
                                Image(systemName: "arrowtriangle.right.fill")
                                    .resizable()
                                    .aspectRatio(1.0, contentMode: .fit)
                                    .padding(geometry.size.height * 0.03)
                                    .foregroundColor(Color.white)
                            })
                            .frame(height: geometry.size.height * 0.15)
                            
                        }
                        .frame(width: geometry.size.width, height:geometry.size.height * 0.15)
                        .background(Color.init(red: 0.2, green: 0.2, blue: 0.2))
                        
                        //Knob 1
                        VStack(spacing: 0)
                            {
                                
                            Text(self.oneControlEffect.control1.display)
                                .textStyle(ShrinkTextStyle())
                                .frame(width: geometry.size.width * 0.2,
                                       height: geometry.size.height * 0.1)
                                
                            KnobComplete(knobModel: self.$oneControlEffect.control1,
                                         knobModColor: self.$knobModColor,
                                         specialSelection: self.$specialSelection)
                                .aspectRatio(1.0, contentMode: .fit)
                                .frame(width:geometry.size.width * 0.175)
                                .padding(.vertical, geometry.size.height * 0.05)
                                
                            Text(self.oneControlEffect.control1.name)
                                .bold()
                                .textStyle(ShrinkTextStyle())
                                .frame(width: geometry.size.width * 0.2,
                                       height: geometry.size.height * 0.1)
                            }
                            .padding(geometry.size.width * 0.025)
                            .frame(height: geometry.size.height * 0.7)
                        
                        
                    }
                    }//VStack
                }
                }
                
                EffectTitleBar(title: self.$oneControlEffect.name,
                               selectedBlockDisplay: self.$oneControlEffect.selectedBlockDisplay,
                               isBypassed: self.$oneControlEffect.isBypassed)
                .frame(height:geometry.size.height * 0.15)
                
            } //VStack pre if/else
            //.padding(5)
            //.border(Color.BlackWhiteColor(for: self.colorScheme), width: 5)
        } //Geometry Reader
    } //View
} //Struct

struct PresetPicker_Previews: PreviewProvider {
    static var previews: some View {
        PresetPicker(oneControlEffect: .constant(AppleReverbAudioEffect(pos: 1)),
                     knobModColor: .constant(Color.yellow),
                     specialSelection: .constant(SpecialSelection.none))
        .previewLayout(.fixed(width: 280, height: 220))
    }
}

struct Preset: Identifiable {
    var id = UUID()
    var name: String
}
