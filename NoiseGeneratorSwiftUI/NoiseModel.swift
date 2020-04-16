//
//  NoiseModel.swift
//  NoiseGeneratorSwiftUI
//
//  Created by Macbook on 3/29/20.
//  Copyright © 2020 Matt Pfeiffer. All rights reserved.
//

import AudioKit
import Combine

final class NoiseModel : ObservableObject{
    
    // Single shared data model
    static let shared = NoiseModel()
    
    // Master Sound On/Off
    @Published var isPlaying = true
    
    // Master Amplitude
    @Published var amplitude = 1.0 {
        didSet { setAllAmplitudes() }
    }
    
    // Noise Generating Oscillators
    private let whiteNoise = AKWhiteNoise()
    private let pinkNoise = AKPinkNoise()
    private let brownNoise = AKBrownianNoise()
    
    // Mixers
    var inputMixer = AKMixer()
    var effectMixer = AKMixer()
    var outputMixer = AKMixer()
    
    // Amplitude of Noise Oscillators
    private var whiteAmplitude = 0.33
    @Published var whiteVal = 1.0 {
        didSet { setWhiteAmplitude() }
    }
    private var pinkAmplitude = 0.33
    @Published var pinkVal = 1.0 {
        didSet { setPinkAmplitude() }
    }
    private var brownAmplitude = 0.33
    @Published var brownVal = 1.0 {
        didSet { setBrownAmplitude() }
    }
    
    //Audio Inputs
    var audioInputs : [AKNode] = []
    
    //Audio Effects
    var audioEffects : [AKInput] = []
    @Published var allControlEffects: [AudioEffect] = []
    
    class ObservableArray<T>: ObservableObject {

        @Published var array:[T] = []
        
        var cancellables = [AnyCancellable]()

        init(array: [T]) {
            self.array = array

        }

        func observeChildrenChanges<T: ObservableObject>() -> ObservableArray<T> {
            let array2 = array as! [T]
            array2.forEach({
                let c = $0.objectWillChange.sink(receiveValue: { _ in self.objectWillChange.send() })

                // Important: You have to keep the returned value allocated,
                // otherwise the sink subscription gets cancelled
                self.cancellables.append(c)
            })
            return self as! ObservableArray<T>
        }
    }
    
    @Published var twoControlEffects = [TwoControlAudioEffect]()
    
    
    @Published var twoControlEffectsStore : ObservableArray<TwoControlAudioEffect> = ObservableArray(array:[])
    
    class AudioEffect: Identifiable, ObservableObject{
        
        var id: UUID = UUID()
        var effect: AKInput
        
        @Published var isBypassed = false{
            didSet{
                setBypass()
            }
        }

        // Position in the audio effect chain
        @Published var position: Int
        
        // Is the effect currently shown on GUI
        @Published var isDisplayed = true
        
        init(pos: Int, toggle: AKToggleable, node: AKInput ){
            position = pos
            toggleControls = toggle
            effect = node
            //setBypass()
        }

        var toggleControls: AKToggleable
        
        func toggleDisplayed(){
            isDisplayed.toggle()
        }
        
        func setBypass(){
            if(isBypassed){
                toggleControls.stop()
            }
            else{
                toggleControls.start()
            }
        }
        
    }
    
    public class TwoControlAudioEffect: AudioEffect{
        
        override init(pos: Int, toggle: AKToggleable, node: AKInput){
            super.init(pos: pos, toggle: toggle, node: node)
        }
        @Published var control1 = KnobCompleteModel(){
            didSet{ setControl1() }
        }
        @Published var control2 = KnobCompleteModel(){
            didSet{ setControl2() }
        }
        func setControl1(){}
        func setControl2(){}
    }
    
    class MoogLadderAudioEffect: TwoControlAudioEffect{
        var filter = AKMoogLadder()
        init(pos: Int){
            super.init(pos: pos, toggle: filter, node: filter)
            setDefaults()
            setControl1()
            setControl2()
        }
        func setDefaults(){
            filter.rampDuration = 0.0
            control1.name = "Cutoff"
            control1.range = 19980
            control1.unit = " Hz"
            //control1.percentRotated = 0.0
            control2.name = "Resonance"
        }
        override func setControl1(){
            filter.cutoffFrequency = 8 + pow(control1.realModValue, 5) * control1.range
            control1.display = String(format: "%.1f", 8 + pow(control1.percentRotated, 5) * control1.range) + control1.unit
        }
        override func setControl2(){
            filter.resonance = control2.realModValue * control2.range
            control2.display = String(format: "%.1f", control2.percentRotated * control2.range) + control2.unit
        }
    }
    
    //@Published var myFilter = MoogLadderAudioEffect(pos: 1)
    
    
    //FILTER
    /*
    var lowPassFilter = AKMoogLadder() //AKLowPassFilter()
    @Published var filterDisplayed = true
    @Published var filterBypassed = false {
        didSet{ setLowPassBypass() }
    }
    @Published var lowPassCutoffControl = KnobCompleteModel(){
        didSet{setLowPassCutoff()}
    }
    @Published var lowPassResonanceControl = KnobCompleteModel(){
        didSet{setLowPassResonance()}
    }
    func toggleFilterDisplay(){
        filterDisplayed.toggle()
    }
    */
    
