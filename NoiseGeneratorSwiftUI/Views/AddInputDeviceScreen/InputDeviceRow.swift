//
//  InputDeviceRow.swift
//  NoiseGeneratorSwiftUI
//
//  Created by Macbook on 5/8/20.
//  Copyright © 2020 Matt Pfeiffer. All rights reserved.
//

import SwiftUI



struct InputDeviceRow: View {
    
    var deviceID: String
    var description: String
    
    var body: some View {
        ZStack(alignment: .leading){
            Color.init(red: 0.9, green: 0.9, blue: 0.9)
            HStack{
                Image(systemName: "mic.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50, alignment: .center)
                    .foregroundColor(Color.black)
                    
                VStack(alignment: .leading, spacing: 0) {
                    Text(deviceID)
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
                }
                .padding(.horizontal, 0)
            }
            .padding(10)
        }
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

struct InputDeviceRow_Previews: PreviewProvider {
    static var previews: some View {
        InputDeviceRow(deviceID: "Built-In Microphone Bottom",
                       description: "<Device: iPhone Microphone (Built-In Microphone Bottom)>")
        .previewLayout(.fixed(width: 568, height: 320))
    }
}
