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
    @Published var volumeControl: Double{
        didSet{input.volume = volumeControl}
    }
    @Published var isRightHanded: Bool
    @Published var numberOfRects: Int
    @Published var name: String
    
    var input = AKMixer()
    var output = AKAmplitudeTracker()
    
    init(){
        amplitude = 0
        volumeControl = 1.0
        isRightHanded = true
        numberOfRects = 20
        name = "OUT"
        
        setupAudioRouting()
    }
    
    func setupAudioRouting(){
        output.mode = .peak
        input.setOutput(to: output)
    }
    
    func getAmplitude() -> Double{
        return output.amplitude
    }
}
