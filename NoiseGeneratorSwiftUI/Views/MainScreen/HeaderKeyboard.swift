//
//  HeaderKeyboard.swift
//  NoiseGeneratorSwiftUI
//
//  Created by Macbook on 5/27/20.
//  Copyright © 2020 Matt Pfeiffer. All rights reserved.
//

import SwiftUI

struct HeaderKeyboard: View {
    
    @EnvironmentObject var noise: Conductor
    
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
                        .cornerRadius(geometry.size.height * 0.2)
                        
                    Image(systemName: "arrow.left")
                        .resizable()
                        .padding(geometry.size.height * 0.1)
                        .foregroundColor(Color.white)
                        .aspectRatio(1.0, contentMode: .fit)
                }
           }
           .padding(geometry.size.height * 0.2)
           .frame(width: geometry.size.width * 0.075)
           //.padding(.leading, geometry.size.width * 0.005)
            
            Spacer()
            
            Text("Octave Count: \(self.noise.octaveCount)")
            .bold()
            .textStyle(ShrinkTextStyle())
            .padding(geometry.size.height * 0.05)
            
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
                         .cornerRadius(geometry.size.height * 0.2)
                         
                     Image(systemName: "minus")
                        .resizable()
                        .padding(geometry.size.height * 0.175)
                        .foregroundColor(Color.white)
                        .aspectRatio(1.5, contentMode: .fit)
                        
                        
                        
                     //.resizable()
                 }
            }
            .padding(geometry.size.height * 0.2)
            .frame(width: geometry.size.width * 0.05)
            
            Button(action: {
                if(self.noise.octaveCount < 7){
                 self.noise.octaveCount = self.noise.octaveCount + 1
                    //print(self.noise.octaveCount)
                }
            }){
                 ZStack{
                     Rectangle()
                         .fill(Color.black)
                         .cornerRadius(geometry.size.height * 0.2)
                         
                     Image(systemName: "plus")
                         .resizable()
                         .padding(geometry.size.height * 0.1)
                         .foregroundColor(Color.white)
                         .aspectRatio(1.0, contentMode: .fit)
                 }
            }
            .padding(geometry.size.height * 0.2)
            .frame(width: geometry.size.width * 0.05)
            
            Spacer()
            
            //Up Octave Button
           Button(action: {
               self.noise.firstOctave = self.noise.firstOctave + 1
           }){
               ZStack{
                       Rectangle()
                            .fill(Color.black)
                            .cornerRadius(geometry.size.height * 0.2)
                       Image(systemName: "arrow.right")
                                    .resizable()
                                    .padding(geometry.size.height * 0.1)
                                    .foregroundColor(Color.white)
                                    .aspectRatio(1.0, contentMode: .fit)
                            }
                       }
                       .padding(geometry.size.height * 0.2)
                       .frame(width: geometry.size.width * 0.075)
        }
        //.frame(height: geometry.size.width * 0.04)
        .background(LinearGradient(Color.lightWood,Color.darkWood))
            
            // Makes the view feel more centered (
            VStack(spacing: 0){
                Rectangle()
                .fill(LinearGradient(Color.lightWood,Color.darkWood))
            }
            .frame(height:geometry.size.width * (0.0025))
            
        }
        }
    }
}

struct HeaderKeyboard_Previews: PreviewProvider {
    static var previews: some View {
        HeaderKeyboard()
        .previewLayout(.fixed(width: 1000, height: 40))
        .environmentObject(Conductor.shared)
    }
}
