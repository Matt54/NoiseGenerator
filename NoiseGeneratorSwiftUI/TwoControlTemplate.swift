//
//  TwoControlTemplate.swift
//  NoiseGeneratorSwiftUI
//
//  Created by Macbook on 4/12/20.
//  Copyright © 2020 Matt Pfeiffer. All rights reserved.
//

import SwiftUI

struct TwoControlTemplate: View {
    @State var title = "EFFECT TITLE"
    @Binding var knobModel1 : KnobCompleteModel
    @Binding var knobModel2 : KnobCompleteModel
    
    var body: some View {

        GeometryReader{ geometry in
            VStack{
                Spacer()
                HStack {
                    Spacer()
                    VStack {
                        Text(self.knobModel1.display)
                        KnobComplete(knobModel: self.$knobModel1)
                            .frame(maxHeight:geometry.size.width * 0.3)
                        Text(self.knobModel1.name)
                            .font(.system(size: 14))
                            .bold()
                            .foregroundColor(Color.black)
                    }
                    .frame(width:geometry.size.width * 0.3)
                    Spacer()
                    VStack {
                        Text(self.knobModel2.display)
                        KnobComplete(knobModel: self.$knobModel2)
                            .frame(maxHeight:geometry.size.width * 0.3)
                        Text(self.knobModel2.name)
                            .font(.system(size: 14))
                            .bold()
                            .foregroundColor(Color.black)
                    }
                    .frame(width:geometry.size.width * 0.3)
                    Spacer()
                }
                    Spacer()
                    HStack {
                        Text(self.title)
                            .font(.system(size: 26))
                            .bold()
                            .foregroundColor(Color.white)
                    }
                    .frame(minWidth: 0,maxWidth: .infinity)
                    .background(Color.init(red: 0.2, green: 0.2, blue: 0.2))
                    
            }
        }
                .padding(5)
                .border(Color.black, width: 5)
    }
}

struct TwoControlTemplate_Previews: PreviewProvider {
    static var previews: some View {
        TwoControlTemplate(knobModel1: .constant(KnobCompleteModel()),
                           knobModel2: .constant(KnobCompleteModel()))
        .previewLayout(.fixed(width: 400, height: 250))
    }
}
