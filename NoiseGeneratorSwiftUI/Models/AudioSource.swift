import AudioKit
import Combine
import SwiftUI

public class AudioSource: Identifiable, ObservableObject, KnobModelHandoff{
    
    @Published var selectedBlockDisplay = SelectedBlockDisplay.controls
    
    // We should never see a heart
    @Published var displayImage = Image(systemName: "heart.circle")
    @Published var displayOnImage = Image(systemName: "heart.circle")
    @Published var displayOffImage = Image(systemName: "heart.circle.fill")
    
    public var name = "default"
    public var id: Int
    
    static var numberOfInputs = 0
    
    @Published var volumeMixer = VolumeMixer()
    
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
        //setupAudioRouting()
    }
    
    /*
    func setupAudioRouting(){
        output.mode = .peak
        outputMixer.setOutput(to: output)
    }
    */
    
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
        //outputAmplitude = output.amplitude
        volumeMixer.updateAmplitude()
        //print(outputAmplitude)
    }
    
    func setupInputRouting(){}
    
    // Called when any KnobCompleteModel has been modulated (let the individual effects handle this)
    func modulationValueWasChanged(_ sender: KnobCompleteModel) {}
    
    // Called when any KnobCompleteModel has been changed by midi cc or macro
    // (let the inheritors handle this)
    func handsFreeTextUpdate(_ sender: KnobCompleteModel) {}
    
    var handoffDelegate:ParameterHandoff?
    
    func KnobModelHandoff(_ sender: KnobCompleteModel) {
        handoffDelegate?.KnobModelHandoff(sender)
    }
    func KnobModelRangeHandoff(_ sender: KnobCompleteModel, adjust: Double) {
    handoffDelegate?.KnobModelRangeHandoff(sender, adjust: adjust)
    }
    
}

public class MonoAudioSource: AudioSource{
    var input: AKInput
    
    override func setupInputRouting(){
        //input.setOutput(to: outputMixer)
        input.setOutput(to:volumeMixer.input)
    }
    
    init(toggle: AKToggleable, node: AKInput ){
        input = node
        super.init(toggle: toggle)
        setupInputRouting()
    }
}

public class StereoAudioSource: AudioSource{
    var input: AKStereoInput
    
    override func setupInputRouting(){
        //input.setOutput(to: outputMixer)
        input.setOutput(to:volumeMixer.input)
    }
    