    //TREMOLO
    var tremolo = AKTremolo()
    @Published var tremoloDisplayed = false;
    @Published var tremoloBypassed = false {
        didSet{ setTremoloBypass() }
    }
    @Published var tremoloFrequencyControl = KnobCompleteModel(){
        didSet{setTremoloFrequency()}
    }
    @Published var tremoloDepthControl = KnobCompleteModel(){
        didSet{setTremoloDepth()}
    }
    func toggleTremoloDisplay(){
        tremoloDisplayed.toggle()
    }
    
    //REVERB
    var reverb = AKReverb()
    @Published var reverbDisplayed = false;
    @Published var reverbBypassed = false {
        didSet{ setReverbBypass() }
    }
    @Published var reverbDryWetControl = KnobCompleteModel(){
        didSet{setReverbDryWet()}
    }
    func toggleReverbDisplay(){
        reverbDisplayed.toggle()
    }
    @Published var reverbPresetIndex = 0{
        didSet{setReverbPreset()}
    }
    @Published var reverbPresets = ["Cathedral", "Large Hall", "Large Hall 2",
    "Large Room", "Large Room 2", "Medium Chamber",
    "Medium Hall", "Medium Hall 2", "Medium Hall 3",
    "Medium Room", "Plate", "Small Room"]
    
    //LIMITER
    var limiter = AKPeakLimiter()
    
    init(){
        
        
        getAllAudioInputs()
        setupInputAudioChain()
        connectInputToEffectChain()

        createNewEffect(pos: allControlEffects.count, effectNumber: 1)
        
        addEffectToAudioChain(effect: tremolo)
        addEffectToAudioChain(effect: reverb)
        addEffectToAudioChain(effect: limiter)
        
        setupEffectAudioChain()
        
        AudioKit.output = outputMixer
        
        //SETUP DEFAULTS
        toggleSound()
        setAllAmplitudes()
        setupLimiter()
        setupReverb()
        setupTremolo()
        //setupLowPassFilter()
        

        //START AUDIOKIT
        do{
            //try AudioKit.start(withPeriodicFunctions: periodicFunction)
            try AudioKit.start()
        }
        catch{
            assert(false, error.localizedDescription)
        }
        
        //START AUDIOBUS
        Audiobus.start()
        
        //periodicFunction.start()

        }
    
    func getAllAudioInputs(){
        addInputToAudioChain(input: whiteNoise)
        addInputToAudioChain(input: pinkNoise)
        addInputToAudioChain(input: brownNoise)
    }
    
    func addInputToAudioChain(input: AKNode){
        audioInputs.append(input)
    }
    
    func setupInputAudioChain(){
        for audioInput in audioInputs{
            inputMixer.connect(input: audioInput)
        }
    }
    
    func connectInputToEffectChain(){
        addEffectToAudioChain(effect: effectMixer)
        inputMixer.connect(to: audioEffects[0])
    }
    
    func addEffectToAudioChain(effect: AKInput){
        audioEffects.append(effect)
    }
    
    func setupEffectAudioChain(){
        
        for i in 1..<audioEffects.count {
            audioEffects[i-1].connect(to: audioEffects[i])
        }
        
        //set the output of the last effect to our output mixer
        audioEffects[audioEffects.count-1].setOutput(to: outputMixer)
    }
    
    func createNewEffect(pos: Int, effectNumber: Int){
        
        let myFilter = getEffectType(pos: pos, effectNumber: effectNumber)
            //MoogLadderAudioEffect(pos: effectNumber)
        
        addEffectToAudioChain(effect: myFilter.effect)
        addEffectToControlArray(effect: myFilter)
        allControlEffects.append(myFilter)
    }
    
    func getEffectType(pos: Int, effectNumber: Int) -> AudioEffect{
        switch effectNumber{
        case 1:
            return MoogLadderAudioEffect(pos: pos)
        default:
            print("I have an unexpected case.")
            return MoogLadderAudioEffect(pos: effectNumber)
        }
    }
    
    func addEffectToControlArray(effect: AudioEffect){
        if let myEffect = effect as? TwoControlAudioEffect {
            // obj is a string array. Do something with stringArray
            twoControlEffects.append(myEffect)
        }
    }
    
    func setupLimiter(){
        limiter.attackDuration = 0.001 // Secs
        limiter.decayDuration = 0.01 // Secs
        limiter.preGain = 0 // dB
    }
    func dropGain(){
        limiter.preGain = -40 // dB
    }
    func resetGain(){
        limiter.preGain = 0 // dB
    }
    
