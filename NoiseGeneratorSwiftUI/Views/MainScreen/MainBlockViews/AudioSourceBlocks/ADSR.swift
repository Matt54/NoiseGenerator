//
//  ADSR.swift
//  NoiseGeneratorSwiftUI
//
//  Created by Macbook on 5/21/20.
//  Copyright © 2020 Matt Pfeiffer. All rights reserved.
//

import SwiftUI

struct ADSR: View {
    
    @Binding var attack: Double
    @Binding var decay: Double
    @Binding var sustain: Double
    @Binding var release: Double
    
    @State var pad: CGFloat = 0
    
    var body: some View {
        GeometryReader
        { geometry in
            ZStack{
                
                Color.darkGray
                    .onAppear{self.pad = geometry.size.width * 0.01}
                
                GridLines(numberOfGridLines: 14,
                          isVerticalOnly: true)
                    .foregroundColor(Color(red: 1.0, green: 1.0, blue: 1.0,opacity: 0.2))
                
                //stroke
                Path{ path in
                
                    //Start at first Point
                    path.move(to: CGPoint(x: self.pad,
                                          y: geometry.size.height - self.pad))
                    
                    //Attack Point
                    path.addLine(to: CGPoint(x: CGFloat(self.attack / 3.0) * geometry.size.width + self.pad,
                                             y: self.pad))
                    
                    //Sustain Point
                    path.addLine(to: CGPoint(x: CGFloat((self.attack + self.decay) / 3.0) * geometry.size.width,
                                             y: ( (1.0 - CGFloat(self.sustain)) * geometry.size.height + self.pad)))
                    
                    //Release Point
                    path.addLine(to: CGPoint(x: CGFloat((self.attack + self.decay + self.release) / 3.0) * geometry.size.width,
                                             y: geometry.size.height - self.pad))
                }
                .stroke(Color(red: 1.0, green: 1.0, blue: 1.0))
                
                //fill
                Path{ path in
                
                    //Start at first Point
                    path.move(to: CGPoint(x: 0,
                                          y: geometry.size.height))
                    
                    path.addLine(to: CGPoint(x: CGFloat(self.attack / 3.0) * geometry.size.width,
                                             y: 0))
                    
                    path.addLine(to: CGPoint(x: CGFloat((self.attack + self.decay) / 3.0) * geometry.size.width,
                                             y: ( (1.0 - CGFloat(self.sustain)) * geometry.size.height)))
                    
                    path.addLine(to: CGPoint(x: CGFloat((self.attack + self.decay + self.release) / 3.0) * geometry.size.width,
                                             y: geometry.size.height))
                    
                    path.addLine(to: CGPoint(x: 0,
                                             y: geometry.size.height))
                }
                .fill(Color(red: 0.4, green: 0.1, blue: 0.7,opacity: 0.3))
                
                
                // Bottom Left
                Circle()
                    .fill(Color(red: 1.0, green: 1.0, blue: 1.0, opacity: 0.9))
                    .frame(width: geometry.size.width * 0.03)
                    .position(CGPoint(x: geometry.size.width * 0.01,
                                      y: geometry.size.height - self.pad))
                
                
                //Attack
                Circle()
                    .fill(Color(red: 1.0, green: 1.0, blue: 1.0, opacity: 0.9))
                    .frame(width: geometry.size.width * 0.03)
                    .position(CGPoint(x: CGFloat(self.attack / 3.0) * geometry.size.width + self.pad,
                    y: self.pad))
                
                
                // Sustain
                Circle()
                    .fill(Color(red: 1.0, green: 1.0, blue: 1.0, opacity: 0.9))
                    .frame(width: geometry.size.width * 0.03)
                    .position(CGPoint(x: CGFloat((self.attack + self.decay) / 3.0) * geometry.size.width,
                    y: ( (1.0 - CGFloat(self.sustain)) * geometry.size.height + self.pad)))
                
                //Release
                Circle()
                    .fill(Color(red: 1.0, green: 1.0, blue: 1.0, opacity: 0.9))
                    .frame(width: geometry.size.width * 0.03)
                    .position(CGPoint(x: CGFloat((self.attack + self.decay + self.release) / 3.0) * geometry.size.width,
                    y: geometry.size.height - self.pad))
                
                
            }
        }
    }
}

struct ADSR_Previews: PreviewProvider {
    static var previews: some View {
        ADSR(attack: .constant(1.5),
             decay: .constant(0.5),
             sustain: .constant(0.2),
             release: .constant(0.1))
        
        .previewLayout(.fixed(width: 250, height: 150))
    }
}
