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
    
    @Binding var morphingOscillator: MorphingOscillatorBank
    
    @Binding var knobModColor: Color
    @Binding var specialSelection: SpecialSelection
    //@Binding var modulationBeingAssigned: Bool
    //@Binding var modulationBeingDeleted: Bool
    
    
    var body: some View {
        GeometryReader
        { geometryOut in
            GeometryReader
            { geometry in
                VStack(spacing: 0){
                    
                    HStack(spacing: 0){
                        
                        VStack(spacing: 0){
                            //OutputPlotView(nodeToPlot: self.morphingOscillator.oscillatorMixer)
                            Rectangle()
                                .border(Color.black, width: geometryOut.size.height * 0.01)
                                .padding(geometry.size.height * 0.05)
                            
                            KnobComplete(knobModel: self.$morphingOscillator.control1,
                                         knobModColor: self.$knobModColor,
                                         specialSelection: self.$specialSelection)
                                         //modulationBeingAssigned: self.$modulationBeingAssigned,
                                         //modulationBeingDeleted: self.$modulationBeingDeleted)
                            .aspectRatio(1.0, contentMode: .fit)
                            .padding(geometry.size.height * 0.05)
                            .frame(height: geometry.size.height * 0.3)
                            
                        }
                        .frame(width: geometry.size.width * 0.65,
                               height: geometry.size.height * 0.85)
                        
                        
                        VolumeComplete(amplitude: self.$morphingOscillator.outputAmplitude,
                                       volumeControl: self.$morphingOscillator.outputVolume,
                                       isRightHanded: .constant(true),
                                       numberOfRects: .constant(10),
                                       title: "VOL")
                            .padding(geometry.size.width * 0.05)
                            .frame(width: geometry.size.width * 0.2,
                                   height:geometry.size.height * 0.85)
                    }
                        
                    TitleBar(title: self.$morphingOscillator.name, isBypassed: self.$morphingOscillator.isBypassed)
                        .frame(height:geometry.size.height * 0.15)
                        
                }
                .background(LinearGradient(Color.white, Color.lightGray))
            }
            .padding(geometryOut.size.height * 0.02)
            .border(Color.black, width: geometryOut.size.height * 0.02)
        }
    }
}

struct MorphingOscillatorView_Previews: PreviewProvider {
    static var previews: some View {
        MorphingOscillatorView(morphingOscillator: .constant(MorphingOscillatorBank()),
                               knobModColor: .constant(Color.yellow),
                               specialSelection: .constant(SpecialSelection.none))
                               //modulationBeingAssigned: .constant(false),
                               //modulationBeingDeleted: .constant(false))
        .previewLayout(.fixed(width: 250, height: 150))
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
