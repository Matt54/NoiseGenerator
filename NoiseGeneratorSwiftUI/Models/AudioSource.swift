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

public class Voice{
    
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
    
    var output: AKAmplitudeEnvelope = AKAmplitudeEnvelope()
    
    init(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel, waveforms: [AKTable]){
        
        /*
        print("")
        print("New Voice!")
        print("Note Number: " + String(note))
        print("Velocity: " + String(velocity))
        print("channel: " + String(channel))
        */
        
        oscillator = AKMorphingOscillator(waveformArray: waveforms)
        
        /*
        var newTable : [Float] = []
        // This is every value in the waveform
        for element in 0...waveforms[0].count - 1{
            let value = waveforms[0][element].value()
            print(value)
            newTable[element] += Float(random(in: -0.3...0.3) + Double(element) / 2_048.0)
        }
        var newTable2 = AKTable(newTable)
        */
        
        oscillator.rampDuration = 0.001
        self.channel = channel
        self.note = note
        setupNote(note: note, velocity: velocity)
    }
    
    func setupNote(note: MIDINoteNumber, velocity: MIDIVelocity){
        //convert midi note to frequency
        setOscillatorFrequency()
        
        //convert 0 to 127 range to 0 to 0.5 (because it's LOUD - maybe even go less)
        oscillator.amplitude = Double(velocity) / 127.0 * 0.2
        
        //print("Amplitude: " + String(oscillator.amplitude))
        
        oscillator.setOutput(to: output)
    }
    
    func setOscillatorFrequency(){
        oscillator.frequency = getFrequencyFromNoteAndPitchBend(note: note, pitchBend: pitchBend)
        //print("Frequency: " + String(oscillator.frequency))
    }
    
    func getFrequencyFromNoteAndPitchBend(note: MIDINoteNumber, pitchBend: UInt16) -> Double {
        return 440.0 * pow(2.0, (((Double(note) - 69.0) / 12.0)
            + Double(pitchBendRange) * (Double(pitchBend) - 8192.0) / (4096.0 * 12.0)))
    }
    
    func setADSR(attackDuration: Double, decayDuration: Double, sustainLevel: Double, releaseDuration: Double){
        output.rampDuration = 0
        setAttack(attackDuration)
        setDecay(decayDuration)
        setSustain(sustainLevel)
        setRelease(releaseDuration)
    }
    
    func setAttack(_ attackDuration: Double){
        output.attackDuration = attackDuration
        //print("we set the attack to: " + String(output.attackDuration) )
    }
    func setDecay(_ decayDuration: Double){
        output.decayDuration = decayDuration
        //print("we set the decay to: " + String(output.decayDuration) )
    }
    func setSustain(_ sustainLevel: Double){
        output.sustainLevel = sustainLevel
        //print("we set the sustain to: " + String(output.sustainLevel ) )
    }
    func setRelease(_ releaseDuration: Double){
        output.releaseDuration = releaseDuration
        //print("we set the release to: " + String(output.releaseDuration) )
    }
    
    func play(){
        oscillator.start()
        output.start()
    }
    
    func kill(){
        output.stop()
        DispatchQueue.main.asyncAfter(deadline: .now() + output.attackDuration + output.decayDuration + output.releaseDuration * 5.0) {
            self.oscillator.stop()
            self.oscillator.detach()
            self.output.detach()
        }
    }
    
    deinit{
        //print("killed the voice")
    }
    
}

class MorphingOscillatorBank: MonoAudioSource{
    
