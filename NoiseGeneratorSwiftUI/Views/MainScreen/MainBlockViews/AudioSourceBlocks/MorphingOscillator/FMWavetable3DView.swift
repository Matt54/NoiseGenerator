//
//  FMWavetable3DView.swift
//  NoiseGeneratorSwiftUI
//
//  Created by Macbook on 6/1/20.
//  Copyright © 2020 Matt Pfeiffer. All rights reserved.
//

import SwiftUI

struct FMWavetable3DView: View {
    
    //@EnvironmentObject var noise: NoiseModel
    @Binding var oscillator: MorphingFMOscillatorBank
    //@Binding var selectedIndex: Int
    @State var xOffset: CGFloat = 0.0
    @State var yOffset: CGFloat = 0.0
    
    var body: some View {
        GeometryReader
        { geometry in
            ZStack{
            Color.darkGray
                .onAppear{
                    self.xOffset = CGFloat(0.4) / CGFloat(self.oscillator.numberOfWavePositions)
                    self.yOffset = CGFloat(-0.6) / CGFloat(self.oscillator.numberOfWavePositions)
                }
                
            ZStack{
                
                //displayWaveTables
                
                /*
                ForEach(self.oscillator.displayWaveTables.indices, id: \.self){ i in
                    Group{
                        Wavetable3DView(wavetable: self.oscillator.displayWaveTables[i].waveform)
                        .frame(width: geometry.size.width * 0.5,
                               height: geometry.size.height * 0.2)
                        .offset(x: CGFloat(i) * geometry.size.width * 0.003,
                                y: CGFloat(i) * geometry.size.height * -0.003)
                    }
                }
                */
                
                
                ForEach((0 ..< (self.oscillator.numberOfWavePositions)).reversed(), id: \.self) { i in
                    Group{
                        Wavetable3D(wavetable: self.oscillator.displayWaveTables[i].waveform)
                        .frame(width: geometry.size.width * 0.5,
                               height: geometry.size.height * 0.2)
                            .offset(x: CGFloat(i) * geometry.size.width * self.xOffset,
                                    y: CGFloat(i) * geometry.size.height * self.yOffset)
                        if(i == self.oscillator.wavePosition){
                            //Wavetable3DHighlight(wavetable: self.oscillator.displayWaveTables[self.oscillator.wavePosition].waveform)
                            Wavetable3DHighlight(wavetable: self.oscillator.displayWaveform)
                            .frame(width: geometry.size.width * 0.5,
                                   height: geometry.size.height * 0.2)
                            .offset(x: CGFloat(self.oscillator.wavePosition) * geometry.size.width * self.xOffset,
                                    y: CGFloat(self.oscillator.wavePosition) * geometry.size.height * self.yOffset)
                            
                        }
                    }
                }
                
                /*
                Wavetable3DHighlightView(wavetable: self.oscillator.displayWaveTables[self.selectedIndex].waveform)
                    .frame(width: geometry.size.width * 0.5,
                           height: geometry.size.height * 0.2)
                    .offset(x: CGFloat(self.selectedIndex) * geometry.size.width * 0.004,
                            y: CGFloat(self.selectedIndex) * geometry.size.height * -0.006)
                */
                
                
                //.foregroundColor(Color.black)
                
                /*
                ForEach(0 ..< 100) { number in
                    Group{
                        Rectangle()
                            .stroke()
                        //.fill(Color.white)
                            .frame(width: geometry.size.width * 0.5,
                                   height: geometry.size.height * 0.2)
                        
                            //.offset(x: 0, y: number * geometry.size.height * 0.01)
                            //.rotation3DEffect(.degrees(-45), axis: (x: 0, y: 1, z: 0))
                            //.rotation3DEffect(.degrees(-15), axis: (x: 1, y: 0, z: 0))
                            //.rotation(Angle(degrees: 60), anchor:.bottom)
                            //.rotationEffect(Angle(degrees: 10), anchor: .bottom)
                            .offset(x: CGFloat(number) * geometry.size.width * 0.003,
                                    y: CGFloat(number) * geometry.size.height * -0.003)
                    }
                    //.rotation3DEffect(.degrees(-15), axis: (x: 1, y: 1, z: -1))
                }
                */
            }
            .offset(x: geometry.size.width * -0.2, y: geometry.size.height * 0.3)
            }
        }
    }
}

struct FMWavetable3DView_Previews: PreviewProvider {
    static var previews: some View {
        FMWavetable3DView(oscillator: .constant(MorphingFMOscillatorBank()))
        .previewLayout(.fixed(width: 700, height: 400))
    }
}
