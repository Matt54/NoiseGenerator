//
//  NoiseTitleBar.swift
//  NoiseGeneratorSwiftUI
//
//  Created by Macbook on 5/28/20.
//  Copyright © 2020 Matt Pfeiffer. All rights reserved.
//

import SwiftUI

struct NoiseTitleBar: View {
    @Binding var title: String
    @Binding var selectedBlockDisplay: SelectedBlockDisplay
    @Binding var isBypassed: Bool
    
    var body: some View {
        GeometryReader
        { geometry in
            ZStack
                {
                Rectangle()
                    .fill(LinearGradient(Color.darkStart,Color.darkGray))
                    
                    HStack(spacing: 0){
                        
                        PowerButton2(isBypassed: self.$isBypassed)
                            .padding(geometry.size.width * 0.02)
                            .aspectRatio(1.0, contentMode: .fit)
                            .frame(height: geometry.size.height)
                        
                        
                        Text(self.title)
                            .bold()
                            .textStyle(ShrinkTextStyle())
                            .foregroundColor(Color.white)
                            .padding(.vertical, geometry.size.height * 0.05)
                            //.padding(.leading, geometry.size.width * 0.02)
                            //.frame(height: geometry.size.height * 0.8)
                        Spacer()
                        
                        Button(action: {
                            self.selectedBlockDisplay = SelectedBlockDisplay.adsr
                        }){
                            ZStack{
                                if(self.selectedBlockDisplay == .adsr){
                                    Circle()
                                        .fill(Color.yellow)
                                        .aspectRatio(1.0, contentMode: .fit)
                                    Image(systemName: "skew")
                                        .resizable()
                                        .padding(geometry.size.height * 0.2)
                                        //.border(Color.black, width: geometry.size.width * 0.05)
                                        .foregroundColor(Color.black)
                                        .aspectRatio(1.0, contentMode: .fit)
                                }
                                else{
                                    Circle()
                                        .fill(Color.white)
                                        .aspectRatio(1.0, contentMode: .fit)
                                    Image(systemName: "skew")
                                        .resizable()
                                        .padding(geometry.size.height * 0.2)
                                        .foregroundColor(Color.black)
                                        .aspectRatio(1.0, contentMode: .fit)
                                }
                            }
                        }
                        .padding(geometry.size.height * 0.15)
                        .frame(height: geometry.size.height)
                        
                        /*
                        Button(action: {
                            self.selectedBlockDisplay = SelectedBlockDisplay.controls
                        }){
                            ZStack{
                                if(self.selectedBlockDisplay == .controls){
                                    Circle()
                                        .fill(Color.yellow)
                                        .aspectRatio(1.0, contentMode: .fit)
                                    Image(systemName: "waveform.path")
                                        .resizable()
                                        .padding(geometry.size.height * 0.2)
                                        //.border(Color.black, width: geometry.size.width * 0.05)
                                        .foregroundColor(Color.black)
                                        .aspectRatio(1.0, contentMode: .fit)
                                }
                                else{
                                    Circle()
                                        .fill(Color.white)
                                        .aspectRatio(1.0, contentMode: .fit)
                                    Image(systemName: "waveform.path")
                                        .resizable()
                                        .padding(geometry.size.height * 0.2)
                                        .foregroundColor(Color.black)
                                        .aspectRatio(1.0, contentMode: .fit)
                                }
                            }
                        }
                        .padding(geometry.size.height * 0.15)
                        .frame(height: geometry.size.height)
                        */
                        
                        Button(action: {
                            self.selectedBlockDisplay = SelectedBlockDisplay.volume
                        }){
                            ZStack{
                                if(self.selectedBlockDisplay == .volume){
                                    Circle()
                                        .fill(Color.yellow)
                                        .aspectRatio(1.0, contentMode: .fit)
                                    Image(systemName: "speaker.3.fill")
                                        .resizable()
                                        .padding(geometry.size.height * 0.2)
                                        //.border(Color.black, width: geometry.size.width * 0.05)
                                        .foregroundColor(Color.black)
                                        .aspectRatio(1.0, contentMode: .fit)
                                }
                                else{
                                    Circle()
                                        .fill(Color.white)
                                        .aspectRatio(1.0, contentMode: .fit)
                                    Image(systemName: "speaker.3.fill")
                                        .resizable()
                                        .padding(geometry.size.height * 0.2)
                                        .foregroundColor(Color.black)
                                        .aspectRatio(1.0, contentMode: .fit)
                                }
                            }
                        }
                        .padding(geometry.size.height * 0.15)
                        .frame(height: geometry.size.height)
                        
                    }
                    
                }
        }
    }
}

struct NoiseTitleBar_Previews: PreviewProvider {
    static var previews: some View {
        NoiseTitleBar(title: .constant("NGEN 1"),
                           selectedBlockDisplay: .constant(SelectedBlockDisplay.controls),
                           isBypassed: .constant(false))
        .previewLayout(.fixed(width: 150, height: 20))
    }
}
