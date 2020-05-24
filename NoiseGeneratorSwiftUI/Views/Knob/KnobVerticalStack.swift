//
//  KnobVerticalStack.swift
//  NoiseGeneratorSwiftUI
//
//  Created by Macbook on 5/20/20.
//  Copyright © 2020 Matt Pfeiffer. All rights reserved.
//

import SwiftUI

struct KnobVerticalStack: View {
    @EnvironmentObject var noise: NoiseModel
    @Binding var knobModel : KnobCompleteModel
    var removeValue: Bool = false
    
    var body: some View {
        GeometryReader
        { geometry in
            //Knob 1
            VStack(spacing: 0)
            {
                
                // Text - Value Display
                if(!self.removeValue){
                    Text(self.knobModel.display)
                        .textStyle(ShrinkTextStyle())
                        .frame(height: geometry.size.height * 0.25)
                        .scaledToFit()
                }
                
                
                // Knob Controller
                KnobComplete(knobModel: self.$knobModel,
                             knobModColor: self.$noise.knobModColor,
                             specialSelection: self.$noise.specialSelection)
                    .aspectRatio(1.0, contentMode: .fit)
                    .padding(.vertical, geometry.size.height * 0.05)
                    //.frame(height:geometry.size.height * 0.5)
                    
                    
                // Text - Parameter
                Text(self.knobModel.name)
                    .bold()
                    .textStyle(ShrinkTextStyle())
                    .frame(height: geometry.size.height * 0.25)
                
            }
        }
    }
}

struct KnobVerticalStack_Previews: PreviewProvider {
    static var previews: some View {
        KnobVerticalStack(knobModel: .constant(KnobCompleteModel()))
            .environmentObject(NoiseModel.shared)
            .previewLayout(.fixed(width: 400, height: 600))
    }
}
