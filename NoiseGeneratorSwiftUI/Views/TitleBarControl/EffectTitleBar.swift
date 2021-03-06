//
//  EffectTitleBar.swift
//  NoiseGeneratorSwiftUI
//
//  Created by Macbook on 5/28/20.
//  Copyright © 2020 Matt Pfeiffer. All rights reserved.
//

import SwiftUI

struct EffectTitleBar: View {
    @Binding var title: String
    @Binding var selectedBlockDisplay: SelectedBlockDisplay
    @Binding var isBypassed: Bool
    
    var body: some View {
        GeometryReader
        { geometry in
            
            ZStack{
                
                //Background
                Rectangle()
                    .fill(LinearGradient(Color.darkStart,Color.darkGray))
                
                //Content
                HStack(spacing: 0){
                    
                    //Power Button
                    PowerButton2(isBypassed: self.$isBypassed)
                        .padding(geometry.size.width * 0.02)
                        .aspectRatio(1.0, contentMode: .fit)
                        .frame(height: geometry.size.height)
                        
                    //Title Text
                    Text(self.title)
                        .bold()
                        .textStyle(ShrinkTextStyle())
                        .foregroundColor(Color.white)
                        .padding(.vertical, geometry.size.height * 0.05)
                    
                    //Push above to Left and below to right
                    Spacer()
                        
                    //button 1
                    Button(action: {
                        self.selectedBlockDisplay = SelectedBlockDisplay.controls
                    }){
                        ZStack{
                            if(self.selectedBlockDisplay == .controls){
                                Circle()
                                    .fill(Color.yellow)
                                    .aspectRatio(1.0, contentMode: .fit)
                                Image(systemName: "slider.horizontal.3")
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
                                Image(systemName: "slider.horizontal.3")
                                    .resizable()
                                    .padding(geometry.size.height * 0.2)
                                    .foregroundColor(Color.black)
                                    .aspectRatio(1.0, contentMode: .fit)
                            }
                        }
                    }
                    .padding(geometry.size.height * 0.15)
                    .frame(height: geometry.size.height)
                       
                    //button 2
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
                    
                }//hstack
            }//zstack
        }//geometry
    }//view
}//struct

struct EffectTitleBar_Previews: PreviewProvider {
    static var previews: some View {
        EffectTitleBar(title: .constant("Block Title"),
                           selectedBlockDisplay: .constant(SelectedBlockDisplay.controls),
                           isBypassed: .constant(false))
        .previewLayout(.fixed(width: 150, height: 20))
    }
}
