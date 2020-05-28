//
//  MorphingOscillatorView.swift
//  NoiseGeneratorSwiftUI
//
//  Created by Macbook on 5/14/20.
//  Copyright © 2020 Matt Pfeiffer. All rights reserved.
//

import SwiftUI
import AudioKit
import AudioKitUI

struct MorphingOscillatorView: View {
    
    @EnvironmentObject var noise: Conductor
    @Binding var morphingOscillator: MorphingOscillatorBank
    
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
                                         Wavetable3DView(oscillator: self.$morphingOscillator)
                                     }
                                     else{
                                        WavetableDisplay(wavetable: self.$morphingOscillator.displayWaveform)
                                    }
                                }
                                .padding(geometry.size.height * 0.01)
                                .border(Color.black, width: geometry.size.height * 0.01)
                                .frame(width: geometry.size.width * 0.6,
                                       height: geometry.size.height * 0.4)
                                
                                
                                
                            
                                KnobVerticalStack(knobModel: self.$morphingOscillator.indexControl,
                                removeValue: true)
                                    .frame(width: geometry.size.width * 0.5)
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
                                
                                ADSR(attack: self.$morphingOscillator.attack,
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
                            
                            Rectangle()
                                .border(Color.black, width: geometryOut.size.height * 0.01)
                                .padding(geometry.size.height * 0.05)
                            
                            VolumeComplete(volumeMixer: self.$morphingOscillator.volumeMixer)
                                .padding(geometry.size.width * 0.05)
                                .frame(width: geometry.size.width * 0.2)
                        }
                        //Spacer()
                        
                        /*
                        BlockDisplaySelect(selectedBlockDisplay: .constant(SelectedBlockDisplay.controls))
                            .frame(width: geometry.size.height * 0.15)
                        */
                        
                    }
                    .frame(height: geometry.size.height * 0.85)
                    
                    OscillatorTitleBar(title: self.$morphingOscillator.name,
                                       selectedBlockDisplay: self.$morphingOscillator.selectedBlockDisplay)
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

struct MorphingOscillatorView_Previews: PreviewProvider {
    static var previews: some View {
        MorphingOscillatorView(morphingOscillator: .constant(MorphingOscillatorBank()))
        .environmentObject(Conductor.shared)
        .previewLayout(.fixed(width: 250, height: 200))
    }
}


struct OutputPlotView: UIViewRepresentable {
    typealias UIViewType = AKNodeOutputPlot
    //var UIView : AKNodeOutputPlot = AKNodeOutputPlot()
    
    //@EnvironmentObject var noise: NoiseModel
    @State var nodeToPlot: AKMixer?
    //@Binding var octave: Int

    func makeUIView(context: UIViewRepresentableContext<OutputPlotView>) -> AKNodeOutputPlot {
        
        //This is hacky and there's got to be a reason why I got stuck here but,
        //my waveform plots don't work in preview.
        if((ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"]) != "1"){
            let view = AKNodeOutputPlot(nodeToPlot)
            view.plotType = .buffer
            view.shouldFill = false
            view.shouldMirror = true
            view.color = .blue
            view.backgroundColor = .clear
            return view
        }
        else{
            let view = AKNodeOutputPlot()
            view.plotType = .buffer
            view.shouldFill = false
            view.shouldMirror = true
            view.color = .blue
            view.backgroundColor = .clear
            return view
        }

    }

    func updateUIView(_ uiView: AKNodeOutputPlot, context: UIViewRepresentableContext<OutputPlotView>) {
        uiView.frame = CGRect(x:0, y:0, width: uiView.intrinsicContentSize.width, height: uiView.intrinsicContentSize.height)
        uiView.sizeToFit()
        //uiView.firstOctave = octave
    }
    
}
