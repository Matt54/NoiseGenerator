//
//  OscillatorView.swift
//  NoiseGeneratorSwiftUI
//
//  Created by Macbook on 6/1/20.
//  Copyright © 2020 Matt Pfeiffer. All rights reserved.
//

import SwiftUI

struct OscillatorView: View {
    
    @EnvironmentObject var noise: Conductor
    @Binding var morphingOscillator: OscillatorBank
    
    // how far the circle has been dragged
    @State private var offset = CGSize.zero

    // whether it is currently being dragged or not
    @State private var isDragging = false
    
    @State private var swipeDistance : CGFloat = 0.0
    
    var body: some View {
        
        // a drag gesture that updates offset and isDragging as it moves around
        let dragGesture = DragGesture(minimumDistance: 0.0, coordinateSpace: .local)
            .onChanged {
                value in self.offset = value.translation
                print(value.location.x)
                
                //if(!self.hasDragged){ self.hasDragged = true }
                
                //print(self.offset)
                
                if(!self.morphingOscillator.isWavetableSwap){
                    if(value.location.x > self.swipeDistance){
                        self.offset = .zero
                        self.isDragging = false
                        self.morphingOscillator.loadWavetable(wavetableURL: DirectorySystem.sharedInstance.getNextWavetable()!)
                    }
                    else if(value.location.x < 0){
                        self.offset = .zero
                        self.isDragging = false
                        self.morphingOscillator.loadWavetable(wavetableURL: DirectorySystem.sharedInstance.getPreviousWavetable()!)
                        
                    }
                }
                
            }
            .onEnded { _ in
                withAnimation {
                    self.offset = .zero
                    self.isDragging = false
                    print("drag ended")
                }
            }

        // a long press gesture that enables isDragging
        let pressGesture = LongPressGesture(minimumDuration: 0.5)
            .onEnded { value in
                withAnimation {
                    if(!self.morphingOscillator.isWavetableSwap){
                        self.isDragging = true
                        print("is Dragging is true")
                    }
                }
            }
        
        // a combined gesture that forces the user to long press then drag
        let combined = pressGesture.sequenced(before: dragGesture)
        
        return GeometryReader
        { geometryOut in
            GeometryReader
            { geometry in

                VStack(spacing: 0){
                    
                    HStack(spacing: 0){
                        
                        //VStack(spacing: 0){
                            
                        if(self.morphingOscillator.selectedBlockDisplay == .controls){
                            VStack(spacing: geometry.size.height * 0.02){
                                
                                ZStack(alignment: .top){
                                    
                                    VStack(spacing: 0.0){
                                        
                                        ZStack{
                                            Rectangle()
                                                .fill(Color.init(UIColor(red:0.2, green:0.2, blue:0.2, alpha: 1.0)))
                                            Text(self.morphingOscillator.wavetableName)
                                                .bold()
                                                .textStyle(ShrinkTextStyle())
                                                .foregroundColor(.white)
                                        }
                                        //.border(Color.black, width: geometry.size.width * 0.5 * 0.015)
                                        .frame(height: geometry.size.height * 0.1)
                                        
                                        Divider()
                                        
                                        /*Button(action: {
                                            self.morphingOscillator.is3DView = !self.morphingOscillator.is3DView
                                        }){*/
                                        
                                        ZStack{
                                             if(self.morphingOscillator.is3DView){
                                                 OscillatorWavetable3DView(oscillator: self.$morphingOscillator)
                                             }
                                             else{
                                                WavetableDisplay(wavetable: self.$morphingOscillator.displayWaveform)
                                            }
                                            if(self.isDragging){
                                                HStack(spacing: 0.0){
                                                    Image(systemName: "arrowtriangle.left.fill")
                                                        .resizable()
                                                        .aspectRatio(0.5, contentMode: .fit)
                                                        .padding(geometry.size.height * 0.07)
                                                        .foregroundColor(Color.white)
                                                        .background(Color.black)
                                                        .opacity(0.4)
                                                    
                                                    
                                                    ZStack{
                                                        Rectangle().opacity(0.4)
                                                            
                                                        Text("SWAP WAVETABLE")
                                                            .bold()
                                                            .textStyle(ShrinkTextStyle())
                                                            .foregroundColor(.white)
                                                    }
                                                    
                                                    
                                                    Image(systemName: "arrowtriangle.right.fill")
                                                        .resizable()
                                                        .aspectRatio(0.5, contentMode: .fit)
                                                        .padding(geometry.size.height * 0.07)
                                                        .foregroundColor(Color.white)
                                                        .background(Color.black)
                                                        .opacity(0.4)
                                                }.animation(.easeInOut)
                                            
                                            }
                                            if(self.morphingOscillator.isWavetableSwap){
                                                ZStack{
                                                    Rectangle()
                                                        
                                                    Text("Loading")
                                                        .bold()
                                                        .textStyle(ShrinkTextStyle())
                                                        .foregroundColor(.white)
                                                    }.opacity(0.5)
                                            }
                                        }
                                        .onTapGesture(count: 2){
                                            self.morphingOscillator.randomizeWaveform()
                                        }
                                        .onTapGesture {
                                            self.morphingOscillator.is3DView = !self.morphingOscillator.is3DView
                                            self.offset = .zero
                                            self.isDragging = false
                                        }
                                        .simultaneousGesture(combined)
                                        
                                        //.gesture(combined)
                                        .onAppear(perform: {self.swipeDistance = geometry.size.width})
                                        
                                    }
                                    
                                }
                                .padding(geometry.size.height * 0.01)
                                .border(Color.black, width: geometry.size.height * 0.01)
                                //.padding(geometry.size.height * 0.03)
                                .frame(height: geometry.size.height * 0.5)
                                
                                
                                HStack(spacing: 0){
                                    KnobVerticalStack(knobModel: self.$morphingOscillator.waveformIndexControl, removeValue: true)
                                    //.frame(width: geometry.size.width * 0.5)
                                    
                                    KnobVerticalStack(knobModel: self.$morphingOscillator.warpIndexControl, removeValue: true)
                                    //.frame(width: geometry.size.width * 0.5)
                                }
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
                                
                                ADSR(attack: self.$morphingOscillator.attackDisplay,
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

                            OutputPlotView(inputNode: self.$morphingOscillator.volumeMixer.input)
                                .frame(width: geometry.size.width * 0.7, height: geometry.size.height * 0.6)
                            
                                
                                VolumeComplete(volumeMixer: self.$morphingOscillator.volumeMixer)
                                    .padding(geometry.size.width * 0.05)
                                    .frame(width: geometry.size.width * 0.2)
                        }
                        
                    }
                    .frame(height: geometry.size.height * 0.85)
                    
                    OscillatorTitleBar(title: self.$morphingOscillator.name,
                                       selectedBlockDisplay: self.$morphingOscillator.selectedBlockDisplay,
                                       isBypassed: self.$morphingOscillator.isBypassed)
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

struct OscillatorView_Previews: PreviewProvider {
    static var previews: some View {
        OscillatorView(morphingOscillator: .constant(OscillatorBank()))
        .environmentObject(Conductor.shared)
        .previewLayout(.fixed(width: 250, height: 200))
    }
}
