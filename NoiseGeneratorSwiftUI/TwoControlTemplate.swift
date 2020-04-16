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
    @Binding var isBypassed : Bool
    @Binding var knobModel1 : KnobCompleteModel
    @Binding var knobModel2 : KnobCompleteModel
    
    var body: some View
    {
    GeometryReader
        { geometry in
        ZStack
            {
                VStack {
                    HStack {
                        Button(action: {self.isBypassed.toggle()}){
                            if(!self.isBypassed){
                            Circle()
                                .fill(Color.init(red: 0.2, green: 0.2, blue: 0.2))
                                .frame(width:geometry.size.width * 0.09,
                                       height:geometry.size.width * 0.09)
                                .overlay(
                                Image(systemName: "power")
                                    .font(.system(size: 18))
                                    .foregroundColor(Color.yellow)
                                )
                            }
                            else{
                                Circle()
                                .fill(Color.init(red: 0.2, green: 0.2, blue: 0.2))
                                .frame(width:geometry.size.width * 0.09,
                                       height:geometry.size.width * 0.09)
                                .overlay(
                                Image(systemName: "power")
                                    .font(.system(size: 18))
                                    .foregroundColor(Color.gray)
                                )
                            }
                        }
                        Spacer()
                    }
                    Spacer()
                }
                .padding(5)
                //.padding(EdgeInsets(top: 8, leading: 5, bottom: 0, trailing: 0))
                
            VStack
                {
                Spacer()
                HStack
                    {
                    Spacer()
                    VStack
                        {
                        Text(self.knobModel1.display)
                            .font(.system(size: 14))
                        KnobComplete(knobModel: self.$knobModel1)
                            .frame(maxWidth:geometry.size.width * 0.3)
                        Text(self.knobModel1.name)
                            .font(.system(size: 14))
                            .bold()
                            .foregroundColor(Color.black)
                        }
                        .frame(width:geometry.size.width * 0.35)
                    Spacer()
                    VStack
                        {
                        Text(self.knobModel2.display)
                            .font(.system(size: 14))
                        KnobComplete(knobModel: self.$knobModel2)
                            .frame(maxWidth:geometry.size.width * 0.3)
                        Text(self.knobModel2.name)
                            .font(.system(size: 14))
                            .bold()
                            .foregroundColor(Color.black)
                        }
                        .frame(width:geometry.size.width * 0.35)
                    Spacer()
                    }
                    Spacer()
                    HStack
                        {
                        Text(self.title)
                            .font(.system(size: 16))
                            .bold()
                            .foregroundColor(Color.white)
                        }
                        .frame(minWidth: 0,maxWidth: .infinity)
                        .background(Color.init(red: 0.2, green: 0.2, blue: 0.2))
                    }
                }//zstack
        }//georeader
        .padding(5)
        .border(Color.black, width: 5)
    }//view
}//struct

struct TwoControlTemplate_Previews: PreviewProvider {
    static var previews: some View {
        TwoControlTemplate(isBypassed: .constant(false),
                            knobModel1: .constant(KnobCompleteModel()),
                           knobModel2: .constant(KnobCompleteModel()))
        .previewLayout(.fixed(width: 280, height: 180))
    }
}
