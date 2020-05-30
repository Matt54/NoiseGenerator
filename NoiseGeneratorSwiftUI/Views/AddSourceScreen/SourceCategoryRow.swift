//
//  SourceCategoryRow.swift
//  NoiseGeneratorSwiftUI
//
//  Created by Macbook on 5/29/20.
//  Copyright © 2020 Matt Pfeiffer. All rights reserved.
//

import SwiftUI

struct SourceCategoryRow: View {
    
    var categoryID: String
    var image: Image
    var description: String
    
    var body: some View {
        GeometryReader{ geometry in
        ZStack(alignment: .leading){
            Color.init(red: 0.9, green: 0.9, blue: 0.9)
            ZStack{
                
                HStack{
                self.image
                    .resizable()
                    .aspectRatio(1.0, contentMode: .fit)
                    .frame(height: geometry.size.height * 0.8)
                    //.padding(.trailing, geometry.size.width * 0.05)
                    .foregroundColor(Color.black)
                    
                Spacer()
                }
                
                VStack(alignment: .center, spacing: 0) {
                    Text(self.categoryID)
                        //.font(.headline)
                        .fontWeight(.bold)
                        .textStyle(ShrinkTextStyle())
                        .frame(height: geometry.size.height * 0.4)
                        .foregroundColor(Color.black)
                        //.fontWeight(.bold)
                        .lineLimit(2)
                        .padding(.bottom, geometry.size.height * 0.05)
                    
                    Text(self.description)
                        .textStyle(ShrinkTextStyle())
                        .frame(height: geometry.size.height * 0.3)
                        .foregroundColor(Color.black)
                }
                .frame(height: geometry.size.height * 0.8)
                //.padding(.horizontal, geometry.size.height * 0.1)
                
                Spacer()
            }
            .padding(geometry.size.height * 0.1)
        }
        .frame(width: geometry.size.width)
        .clipShape(RoundedRectangle(cornerRadius: geometry.size.height * 0.2))
    }
    }
}

struct SourceCategoryRow_Previews: PreviewProvider {
    static var previews: some View {
        SourceCategoryRow(categoryID: "Oscillator",
                          image: Image(systemName: "waveform.circle.fill"),
                          description: "Oscillator Audio Sources")
        //.previewLayout(.fixed(width: 568, height: 320))
        .previewLayout(.fixed(width: 812, height: 125))
    }
}
