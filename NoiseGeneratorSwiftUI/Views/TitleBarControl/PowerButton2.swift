//
//  PowerButton2.swift
//  NoiseGeneratorSwiftUI
//
//  Created by Macbook on 6/2/20.
//  Copyright © 2020 Matt Pfeiffer. All rights reserved.
//

import SwiftUI

struct PowerButton2: View {
    
    @Binding var isBypassed: Bool
    
    var body: some View {
        GeometryReader
        { geometry in
            
            Button(action: {self.isBypassed.toggle()}){
                if(!self.isBypassed){
                    ZStack{
                        Circle()
                            .fill(Color.init(red: 0.0, green: 0.0, blue: 0.0))
                        Image(systemName: "power")
                            .resizable()
                            .aspectRatio(1.0, contentMode: .fit)
                            .padding(geometry.size.width * 0.2)
                            .foregroundColor(Color.yellow)
                        }
                    }
                else{
                    ZStack{
                        Circle()
                            .fill(Color.init(red: 0.0, green: 0.0, blue: 0.0))
                       Image(systemName: "power")
                            .resizable()
                            .aspectRatio(1.0, contentMode: .fit)
                            .padding(geometry.size.width * 0.2)
                            .foregroundColor(Color.gray)
                    }
                }
            }
            
        }
    }
}

struct PowerButton2_Previews: PreviewProvider {
    static var previews: some View {
        PowerButton2(isBypassed: .constant(false))
    }
}
