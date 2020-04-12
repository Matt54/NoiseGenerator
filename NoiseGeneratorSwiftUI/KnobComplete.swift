//
//  KnobComplete.swift
//  NoiseGeneratorSwiftUI
//
//  Created by Macbook on 4/9/20.
//  Copyright © 2020 Matt Pfeiffer. All rights reserved.
//

import SwiftUI

struct KnobComplete: View {
    //@ObservedObject var knobModel = KnobCompleteModel()
    
    //@Binding var percentRotated: Double// = 1.0
    //@Binding var realModValue: Double// = 1.0
    //@Binding var realModulationRange: Double// = 1.0
    //@Binding var modSelected: Bool// = 1.0
    
    @Binding var knobModel : KnobCompleteModel
    
    var body: some View {
        GeometryReader{ geometry in
            ZStack{
                
                //modulation background
                Arc(startAngle: .constant(130 * .pi / 180),
                    endAngle: .constant( (270.0 * 1.0 + 140.0) * .pi / 180.0),
                    lineWidth: geometry.size.width * 0.05,
                    center: CGPoint(x: geometry.size.width/2, y: geometry.size.height/2),
                    radius: geometry.size.width/2 - geometry.size.width * 0.05 * 0.5)
                    .fill(Color.init(red: 0.5, green: 0.5, blue: 0.5))
                
                //modulation background border
                Arc(startAngle: .constant(130 * .pi / 180),
                    endAngle: .constant( (270.0 * 1.0 + 140.0) * .pi / 180.0),
                    lineWidth: geometry.size.width * 0.05,
                    center: CGPoint(x: geometry.size.width/2, y: geometry.size.height/2),
                    radius: geometry.size.width/2 - geometry.size.width * 0.05 * 0.5)
                    .stroke(Color.init(red: 0.2, green: 0.2, blue: 0.2),
                            lineWidth: geometry.size.width * 0.005)
                
                //modulation
                if(self.knobModel.modSelected)
                {
                    Arc(startAngle: .constant((270.0 * self.knobModel.percentRotated + 130) * .pi / 180),
                        endAngle: .constant((270 * self.knobModel.realModulationRange + 270.0 * self.knobModel.percentRotated + 140.0) * .pi / 180.0),
                        lineWidth: geometry.size.width * 0.05,
                        center: CGPoint(x: geometry.size.width/2, y: geometry.size.height/2),
                        radius: geometry.size.width/2 - geometry.size.width * 0.05 * 0.5)
                        .fill(Color.init(red: 1.0, green: 1.0, blue: 0.0))
                }

                
                KnobControl(percentRotated: self.$knobModel.percentRotated, realModValue: self.$knobModel.realModValue)
                    .frame(width:geometry.size.width * 0.9)
                }
        }
    }
}

final class KnobCompleteModel : ObservableObject{
    @Published var percentRotated = 0.0{
    didSet {
        calculateRealValue()
        calculateRealRange()
        }
    }
    
    func calculateRealValue(){
        if(percentRotated + modulationValue > 1.0){
            realModValue = 1.0
        }
        else if(percentRotated + modulationValue < 0.0){
            realModValue = 0.0
        }
        else{
            realModValue = modulationValue + percentRotated
        }
        
        //display = String(format: "%.1f", realModValue * range) + unit
    }
    
    func calculateRealRange(){
        if(percentRotated + attemptedModulationRange > 1.0){
            realModulationRange = (1.0 - percentRotated)
        }
        else if(percentRotated + attemptedModulationRange < 0.0){
            realModulationRange = percentRotated
        }
        else{
            realModulationRange = attemptedModulationRange
        }
    }
    
    
    @Published var modSelected = false
    @Published var realModValue = 0.0
    @Published var modulationValue = 0.0
    @Published var realModulationRange = 0.0
    @Published var attemptedModulationRange = 0.0
    
    @Published var name = "Parameter"
    @Published var range = 1.0
    @Published var unit = ""
    
    @Published var display = "Display"
    
    //var timer = Timer()
    
    @objc func timerAction(){
        modulationValue = modulationValue + (realModulationRange / 200)
        if(modulationValue > realModulationRange){
            modulationValue = 0
        }
        calculateRealValue()
        calculateRealRange()
    }

    init(){
        /*
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.005, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
         */
        calculateRealValue()
        calculateRealRange()
    }
}


struct KnobComplete_Previews: PreviewProvider {
    static var previews: some View {
        KnobComplete(knobModel: .constant(KnobCompleteModel()))
    }
}
