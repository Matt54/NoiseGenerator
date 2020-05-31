//
//  AddInstrumentForm.swift
//  NoiseGeneratorSwiftUI
//
//  Created by Macbook on 5/30/20.
//  Copyright © 2020 Matt Pfeiffer. All rights reserved.
//

import SwiftUI

struct AddInstrumentForm: View {

    @EnvironmentObject var noise: Conductor
    
    init(){
        UITableView.appearance().backgroundColor = UIColor.systemBackground
        UITableView.appearance().separatorColor = UIColor.systemBackground
    }
    
    var body: some View {
        GeometryReader{ geometry in
        VStack(spacing: 0){
            ZStack{
                HStack{
                    
                    Button(action: {
                        print("cancel pressed")
                        self.noise.selectedScreen = SelectedScreen.main
                        
                    })
                    {
                        Text("Cancel")
                        .textStyle(ShrinkTextStyle())
                        .frame(width: geometry.size.width * 0.15,
                        height: geometry.size.height * 0.1,
                        alignment: .leading)
                    }
                    Spacer()
                }
                .padding(.leading, geometry.size.width * 0.015)
                
                Text("Add Physical Instrument")
                    //.font(.title)
                    .fontWeight(.bold)
                    .textStyle(ShrinkTextStyle())
                    .frame(width: geometry.size.width * 0.3,
                           height: geometry.size.height * 0.1)
            }
            .frame(width: geometry.size.width,
                   height: geometry.size.height * 0.175)
            
        ScrollView {
            VStack(spacing: geometry.size.height * 0.05){
                ForEach(self.noise.listedInstruments , id: \.id){ i in
                    Button(action: {
                        print("You pressed: " + String(i.id))
                        self.noise.selectedScreen = SelectedScreen.main
                        self.noise.createNewSource(sourceNumber: i.id)
                    })
                    {
                        EffectRow(title: i.display,
                                  image: i.symbol,
                                  description: i.description,
                                  parameters: i.parameters)
                        .frame(height: geometry.size.height * 0.225)
                    }
                    .padding(.horizontal, geometry.size.width * 0.02)
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.top)
        .background(Color.white)
        }
    }
}

struct AddInstrumentForm_Previews: PreviewProvider {
    static var previews: some View {
        AddInstrumentForm().environmentObject(Conductor.shared)
        //.previewLayout(.fixed(width: 2688, height: 1242))
        .previewLayout(.fixed(width: 812, height: 375))
    }
}
