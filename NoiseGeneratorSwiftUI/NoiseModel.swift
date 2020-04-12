//
//  NoiseModel.swift
//  NoiseGeneratorSwiftUI
//
//  Created by Macbook on 3/29/20.
//  Copyright © 2020 Matt Pfeiffer. All rights reserved.
//

import AudioKit

final class NoiseModel : ObservableObject{
    
    //private let metronome = AKMetronome()
    
    /*
    let periodicFunction = AKPeriodicFunction(frequency: 5.0){
        //print("hello world")
    }
     */
    
    // single shared instance
    static let shared = NoiseModel()
    
    // is sound playing?
    @Published var isPlaying = true
    
    // white noise generator
    private let whiteNoise = AKWhiteNoise()
    
    // pink noise generator
    private let pinkNoise = AKPinkNoise()
    
    // brown noise generator
    private let brownNoise = AKBrownianNoise()
    
    // overall amplitude
    @Published var amplitude = 1.0 {
        didSet { setAllAmplitudes() }
    }
    
    //@Published var balance = 1.0
    
    @Published var whiteVal = 1.0 {
        didSet { setWhiteAmplitude() }
    }
    @Published var pinkVal = 1.0 {
        didSet { setPinkAmplitude() }
    }
    @Published var brownVal = 1.0 {
        didSet { setBrownAmplitude() }
    }
    
    /*
    @Published var triggersPerMinute = 250.0{
        didSet{changeRate()}
    }
     */
    
    var lowPassFilter = AKLowPassFilter()
    @Published var lowPassCutoffControl = KnobCompleteModel(){
        didSet{setLowPassCutoff()}
    }
    @Published var lowPassResonanceControl = KnobCompleteModel(){
        didSet{setLowPassResonance()}
    }
    
    var tremolo = AKTremolo()
    
    /*
    @Published var tremoloDepth = 0.5{
        didSet{changeTremolo()}
    }
    
    @Published var tremoloFrequency = 8.0{
        didSet{changeTremolo()}
    }
     */
    
    @Published var tremoloFrequencyControl = KnobCompleteModel(){
        didSet{setTremoloFrequency()}
    }
    @Published var tremoloDepthControl = KnobCompleteModel(){
        didSet{setTremoloDepth()}
    }
    
    
    
    private var whiteAmplitude = 0.33
    private var pinkAmplitude = 0.33
    private var brownAmplitude = 0.33
    
    var isGated = false
    
    
    
    
    
    
    
    var reverb = AKReverb()
    @Published var reverbDryWet = 0.0{
        didSet{changeReverb()}
    }
    
    init(){
        setAllAmplitudes()
        lowPassFilter = AKLowPassFilter(AKMixer(whiteNoise, pinkNoise, brownNoise))
        tremolo = AKTremolo(lowPassFilter)
        reverb = AKReverb(tremolo)
        AudioKit.output = reverb
        
        changeReverb()
        reverb.loadFactoryPreset(.cathedral)
        
        setupTremolo()
        setupLowPassFilter()
        toggleSound()

        do{
            try AudioKit.start()
        }
        catch{
            assert(false, error.localizedDescription)
        }
        
        Audiobus.start()
        
        
        
        //AudioKit.output = AKMixer(whiteNoise, pinkNoise, brownNoise,metronome)

        
        
        
        /*
        metronomeSetup()
        
        metronome.tempo = triggersPerMinute
        metronome.start()
        */
        
        //periodicFunction.start()

        }
    
    /*
    func myMetronomeCallback(){
        //print("caught my callback")
        
        //isGated = !isGated
        if isGated{
            amplitude = 0
        }
        else{
            amplitude = 1.0
        }
         
    }
     
    
    func changeRate(){
        metronome.tempo = triggersPerMinute
    }
     */
    
