import AudioKit
import Combine
import SwiftUI
import Foundation

final class NoiseModel : ObservableObject, ModulationDelegateUI, AudioEffectKnobHandoff{
    
    // Single shared data model
    static let shared = NoiseModel()
    
    // Master Sound On/Off
    @Published var isNoiseBypassed = true{
        didSet { setNoiseBypass() }
    }
    
    // Master Amplitude Control
    @Published var masterAmplitude = 0.9{
        didSet { outputMixer.volume = masterAmplitude }
    }
    
    // External Sound (Disables Inputted Sound)
    @Published var enabledExternalInput = false {
        didSet { setExternalSource() }
    }
    
    //External Input
    let externalInput = AKStereoInput()
    
    // Noise Generator Volume Control
    @Published var noiseVolume = 1.0 {
        didSet { setNoiseVolumes() }
    }
    
    // Noise Amplitude Tracker
    var noiseAmplitudeTracker = AKAmplitudeTracker()
    @Published var noiseAmplitude: Double = 0.0
    
    // Noise Generating Oscillators
    private let whiteNoise = AKWhiteNoise()
    private let pinkNoise = AKPinkNoise()
    private let brownNoise = AKBrownianNoise()
    
    var noiseMixer = AKMixer()
    
    // Mixers
    var inputMixer = AKMixer()
    var effectMixer = AKMixer()
    var outputMixer = AKMixer()
    
    // Ouput Amplitude Tracker
    var outputAmplitudeTracker = AKAmplitudeTracker()
    @Published var outputAmplitude: Double = 0.0
    
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
    
    // Audio Inputs
    var audioInputs : [AKNode] = []
    
    // Control Effects (What the user interracts with)
    @Published var allControlEffects = [AudioEffect]()
    @Published var twoControlEffects = [TwoControlAudioEffect]()
    @Published var fourControlEffects = [FourControlAudioEffect]()
    @Published var oneControlWithPresetsEffects = [OneControlWithPresetsAudioEffect]()
    
    // All Effects that can be added
    @Published var listedEffects = [
        ListedEffect(id: 1,
                     display: "Moog Filter",
                     symbol: Image(systemName: "f.circle.fill"),
                     description: "Digital Implementation of the Moog Ladder Filter",
                     parameters: ["Cutoff", "Resonance"]
        ),
        ListedEffect(id: 2,
                     display: "Tremelo",
                     symbol: Image(systemName: "t.circle.fill"),
                     description: "A Variation in Amplitude",
                     parameters: ["Depth", "Frequency"]
        ),
        ListedEffect(id: 3,
                     display: "Reverb",
                     symbol: Image(systemName: "r.circle.fill"),
                     description: "Apple's Reverb Audio Unit",
                     parameters: ["Preset", "Dry/Wet"]
        ),
        ListedEffect(id: 4,
                     display: "Delay",
                     symbol: Image(systemName: "d.circle.fill"),
                     description: "Apple's Delay Audio Unit",
                     parameters: ["Time","Feedback","LP Cutoff","Dry/Wet"]
        ),
        ListedEffect(id: 5,
                     display: "Chorus",
                     symbol: Image(systemName: "c.circle.fill"),
                     description: "Delays/Pitch Modulates the Signal",
                     parameters: ["Time","Feedback","LP Cutoff","Dry/Wet"]
        ),
        ListedEffect(id: 6,
                     display: "Bit Crusher",
                     symbol: Image(systemName: "b.circle.fill"),
                     description: "Reduces Resolution/Bandwidth of Signal",
                     parameters: ["Bit Depth","Sample Rate"]
        ),
        ListedEffect(id: 7,
                     display: "Flanger",
                     symbol: Image(systemName: "l.circle.fill"),
                     description: "Swept Comb Filter Effect",
                     parameters: ["Depth","Feedback","Frequency","Dry/Wet"])
    ]
    
    // Used for navigation of the UI when adding a new effect
    @Published var addingEffects: Bool = false
    
    // Modulations
    var modulations : [Modulation] = []

