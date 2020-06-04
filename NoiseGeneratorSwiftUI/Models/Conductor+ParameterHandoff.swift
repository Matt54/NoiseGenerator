//
//  Conductor+ParameterHandoff.swift
//  NoiseGeneratorSwiftUI
//
//  Created by Macbook on 5/28/20.
//  Copyright © 2020 Matt Pfeiffer. All rights reserved.
//

import Foundation

extension Conductor: ParameterHandoff {
    func KnobModelHandoff(_ sender: KnobCompleteModel) {
        if(specialSelection == .assignModulation){
            //print("we hit noise modulation assignment")
            for modulation in modulations{
                if(modulation.isDisplayed){
                    modulation.addModulationTarget(newTarget: sender)
                    sender.addModulationTracker(modulation)
                    //print("knob assigned in noise")
                }
            }
        }
        else if(specialSelection == .deleteModulation){
            //print("we hit noise modulation delete")
            for modulation in modulations{
                if(modulation.isDisplayed){
                    modulation.removeModulationTarget(removeTarget: sender)
                    sender.removeModulationTracker(modulation)
                    //print("knob removed in noise")
                    
                    if(modulation.modulationTargets.count < 1){
                        specialSelection = .none
                    }
                }
            }
            sender.modSelected = false
            //sender.modulationValue = sender.percentRotated
        }
        else if(specialSelection == .midiLearn){
            //print("we hit noise midi learn")
            
            if selectedKnob != nil {
                selectedKnob?.isMidiLearning = false
            }
            
            selectedKnob = sender
            selectedKnob?.isMidiLearning = true
        }
    }
    
    func KnobModelRangeHandoff(_ sender: KnobCompleteModel, adjust: Double) {
        if(specialSelection == .assignModulation){
            for modulation in modulations{
                if(modulation.isDisplayed){
                    //print("Range Should Adjust by " + String(adjust))
                    modulation.adjustModulationRange(target: sender, val: adjust)
                }
            }
        }
    }
    
}
