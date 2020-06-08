//
//  VolumeMixer.swift
//  NoiseGeneratorSwiftUI
//
//  Created by Macbook on 5/19/20.
//  Copyright © 2020 Matt Pfeiffer. All rights reserved.
//

import Foundation
import AudioKit

public class VolumeMixer : ObservableObject{
    @Published var amplitude: Double
    
    @Published var leftAmplitude: Double
    @Published var rightAmplitude: Double
    
    @Published var isStereo: Bool = false
    
    @Published var volumeControl: Double{
        didSet{input.volume = volumeControl}
    }
    @Published var isRightHanded: Bool
    @Published var numberOfRects: Int
    @Published var name: String
    
    var input = AKMixer()
    var output = AKAmplitudeTracker()
    
    init(){
        amplitude = 0.0
        leftAmplitude = 0.0
        rightAmplitude = 0.0
        volumeControl = 1.0
        numberOfRects = 10
        name = "OUT"
        isRightHanded = true
        setupAudioRouting()
    }
    
    init(isRightHanded: Bool){
        amplitude = 0.0
        leftAmplitude = 0.0
        rightAmplitude = 0.0
        volumeControl = 1.0
        numberOfRects = 10
        name = "OUT"
        self.isRightHanded = isRightHanded
        setupAudioRouting()
    }
    
    func setupAudioRouting(){
        output.mode = .peak
        input.setOutput(to: output)
    }
    
    func updateAmplitude(){
        if(!isStereo){
            amplitude = output.amplitude
        }
        else{
            leftAmplitude = output.leftAmplitude
            rightAmplitude = output.rightAmplitude
        }
    }
}