    var waveforms : [AKTable] = [AKTable(.sine), AKTable(.triangle), AKTable(.square), AKTable(.sawtooth)]
    var displayWaveform : [Float] = [Float](AKTable(.sine))
    
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
        }
    }
    
    var attack: Double = 99{
        didSet{
            for voice in voices{
                voice.setAttack(attack)
            }
        }
    }
    
    var decay: Double = 0.1{
        didSet{
            for voice in voices{
                voice.setDecay(decay)
            }
        }
    }
    
    var sustain: Double = 1.0{
        didSet{
            for voice in voices{
                voice.setSustain(sustain)
            }
        }
    }

    var release: Double = 0.01{
        didSet{
            for voice in voices{
                voice.setRelease(release)
            }
        }
    }
    
    var releaseDisplay: Double = 0.01
    
    var oscillatorMixer = AKMixer()
    
    @Published var indexControl = KnobCompleteModel(){
        didSet{ setIndexControl() }
    }
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
    
    init(){
        //displayWaveform = calculateDisplayWavetable()
        //[Float](vDSP.linearInterpolate([Float](waveforms[0]),[Float](waveforms[1]),using: Float(index)))
        
        super.init(toggle: oscillatorMixer, node: oscillatorMixer)
        
        displayOnImage = Image(systemName: "o.circle.fill")
        displayOffImage = Image(systemName: "o.circle")
        setDisplayImage()
        
        indexControl.name = "Waveform"
        indexControl.handoffDelegate = self
        indexControl.range = Double(waveforms.count - 1)
        setIndexControl()
        
        attackControl.name = "Attack"
        attackControl.handoffDelegate = self
        attackControl.percentRotated = 0.01
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
        releaseControl.range = 1
        setReleaseControl()

        selectedBlockDisplay = SelectedBlockDisplay.controls
        name = "OSC 1"
        
        isSetup = true
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
        else if(sender === attackControl){
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
    
    func setIndexControl(){
        index = indexControl.realModValue * indexControl.range
        indexControl.display = String(format: "%.2f",index)
        
        if(isSetup){
            displayWaveform = calculateDisplayWavetable()
        }
    }
    func setAttackControl(){
        attack = pow(attackControl.realModValue, 3) * attackControl.range
        attackControl.display = String(format: "%.2f",attack) + " s"
        //print("set attack to: " + String(attack))
    }
    func setDecayControl(){
        decay = 0.1 + pow(decayControl.realModValue, 3) * decayControl.range
        decayControl.display = String(format: "%.2f",decay) + " s"
        //print("set decay to: " + String(decay))
    }
    func setSustainControl(){
        sustain = sustainControl.realModValue * sustainControl.range
        sustainControl.display = String(format: "%.2f",sustain) + " db"
        //print("set sustain to: " + String(sustain))
    }
    func setReleaseControl(){
        release = 0.01 + pow(releaseControl.realModValue, 3) * releaseControl.range
        releaseDisplay = release * 5.0
        releaseControl.display = String(format: "%.2f", releaseDisplay) + " s"
        //print("set release to: " + String(release))
    }
    
    func calculateDisplayWavetable() -> [Float]{
        
        //var arrayCount = waveforms[0].count
        
        //var table3 = [Float](waveforms[0])
        //var table4 = [Float](waveforms[0])
        
        /*
        var table1 : [Double] = Array(repeating: 0.0, count: arrayCount)
        var table2 : [Double] = Array(repeating: 0.0, count: arrayCount)
        
        for element in 0...waveforms[0].count - 1{
            //let value = waveforms[0][element].value()
            //print(value)
            table1[element] = waveforms[0][element].value()
            table2[element] = waveforms[1][element].value()
        }
        */
        
        //displayWaveform = result
        if(index < 1){
            return [Float](vDSP.linearInterpolate([Float](waveforms[0]),[Float](waveforms[1]),using: Float(index)))
        }
        else if(index < 2){
            return [Float](vDSP.linearInterpolate([Float](waveforms[1]),[Float](waveforms[2]),using: Float(index - 1)))
        }
        else{
            return [Float](vDSP.linearInterpolate([Float](waveforms[2]),[Float](waveforms[3]),using: Float(index - 2)))
        }
        
        
        
        /*
        for element in 0...waveforms[0].count - 1{
            displayWaveform[element] = Float(result[element])
            print(displayWaveform[element])
        }
        */
        
        //displayWaveform
        
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