    /*
    func setupLowPassFilter(){
        lowPassCutoffControl.name = "Cutoff"
        lowPassCutoffControl.range = 19980//20000
        lowPassCutoffControl.unit = " Hz"
        lowPassCutoffControl.percentRotated = 0.0
        lowPassCutoffControl.modSelected = true
        lowPassCutoffControl.attemptedModulationRange = 0.5
        
        lowPassResonanceControl.name = "Resonance"
        
        lowPassFilter.rampDuration = 0.0
        
        setLowPassCutoff()
        setLowPassResonance()
        setLowPassBypass()
    }
    func setLowPassCutoff(){
        //lowPassFilter.cutoffFrequency = lowPassCutoffControl.realModValue * lowPassCutoffControl.range
        lowPassFilter.cutoffFrequency = 8 + pow(lowPassCutoffControl.realModValue, 5) * lowPassCutoffControl.range
        lowPassCutoffControl.display = String(format: "%.1f", 8 + pow(lowPassCutoffControl.percentRotated, 5) * lowPassCutoffControl.range) + lowPassCutoffControl.unit
    }
    func setLowPassResonance(){
        lowPassFilter.resonance = lowPassResonanceControl.realModValue * lowPassResonanceControl.range
        lowPassResonanceControl.display = String(format: "%.1f", lowPassResonanceControl.percentRotated * lowPassResonanceControl.range) + lowPassResonanceControl.unit
    }
    func setLowPassBypass(){
        if(filterBypassed){
            lowPassFilter.stop()
        }
        else{
            lowPassFilter.start()
        }
    }
    let periodicFunction = AKPeriodicFunction(frequency: 100.0){
        print("hello world")
        shared.modulateLowPassCutoff()
    }
    func modulateLowPassCutoff(){
        
        //lowPassCutoffControl.stepModulationValue()
        
        lowPassCutoffControl.modulationValue = lowPassCutoffControl.modulationValue + (lowPassCutoffControl.realModulationRange / 200)
        if(lowPassCutoffControl.modulationValue > lowPassCutoffControl.realModulationRange){
            lowPassCutoffControl.modulationValue = 0
        }
        lowPassCutoffControl.calculateRealValue()
        lowPassCutoffControl.calculateRealRange()
        //lowPassCutoffControl.objectWillChange.send()
        setLowPassCutoff()
        
        self.objectWillChange.send()
    }
    */
    
    let periodicFunction = AKPeriodicFunction(frequency: 100.0){
        print("hello world")
        //shared.modulateLowPassCutoff()
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
        setTremoloBypass()
    }
    func setTremoloDepth(){
        tremolo.depth = tremoloDepthControl.realModValue * tremoloDepthControl.range
        tremoloDepthControl.display = String(format: "%.1f", tremoloDepthControl.realModValue * tremoloDepthControl.range) + tremoloDepthControl.unit
    }
    
    func setTremoloFrequency(){
        tremolo.frequency = tremoloFrequencyControl.realModValue * tremoloFrequencyControl.range
        tremoloFrequencyControl.display = String(format: "%.1f", tremoloFrequencyControl.realModValue * tremoloFrequencyControl.range) + tremoloFrequencyControl.unit
    }
    func setTremoloBypass(){
        if(tremoloBypassed){
            tremolo.stop()
        }
        else{
            tremolo.start()
        }
    }
    
    
    /*
    func changeReverb(){
        reverb.dryWetMix = reverbDryWet
    }
    */
    
    func setupReverb(){
        reverbDryWetControl.name = "Dry/Wet"
        reverbDryWetControl.unit = "%"
        setReverbDryWet()
        setReverbPreset()
        setReverbBypass()
    }
    func setReverbDryWet(){
        reverb.dryWetMix = reverbDryWetControl.realModValue * reverbDryWetControl.range
        reverbDryWetControl.display = String(format: "%.0f", reverbDryWetControl.realModValue * reverbDryWetControl.range * 100) + reverbDryWetControl.unit
    }
    func setReverbBypass(){
        if(reverbBypassed){
            reverb.stop()
        }
        else{
            reverb.start()
        }
    }
    func setReverbPreset(){
        switch reverbPresets[reverbPresetIndex]{
        case "Cathedral":
            reverb.loadFactoryPreset(.cathedral)
        case "Large Hall":
            reverb.loadFactoryPreset(.largeHall)
        case "Large Hall 2":
            reverb.loadFactoryPreset(.largeHall2)
        case "Large Room":
            reverb.loadFactoryPreset(.largeRoom)
        case "Large Room 2":
            reverb.loadFactoryPreset(.largeRoom2)
        case "Medium Chamber":
            reverb.loadFactoryPreset(.mediumChamber)
        case "Medium Hall":
            reverb.loadFactoryPreset(.mediumHall)
        case "Medium Hall 2":
            reverb.loadFactoryPreset(.mediumHall2)
        case "Medium Hall 3":
            reverb.loadFactoryPreset(.mediumHall3)
        case "Medium Room":
            reverb.loadFactoryPreset(.mediumRoom)
        case "Plate":
            reverb.loadFactoryPreset(.plate)
        case "Small Room":
            reverb.loadFactoryPreset(.smallRoom)
        default:
            print("Error - reverb not found")
        }
        
        
        
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

}
