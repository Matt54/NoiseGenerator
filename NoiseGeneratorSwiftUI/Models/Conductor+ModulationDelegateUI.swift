//
//  Conductor+ModulationDelegateUI.swift
//  NoiseGeneratorSwiftUI
//
//  Created by Macbook on 5/28/20.
//  Copyright © 2020 Matt Pfeiffer. All rights reserved.
//

import Foundation
import SwiftUI

extension Conductor: ModulationDelegateUI {
    
    // Updates UI when modulation timer triggers
    func modulationUpdateUI(_ sender: Modulation) {
        
        // TODO: We should have the ability to change the screenUpdateSetting
        
        // Sending this would make the UI update much faster
        if(screenUpdateSetting == .custom){
            let timeNow = Double(DispatchTime.now().uptimeNanoseconds) / 1_000_000_000
            if( (timeNow - timeOfLastScreenUpdate) > screenUpdateTimeDuration){
                timeOfLastScreenUpdate = timeNow
                self.objectWillChange.send()
            }
        }
        else if(screenUpdateSetting == .fastest){
            self.objectWillChange.send()
        }

    }
    
    func modulationDisplayChange(_ sender: Modulation) {
        if(sender.isDisplayed){
            knobModColor = sender.modulationColor
            selectedPattern = sender.pattern
        }
        else{
            knobModColor = Color.init(red: 0.9, green: 0.9, blue: 0.9)
            if( (self.specialSelection == .assignModulation) || (self.specialSelection == .deleteModulation) ){
                self.specialSelection = .none
            }
        }
        self.objectWillChange.send()
    }
    
    func createNewModulation(){
        hideModulations()
        let modulation = Modulation()//(tempo: tempo)
        modulation.delegate = self
        modulation.handoffDelegate = self
        modulations.append(modulation)
    }
    
    func stopModulations(){
        for modulation in modulations{
            modulation.stop()
        }
    }
    
    func startModulations(){
        for modulation in modulations{
            modulation.start()
        }
    }
    
    func updateModulations(){
        for modulation in modulations{
            modulation.setTimeInterval()
        }
    }
    
    func setModulationTriggers(){
        for modulation in modulations{
            modulation.isTriggered = isModulationTriggered
        }
    }
    
    func checkForDeadModulation(){
        
        for modulation in modulations{
            if(modulation.isTriggerMode || modulation.isEnvelopeMode){
                
                if((Double(DispatchTime.now().uptimeNanoseconds) - modulation.timeOfLastTimerAction) / 1_000_000_000 > 0.1){
                    print("found a dead modulation!")
                    modulation.setTimeInterval(timeInterval: modulation.timeInterval)
                }
                
                //let leftoverTime = (Double(DispatchTime.now().uptimeNanoseconds) - modulation.timeOfLastTimerAction) / 1_000_000_000
                //print(leftoverTime)
            }
        }
         //use 0.01 for cutoff
        
    }
    
}
