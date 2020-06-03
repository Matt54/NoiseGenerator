//
//  FMOscillatorView.swift
//  NoiseGeneratorSwiftUI
//
//  Created by Macbook on 6/1/20.
//  Copyright © 2020 Matt Pfeiffer. All rights reserved.
//

import SwiftUI

struct FMOscillatorView: View {
    
    @EnvironmentObject var noise: Conductor
    @Binding var morphingOscillator: MorphingFMOscillatorBank
    
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
                                
                                Text("Wavetable Plot")
                                .bold()
                                .textStyle(ShrinkTextStyle())
                                .frame(height: geometry.size.height * 0.1)
                                
                                Button(action: {
                                    self.morphingOscillator.is3DView = !self.morphingOscillator.is3DView
                                }){
                                     if(self.morphingOscillator.is3DView){
                                         FMWavetable3DView(oscillator: self.$morphingOscillator)
                                     }
                                     else{
                                        WavetableDisplay(wavetable: self.$morphingOscillator.displayWaveform)
                                    }
                                }
                                .padding(geometry.size.height * 0.01)
                                .border(Color.black, width: geometry.size.height * 0.01)
                                .frame(width: geometry.size.width * 0.6,
                                       height: geometry.size.height * 0.4)
                                
                                
                                
                                HStack(spacing: 0){
                                    
                                    KnobVerticalStack(knobModel: self.$morphingOscillator.waveformIndexControl,
                                                    removeValue: true)
                                    .frame(width: geometry.size.width * 0.5)
                                    
                                    KnobVerticalStack(knobModel: self.$morphingOscillator.modulationIndexControl,
                                                      removeValue: true)
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
                            //HStack(spacing: 0){
                            
                            /*
                                Rectangle()
                                    .border(Color.black, width: geometryOut.size.height * 0.01)
                                    .padding(geometry.size.height * 0.05)
                            */
                                
                            
                            OutputPlotView(inputNode: self.$morphingOscillator.volumeMixer.input)
                                .frame(width: geometry.size.width * 0.7, height: geometry.size.height * 0.6)
                            
                                
                                VolumeComplete(volumeMixer: self.$morphingOscillator.volumeMixer)
                                    .padding(geometry.size.width * 0.05)
                                    .frame(width: geometry.size.width * 0.2)
                            //}
                        }
                        //Spacer()
                        
                        /*
                        BlockDisplaySelect(selectedBlockDisplay: .constant(SelectedBlockDisplay.controls))
                            .frame(width: geometry.size.height * 0.15)
                        */
                        
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

struct FMOscillatorView_Previews: PreviewProvider {
    static var previews: some View {
        FMOscillatorView(morphingOscillator: .constant(MorphingFMOscillatorBank()))
        .environmentObject(Conductor.shared)
        .previewLayout(.fixed(width: 250, height: 200))
    }
}
