//
//  BasicSourceView.swift
//  NoiseGeneratorSwiftUI
//
//  Created by Macbook on 5/31/20.
//  Copyright © 2020 Matt Pfeiffer. All rights reserved.
//

import SwiftUI

struct BasicSourceView: View {
    
    @EnvironmentObject var noise: Conductor
    @Binding var adsrAudioSource: RhodesPianoBank
    
    //@Binding var knobModColor: Color
    //@Binding var specialSelection: SpecialSelection
    
    var body: some View {
        GeometryReader
        { geometryOut in
            GeometryReader
            { geometry in
                VStack(spacing: 0){
                    
                    HStack(spacing: 0){
                        
                        if(self.adsrAudioSource.selectedBlockDisplay == .adsr){
                            VStack(spacing: geometry.size.height * 0.02){
                                Text("ADSR Volume Envelope")
                                    .bold()
                                    .textStyle(ShrinkTextStyle())
                                    .frame(height: geometry.size.height * 0.1)
                                
                                ADSR(attack: self.$adsrAudioSource.attackDisplay,
                                     decay: self.$adsrAudioSource.decay,
                                     sustain: self.$adsrAudioSource.sustain,
                                     release: self.$adsrAudioSource.releaseDisplay)
                                .clipShape(Rectangle())
                                .padding(geometry.size.height * 0.01)
                                .border(Color.black, width: geometry.size.height * 0.01)
                                .frame(width: geometry.size.width * 0.85,
                                       height: geometry.size.height * 0.4)

                                HStack(spacing: geometry.size.height * 0.05){
                                
                                    KnobVerticalStack(knobModel: self.$adsrAudioSource.attackControl,
                                                      removeValue: true)
                                    KnobVerticalStack(knobModel: self.$adsrAudioSource.decayControl,
                                    removeValue: true)
                                    KnobVerticalStack(knobModel: self.$adsrAudioSource.sustainControl,
                                    removeValue: true)
                                    KnobVerticalStack(knobModel: self.$adsrAudioSource.releaseControl,
                                    removeValue: true)
                                    }
                            }
                            .padding(geometry.size.height * 0.05)
                        }
                        
                        
                        if(self.adsrAudioSource.selectedBlockDisplay == .volume){
                            
                            OutputPlotView(inputNode: self.$adsrAudioSource.volumeMixer.input)
                                .frame(width: geometry.size.width * 0.7, height: geometry.size.height * 0.6)
                            
                                
                                VolumeComplete(volumeMixer: self.$adsrAudioSource.volumeMixer)
                                    .padding(geometry.size.width * 0.05)
                                    .frame(width: geometry.size.width * 0.2)
                        }
                        
                    }
                    .frame(height: geometry.size.height * 0.85)
                    
                    BasicSourceTitleBar(title: self.$adsrAudioSource.name,
                                       selectedBlockDisplay: self.$adsrAudioSource.selectedBlockDisplay)
                    .frame(height:geometry.size.height * 0.15)
                        
                }
                .background(LinearGradient(Color.white, Color.lightGray))
            }
            .padding(geometryOut.size.height * 0.00)
            .border(Color.black, width: geometryOut.size.height * 0.00)
        }
    }
}

struct BasicSourceView_Previews: PreviewProvider {
    static var previews: some View {
        BasicSourceView(adsrAudioSource: .constant(RhodesPianoBank()))
        .environmentObject(Conductor.shared)
        .previewLayout(.fixed(width: 250, height: 200))
    }
}
