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
            VStack(spacing: 0){
                
                VStack(spacing: 0){
                    Rectangle()
                    .overlay(
                        LinearGradient(gradient:
                                        Gradient(colors:
                                            [Color.init(red: 0.7, green: 0.7, blue: 0.7),
                                             Color.lightWood,
                                             Color.darkWood]),
                                       startPoint: .top,
                                       endPoint: .bottom)
                    )
                }
                .frame(height:geometry.size.width * (0.005))
                
                
                HStack(spacing: 0){
                
                    //Down Octave
                   Button(action: {
                        self.noise.firstOctave = self.noise.firstOctave - 1
                   }){
                        ZStack{
                            Rectangle()
                                .fill(Color.black)
                                .cornerRadius(geometry.size.height * 0.03)
                                
                            Image(systemName: "arrow.left")
                                .resizable()
                                .padding(geometry.size.height * 0.02)
                                .foregroundColor(Color.white)
                                .aspectRatio(1.0, contentMode: .fit)
                        }
                   }
                   .padding(geometry.size.height * 0.03)
                   .frame(width: geometry.size.height * 0.4)
                   .padding(.leading, geometry.size.width * 0.01)
                    
                    Spacer()
                    
                    /*
                    Stepper("Octave Count: \(self.noise.octaveCount)", value: self.$noise.octaveCount, in: 1...4)
                    .frame(width: geometry.size.width * 0.3
                           )
                    
                    Spacer()
                    */
                    
                    Text("Octave Count: \(self.noise.octaveCount)")
                    .bold()
                    .textStyle(ShrinkTextStyle())
                    //.foregroundColor(Color.white)
                    
                    Button(action: {
                        if(self.noise.octaveCount > 1){
                         self.noise.octaveCount = self.noise.octaveCount - 1
                            //self.noise.keyboardViewController
                            //print(self.noise.octaveCount)
                        }
                    }){
                         ZStack{
                             Rectangle()
                                 .fill(Color.black)
                                 .cornerRadius(geometry.size.height * 0.03)
                                 
                             Image(systemName: "minus")
                                //.resizable()
                                .padding(geometry.size.height * 0.02)
                                .foregroundColor(Color.white)
                                .aspectRatio(1.0, contentMode: .fit)
                                .frame(height: geometry.size.height * 0.1)
                                
                                
                                
                             //.resizable()
                         }
                    }
                    .padding(geometry.size.height * 0.03)
                    .frame(width: geometry.size.height * 0.3)
                    
                    Button(action: {
                        if(self.noise.octaveCount < 7){
                         self.noise.octaveCount = self.noise.octaveCount + 1
                            //print(self.noise.octaveCount)
                        }
                    }){
                         ZStack{
                             Rectangle()
                                 .fill(Color.black)
                                 .cornerRadius(geometry.size.height * 0.03)
                                 
                             Image(systemName: "plus")
                                 .resizable()
                                 .padding(geometry.size.height * 0.02)
                                 .foregroundColor(Color.white)
                                 .aspectRatio(1.0, contentMode: .fit)
                         }
                    }
                    .padding(geometry.size.height * 0.03)
                    .frame(width: geometry.size.height * 0.3)
                    
                    Spacer()
                    
                    //Up Octave Button
                   Button(action: {
                       self.noise.firstOctave = self.noise.firstOctave + 1
                   }){
                       ZStack{
                               Rectangle()
                                    .fill(Color.black)
                                    .cornerRadius(geometry.size.height * 0.03)
                               Image(systemName: "arrow.right")
                                   .resizable()
                                   .padding(geometry.size.height * 0.02)
                                   .foregroundColor(Color.white)
                                   .aspectRatio(1.0, contentMode: .fit)
                           }
                   }
                    .padding(geometry.size.height * 0.03)
                    .frame(width: geometry.size.height * 0.4)
                    .padding(.trailing, geometry.size.width * 0.01)
                }
                .frame(height: geometry.size.height * 0.2)
                .background(LinearGradient(Color.lightWood,Color.darkWood))
                
                HStack(spacing: 0){
                    
                     Rectangle()
                       .frame(width:geometry.size.width * (0.001))
                       .foregroundColor(Color.init(red: 0.7, green: 0.7, blue: 0.7))
                       Rectangle()
                           .fill(LinearGradient(Color.lightWood,Color.darkWood))
                           .frame(width:geometry.size.width * (0.002))
                       Rectangle()
                           .fill(LinearGradient(Color.lightWood,Color.darkWood))
                           .frame(width:geometry.size.width * (0.002))
                       Rectangle()
                           .frame(width:geometry.size.width * (0.001))
                           .foregroundColor(Color.init(red: 0.7, green: 0.7, blue: 0.7))
                    
                    //Keyboard
                    self.noise.keyboardViewController
                        .border(Color.black, width: geometry.size.height * 0.02)
                        //.frame(width: geometry.size.width,height: geometry.size.height * 0.8)
                        
                    
                    Rectangle()
                    .frame(width:geometry.size.width * (0.001))
                    .foregroundColor(Color.init(red: 0.7, green: 0.7, blue: 0.7))
                    Rectangle()
                        .fill(LinearGradient(Color.darkWood,Color.lightWood))
                        .frame(width:geometry.size.width * (0.002))
                    Rectangle()
                        .fill(LinearGradient(Color.darkWood,Color.lightWood))
                        .frame(width:geometry.size.width * (0.002))
                    Rectangle()
                        .frame(width:geometry.size.width * (0.001))
                        .foregroundColor(Color.init(red: 0.7, green: 0.7, blue: 0.7))
                }
                //.frame(height: geometry.size.height * 0.8)

            }
        }
    }
}

struct KeyBoard_Previews: PreviewProvider {
    static var previews: some View {
        KeyBoard()
            .previewLayout(.fixed(width: 1000, height: 100))
            .environmentObject(NoiseModel.shared)
    }
}

struct KeyBoardViewController: UIViewRepresentable {
    typealias UIViewType = AKKeyboardView
    
    @State var keyboardView : AKKeyboardView = AKKeyboardView()
    @State var firstOctave = 1
    @State var octaveCount : Int = 3// = 3
    
    func setKeyboardOctave(_ octaveCount: Int){
        keyboardView.octaveCount = octaveCount
        keyboardView.setNeedsDisplay()
    }
    

    func makeUIView(context: UIViewRepresentableContext<KeyBoardViewController>) -> AKKeyboardView {
        //view.delegate = noise
        
        // Without this, the keyboard does not respect the frame
        keyboardView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        keyboardView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        keyboardView.firstOctave = firstOctave
        keyboardView.keyOnColor = UIColor.init(red: 0.4, green: 0.1, blue: 0.7, alpha: 1.0)
        keyboardView.polyphonicMode = true
        keyboardView.octaveCount = octaveCount
        
        keyboardView.whiteKeyOff = UIColor.init(red: 1.0, green: 1.0, blue: 245/255, alpha: 1.0)
        
        return keyboardView
    }

    func updateUIView(_ uiView: AKKeyboardView, context: UIViewRepresentableContext<KeyBoardViewController>) {
        
        keyboardView.frame = CGRect(x:0, y:0, width: uiView.intrinsicContentSize.width, height: uiView.intrinsicContentSize.height)
        keyboardView.sizeToFit()
        keyboardView.firstOctave = firstOctave
        keyboardView.octaveCount = octaveCount
        
        
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
