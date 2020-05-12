//
//  MainHeader.swift
//  NoiseGeneratorSwiftUI
//
//  Created by Macbook on 5/11/20.
//  Copyright © 2020 Matt Pfeiffer. All rights reserved.
//

import SwiftUI
import Combine

struct MainHeader: View {
    
    @EnvironmentObject var noise: NoiseModel
    
    var body: some View {
        GeometryReader{ geometry in
            ZStack{
                
                LinearGradient(Color.white, Color.lightGray)
                
                // Master Volume
                HStack(spacing: geometry.size.width * 0){
                    
                    VStack() {
                        DecimalTextField("0", value: self.$noise.tempo.bpmDecimal)
                    }
                    
                    //VStack(alignment: .leading) {
                    //Group{
                    //    NumberEntryField(value: self.$noise.tempo.bpmString)
                    //}
                    //.keyboardType(.decimalPad)
                        /*
                    .onReceive(Just(self.noise.tempo.bpmString)) { newValue in
                        let filtered = newValue.filter { "0123456789.".contains($0) }
                        if filtered != newValue {
                            self.noise.tempo.bpm = Double(filtered)!
                        }
                    }
                    */
                        //Text("Your username: \(self.noise.tempo.bpmString)")
                    //}
                    
                    //.padding()
                    
                    /*
                    TextField("BPM", text: self.$noise.tempo.bpmString)
                        .font(.system(size: geometry.size.height * 0.5))
                        //.minimumScaleFactor(0.0001)
                        .lineLimit(1)
                        //.scaledToFit()
                    .frame(width:geometry.size.width * (1/10))
                    */
                    
                    ZStack{
                        //Rectangle()
                        Text("BPM:")
                            .bold()
                            .textStyle(ShrinkTextStyle())
                            //.foregroundColor(Color.white)
                    }
                    .frame(width:geometry.size.width * (1/10))
                    
                    ZStack{
                        //Rectangle()
                        Text(String(self.noise.tempo.bpm))
                            .bold()
                            .textStyle(ShrinkTextStyle())
                            //.foregroundColor(Color.white)
                    }
                    .frame(width:geometry.size.width * (1/10))
                    
                    Spacer()
                    
                    KnobComplete(knobModel: self.$noise.masterVolumeControl,
                                 knobModColor: self.$noise.knobModColor,
                    modulationBeingAssigned: self.$noise.modulationBeingAssigned,
                    modulationBeingDeleted: self.$noise.modulationBeingDeleted)
                    .padding(geometry.size.height * 0.1)
                    .aspectRatio(1.0, contentMode: .fit)

                    StereoVolumeDisplay(leftAmplitude: self.$noise.outputAmplitudeLeft,
                                        rightAmplitude: self.$noise.outputAmplitudeRight,
                                        numberOfRects: .constant(8))
                    .padding(geometry.size.height * 0.1)
                    .frame(width:geometry.size.width * (1/15))
                }
            }
        }
    }
}

struct MainHeader_Previews: PreviewProvider {
    static var previews: some View {
        MainHeader().environmentObject(NoiseModel.shared)
        .previewLayout(.fixed(width: 1500, height: 100))
    }
}
