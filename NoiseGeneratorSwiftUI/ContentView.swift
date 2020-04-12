//
//  ContentView.swift
//  NoiseGeneratorSwiftUI
//
//  Created by Macbook on 3/29/20.
//  Copyright © 2020 Matt Pfeiffer. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var noise: NoiseModel
    
    var body: some View {
        VStack{
            VStack {
                HStack {
                    Button(action: noise.toggleSound) {
                        Text(noise.isPlaying ? "Sound on" : "Sound off")
                            .frame(width: 100, height: 20)
                        Spacer()
                    }
                }
            }
            HStack {
                Spacer()

                TriangleDrag(lVal: $noise.whiteVal,
                            tVal: $noise.pinkVal,
                            rVal: $noise.brownVal)
                    .frame(width:300, height: 300)
                Spacer()
            }

            Spacer()
            TwoControlTemplate(title: "Tremolo",
                           knobModel1: $noise.tremoloDepthControl,
                           knobModel2: $noise.tremoloFrequencyControl)
            .frame(width: 330, height: 200)
            Spacer()
            TwoControlTemplate(title: "Low Pass Filter",
                               knobModel1: $noise.lowPassCutoffControl,
                               knobModel2: $noise.lowPassResonanceControl)
                .frame(width: 330, height: 200)
            Spacer()
            /*
            VStack {
                Text("Reverb Dry/Wet (0 - 1)")
                Slider(value: $noise.reverbDryWet, in: 0.0...1.0)
                Text("\(String(format: "%.1f",noise.reverbDryWet))")
            }
             */
        }
        .padding(.leading,30)
        .padding(.trailing,30)
        .padding(.bottom,10)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(NoiseModel.shared)
    }
}
