import AudioKit
import Combine
import SwiftUI
import Foundation

final class NoiseModel : ObservableObject, ModulationDelegateUI{
    
    // Single shared data model
    static let shared = NoiseModel()
    
    // Master Sound On/Off
    @Published var isPlaying = true
    
    // Master Amplitude
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
    
    @Published var allControlEffects = [AudioEffect]()//: [AudioEffect] = []
    @Published var twoControlEffects = [TwoControlAudioEffect]()
    @Published var fourControlEffects = [FourControlAudioEffect]()
    @Published var oneControlWithPresetsEffects = [OneControlWithPresetsAudioEffect]()
    
    @Published var listedEffects = [
        ListedEffect(id: 1, display: "Moog Filter", symbol: Image(systemName: "f.circle.fill")),
        ListedEffect(id: 2, display: "Tremelo", symbol: Image(systemName: "t.circle.fill")),
        ListedEffect(id: 3, display: "Reverb", symbol: Image(systemName: "r.circle.fill")),
        ListedEffect(id: 4, display: "Delay", symbol: Image(systemName: "d.circle.fill")),
        ListedEffect(id: 5, display: "Chorus", symbol: Image(systemName: "c.circle.fill")),
        ListedEffect(id: 6, display: "Bit Crusher", symbol: Image(systemName: "b.circle.fill")),
        ListedEffect(id: 7, display: "Flanger", symbol: Image(systemName: "l.circle.fill"))
    ]
    
    @Published var addingEffects: Bool = false
    
    //Modulations
    var modulations : [Modulation] = []
    
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
    
    @Published var modulationSelected: Bool = false
    
    @Published var knobModColor = Color.init(red: 0, green: 1.0, blue: 0)
    
    init(){
        getAllAudioInputs()
        setupInputAudioChain()
        connectInputToEffectChain()
        
        //addEffectToAudioChain(effect: limiter)
        setupEffectAudioChain()
        
        //create a filter to play with
        createNewEffect(pos: allControlEffects.count, effectNumber: 1)

        AudioKit.output = outputMixer
        
        //SETUP DEFAULTS
        toggleSound()
        setAllAmplitudes()
        //setupLimiter()

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
        modulations[0].addTarget(newTarget: twoControlEffects[0].control1)
        
        twoControlEffects[0].control1.modSelected = true
        twoControlEffects[0].control1.attemptedModulationRange = 0.5
    }
    
    func getAllAudioInputs(){
        addInputToAudioChain(input: whiteNoise)
        addInputToAudioChain(input: pinkNoise)
        addInputToAudioChain(input: brownNoise)
        addInputToAudioChain(input: externalInput)
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
    
    public func createNewEffect(pos: Int, effectNumber: Int){
        let audioEffect = getEffectType(pos: pos, effectNumber: effectNumber)
        addEffectToAudioChain(effect: audioEffect.effect)
        addEffectToControlArray(effect: audioEffect)
        allControlEffects.append(audioEffect)
        setupEffectAudioChain()
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
