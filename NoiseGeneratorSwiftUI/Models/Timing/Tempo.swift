//
//  Tempo.swift
//  NoiseGeneratorSwiftUI
//
//  Created by Macbook on 5/11/20.
//  Copyright © 2020 Matt Pfeiffer. All rights reserved.
//

import Foundation

struct Global{
    static var masterTempo = Tempo(bpm: 120)
}

public class Tempo: ObservableObject{
    
    // blocks invalid tempo from being created (currently unused)
    var isInvalid: Bool = true
    
    var isPaused: Bool = false
    
    func validateTempo(tempoString: String) -> Bool{

        //make sure we get just numbers
        let filtered = tempoString.filter { "0123456789.".contains($0) }
        if filtered != tempoString {
            return false
        }
        else{
            
            //make sure there's something there
            if tempoString == ""{
                return false
            }

            //get the numbers
            let myProposedTempo = Double(tempoString)!
            if( (myProposedTempo > 200) || (myProposedTempo < 20)){
                return false
            }
        }
        return true
    }
    
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
    
    var regularIntervals: [Double] = [32, 16, 8, 4, 2, 1, 1/2, 1/4, 1/8, 1/16, 1/32, 1/64, 1/128, 1/256]
    var regularIntervalStrings: [String] = ["32", "16", "8", "4", "2", "1", "1/2", "1/4", "1/8", "1/16", "1/32", "1/64", "1/128", "1/256"]
    
    func getTimeForRegularInterval(intNumber: Int) -> Double {
        return regularIntervals[intNumber] * secondsPerBeat * 4
    }
    
    func getTimeWithSteps(intNumber: Int, numberOfSteps: Double) -> Double {
        return getTimeForRegularInterval(intNumber: intNumber) / numberOfSteps
    }
    
    init(bpm: Double){
        self.bpm = bpm
        secondsPerBeat = 60 / self.bpm
        bpmString = String(bpm)
        bpmDecimal = Decimal(bpm)
    }

}
