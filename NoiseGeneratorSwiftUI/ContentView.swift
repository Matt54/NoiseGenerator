//
//  ContentView.swift
//  NoiseGeneratorSwiftUI
//
//  Created by Macbook on 3/29/20.
//  Copyright © 2020 Matt Pfeiffer. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView: View {
    @EnvironmentObject var noise: NoiseModel
    
    var body: some View {
        VStack{
            VStack {
                HStack {
                    Button(action: noise.toggleSound) {
                        if(noise.isPlaying){
                            Image(systemName: "stop.circle")
                                .font(.system(size: 26))
                        }
                        else{
                            Image(systemName: "play.circle")
                                .font(.system(size: 26))
                        }
                        //Text(noise.isPlaying ? "Sound on" : "Sound off")
                            
                            
                        Spacer()
                    }
                }
            }
            HStack {
                Spacer()

                TriangleDrag(lVal: $noise.whiteVal,
                            tVal: $noise.pinkVal,
                            rVal: $noise.brownVal)
                    .frame(width:250, height: 250)
                Spacer()
            }

            if(noise.tremoloDisplayed){
                Spacer()
                TwoControlTemplate(title: "Tremolo",
                                   isBypassed: $noise.tremoloBypassed,
                                   knobModel1: $noise.tremoloDepthControl,
                                   knobModel2: $noise.tremoloFrequencyControl)
                .frame(width: 280, height: 180)
            }
            
            /*
            ForEach(self.$noise.twoControlEffects, id: \.id) { effect in
                
                    TwoControlTemplate(title: "Low Pass Filter",
                        isBypassed: effect.isBypassed,
                        knobModel1: effect.control1,
                        knobModel2: effect.control2)
                        .frame(width: 280, height: 180)
                
                Text(String(effect.control1.name))
            }
             
             
             
            */
             
            //ForEach(noise.twoControlEffects.indices) { index in
            /*
            ForEach($noise.twoControlEffects) { (effect: Binding<NoiseModel>) in
                if(self.noise.twoControlEffects[index].isDisplayed){
                    Spacer()
                    TwoControlTemplate(title: "Low Pass Filter",
                        isBypassed: self.effect.isBypassed,
                        knobModel1: self.effect.control1,
                        knobModel2: self.effect.control2)
                        .frame(width: 280, height: 180)
                }
            }
             
             ForEach(noise.twoControlEffects.indices){ index in
                 if(self.noise.twoControlEffects[0].isDisplayed){
                     Spacer()
                     TwoControlTemplate(title: "Low Pass Filter",
                         isBypassed: self.$noise.twoControlEffects[0].isBypassed,
                         knobModel1: self.$noise.twoControlEffects[0].control1,
                         knobModel2: self.$noise.twoControlEffects[0].control2)
                         .frame(width: 280, height: 180)
                }
             }
 */
            //ForEach(noise.twoControlEffects){ effect in
                
            //ForEach (0 ..< self.noise.twoControlEffects.count) { i in
            ForEach(noise.twoControlEffects.indices){ i in
                Spacer()
                VStack{
                if(self.noise.twoControlEffects[i].isDisplayed){
                  TwoControlTemplate(title: "Low Pass Filter",
                      isBypassed: self.$noise.twoControlEffects[i].isBypassed,
                      knobModel1: self.$noise.twoControlEffects[i].control1,
                      knobModel2: self.$noise.twoControlEffects[i].control2)
                        .frame(width: 280, height: 180)
                }
                }
            }
            
            /*
            ForEach (0 ..< self.noise.twoControlEffects.count) { i in
                if(self.noise.twoControlEffects[i].isDisplayed){
                     Spacer()
                     TwoControlTemplate(title: "Low Pass Filter",
                         isBypassed: self.$noise.twoControlEffects[i].isBypassed,
                         knobModel1: self.$noise.twoControlEffects[i].control1,
                         knobModel2: self.$noise.twoControlEffects[i].control2)
                         .frame(width: 280, height: 180)
                }
            }
 */
            
            /*
            ForEach(noise.twoControlEffects.indices) { index in
                 if(self.noise.twoControlEffects[index].isDisplayed){
                     Spacer()
                     TwoControlTemplate(title: "Low Pass Filter",
                         isBypassed: self.$noise.twoControlEffects[index].isBypassed,
                         knobModel1: self.$noise.twoControlEffects[index].control1,
                         knobModel2: self.$noise.twoControlEffects[index].control2)
                         .frame(width: 280, height: 180)
                }
             }
 */
            
            /*
            if(noise.myFilter.isDisplayed){
                Spacer()
                TwoControlTemplate(title: "Low Pass Filter",
                                   isBypassed: $noise.myFilter.isBypassed,
                                   knobModel1: $noise.myFilter.control1,
                                   knobModel2: $noise.myFilter.control2)
                    .frame(width: 280, height: 180)
            }
            */
            
            if(noise.reverbDisplayed){
                Spacer()
                PresetPicker(title: "Apple Simple Reverb",
                             isBypassed: $noise.reverbBypassed,
                             presetIndex: $noise.reverbPresetIndex,
                             knobModel: $noise.reverbDryWetControl,
                             presets: $noise.reverbPresets)
                    .frame(width: 280, height: 220)
            }
            
            Spacer()
            
            HStack {
                Button(action: noise.toggleTremoloDisplay) {
                    if(noise.tremoloDisplayed){
                        Image(systemName: "t.circle.fill")
                            .font(.system(size: 26))
                    }
                    else{
                        Image(systemName: "t.circle")
                            .font(.system(size: 26))
                    }
                }
                
                ForEach(noise.allControlEffects.indices) { index in
                    Button(action: self.noise.allControlEffects[index].toggleDisplayed) {
                        if(self.noise.allControlEffects[index].isDisplayed){
                            Image(systemName: "f.circle.fill")
                                .font(.system(size: 26))
                        }
                        else{
                            Image(systemName: "f.circle")
                                .font(.system(size: 26))
                        }
                    }
                        /*
                    if(self.noise.myFilter.isDisplayed){
                        Spacer()
                        TwoControlTemplate(title: "Low Pass Filter",
                            isBypassed: self.$noise.twoControlEffects[index].isBypassed,
                            knobModel1: self.$noise.twoControlEffects[index].control1,
                            knobModel2: self.$noise.twoControlEffects[index].control2)
                            .frame(width: 280, height: 180)
                    }
                    */
                }
                /*
                Button(action: noise.toggleFilterDisplay) {
                    if(noise.filterDisplayed){
                        Image(systemName: "f.circle.fill")
                            .font(.system(size: 26))
                    }
                    else{
                        Image(systemName: "f.circle")
                            .font(.system(size: 26))
                    }
                }
                */
                Button(action: noise.toggleReverbDisplay) {
                    if(noise.reverbDisplayed){
                        Image(systemName: "r.circle.fill")
                            .font(.system(size: 26))
                    }
                    else{
                        Image(systemName: "r.circle")
                            .font(.system(size: 26))
                    }
                }
            }
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
