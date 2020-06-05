//
//  ModulationTitleBar.swift
//  NoiseGeneratorSwiftUI
//
//  Created by Macbook on 6/4/20.
//  Copyright © 2020 Matt Pfeiffer. All rights reserved.
//

import SwiftUI

struct ModulationTitleBar: View {
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
                        
                    //pattern button
                    Button(action: {
                        self.selectedBlockDisplay = SelectedBlockDisplay.pattern
                    }){
                        ZStack{
                            if(self.selectedBlockDisplay == .pattern){
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

                    //pattern button
                    Button(action: {
                        self.selectedBlockDisplay = SelectedBlockDisplay.controls
                    }){
                        ZStack{
                            if(self.selectedBlockDisplay == .controls){
                                Circle()
                                    .fill(Color.yellow)
                                    .aspectRatio(1.0, contentMode: .fit)
                                Image(systemName: "gear")
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
                                Image(systemName: "gear")
                                    .resizable()
                                    .padding(geometry.size.height * 0.2)
                                    .foregroundColor(Color.black)
                                    .aspectRatio(1.0, contentMode: .fit)
                            }
                        }
                    }
                    .padding(geometry.size.height * 0.15)
                    .frame(height: geometry.size.height)
                       
                    //list button
                    Button(action: {
                        self.selectedBlockDisplay = SelectedBlockDisplay.list
                    }){
                        ZStack{
                            if(self.selectedBlockDisplay == .list){
                                Circle()
                                    .fill(Color.yellow)
                                    .aspectRatio(1.0, contentMode: .fit)
                                Image(systemName: "list.dash")
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
                                Image(systemName: "list.dash")
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

struct ModulationTitleBar_Previews: PreviewProvider {
    static var previews: some View {
        ModulationTitleBar(title: .constant("LFO 1"),
                           selectedBlockDisplay: .constant(SelectedBlockDisplay.controls),
                           isBypassed: .constant(false))
        .previewLayout(.fixed(width: 150, height: 20))
    }
}
