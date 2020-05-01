//
//  EffectRow.swift
//  NoiseGeneratorSwiftUI
//
//  Created by Macbook on 4/29/20.
//  Copyright © 2020 Matt Pfeiffer. All rights reserved.
//

import SwiftUI

struct EffectRow: View {
    
    var title: String
    var image: Image
    var description: String
    var parameters: [String]
    
    var body: some View {
        ZStack(alignment: .leading){
            Color.init(red: 0.9, green: 0.9, blue: 0.9)
            HStack{
                image
                    .font(.system(size: 40))
                    .foregroundColor(Color.black)
                    .frame(width: 50, height: 50, alignment: .center)
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(Color.black)
                        .fontWeight(.bold)
                        .lineLimit(2)
                        .padding(.bottom, 5)
                    
                    Text(description)
                        .font(.footnote)
                        .foregroundColor(Color.black)
                        .padding(.bottom, 5)
                    .padding(.bottom, 5)
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(parameters, id: \.self) { category in
                                CategoryPill(categoryName: category)
                            }
                        }
                    }
                    
                }
                .padding(.horizontal, 0)
            }
            .padding(10)
        }
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

struct EffectRow_Previews: PreviewProvider {
    static var previews: some View {
        EffectRow(title: "Flanger",
                  image: Image(systemName: "l.circle.fill"),
                  description: "Swept Comb Filter Effect.",
                  parameters: ["Depth","Feedback","Frequency","Dry/Wet"])
    }
}

struct CategoryPill: View {
    
    var categoryName: String
    var fontSize: CGFloat = 12.0
    
    var body: some View {
        ZStack {
            Text(categoryName)
                .font(.system(size: fontSize, weight: .regular))
                .lineLimit(1)
                .foregroundColor(.white)
                .padding(5)
                .background(Color.green)
                .cornerRadius(5)
        }
    }
}