    // ON - modulation range and color is shown on knobs
    @Published var modulationSelected: Bool = false
    
    // ON - modulation can be assigned and range can be adjusted
    @Published var modulationBeingAssigned: Bool = false{
        willSet{
            if(modulationBeingDeleted){
                modulationBeingDeleted = false
            }
        }
    }
    
    // ON - modulation can be removed from knobs
    @Published var modulationBeingDeleted: Bool = false{
        willSet{
            if(modulationBeingAssigned){
                modulationBeingAssigned = false
            }
        }
    }
    
    // This controls the color of the modulation part of the knobs
    @Published var knobModColor = Color.init(red: 0.9, green: 0.9, blue: 0.9)
    
    init(){
        getAllAudioInputs()
        setupInputAudioChain()
        connectInputToEffectChain()
        
        //create a filter to play with
        createNewEffect(pos: allControlEffects.count, effectNumber: 1)

        setupOutputChain()
        AudioKit.output = outputAmplitudeTracker//outputMixer
        
        //SETUP DEFAULTS
        setNoiseBypass()
        setNoiseVolumes()

        //START AUDIOKIT
        do{
            try AudioKit.start()
        }
        catch{
            assert(false, error.localizedDescription)
        }
        
        //START AUDIOBUS
        Audiobus.start()
        
        /*
        if let inputs = AudioKit.inputDevices {
            for input in inputs{
                print(input)
            }
        }
        */
        
        createNewModulation()
    }
    
    func getAllAudioInputs(){
        noiseMixer.connect(input: whiteNoise)
        noiseMixer.connect(input: pinkNoise)
        noiseMixer.connect(input: brownNoise)
        
        noiseAmplitudeTracker = AKAmplitudeTracker(noiseMixer)
        noiseAmplitudeTracker.mode = .peak
        
        addInputToAudioChain(input: noiseAmplitudeTracker)

    }
    
    func addInputToAudioChain(input: AKNode){
        audioInputs.append(input)
    }
    
    func setupInputAudioChain(){
        for audioInput in audioInputs{
            inputMixer.connect(input: audioInput)
        }
    }
    
    func setExternalSource(){
        if(enabledExternalInput){
            inputMixer.connect(input: externalInput)
        }
        else{
            externalInput.disconnectOutput(from: inputMixer)
        }
    }
    
    func connectInputToEffectChain(){
        
        // Disconnect input mixer from all outputs
        // if there are audio effects, connect to the first in chain
        // else, connect to the output mixer
        inputMixer.disconnectOutput()
        if(allControlEffects.count > 0){
            inputMixer.connect(to: allControlEffects[0].input)
        }
        else{
            inputMixer.connect(to: outputMixer)
        }
    }
    
    func setupEffectAudioChain(){
        
        // Connect input
        connectInputToEffectChain()
        
        for i in 0..<allControlEffects.count {
            allControlEffects[i].output.disconnectOutput()
        }
        
        
        // Route each audio effect to the next in line
        for i in 0..<allControlEffects.count - 1  {
            allControlEffects[i].output.setOutput(to: allControlEffects[i+1].input)
        }
        
        //set the output of the last effect to our output mixer
        allControlEffects[allControlEffects.count - 1].output.setOutput(to: outputMixer)
    }

    
    func setupOutputChain(){
        outputMixer.volume = masterAmplitude
        outputAmplitudeTracker = AKAmplitudeTracker(outputMixer)
        outputAmplitudeTracker.mode = .peak
        outputAmplitudeTimer.eventHandler = {self.getOutputAmplitude()}
        outputAmplitudeTimer.resume()
    }
    
    var outputAmplitudeTimer = RepeatingTimer(timeInterval: 0.03)
    @objc func getOutputAmplitude(){
        DispatchQueue.main.async {
            //print(String(self.outputAmplitudeTracker.amplitude))
            self.outputAmplitude = self.outputAmplitudeTracker.amplitude
            self.noiseAmplitude = self.noiseAmplitudeTracker.amplitude
            
            for i in 0..<self.allControlEffects.count {
                if(self.allControlEffects[i].isDisplayed){
                    self.allControlEffects[i].readAmplitudes()
                }
            }
        }
    }
    
