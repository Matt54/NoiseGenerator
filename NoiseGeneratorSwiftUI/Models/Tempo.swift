//
//  Tempo.swift
//  NoiseGeneratorSwiftUI
//
//  Created by Macbook on 5/11/20.
//  Copyright © 2020 Matt Pfeiffer. All rights reserved.
//

import Foundation

public class Tempo: ObservableObject{
    
    
    var bpmDecimal: Decimal
    
    var bpm: Double{
        didSet{
            calculateTimeInterval()
            bpmString = String(bpm)
            bpmDecimal = Decimal(bpm)
        }
    }
    
    var bpmStringIsAdjusting: Bool = false
    
    var bpmString: String{
        didSet{
            if(bpmStringIsAdjusting){
                bpm = Double(bpmString)!
            }
        }
    }
    
    
    func calculateTimeInterval(){
        secondsPerBeat = 60 / bpm
    }
    
    var secondsPerBeat: TimeInterval
    
    init(bpm: Double){
        self.bpm = bpm
        secondsPerBeat = 60 / self.bpm
        bpmString = String(bpm)
        bpmDecimal = Decimal(bpm)
    }

}
