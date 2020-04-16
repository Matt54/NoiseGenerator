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
    
    @Published var allControlEffects = [AudioEffect]()//: [AudioEffect] = []
    @Published var twoControlEffects = [TwoControlAudioEffect]()
    @Published var oneControlWithPresetsEffects = [OneControlWithPresetsAudioEffect]()
    
    //LIMITER
    var limiter = AKPeakLimiter()
    
    init(){
        getAllAudioInputs()
        setupInputAudioChain()
        connectInputToEffectChain()

        createNewEffect(pos: allControlEffects.count, effectNumber: 2) //2 is AKTremolo
        createNewEffect(pos: allControlEffects.count, effectNumber: 1) //1 is AKMoogFilter
        createNewEffect(pos: allControlEffects.count, effectNumber: 3) //3 is AKReverb
        
        addEffectToAudioChain(effect: limiter)
        
        setupEffectAudioChain()
        
        AudioKit.output = outputMixer
        
        //SETUP DEFAULTS
        toggleSound()
        setAllAmplitudes()
        setupLimiter()
        

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
        let audioEffect = getEffectType(pos: pos, effectNumber: effectNumber)
        addEffectToAudioChain(effect: audioEffect.effect)
        addEffectToControlArray(effect: audioEffect)
        allControlEffects.append(audioEffect)
    }
    
    func getEffectType(pos: Int, effectNumber: Int) -> AudioEffect{
        switch effectNumber{
        case 1:
            return MoogLadderAudioEffect(pos: pos)
        case 2:
            return TremoloAudioEffect(pos: pos)
        case 3:
            return AppleReverbAudioEffect(pos: pos)
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
    
    /*
    KEEP THIS MODULATION IDEA
    let periodicFunction = AKPeriodicFunction(frequency: 100.0){
        print("hello world")
        shared.modulateLowPassCutoff()
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

}