    public func createNewEffect(pos: Int, effectNumber: Int){
        let audioEffect = getEffectType(pos: pos, effectNumber: effectNumber)
        //addEffectToAudioChain(effect: audioEffect.effect)
        addEffectToControlArray(effect: audioEffect)
        allControlEffects.append(audioEffect)
        setupEffectAudioChain()
        audioEffect.handoffDelegate = self
    }
    
    func getEffectType(pos: Int, effectNumber: Int) -> AudioEffect{
        switch effectNumber{
        case 1:
            return MoogLadderAudioEffect(pos: pos)
        case 2:
            return TremoloAudioEffect(pos: pos)
        case 3:
            return AppleReverbAudioEffect(pos: pos)
        case 4:
            return AppleDelayAudioEffect(pos: pos)
        case 5:
            return ChorusAudioEffect(pos: pos)
        case 6:
            return BitCrusherAudioEffect(pos: pos)
        case 7:
            return FlangerAudioEffect(pos: pos)
        default:
            print("I have an unexpected case.")
            return MoogLadderAudioEffect(pos: effectNumber)
        }
    }
    
    func addEffectToControlArray(effect: AudioEffect){
        if let myEffect = effect as? TwoControlAudioEffect {
            twoControlEffects.append(myEffect)
        }
        else if let myEffect = effect as? OneControlWithPresetsAudioEffect {
            oneControlWithPresetsEffects.append(myEffect)
        }
        else if let myEffect = effect as? FourControlAudioEffect {
            fourControlEffects.append(myEffect)
        }
    }
    
    func createNewModulation(){
        let modulation = Modulation()
        modulation.delegate = self
        modulation.start()
        modulations.append(modulation)
    }
    
    // Updates UI when modulation timer triggers
    func modulationUpdateUI(_ sender: Modulation) {
        self.objectWillChange.send()
    }
    
    func modulationDisplayChange(_ sender: Modulation) {
        if(sender.isDisplayed){
            knobModColor = sender.modulationColor
        }
        else{
            knobModColor = Color.init(red: 0.9, green: 0.9, blue: 0.9)
            self.modulationBeingAssigned = false
        }
        self.objectWillChange.send()
    }
    
    func KnobModelAssignToModulation(_ sender: KnobCompleteModel) {
        print("we hit noise")
        for modulation in modulations{
            if(modulation.isDisplayed){
                modulation.addModulationTarget(newTarget: sender)
                print("knob added")
            }
        }
    }
    
    func KnobModelRemoveModulation(_ sender: KnobCompleteModel) {
        print("we hit noise")
        for modulation in modulations{
            if(modulation.isDisplayed){
                modulation.removeModulationTarget(removeTarget: sender)
                print("knob removed")
            }
        }
        sender.modSelected = false
        sender.modulationValue = sender.percentRotated
    }
    
    func KnobModelAdjustModulationRange(_ sender: KnobCompleteModel, adjust: Double) {
        for modulation in modulations{
            if(modulation.isDisplayed){
                print("Range Should Adjust")
                modulation.adjustModulationRange(target: sender, val: adjust)
            }
        }
    }
    
    func setNoiseBypass(){
        if isNoiseBypassed{
            stopGenerator()
        }
        else{
            startGenerator()
        }
    }
    
    func setNoiseVolumes(){
        setWhiteAmplitude()
        setPinkAmplitude()
        setBrownAmplitude()
    }
    
    func setWhiteAmplitude(){
        whiteAmplitude = whiteVal * noiseVolume
        whiteNoise.amplitude = whiteAmplitude
    }
    
    func setPinkAmplitude(){
        pinkAmplitude = pinkVal * noiseVolume
        pinkNoise.amplitude = pinkAmplitude
    }
    
    func setBrownAmplitude(){
        brownAmplitude = brownVal * noiseVolume
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
