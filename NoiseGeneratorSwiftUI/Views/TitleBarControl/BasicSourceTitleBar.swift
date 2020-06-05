//
//  BasicSourceTitleBar.swift
//  NoiseGeneratorSwiftUI
//
//  Created by Macbook on 5/31/20.
//  Copyright © 2020 Matt Pfeiffer. All rights reserved.
//

import SwiftUI

struct BasicSourceTitleBar: View {
    @Binding var title: String
    @Binding var selectedBlockDisplay: SelectedBlockDisplay
    
    var body: some View {
        GeometryReader
        { geometry in
            ZStack
                {
                Rectangle()
                    .fill(LinearGradient(Color.darkStart,Color.darkGray))
                    
                    HStack(spacing: 0){
                        Text(self.title)
                            .bold()
                            .textStyle(ShrinkTextStyle())
                            .foregroundColor(Color.white)
                            .padding(.vertical, geometry.size.height * 0.05)
                            //.padding(.leading, geometry.size.width * 0.02)
                            //.frame(height: geometry.size.height)
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

struct BasicSourceTitleBar_Previews: PreviewProvider {
    static var previews: some View {
        BasicSourceTitleBar(title: .constant("Block Title"),
                           selectedBlockDisplay: .constant(SelectedBlockDisplay.adsr))
        .previewLayout(.fixed(width: 150, height: 20))
    }
}
