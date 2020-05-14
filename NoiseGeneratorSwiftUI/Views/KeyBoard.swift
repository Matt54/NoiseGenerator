//
//  KeyBoard.swift
//  NoiseGeneratorSwiftUI
//
//  Created by Macbook on 5/13/20.
//  Copyright © 2020 Matt Pfeiffer. All rights reserved.
//

import SwiftUI
import AudioKit
import AudioKitUI


struct KeyBoard: View {
    
    @EnvironmentObject var noise: NoiseModel
    
    var body: some View {
        GeometryReader{ geometry in
            
            HStack(spacing: 0){
                //Invert Button
                VStack(spacing: 0){
                    Text("OCTAVE")
                        .bold()
                        .textStyle(ShrinkTextStyle())
                        .frame(height: geometry.size.height * 0.3)
                    
                   Button(action: {
                        self.noise.firstOctave = self.noise.firstOctave - 1
                   }){
                       Image(systemName: "arrow.down.square.fill")
                           .resizable()
                           .padding(geometry.size.height * 0.05)
                            .foregroundColor(Color.black)
                            .aspectRatio(1.0, contentMode: .fit)
                   }
                    
                }
                .padding(geometry.size.height * 0.1)
                .frame(width: geometry.size.height,
                       height: geometry.size.height)
                .border(Color.black, width: geometry.size.height * 0.02)
                
                KeyBoardView(noise: self.noise, octave: self.$noise.firstOctave)
                    .frame(width: geometry.size.width - geometry.size.height * 2,
                           height: geometry.size.height)
                    .border(Color.black, width: geometry.size.height * 0.02)
                
                
                VStack(spacing: 0){
                Text("OCTAVE")
                    .bold()
                    .textStyle(ShrinkTextStyle())
                    .frame(height: geometry.size.height * 0.3)
                //Invert Button
               Button(action: {
                   self.noise.firstOctave = self.noise.firstOctave + 1
               }){
                       Image(systemName: "arrow.up.square.fill")
                           .resizable()
                           .padding(geometry.size.height * 0.05)
                            .foregroundColor(Color.black)
                            .aspectRatio(1.0, contentMode: .fit)
               }

                }
                .padding(geometry.size.height * 0.1)
                .frame(width: geometry.size.height,
                       height: geometry.size.height)
                .border(Color.black, width: geometry.size.height * 0.02)
            }
        }
    }
}

struct KeyBoard_Previews: PreviewProvider {
    static var previews: some View {
        KeyBoard()
            .previewLayout(.fixed(width: 500, height: 50))
            .environmentObject(NoiseModel.shared)
    }
}

struct KeyBoardView: UIViewRepresentable {
    typealias UIViewType = AKKeyboardView
    
    //@EnvironmentObject var noise: NoiseModel
    @ObservedObject var noise: NoiseModel
    @Binding var octave: Int

    func makeUIView(context: UIViewRepresentableContext<KeyBoardView>) -> AKKeyboardView {
        let view = AKKeyboardView()
        
        view.delegate = noise
        
        // Without this, the keyboard does not respect the frame
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        view.firstOctave = octave
        view.keyOnColor = UIColor.init(red: 0.4, green: 0.1, blue: 0.7, alpha: 1.0)
        view.polyphonicMode = true
        
        return view
    }

    func updateUIView(_ uiView: AKKeyboardView, context: UIViewRepresentableContext<KeyBoardView>) {
        uiView.frame = CGRect(x:0, y:0, width: uiView.intrinsicContentSize.width, height: uiView.intrinsicContentSize.height)
        uiView.sizeToFit()
        uiView.firstOctave = octave
    }
    
    /*
    class Coordinator: NSObject, AKKeyboardDelegate {
        func noteOn(note: MIDINoteNumber) {
            <#code#>
        }
        
        func noteOff(note: MIDINoteNumber) {
            <#code#>
        }
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    */
    

}
