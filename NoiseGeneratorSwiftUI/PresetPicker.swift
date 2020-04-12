//
//  PresetPicker.swift
//  NoiseGeneratorSwiftUI
//
//  Created by Macbook on 4/11/20.
//  Copyright © 2020 Matt Pfeiffer. All rights reserved.
//

import SwiftUI

struct PresetPicker: View {
    
    @State private var presetIndex = 4
    @State var showPresets = false
    
    /*
    var presets: [Preset] = [Preset(name:"Cathedral"), Preset(name:"Large Hall"), Preset(name:"Large Hall 2"),
    Preset(name:"Large Room"), Preset(name:"Large Room 2"), Preset(name:"Medium Chamber"),
    Preset(name:"Medium Hall"), Preset(name:"Medium Hall 2"), Preset(name:"Medium Hall 3"),
    Preset(name:"Medium Room"), Preset(name:"Plate"), Preset(name:"Small Room")]
     */
    
    var presets = ["Cathedral", "Large Hall", "Large Hall 2",
    "Large Room", "Large Room 2", "Medium Chamber",
    "Medium Hall", "Medium Hall 2", "Medium Hall 3",
    "Medium Room", "Plate", "Small Room"]
    
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
                                .font(.system(size: 26))
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
                
                
                HStack {
                    Spacer()
                    Button(action: {
                        if(self.presetIndex > 0)
                        {
                            self.presetIndex = self.presetIndex - 1
                        }
                    }, label: {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(Color.white)
                    })
                    .frame(minWidth: 0,maxWidth: 40)
                    Button(action: {
                        self.showPresets.toggle()
                    }, label: {
                        Text(self.presets[self.presetIndex])
                            .font(.system(size: 26))
                            .bold()
                            .foregroundColor(Color.white)
                    })
                    .frame(minWidth: 0,maxWidth: .infinity)
                    Button(action: {
                        if(self.presetIndex < self.presets.count - 1)
                        {
                            self.presetIndex = self.presetIndex + 1
                        }
                    }, label: {
                        Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: 26))
                        .foregroundColor(Color.white)
                    })
                    .frame(minWidth: 0,maxWidth: 40)
                    Spacer()
                }
                .frame(minHeight: 40)
                .background(Color.gray)
                Spacer()
                VStack {
                    
                    Text("Value")
                    KnobComplete(knobModel: .constant(KnobCompleteModel()))
                        .frame(maxHeight:geometry.size.width * 0.3)
                    Text("DRY/WET")
                        .font(.system(size: 14))
                        .bold()
                        .foregroundColor(Color.black)
                    
                }
                .frame(width:geometry.size.width * 0.3)
                
                Spacer()
                HStack {
                    Text("Apple Simple Reverb")
                        .font(.system(size: 26))
                        .bold()
                        .foregroundColor(Color.white)
                        
                        
                }
                .frame(minWidth: 0,maxWidth: .infinity)
                .background(Color.init(red: 0.2, green: 0.2, blue: 0.2))
                
            }

            }
            .padding(5)
            .border(Color.black, width: 5)
        }
    }
}

struct PresetPicker_Previews: PreviewProvider {
    static var previews: some View {
        PresetPicker()
        .previewLayout(.fixed(width: 400, height: 280))
    }
}

struct Preset: Identifiable {
    var id = UUID()
    var name: String
}
