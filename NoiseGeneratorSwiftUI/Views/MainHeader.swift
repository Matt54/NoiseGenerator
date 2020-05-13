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
    @State private var textRemember: String = ""
    
    private var decimalFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        return f
    }()
    
    var body: some View {
        GeometryReader{ geometryOut in
        GeometryReader{ geometry in
            ZStack{
                
                LinearGradient(Color.white, Color.lightGray)
                
                // Master Volume
                HStack(spacing: 0){

                    
                    ZStack{
                        //Rectangle()
                        Text("BPM:")
                            .bold()
                            .textStyle(ShrinkTextStyle())
                            //.foregroundColor(Color.white)
                    }
                    .frame(width:geometry.size.width * (1/10))
                    
                        TextField("",
                                  text: self.$noise.tempo.bpmString,
                                  onEditingChanged: { (editing) in
                                    // Deletes old entry
                                    if editing {
                                        print("editing")
                                        self.textRemember = self.noise.tempo.bpmString
                                        self.noise.tempo.bpmString = ""
                                        self.noise.stopModulations()
                                    }
                                    else{
                                        print("changed")
                                        if( !self.noise.tempo.validateTempo(tempoString: self.noise.tempo.bpmString) )
                                        {
                                            self.noise.tempo.bpmString = self.textRemember
                                        }
                                        
                                        self.noise.tempo.bpm = Double(self.noise.tempo.bpmString)!
                                        self.noise.updateModulations()
                                        self.noise.startModulations()
                                    }
                                    })
                        /*,
                                  onCommit: {
                                    print("Commited")
                                    //self.output = "You typed: " + self.input
                                })*/
                            .font(.system(size: geometry.size.height * 0.5))
                            .keyboardType(.decimalPad)
                            .background(Color.white)
                            .cornerRadius(geometry.size.height * 0.2)
                            .multilineTextAlignment(.center)
                            .frame(width: geometry.size.width * (1/10),
                                   height: geometry.size.height * 0.7)
                    
                    
                    
                    /*
                    ZStack{
                        //Rectangle()
                        Text(String(self.noise.tempo.bpm))
                            .bold()
                            .textStyle(ShrinkTextStyle())
                            //.foregroundColor(Color.white)
                    }
                    .frame(width:geometry.size.width * (1/10))
                    */
                    
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
        .padding(geometryOut.size.height * 0)
        .border(Color.black, width: geometryOut.size.height * 0)
        }
    }
}

struct MainHeader_Previews: PreviewProvider {
    static var previews: some View {
        MainHeader().environmentObject(NoiseModel.shared)
        .previewLayout(.fixed(width: 1500, height: 100))
    }
}
