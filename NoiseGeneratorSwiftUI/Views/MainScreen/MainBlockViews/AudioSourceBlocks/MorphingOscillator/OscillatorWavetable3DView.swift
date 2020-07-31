//
//  FMWavetable3DView.swift
//  NoiseGeneratorSwiftUI
//
//  Created by Macbook on 6/1/20.
//  Copyright © 2020 Matt Pfeiffer. All rights reserved.
//

import SwiftUI

struct OscillatorWavetable3DView: View {
    
    //@EnvironmentObject var noise: NoiseModel
    @Binding var oscillator: OscillatorBank
    //@Binding var selectedIndex: Int
    @State var xOffset: CGFloat = 0.0
    @State var yOffset: CGFloat = 0.0
    
    var body: some View {
        GeometryReader
        { geometry in
            ZStack{
            Color.darkGray
                .onAppear{
                    self.xOffset = CGFloat(0.45) / CGFloat(self.oscillator.numberOfWavePositions)
                    self.yOffset = CGFloat(-0.6) / CGFloat(self.oscillator.numberOfWavePositions)
                }
                
            ZStack{
                
                
                
                ForEach((0 ..< (self.oscillator.numberOfWavePositions)).reversed(), id: \.self) { i in
                    Group{
                        Wavetable3D(wavetable: self.oscillator.displayWaveTables[i].waveform)
                        .frame(width: geometry.size.width * 0.5,
                               height: geometry.size.height * 0.35)
                            .offset(x: CGFloat(i) * geometry.size.width * self.xOffset,
                                    y: CGFloat(i) * geometry.size.height * self.yOffset)
                        if(i == self.oscillator.wavePosition){
                            Wavetable3DHighlight(wavetable: self.oscillator.displayWaveform)
                            .frame(width: geometry.size.width * 0.5,
                                   height: geometry.size.height * 0.35)
                            .offset(x: CGFloat(self.oscillator.wavePosition) * geometry.size.width * self.xOffset,
                                    y: CGFloat(self.oscillator.wavePosition) * geometry.size.height * self.yOffset)
                            
                        }
                    }
                }

            }
            .offset(x: geometry.size.width * -0.225, y: geometry.size.height * 0.3)
            }
        }
    }
}

struct OscillatorWavetable3DView_Previews: PreviewProvider {
    static var previews: some View {
        OscillatorWavetable3DView(oscillator: .constant(OscillatorBank()))
        .previewLayout(.fixed(width: 700, height: 400))
    }
}
