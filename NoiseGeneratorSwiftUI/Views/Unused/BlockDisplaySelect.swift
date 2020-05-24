//
//  BlockDisplaySelect.swift
//  NoiseGeneratorSwiftUI
//
//  Created by Macbook on 5/19/20.
//  Copyright © 2020 Matt Pfeiffer. All rights reserved.
//

import SwiftUI

struct BlockDisplaySelect: View {
    
    @Binding var selectedBlockDisplay: SelectedBlockDisplay
    
    var body: some View {
        GeometryReader{ geometryOut in
        GeometryReader{ geometry in
            VStack(spacing: 0){
                //Settings button
                Button(action: {
                    self.selectedBlockDisplay = SelectedBlockDisplay.controls
                }){
                    ZStack{
                        if(self.selectedBlockDisplay == .controls){
                            Rectangle()
                                //.fill(LinearGradient(Color.darkEnd, Color.darkStart))
                                .fill(Color.yellow)
                            Image(systemName: "slider.horizontal.3")
                                .resizable()
                                .padding(geometry.size.width * 0.2)
                                //.border(Color.black, width: geometry.size.width * 0.05)
                                .foregroundColor(Color.black)
                                .aspectRatio(1.0, contentMode: .fit)
                        }
                        else{
                            Rectangle()
                                .fill(Color.white)
                                //.fill(LinearGradient(Color.offWhite, Color.almostWhite))
                            Image(systemName: "slider.horizontal.3")
                                .resizable()
                                .padding(geometry.size.width * 0.2)
                                //.border(Color.black, width: geometry.size.width * 0.05)
                                .foregroundColor(Color.black)
                                .aspectRatio(1.0, contentMode: .fit)
                        }
                    }
                }
                .aspectRatio(1.0, contentMode: .fit)
                .frame(width: geometry.size.width)
                
                //Settings button
                Button(action: {
                    self.selectedBlockDisplay = SelectedBlockDisplay.volume
                }){
                    ZStack{
                        if(self.selectedBlockDisplay == .volume){
                            Rectangle()
                                //.fill(Color.black)
                                .fill(Color.yellow)
                                //.fill(LinearGradient(Color.darkEnd, Color.darkStart))
                            Image(systemName: "speaker.3.fill")
                                .resizable()
                                .padding(geometry.size.width * 0.2)
                                //.border(Color.black, width: geometry.size.width * 0.05)
                                .foregroundColor(Color.black)
                                .aspectRatio(1.0, contentMode: .fit)
                        }
                        else{
                            Rectangle()
                                .fill(Color.white)
                                //.fill(LinearGradient(Color.offWhite, Color.almostWhite))
                            Image(systemName: "speaker.3.fill")
                                .resizable()
                                .padding(geometry.size.width * 0.2)
                                //.border(Color.black, width: geometry.size.width * 0.05)
                                .foregroundColor(Color.black)
                                .aspectRatio(1.0, contentMode: .fit)
                        }
                    }
                }
                .aspectRatio(1.0, contentMode: .fit)
                .frame(width: geometry.size.width)
            }
            
            Spacer()
        }
        .background(LinearGradient(Color.darkStart,Color.darkGray))
        .padding(geometryOut.size.width * 0.0)
        .border(Color.black, width: geometryOut.size.width * 0.0)
        }
    }
}

struct BlockDisplaySelect_Previews: PreviewProvider {
    static var previews: some View {
        BlockDisplaySelect(selectedBlockDisplay: .constant(SelectedBlockDisplay.volume))
        .previewLayout(.fixed(width: 50, height: 250))
    }
}

public enum SelectedBlockDisplay{
    case controls, volume, adsr
    var name: String {
        return "\(self)"
    }
}
