//
//  OscillatorView.swift
//  NoiseGeneratorSwiftUI
//
//  Created by Macbook on 6/1/20.
//  Copyright © 2020 Matt Pfeiffer. All rights reserved.
//

import SwiftUI

struct OscillatorView: View {
    
    @EnvironmentObject var noise: Conductor
    @Binding var morphingOscillator: OscillatorBank
    
    //@Binding var knobModColor: Color
    //@Binding var specialSelection: SpecialSelection
    
    var body: some View {
        GeometryReader
        { geometryOut in
            GeometryReader
            { geometry in
                VStack(spacing: 0){
                    
                    HStack(spacing: 0){
                        
                        //VStack(spacing: 0){
                            
                        if(self.morphingOscillator.selectedBlockDisplay == .controls){
                            VStack(spacing: geometry.size.height * 0.02){
                                
                                ZStack(alignment: .top){
                                    
                                    VStack(spacing: 0.0){
                                        
                                        ZStack{
                                            Rectangle()
                                                .fill(Color.init(UIColor(red:0.2, green:0.2, blue:0.2, alpha: 1.0)))
                                            Text(self.morphingOscillator.wavetableName)
                                                .bold()
                                                .textStyle(ShrinkTextStyle())
                                                .foregroundColor(.white)
                                        }
                                        //.border(Color.black, width: geometry.size.width * 0.5 * 0.015)
                                        .frame(height: geometry.size.height * 0.1)
                                        
                                        Divider()
                                        
                                        Button(action: {
                                            self.morphingOscillator.is3DView = !self.morphingOscillator.is3DView
                                        }){
                                             if(self.morphingOscillator.is3DView){
                                                 OscillatorWavetable3DView(oscillator: self.$morphingOscillator)
                                                    //.padding(geometry.size.width * 0.4 * 0.015)
                                                    //.border(Color.black, width: geometry.size.width * 0.4 * 0.015)
                                             }
                                             else{
                                                WavetableDisplay(wavetable: self.$morphingOscillator.displayWaveform)
                                            }
                                        }
                                    }
                                    
                                }
                                .padding(geometry.size.height * 0.01)
                                .border(Color.black, width: geometry.size.height * 0.01)
                                .padding(geometry.size.height * 0.03)
                                .frame(height: geometry.size.height * 0.55)
                                
                                
                                HStack(spacing: 0){
                                    
                                    KnobVerticalStack(knobModel: self.$morphingOscillator.waveformIndexControl, removeValue: true)
                                    .frame(width: geometry.size.width * 0.5)
                                    
                                    KnobVerticalStack(knobModel: self.$morphingOscillator.warpIndexControl, removeValue: true)
                                    .frame(width: geometry.size.width * 0.5)
                                }
                            }
                            //.frame(width: geometry.size.width)
                            //.aspectRatio(1.0, contentMode: .fit)
                            //.padding(geometry.size.height * 0.05)
                            //.frame(height: geometry.size.height * 0.3)
                        }
                            
                        //}
                        //.frame(width: geometry.size.width * 0.65)
                        
                        
                        
                        if(self.morphingOscillator.selectedBlockDisplay == .adsr){
                            VStack(spacing: geometry.size.height * 0.02){
                                Text("ADSR Volume Envelope")
                                    .bold()
                                    .textStyle(ShrinkTextStyle())
                                    .frame(height: geometry.size.height * 0.1)
                                
                                ADSR(attack: self.$morphingOscillator.attackDisplay,
                                     decay: self.$morphingOscillator.decay,
                                     sustain: self.$morphingOscillator.sustain,
                                     release: self.$morphingOscillator.releaseDisplay)
                                .clipShape(Rectangle())
                                .padding(geometry.size.height * 0.01)
                                .border(Color.black, width: geometry.size.height * 0.01)
                                .frame(width: geometry.size.width * 0.85,
                                       height: geometry.size.height * 0.4)

                                HStack(spacing: geometry.size.height * 0.05){
                                
                                    KnobVerticalStack(knobModel: self.$morphingOscillator.attackControl,
                                                      removeValue: true)
                                    KnobVerticalStack(knobModel: self.$morphingOscillator.decayControl,
                                    removeValue: true)
                                    KnobVerticalStack(knobModel: self.$morphingOscillator.sustainControl,
                                    removeValue: true)
                                    KnobVerticalStack(knobModel: self.$morphingOscillator.releaseControl,
                                    removeValue: true)
                                    }
                            }
                            .padding(geometry.size.height * 0.05)
                        }
                        
                        //.frame(width: geometry.size.width * 0.65)
                        
                        
                        if(self.morphingOscillator.selectedBlockDisplay == .volume){

                            OutputPlotView(inputNode: self.$morphingOscillator.volumeMixer.input)
                                .frame(width: geometry.size.width * 0.7, height: geometry.size.height * 0.6)
                            
                                
                                VolumeComplete(volumeMixer: self.$morphingOscillator.volumeMixer)
                                    .padding(geometry.size.width * 0.05)
                                    .frame(width: geometry.size.width * 0.2)
                        }
                        
                    }
                    .frame(height: geometry.size.height * 0.85)
                    
                    OscillatorTitleBar(title: self.$morphingOscillator.name,
                                       selectedBlockDisplay: self.$morphingOscillator.selectedBlockDisplay,
                                       isBypassed: self.$morphingOscillator.isBypassed)
                    .frame(height:geometry.size.height * 0.15)
                        
                    /*
                    TitleBar(title: self.$morphingOscillator.name, isBypassed: self.$morphingOscillator.isBypassed)
                        .frame(height:geometry.size.height * 0.15)
                    */
                        
                }
                .background(LinearGradient(Color.white, Color.lightGray))
            }
            .padding(geometryOut.size.height * 0.00)
            .border(Color.black, width: geometryOut.size.height * 0.00)
        }
    }
}

struct OscillatorView_Previews: PreviewProvider {
    static var previews: some View {
        OscillatorView(morphingOscillator: .constant(OscillatorBank()))
        .environmentObject(Conductor.shared)
        .previewLayout(.fixed(width: 250, height: 200))
    }
}