    func setupLowPassFilter(){
        lowPassCutoffControl.name = "Cutoff"
        lowPassCutoffControl.range = 20000
        lowPassCutoffControl.unit = " Hz"
        lowPassCutoffControl.percentRotated = 1.0
        //lowPassResonanceControl.realModValue = 1.0
        
        lowPassResonanceControl.name = "Resonance"
        lowPassResonanceControl.range = 20
        
        setLowPassCutoff()
        setLowPassResonance()
    }
    func setLowPassCutoff(){
        //lowPassFilter.cutoffFrequency = lowPassCutoffControl.realModValue * lowPassCutoffControl.range
        lowPassFilter.cutoffFrequency = pow(lowPassCutoffControl.realModValue, 2) * lowPassCutoffControl.range
        lowPassCutoffControl.display = String(format: "%.1f", pow(lowPassCutoffControl.realModValue, 2) * lowPassCutoffControl.range) + lowPassCutoffControl.unit
    }
    
    func setLowPassResonance(){
        lowPassFilter.resonance = lowPassResonanceControl.realModValue * lowPassResonanceControl.range
        lowPassResonanceControl.display = String(format: "%.1f", lowPassResonanceControl.realModValue * lowPassResonanceControl.range) + lowPassResonanceControl.unit
    }
    
    
    func setupTremolo(){
        tremoloDepthControl.name = "Depth"
        tremoloDepthControl.percentRotated = 0.0
        
        tremoloFrequencyControl.name = "Frequency"
        tremoloFrequencyControl.range = 20
        tremoloFrequencyControl.unit = " Hz"
        tremoloFrequencyControl.percentRotated = 0.4
        
        setTremoloDepth()
        setTremoloFrequency()
    }
    func setTremoloDepth(){
        tremolo.depth = tremoloDepthControl.realModValue * tremoloDepthControl.range
        tremoloDepthControl.display = String(format: "%.1f", tremoloDepthControl.realModValue * tremoloDepthControl.range) + tremoloDepthControl.unit
    }
    
    func setTremoloFrequency(){
        tremolo.frequency = tremoloFrequencyControl.realModValue * tremoloFrequencyControl.range
        tremoloFrequencyControl.display = String(format: "%.1f", tremoloFrequencyControl.realModValue * tremoloFrequencyControl.range) + tremoloFrequencyControl.unit
    }
    
    
    
    func changeReverb(){
        reverb.dryWetMix = reverbDryWet
    }
 
    
    func toggleSound(){
        if isPlaying{
            stopGenerator()
        }
        else{
            
            startGenerator()
        }
        isPlaying = whiteNoise.isPlaying
    }
    
    /*
    func setGeneratorAmplitudes(){
        
        // Set relative balance with respect to overall amplitude level
        whiteAmplitude = (1.0 - balance) * amplitude
        pinkAmplitude = (balance) * amplitude
        
        whiteNoise.amplitude = whiteAmplitude
        pinkNoise.amplitude = pinkAmplitude
    }
 */
    
    func setAllAmplitudes(){
        setWhiteAmplitude()
        setPinkAmplitude()
        setBrownAmplitude()
    }
    
    func setWhiteAmplitude(){
        whiteAmplitude = whiteVal * amplitude
        whiteNoise.amplitude = whiteAmplitude
    }
    
    func setPinkAmplitude(){
        pinkAmplitude = pinkVal * amplitude
        pinkNoise.amplitude = pinkAmplitude
    }
    
    func setBrownAmplitude(){
        brownAmplitude = brownVal * amplitude
        brownNoise.amplitude = brownAmplitude
    }
    
    func stopGenerator(){
        whiteNoise.stop()
        pinkNoise.stop()
        brownNoise.stop()
    }
    
    func startGenerator(){
        whiteNoise.start()
        pinkNoise.start()
        brownNoise.start()
    }
    
    /*
    func metronomeSetup(){
        metronome.frequency1 = 0;
        metronome.frequency2 = 0;
        metronome.callback = {
            DispatchQueue.main.async {
                self.myMetronomeCallback()
            }
        }
    }
     */
    
    
}
