//
//  MainBlocks.swift
//  NoiseGeneratorSwiftUI
//
//  Created by Macbook on 5/19/20.
//  Copyright © 2020 Matt Pfeiffer. All rights reserved.
//

import SwiftUI

struct MainBlocks: View {
    
    @EnvironmentObject var noise: NoiseModel
    
    var body: some View {
        GeometryReader{ geometry in
            HStack(spacing: 0){
                
                HStack(spacing: 0){
                    //.fill(LinearGradient(Color.darkStart,Color.darkGray)
                    Rectangle()
                    .frame(width:geometry.size.width * (0.001))
                    .foregroundColor(Color.init(red: 0.7, green: 0.7, blue: 0.7))
                    Rectangle()
                        .fill(LinearGradient(Color.darkStart,Color.darkGray))
                        .frame(width:geometry.size.width * (0.002))
                    Rectangle()
                        .fill(LinearGradient(Color.darkGray,Color.darkStart))
                        .frame(width:geometry.size.width * (0.002))
                    Rectangle()
                        .frame(width:geometry.size.width * (0.001))
                        .foregroundColor(Color.init(red: 0.7, green: 0.7, blue: 0.7))
                }
                
                AudioSourceView()
                    //.frame(width:geometry.size.width * (1/3), height: geometry.size.height * 0.6)

                HStack(spacing: 0){
                    //.fill(LinearGradient(Color.darkStart,Color.darkGray)
                    Rectangle()
                    .frame(width:geometry.size.width * (0.001))
                    .foregroundColor(Color.init(red: 0.7, green: 0.7, blue: 0.7))
                    Rectangle()
                        .fill(LinearGradient(Color.darkStart,Color.darkGray))
                        .frame(width:geometry.size.width * (0.002))
                    Rectangle()
                        .fill(LinearGradient(Color.darkGray,Color.darkStart))
                        .frame(width:geometry.size.width * (0.002))
                    Rectangle()
                        .frame(width:geometry.size.width * (0.001))
                        .foregroundColor(Color.init(red: 0.7, green: 0.7, blue: 0.7))
                }
                
                AudioEffectView()
                    //.frame(width:geometry.size.width * (1/3), height: geometry.size.height * 0.6)
                
                HStack(spacing: 0){
                    //.fill(LinearGradient(Color.darkStart,Color.darkGray)
                    Rectangle()
                    .frame(width:geometry.size.width * (0.001))
                    .foregroundColor(Color.init(red: 0.7, green: 0.7, blue: 0.7))
                    Rectangle()
                        .fill(LinearGradient(Color.darkStart,Color.darkGray))
                        .frame(width:geometry.size.width * (0.002))
                    Rectangle()
                        .fill(LinearGradient(Color.darkGray,Color.darkStart))
                        .frame(width:geometry.size.width * (0.002))
                    Rectangle()
                        .frame(width:geometry.size.width * (0.001))
                        .foregroundColor(Color.init(red: 0.7, green: 0.7, blue: 0.7))
                }
                
                /*
                VStack(spacing: 0){
                    
                    
                    Rectangle()
                        .frame(width:geometry.size.width * (0.001),
                               height: geometry.size.height * (0.22))
                        .foregroundColor(Color.init(red: 0.2, green: 0.2, blue: 0.2))
                        
                    
                    Rectangle()
                        .frame(width:geometry.size.width * (0.001),
                               height: geometry.size.height * (0.665))
                        .foregroundColor(Color.init(red: 0.7, green: 0.7, blue: 0.7))
                    
                    Rectangle()
                        .frame(width:geometry.size.width * (0.001),
                               height: geometry.size.height * (0.115))
                        .foregroundColor(Color.init(red: 0.2, green: 0.2, blue: 0.2))
                }
                */
                //Rectangle()
                //    .frame(width:geometry.size.width * (0.005))
                
                ModulationSourceView()
                    //.frame(width:geometry.size.width * (1/3), height: geometry.size.height * 0.6)
                
                HStack(spacing: 0){
                    //.fill(LinearGradient(Color.darkStart,Color.darkGray)
                    Rectangle()
                    .frame(width:geometry.size.width * (0.001))
                    .foregroundColor(Color.init(red: 0.7, green: 0.7, blue: 0.7))
                    Rectangle()
                        .fill(LinearGradient(Color.darkStart,Color.darkGray))
                        .frame(width:geometry.size.width * (0.002))
                    Rectangle()
                        .fill(LinearGradient(Color.darkGray,Color.darkStart))
                        .frame(width:geometry.size.width * (0.002))
                    Rectangle()
                        .frame(width:geometry.size.width * (0.001))
                        .foregroundColor(Color.init(red: 0.7, green: 0.7, blue: 0.7))
                }
                
            }
        }
    }
}

struct MainBlocks_Previews: PreviewProvider {
    static var previews: some View {
        MainBlocks().environmentObject(NoiseModel.shared)
        .previewLayout(.fixed(width: 568, height: 250))
    }
}
