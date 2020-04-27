import AudioKit
import Combine
import SwiftUI
import Foundation

final class NoiseModel : ObservableObject, ModulationDelegateUI, AudioEffectKnobHandoff{
    
    // Single shared data model
    static let shared = NoiseModel()
    
    // Master Sound On/Off
    @Published var isPlaying = true
    
    // Master Amplitude Control
    @Published var masterAmplitude = 0.9{
        didSet { outputMixer.volume = masterAmplitude }
    }
    
    // Input Noise Amplitude Control
    @Published var amplitude = 1.0 {
        didSet { setAllAmplitudes() }
    }
    
    // External Sound (Disables Inputted Sound)
    @Published var enabledExternalInput = false {
        didSet { setExternalSource() }
    }
    
    //External Input
    let externalInput = AKStereoInput()
    
    // Noise Generating Oscillators
    private let whiteNoise = AKWhiteNoise()
    private let pinkNoise = AKPinkNoise()
    private let brownNoise = AKBrownianNoise()
    
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
    
    // Audio Effects (The Actual Nodes)
    var audioEffects : [AKInput] = []
    
    // Control Effects (What the user interracts with)
    @Published var allControlEffects = [AudioEffect]()
    @Published var twoControlEffects = [TwoControlAudioEffect]()
    @Published var fourControlEffects = [FourControlAudioEffect]()
    @Published var oneControlWithPresetsEffects = [OneControlWithPresetsAudioEffect]()
    
    // All Effects that can be added
    @Published var listedEffects = [
        ListedEffect(id: 1, display: "Moog Filter", symbol: Image(systemName: "f.circle.fill")),
        ListedEffect(id: 2, display: "Tremelo", symbol: Image(systemName: "t.circle.fill")),
        ListedEffect(id: 3, display: "Reverb", symbol: Image(systemName: "r.circle.fill")),
        ListedEffect(id: 4, display: "Delay", symbol: Image(systemName: "d.circle.fill")),
        ListedEffect(id: 5, display: "Chorus", symbol: Image(systemName: "c.circle.fill")),
        ListedEffect(id: 6, display: "Bit Crusher", symbol: Image(systemName: "b.circle.fill")),
        ListedEffect(id: 7, display: "Flanger", symbol: Image(systemName: "l.circle.fill"))
    ]
    
    // Used for navigation of the UI when adding a new effect
    @Published var addingEffects: Bool = false
    
    // Modulations
    var modulations : [Modulation] = []

    // ON - modulation range and color is shown on knobs
    @Published var modulationSelected: Bool = false
    
    // ON - modulation can be assigned and range can be adjusted
    @Published var modulationBeingAssigned: Bool = false
    
    // This controls the color of the modulation part of the knobs
    @Published var knobModColor = Color.init(red: 0.9, green: 0.9, blue: 0.9)
    
    init(){
        getAllAudioInputs()
        setupInputAudioChain()
        connectInputToEffectChain()

        setupEffectAudioChain()
        
        //create a filter to play with
        createNewEffect(pos: allControlEffects.count, effectNumber: 1)

        setupOutputChain()
        AudioKit.output = outputAmplitudeTracker//outputMixer
        
        //SETUP DEFAULTS
        toggleSound()
        setAllAmplitudes()

        //START AUDIOKIT
        do{
            try AudioKit.start()
        }
        catch{
            assert(false, error.localizedDescription)
        }
        
        //START AUDIOBUS
        Audiobus.start()

        if let inputs = AudioKit.inputDevices {
            for input in inputs{
                print(input)
            }
        }
        
        createNewModulation()
    }
    
    func getAllAudioInputs(){
        addInputToAudioChain(input: whiteNoise)
        addInputToAudioChain(input: pinkNoise)
        addInputToAudioChain(input: brownNoise)
        //addInputToAudioChain(input: externalInput)
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
        addEffectToAudioChain(effect: effectMixer)
        inputMixer.connect(to: audioEffects[0])
    }
    
    func addEffectToAudioChain(effect: AKInput){
        audioEffects.append(effect)
    }
    
    func setupEffectAudioChain(){
        // Disconnect all audio effect outputs
        for i in 0..<audioEffects.count {
            audioEffects[i].disconnectOutput()
        }
        
        // Route each audio effect to the next in line
        for i in 0..<audioEffects.count - 1 {
            //audioEffects[i].connect(to: audioEffects[i+1])
            audioEffects[i].setOutput(to: audioEffects[i+1])
        }
            
        //set the output of the last effect to our output mixer
        audioEffects[audioEffects.count - 1].setOutput(to: outputMixer)
    }
    
    func setupOutputChain(){
        outputMixer.volume = masterAmplitude
        outputAmplitudeTracker = AKAmplitudeTracker(outputMixer)
        outputAmplitudeTracker.mode = .peak
        outputAmplitudeTimer.eventHandler = {self.getOutputAmplitude()}
        outputAmplitudeTimer.resume()
    }
    
    var outputAmplitudeTimer = RepeatingTimer(timeInterval: 0.1)
    @objc func getOutputAmplitude(){
        DispatchQueue.main.async {
            //print(String(self.outputAmplitudeTracker.amplitude))
            self.outputAmplitude = self.outputAmplitudeTracker.amplitude
            
            /*
            print(String(20 * log10(self.outputAmplitudeTracker.amplitude)))
            self.outputAmplitude = 20 * log10(self.outputAmplitudeTracker.amplitude) // Convert to DBFS
             */
        }
    }
    
    public func createNewEffect(pos: Int, effectNumber: Int){
        let audioEffect = getEffectType(pos: pos, effectNumber: effectNumber)
        addEffectToAudioChain(effect: audioEffect.effect)
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
            // obj is a string array. Do something with stringArray
            twoControlEffects.append(myEffect)
        }
        else if let myEffect = effect as? OneControlWithPresetsAudioEffect {
            // obj is a string array. Do something with stringArray
            oneControlWithPresetsEffects.append(myEffect)
        }
        else if let myEffect = effect as? FourControlAudioEffect {
            // obj is a string array. Do something with stringArray
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
    
    func KnobModelAdjustModulationRange(_ sender: KnobCompleteModel, adjust: Double) {
        for modulation in modulations{
            if(modulation.isDisplayed){
                print("Range Should Adjust")
                modulation.adjustModulationRange(target: sender, val: adjust)
            }
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