    init(){
        //input = node
        input = AKStereoInput()
        super.init(toggle: input)
        setupInputRouting()
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
        //stereoFieldLimiter.setOutput(to: outputMixer)
        stereoFieldLimiter.setOutput(to: volumeMixer.input)
        
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



public class adsrPolyphonicController: MonoAudioSource{
    
    var attack: Double = 99{
        didSet{ attackControlChange() }
    }
    
    var decay: Double = 0.1{
        didSet{ decayControlChange() }
    }
    
    var sustain: Double = 1.0{
        didSet{ sustainControlChange() }
    }

    var release: Double = 0.01{
        didSet{ releaseControlChange() }
    }
    
    func attackControlChange(){}
    func decayControlChange(){}
    func sustainControlChange(){}
    func releaseControlChange(){}
    
    var attackDisplay: Double = 0.01
    var releaseDisplay: Double = 0.01
    
    @Published var attackControl = KnobCompleteModel(){
        didSet{ setAttackControl() }
    }
    @Published var decayControl = KnobCompleteModel(){
        didSet{ setDecayControl() }
    }
    @Published var sustainControl = KnobCompleteModel(){
        didSet{ setSustainControl() }
    }
    @Published var releaseControl = KnobCompleteModel(){
        didSet{ setReleaseControl() }
    }
    
    override init(toggle: AKToggleable, node: AKInput ){
        
        super.init(toggle: toggle, node: node )
        
        attackControl.name = "Attack"
        attackControl.handoffDelegate = self
        attackControl.percentRotated = 0.2
        attackControl.range = 10
        setAttackControl()
        
        decayControl.name = "Decay"
        decayControl.handoffDelegate = self
        decayControl.percentRotated = 0.5
        decayControl.range = 10
        setDecayControl()
        
        sustainControl.name = "Sustain"
        sustainControl.handoffDelegate = self
        sustainControl.percentRotated = 1.0
        //sustainControl.range = 1
        setSustainControl()
        
        releaseControl.name = "Release"
        releaseControl.handoffDelegate = self
        releaseControl.percentRotated = 0.2
        releaseControl.range = 1
        setReleaseControl()
    }
    
    func attachDelegatesADSR(_ audioSource: AudioSource){
        attackControl.handoffDelegate = audioSource
        decayControl.handoffDelegate = audioSource
        sustainControl.handoffDelegate = audioSource
        releaseControl.handoffDelegate = audioSource
    }
    
    func checkControlsADSR(_ sender: KnobCompleteModel) {
        if(sender === attackControl){
            setAttackControl()
        }
        else if(sender === decayControl){
            setDecayControl()
        }
        else if(sender === sustainControl){
            setSustainControl()
        }
        else if(sender === releaseControl){
            setReleaseControl()
        }
    }
    
    func setAttackControl(){
        attack = pow(attackControl.realModValue, 3) * attackControl.range
        attackDisplay = attack * 2.0
        attackControl.display = String(format: "%.2f",attackDisplay) + " s"
    }
    func setDecayControl(){
        decay = 0.1 + pow(decayControl.realModValue, 3) * decayControl.range
        decayControl.display = String(format: "%.2f",decay) + " s"
    }
    func setSustainControl(){
        sustain = sustainControl.realModValue * sustainControl.range
        sustainControl.display = String(format: "%.2f",sustain) + " db"
    }
    func setReleaseControl(){
        release = 0.01 + pow(releaseControl.realModValue, 3) * releaseControl.range
        releaseDisplay = release * 5.0
        releaseControl.display = String(format: "%.2f", releaseDisplay) + " s"
    }
    
}

public class adsrSourceMono: adsrPolyphonicController{
    
    var output: AKAmplitudeEnvelope = AKAmplitudeEnvelope()
    //var sourceNode: AKNode
    
    override init(toggle: AKToggleable, node: AKInput ){
        super.init(toggle: output, node: output )
        //sourceNode = node
        node.setOutput(to: output)
        setADSR(attackDuration: attack, decayDuration: decay, sustainLevel: sustain, releaseDuration: release)
    }
    
    override func attackControlChange(){
        output.attackDuration = attack
    }
    
    override func decayControlChange(){
        output.decayDuration = decay
    }
    override func sustainControlChange(){
        output.sustainLevel = sustain
    }
    override func releaseControlChange(){
        output.releaseDuration = release
    }
    
    func kill(){
        output.stop()
    }

    func setADSR(attackDuration: Double, decayDuration: Double, sustainLevel: Double, releaseDuration: Double){
        output.rampDuration = 0
        output.attackDuration = attackDuration
        output.decayDuration = decayDuration
        output.sustainLevel = sustainLevel
        output.releaseDuration = releaseDuration
    }
    
}

public class NoiseSource: adsrSourceMono{
    
    private let whiteNoise = AKWhiteNoise()
    private let pinkNoise = AKPinkNoise()
    private let brownNoise = AKBrownianNoise()
    
    var noiseMixer = AKMixer()
    
    init(){
        super.init(toggle: noiseMixer, node: noiseMixer)
        stop()
        setNoiseRouting()
        setNoiseVolumes()
        isBypassed = true
        
        displayOnImage = Image(systemName: "n.circle.fill")
        displayOffImage = Image(systemName: "n.circle")
        setDisplayImage()
        
        name = "Noise"
        selectedBlockDisplay = .volume
        isBypassed = false
    }
    
    //This is handling both the on and the off events
    func play(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel){
        if(velocity > 0){
            play()
        }
        else{
            kill()
        }
    }
    
    override func setBypass(){
        if(isBypassed){
            toggleControls.stop()
        }
        else{
            //toggleControls.start()
        }
    }
    
    func play(){
        if(!isBypassed){
            whiteNoise.start()
            pinkNoise.start()
            brownNoise.start()
            output.start()
        }
    }
    
    func stop(){
        whiteNoise.stop()
        pinkNoise.stop()
        brownNoise.stop()
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
        whiteAmplitude = whiteVal
        whiteNoise.amplitude = whiteAmplitude
    }
    
    func setPinkAmplitude(){
        pinkAmplitude = pinkVal
        pinkNoise.amplitude = pinkAmplitude
    }
    
    func setBrownAmplitude(){
        brownAmplitude = brownVal
        brownNoise.amplitude = brownAmplitude
    }
    
}


public class MorphingOscillatorBank: adsrPolyphonicController{
    
    //var waveforms : [AKTable] = [AKTable(.sine), AKTable(.triangle), AKTable(.square), AKTable(.sawtooth)]
    
    //REMEMBER THAT THIS MUST ALWAYS HAVE EXACTLY 4 TABLES (WE USE 1 AND 2)
    var waveforms : [AKTable] = [AKTable(.sine), AKTable(.sawtooth), AKTable(.sine), AKTable(.sine)]
    var displayWaveform : [Float] = [Float](AKTable(.sine))
    
    
    var displayWaveTables : [DisplayWaveTable] = []
    @Published var displayIndex: Int = 0
    @Published var is3DView = false
    var numberOf3DTables = 49
    
    //var waveforms = [AKTable(.sine), AKTable(.sawtooth)]
    
    var voices : [Voice] = []
    
    var isSetup = false
    
    var index: Double = 1.0{
        didSet{
            // I think we need to prevent voices from being destroyed until after this loop
            // EXC_BAD_ACCESS(code=2, address=0x197a65fb8)
            for voice in voices{
                voice.oscillator.index = index// indexControl.realModValue * control1.range
            }
            displayIndex = Int(index * numberOf3DTables)
        }
    }
    
    override func attackControlChange(){
        for voice in voices{
            voice.output.attackDuration = attack
        }
    }
     override func decayControlChange(){
         for voice in voices{
             voice.output.decayDuration = decay
         }
     }
     override func sustainControlChange(){
         for voice in voices{
             voice.output.sustainLevel = sustain
         }
     }
     override func releaseControlChange(){
         for voice in voices{
             voice.output.releaseDuration = release
         }
     }
    
    var oscillatorMixer = AKMixer()
    
    @Published var indexControl = KnobCompleteModel(){
        didSet{ setIndexControl() }
    }
    
    init(){
        //displayWaveform = calculateDisplayWavetable()
        //[Float](vDSP.linearInterpolate([Float](waveforms[0]),[Float](waveforms[1]),using: Float(index)))
        
        super.init(toggle: oscillatorMixer, node: oscillatorMixer)
        
        displayOnImage = Image(systemName: "o.circle.fill")
        displayOffImage = Image(systemName: "o.circle")
        setDisplayImage()
        
        indexControl.name = "Waveform"
        indexControl.handoffDelegate = self
        //indexControl.range = 1 //Double(waveforms.count - 1)
        setIndexControl()

        selectedBlockDisplay = SelectedBlockDisplay.controls
        name = "OSC 1"
        
        isSetup = true
        
        calculateAllWaveTables()
    }
    
    //This is handling both the on and the off events
    func play(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel){
        if(velocity > 0){
            let newVoice = Voice(note: note, velocity: velocity, channel: channel, waveforms: waveforms)
            newVoice.setADSR(attackDuration: attack, decayDuration: decay, sustainLevel: sustain, releaseDuration: release)
            newVoice.oscillator.index = index
            newVoice.output.setOutput(to: oscillatorMixer)
            newVoice.play()
            voices.append(newVoice)
            //print(voices)
            //print(AudioKit.engine.description)
        }
        else{
            let killVoices = voices.filter {$0.note == note}
            for killVoice in killVoices{
                killVoice.kill()
            }
            voices = voices.filter {$0.note != note}
            //print(voices)
            
        }
    }
    
    func handlePitchBend(pitchWheelValue: MIDIWord, channel: MIDIChannel){
        //print("handlePitch")
        
        for voice in voices{
            if(voice.channel.hex == channel.hex){
                //print("same channel")
                voice.pitchBend = pitchWheelValue
            }
        }
        
    }
    
    /* Determines which KnobCompleteModel sent the change and forwards the update to the appropriate parameter */
    override func modulationValueWasChanged(_ sender: KnobCompleteModel) {
        if(sender === indexControl){
            setIndexControl()
        }
        checkControlsADSR(sender)
    }
    
    func setIndexControl(){
        index = indexControl.realModValue * indexControl.range
        indexControl.display = String(format: "%.2f",index)
        
        if(isSetup){
            displayWaveform = calculateDisplayWavetable()
        }
    }
    
    
    func calculateDisplayWavetable() -> [Float]{

        if(index <= 1){
            return [Float](vDSP.linearInterpolate([Float](waveforms[0]),[Float](waveforms[1]),using: Float(index)))
        }
        else if(index <= 2){
            return [Float](vDSP.linearInterpolate([Float](waveforms[1]),[Float](waveforms[2]),using: Float(index - 1)))
        }
        else{
            return [Float](vDSP.linearInterpolate([Float](waveforms[2]),[Float](waveforms[3]),using: Float(index - 2)))
        }

    }
    
    func calculateAllWaveTables(){
        displayWaveTables = []
        for i in 0...numberOf3DTables{
            let interpolatedIndex = Double(i) / Double(numberOf3DTables)
            let table = DisplayWaveTable([Float](vDSP.linearInterpolate([Float](waveforms[0]),
                                                                        [Float](waveforms[1]),
                                                                        using: Float(interpolatedIndex) ) ) )
            displayWaveTables.append(table)
        }
    }
    
}

class DisplayWaveTable{
    var waveform : [Float]
    init(_ waveform: [Float]){
        self.waveform = waveform
    }
}

public class Voice: adsrSourceWithoutControl{
    
    var pitchBend: UInt16 = 16_384 / 2{
        didSet{
            //print("didSet pitchBend")
            setOscillatorFrequency()
        }
    }
    
    var pitchBendRange: UInt16 = 24
    
    var oscillator : AKMorphingOscillator
    var channel: MIDIChannel
    var note: MIDINoteNumber
    var index: Double = 0.8{
        didSet{
            oscillator.index = index
        }
    }
    
    //var output: AKAmplitudeEnvelope = AKAmplitudeEnvelope()
    
    init(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel, waveforms: [AKTable]){
        
        oscillator = AKMorphingOscillator(waveformArray: waveforms)
        
        oscillator.rampDuration = 0.001
        self.channel = channel
        self.note = note
        super.init()
        setupNote(note: note, velocity: velocity)
    }
    
    func setupNote(note: MIDINoteNumber, velocity: MIDIVelocity){
        //convert midi note to frequency
        setOscillatorFrequency()
        
        //convert 0 to 127 range to 0 to 0.5 (because it's LOUD - maybe even go less)
        oscillator.amplitude = Double(velocity) / 127.0 * 0.2
        
        //print("Amplitude: " + String(oscillator.amplitude))
        
        //oscillator.setOutput(to: output)
        connectToADSR(oscillator)
    }
    
    func setOscillatorFrequency(){
        oscillator.frequency = getFrequencyFromNoteAndPitchBend(note: note, pitchBend: pitchBend)
        //print("Frequency: " + String(oscillator.frequency))
    }
    
    func getFrequencyFromNoteAndPitchBend(note: MIDINoteNumber, pitchBend: UInt16) -> Double {
        return 440.0 * pow(2.0, (((Double(note) - 69.0) / 12.0)
            + Double(pitchBendRange) * (Double(pitchBend) - 8192.0) / (4096.0 * 12.0)))
    }
    
    func play(){
        oscillator.start()
        output.start()
    }
    
    override func killSourceNode(){
        self.oscillator.stop()
        self.oscillator.detach()
    }
    
    deinit{
        //print("killed the voice")
    }
    
}

public class adsrSourceWithoutControl{
    
    var output: AKAmplitudeEnvelope = AKAmplitudeEnvelope()
    
    func connectToADSR(_ node: AKNode){
        node.setOutput(to: output)
    }
    
    func kill(){
        output.stop()
        DispatchQueue.main.asyncAfter(deadline: .now() + output.attackDuration + output.decayDuration + output.releaseDuration * 5.0) {
            
            self.killSourceNode()
            
            self.output.detach()
        }
    }
    
    //override this with your node
    func killSourceNode(){}

    func setADSR(attackDuration: Double, decayDuration: Double, sustainLevel: Double, releaseDuration: Double){
        output.rampDuration = 0
        output.attackDuration = attackDuration
        output.decayDuration = decayDuration
        output.sustainLevel = sustainLevel
        output.releaseDuration = releaseDuration
    }

}


public class ListedCategory{
    @Published var id: Int
    @Published var display: String
    @Published var symbol: Image
    @Published var description: String = ""
    
    init(id: Int, display: String, symbol: Image){
        self.id = id
        self.display = display
        self.symbol = symbol
    }
    init(id: Int, display: String, symbol: Image, description: String){
        self.id = id
        self.display = display
        self.symbol = symbol
        self.description = description
    }
}
