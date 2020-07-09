//
//  Wavetable3DView.swift
//  NoiseGeneratorSwiftUI
//
//  Created by Macbook on 5/25/20.
//  Copyright © 2020 Matt Pfeiffer. All rights reserved.
//

import SwiftUI

struct Wavetable3DView: View {
    
    @Binding var oscillator: MorphingOscillatorBank
    @State var xOffset: CGFloat = 0.0
    @State var yOffset: CGFloat = 0.0
    
    var body: some View {
        GeometryReader
        { geometry in
            ZStack{
            Color.darkGray
                .onAppear{
                    self.xOffset = CGFloat(0.4) / CGFloat(self.oscillator.numberOf3DTables + 1)
                    self.yOffset = CGFloat(-0.6) / CGFloat(self.oscillator.numberOf3DTables + 1)
                }
                
            ZStack{
                
                ForEach((0 ..< (self.oscillator.numberOf3DTables+1)).reversed(), id: \.self) { i in
                    Group{
                        Wavetable3D(wavetable: self.oscillator.displayWaveTables[i].waveform)
                        .frame(width: geometry.size.width * 0.5,
                               height: geometry.size.height * 0.2)
                            .offset(x: CGFloat(i) * geometry.size.width * self.xOffset,
                                    y: CGFloat(i) * geometry.size.height * self.yOffset)
                        if(i == self.oscillator.displayIndex){
                            Wavetable3DHighlight(wavetable: self.oscillator.displayWaveTables[self.oscillator.displayIndex].waveform)
                            .frame(width: geometry.size.width * 0.5,
                                   height: geometry.size.height * 0.2)
                            .offset(x: CGFloat(self.oscillator.displayIndex) * geometry.size.width * self.xOffset,
                                    y: CGFloat(self.oscillator.displayIndex) * geometry.size.height * self.yOffset)
                            
                        }
                    }
                }
            }
            .offset(x: geometry.size.width * -0.2, y: geometry.size.height * 0.3)
            }
        }
    }
}

struct WaveformTransformView_Previews: PreviewProvider {
    static var previews: some View {
        Wavetable3DView(oscillator: .constant(MorphingOscillatorBank()))
            .previewLayout(.fixed(width: 700, height: 400))
    }
}

struct Wavetable3D: UIViewRepresentable {
    typealias UIViewType = DrawView
    
    var wavetable: [Float]

    func makeUIView(context: UIViewRepresentableContext<Wavetable3D>) -> DrawView {
        let myView = DrawView(wavetable, hasClearBackground: true)
        
        myView.backgroundColor = UIColor.clear
        
        myView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        myView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        return myView
    }

    func updateUIView(_ uiView: DrawView, context: UIViewRepresentableContext<Wavetable3D>) {
        uiView.frame = CGRect(x:0, y:0, width: uiView.intrinsicContentSize.width, height: uiView.intrinsicContentSize.height)
        uiView.sizeToFit()
        
        uiView.table = wavetable
        
        uiView.setNeedsDisplay()
    }
}

struct Wavetable3DHighlight: UIViewRepresentable {
    typealias UIViewType = DrawView
    
    var wavetable: [Float]

    func makeUIView(context: UIViewRepresentableContext<Wavetable3DHighlight>) -> DrawView {
        let myView = DrawView(wavetable, hasClearBackground: true, isHighlightView: true)
        
        myView.backgroundColor = UIColor.clear
        
        myView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        myView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        return myView
    }

    func updateUIView(_ uiView: DrawView, context: UIViewRepresentableContext<Wavetable3DHighlight>) {
        uiView.frame = CGRect(x:0, y:0, width: uiView.intrinsicContentSize.width, height: uiView.intrinsicContentSize.height)
        uiView.sizeToFit()
        
        uiView.table = wavetable
        
        uiView.setNeedsDisplay()
    }
}
