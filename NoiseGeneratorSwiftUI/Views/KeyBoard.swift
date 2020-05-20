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
                    /*
                    Text("OCTAVE")
                        .bold()
                        .textStyle(ShrinkTextStyle())
                        .frame(height: geometry.size.height * 0.3)
                    */
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
                self.noise.keyboardViewController
                /*
                KeyBoardViewController(noise: self.noise,
                             octave: self.$noise.firstOctave)*/
                             //midiNoteKeyboardChange: self.$noise.midiNoteKeyboardChange)
                    .frame(width: geometry.size.width - geometry.size.height * 2,
                           height: geometry.size.height)
                    .border(Color.black, width: geometry.size.height * 0.02)
                
                
                VStack(spacing: 0){
                    /*
                Text("OCTAVE")
                    .bold()
                    .textStyle(ShrinkTextStyle())
                    .frame(height: geometry.size.height * 0.3)
                    */
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

struct KeyBoardViewController: UIViewRepresentable {
    typealias UIViewType = AKKeyboardView
    
    @State var keyboardView : AKKeyboardView = AKKeyboardView()
    @State var firstOctave = 1
    
    //@ObservedObject var noise: NoiseModel
    //@Binding var octave: Int
    
    //@EnvironmentObject var noise: NoiseModel
    
    //@Binding var midiNoteKeyboardChange : MIDINoteKeyboardChange
    //@Binding var midiExternalNotesOn: [MIDINoteNumber]
    //@State var notesCurrentlyOn: [MIDINoteNumber] = []
    
    //@Binding var midiExternalNotesOff: [MIDINoteNumber]
    
    

    func makeUIView(context: UIViewRepresentableContext<KeyBoardViewController>) -> AKKeyboardView {
        //view.delegate = noise
        
        // Without this, the keyboard does not respect the frame
        keyboardView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        keyboardView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        keyboardView.firstOctave = firstOctave
        keyboardView.keyOnColor = UIColor.init(red: 0.4, green: 0.1, blue: 0.7, alpha: 1.0)
        keyboardView.polyphonicMode = true
        keyboardView.octaveCount = 3
        //view.programmaticNoteOn(<#T##note: MIDINoteNumber##MIDINoteNumber#>)
        
        return keyboardView
    }

    func updateUIView(_ uiView: AKKeyboardView, context: UIViewRepresentableContext<KeyBoardViewController>) {
        uiView.frame = CGRect(x:0, y:0, width: uiView.intrinsicContentSize.width, height: uiView.intrinsicContentSize.height)
        uiView.sizeToFit()
        uiView.firstOctave = firstOctave
        
        /*
        if(midiNoteKeyboardChange.isOn){
            uiView.programmaticNoteOn(midiNoteKeyboardChange.note)
        }else{
            uiView.programmaticNoteOff(midiNoteKeyboardChange.note)
        }
        */
        
        /*
        let newNotes = midiExternalNotesOn.filter {
            !notesCurrentlyOn.contains($0)
        }
        
        let cutNotes = notesCurrentlyOn.filter {
            !midiExternalNotesOn.contains($0)
        }
        
        newNotes.forEach { note in
            uiView.programmaticNoteOn(note)
            //notesCurrentlyOn.append(note)
        }
 
        
        cutNotes.forEach { note in
            uiView.programmaticNoteOff(note)
        }
        */
        
        /*
        midiExternalNotesOff.forEach { note in
            uiView.programmaticNoteOff(note)
            midiExternalNotesOn = midiExternalNotesOn.filter{$0 != note}
            midiExternalNotesOff = midiExternalNotesOff.filter{$0 != note}
        }
        */
        
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
