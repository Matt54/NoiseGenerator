import AudioKit
import Combine
import SwiftUI

public class AudioSource: Identifiable, ObservableObject, ModulationDelegate, KnobModelModulationHandoff{
    
    // We should never see a heart
    @Published var displayImage = Image(systemName: "heart.circle")
    @Published var displayOnImage = Image(systemName: "heart.circle")
    @Published var displayOffImage = Image(systemName: "heart.circle.fill")
    
    public var name = "default"
    public var id: Int
    
    static var numberOfInputs = 0
    
    // All audio sources have outputs, some have inputs
    @Published var outputAmplitude = 1.0
    @Published var outputVolume = 1.0{
        didSet { outputMixer.volume = outputVolume }
    }
    @Published var outputMixer = AKMixer()
    @Published var output = AKAmplitudeTracker()
    
    var toggleControls: AKToggleable
    
    @Published var isBypassed = false{
        didSet{
            setBypass()
        }
    }
    
    public func toggleDisplayed(){
        isDisplayed.toggle()
        setDisplayImage()
    }
    
    // Is the effect currently shown on GUI
    @Published var isDisplayed = true{
        didSet{
            setDisplayImage()
        }
    }
    
    init(toggle: AKToggleable){
        toggleControls = toggle
        AudioEffect.numberOfEffects = AudioEffect.numberOfEffects + 1
        id = AudioEffect.numberOfEffects
        setBypass()
        setupAudioRouting()
    }
    
    func setupAudioRouting(){
        output.mode = .peak
        outputMixer.setOutput(to: output)
    }
    
    func setBypass(){
        if(isBypassed){
            toggleControls.stop()
        }
        else{
            toggleControls.start()
        }
    }
    
    func setDisplayImage(){
        if(isDisplayed){
            displayImage = displayOnImage
        }
        else{
            displayImage = displayOffImage
        }
    }
    
    func readAmplitudes(){
        //inputAmplitude = inputTracker.amplitude
        outputAmplitude = output.amplitude
        //print(outputAmplitude)
    }
    
    // Called when any KnobCompleteModel notices a change
    func modulationValueWasChanged(_ sender: KnobCompleteModel) {}
    
    var handoffDelegate:AudioEffectKnobHandoff?
    func KnobModelAssignToModulation(_ sender: KnobCompleteModel) {
        handoffDelegate?.KnobModelAssignToModulation(sender)
    }
    func KnobModelRemoveModulation(_ sender: KnobCompleteModel) {
        handoffDelegate?.KnobModelRemoveModulation(sender)
    }
    func KnobModelAdjustModulationRange(_ sender: KnobCompleteModel, adjust: Double) {
        handoffDelegate?.KnobModelAdjustModulationRange(sender, adjust: adjust)
    }
    
}

public class MonoAudioSource: AudioSource{
    var input: AKInput
    
    init(toggle: AKToggleable, node: AKInput ){
        input = node
        super.init(toggle: toggle)
        input.setOutput(to: outputMixer)
    }
}

public class StereoAudioSource: AudioSource{
    var input: AKStereoInput
    
    init(){
        //input = node
        input = AKStereoInput()
        super.init(toggle: input)
        input.setOutput(to: outputMixer)
    }
}

//This is currently Mono, that should toggle based on user preference
public class MicrophoneSource: AudioSource{
    
    var input: AKMicrophone! = AKMicrophone()
    
    init(device: AKDevice){
        super.init(toggle: input)

        do{
            try input.setDevice(device)
        }
        catch{
            assert(false, error.localizedDescription)
        }
        isBypassed = true
        
        self.name = device.deviceID
        
        let stereoFieldLimiter = AKStereoFieldLimiter(input)
        stereoFieldLimiter.setOutput(to: outputMixer)
        
        displayOnImage = Image(systemName: "mic.circle.fill")
        displayOffImage = Image(systemName: "mic.circle")
        setDisplayImage()
    }
    
    init(){
        super.init(toggle: input)
    }
    
    func setDevice(device: AKDevice){
        do{
            try input.setDevice(device)
            input.start()
        }
        catch{
            assert(false, error.localizedDescription)
        }
        self.name = device.deviceID
    }
    
}

public class AvailableInputSource{
    public var id: Int
    static var numberOfInputs = 0
    public var device: AKDevice
    
    init(device: AKDevice){
        self.device = device
        AvailableInputSource.numberOfInputs = AvailableInputSource.numberOfInputs + 1
        id = AvailableInputSource.numberOfInputs
    }
}

class MorphingOscillatorBank: MonoAudioSource{
    @Published var oscillatorBank = AKMorphingOscillatorBank()
    public var oscillatorMixer = AKMixer()
    
    @Published var control1 = KnobCompleteModel(){
        didSet{ setControl1() }
    }
    
    init(){
        
        super.init(toggle: oscillatorMixer, node: oscillatorMixer)
        
        oscillatorBank.waveformArray = [AKTable(.sine), AKTable(.triangle), AKTable(.sawtooth),AKTable(.square)]
        
        
        
        displayOnImage = Image(systemName: "o.circle.fill")
        displayOffImage = Image(systemName: "o.circle")
        setDisplayImage()
        
        control1.name = name + " waveform"
        control1.delegate = self
        control1.handoffDelegate = self
        control1.range = Double(oscillatorBank.waveformArray.count)
        setControl1()

        name = "OSC 1"
        oscillatorMixer.connect(input: oscillatorBank)
    }
    
    func play(note: MIDINoteNumber, velocity: MIDIVelocity){
        oscillatorBank.play(noteNumber: note, velocity: velocity)
    }
    
    /* Determines which KnobCompleteModel sent the change and forwards the update to the appropriate parameter */
    override func modulationValueWasChanged(_ sender: KnobCompleteModel) {
        if(sender === control1){
            setControl1()
        }
            /*
        else if(sender === control2){
            setControl2()
        }
        */
    }
    
    func setControl1(){
        oscillatorBank.index = control1.realModValue * control1.range
    }
    
    
}

public class NoiseSource: MonoAudioSource{
    
    private let whiteNoise = AKWhiteNoise()
    private let pinkNoise = AKPinkNoise()
    private let brownNoise = AKBrownianNoise()
    
    var noiseMixer = AKMixer()
    
    init(){
        super.init(toggle: noiseMixer, node: noiseMixer)
        setNoiseRouting()
        setNoiseVolumes()
        isBypassed = true
        
        displayOnImage = Image(systemName: "n.circle.fill")
        displayOffImage = Image(systemName: "n.circle")
        setDisplayImage()
    }
    
    func setNoiseRouting(){
        noiseMixer.connect(input: whiteNoise)
        noiseMixer.connect(input: pinkNoise)
        noiseMixer.connect(input: brownNoise)
    }
    
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
    
    func setNoiseVolumes(){
        setWhiteAmplitude()
        setPinkAmplitude()
        setBrownAmplitude()
    }
    
    func setWhiteAmplitude(){
        whiteAmplitude = whiteVal// * noiseVolume
        whiteNoise.amplitude = whiteAmplitude
    }
    
    func setPinkAmplitude(){
        pinkAmplitude = pinkVal// * noiseVolume
        pinkNoise.amplitude = pinkAmplitude
    }
    
    func setBrownAmplitude(){
        brownAmplitude = brownVal// * noiseVolume
        brownNoise.amplitude = brownAmplitude
    }
    
}
