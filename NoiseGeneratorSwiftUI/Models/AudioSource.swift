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
    @Published var isDisplayed = true
    /*{
        didSet{
            setDisplayImage()
        }
    }*/
    
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
        setDisplayImage()
    }
    
    func setDisplayImage(){
        if(!isBypassed){
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
    
    func ToggleModulationAssignment() {
        //This should tell noise that we are trying to assign a knob
        handoffDelegate?.toggleModulationAssignment()
    }
    
    func ToggleModulationSpecialSelection(){
        handoffDelegate?.toggleModulationSpecialSelection()
    }
    
    func ToggleTempoSync(_ sender: KnobCompleteModel) {
        // this will be override by any tempo synced controls - probably none for sources
    }
    
}

public class MonoAudioSource: AudioSource{
    var input: AKInput
    
    override func setupInputRouting(){
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

/// Input Audio Source
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
        
        //This is currently Mono, that should toggle based on user preference
        let stereoFieldLimiter = AKStereoFieldLimiter(input)
        //stereoFieldLimiter.setOutput(to: outputMixer)
        stereoFieldLimiter.setOutput(to: volumeMixer.input)
        
        displayOnImage = Image(systemName: "mic.circle.fill")
        displayOffImage = Image(systemName: "mic.circle")
        setDisplayImage()
        
        selectedBlockDisplay = .volume
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


/// An audio source that controls ADSR, but doesn not itself implement it (such as a oscillator bank that control individual voices)
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
    
    init(){
        let mixer = AKMixer()
        super.init(toggle: mixer, node: mixer)
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
    
    func play(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel){
        fatalError("This method must be overriden")
    }
    
}


/// An audio source that controls and implements ADSR
public class adsrSourceMono: adsrPolyphonicController{
    
    var output: AKAmplitudeEnvelope = AKAmplitudeEnvelope()
    //var sourceNode: AKNode
    
    override init(toggle: AKToggleable, node: AKInput ){
        super.init(toggle: output, node: output )
        //sourceNode = node
        node.setOutput(to: output)
        setADSR(attackDuration: attack, decayDuration: decay, sustainLevel: sustain, releaseDuration: release)
    }
    
    override init(){
        super.init(toggle: output, node: output)
        self.selectedBlockDisplay = .adsr
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

/// A noise generating audio source that controls and implements ADSR
public class NoiseSource: adsrSourceMono{
    
    private let whiteNoise = AKWhiteNoise()
    private let pinkNoise = AKPinkNoise()
    private let brownNoise = AKBrownianNoise()
    
    var noiseMixer = AKMixer()
    
    override init(){
        super.init(toggle: noiseMixer, node: noiseMixer)
        stop()
        setNoiseRouting()
        setNoiseVolumes()
        isBypassed = true
        
        displayOnImage = Image(systemName: "n.circle.fill")
        displayOffImage = Image(systemName: "n.circle")
        
        name = "Noise"
        selectedBlockDisplay = .volume
        
        isBypassed = false
    }
    
    //This is handling both the on and the off events
    override func play(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel){
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
        setDisplayImage()
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

/// A container for many adsr voices with amplitude, pitch, and adsr control
public class ADSRVoiceBank: adsrPolyphonicController{
    
    var voices : [ADSRVoice] = []
    var oscillatorMixer = AKMixer()
    
    override init(){
        super.init(toggle: oscillatorMixer, node: oscillatorMixer)
        name = "VoiceBank"
    }
    
    //This is handling both the on and the off events
    override func play(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel){
        if(velocity > 0){
            let newVoice = createSpecificVoice(note: note, velocity: velocity, channel: channel)
            newVoice.setADSR(attackDuration: attack, decayDuration: decay, sustainLevel: sustain, releaseDuration: release)
            newVoice.output.setOutput(to: oscillatorMixer)
            newVoice.play()
            voices.append(newVoice)
            //print(AudioKit.engine.description)
        }
        else{
            let killVoices = voices.filter {$0.note == note}
            for killVoice in killVoices{
                killVoice.kill()
            }
            voices = voices.filter {$0.note != note}
        }
    }
    
    func createSpecificVoice(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) -> ADSRVoice{
        let newVoice = ADSRVoice()
        return newVoice
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
    
    func handlePitchBend(pitchWheelValue: MIDIWord, channel: MIDIChannel){
        for voice in voices{
            if(voice.channel.hex == channel.hex){
                //print("same channel")
                voice.pitchBend = pitchWheelValue
            }
        }
    }
    
    /* Determines which KnobCompleteModel sent the change and forwards the update to the appropriate parameter */
    override func modulationValueWasChanged(_ sender: KnobCompleteModel) {
        checkCustomControls(sender)
        checkControlsADSR(sender)
    }
    
    func checkCustomControls(_ sender: KnobCompleteModel){}
    
}

/// A container for many morphing voices (oscillators with waveform, pitch, and adsr control)
public class MorphingOscillatorBank: ADSRVoiceBank{

    //REMEMBER THAT THIS MUST ALWAYS HAVE EXACTLY 4 TABLES (WE USE 1 AND 2)
    var waveforms : [AKTable] = [AKTable(.sine), AKTable(.sawtooth), AKTable(.square), AKTable(.triangle)]
    var displayWaveform : [Float] = [Float](AKTable(.sine))
    
    var displayWaveTables : [DisplayWaveTable] = []
    @Published var displayIndex: Int = 0
    @Published var is3DView = false
    var numberOf3DTables = 49
    
    
    //var voices : [Voice] = []
    
    //This is custom
    var index: Double = 1.0{
        didSet{
            // I think we need to prevent voices from being destroyed until after this loop
            // EXC_BAD_ACCESS(code=2, address=0x197a65fb8)
            for voice in voices{
                let oscillator = voice as! MorphingOscillatorVoice
                oscillator.oscillator.index = index
            }
            displayIndex = Int(index * numberOf3DTables)
        }
    }
    
    @Published var indexControl = KnobCompleteModel(){
        didSet{ setIndexControl() }
    }
    
    override init(){
        super.init()
        
        displayOnImage = Image(systemName: "o.circle.fill")
        displayOffImage = Image(systemName: "o.circle")
        setDisplayImage()
        
        indexControl.name = "Waveform"
        indexControl.handoffDelegate = self
        //indexControl.range = 1 //Double(waveforms.count - 1)
        setIndexControl()

        selectedBlockDisplay = SelectedBlockDisplay.controls
        name = "OSC 1"

        calculateAllWaveTables()
    }
    
    override func createSpecificVoice(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) -> ADSRVoice{
        let newVoice = MorphingOscillatorVoice(note: note, velocity: velocity, channel: channel, waveforms: waveforms)
        newVoice.oscillator.index = index
        return newVoice
    }
    
    override func checkCustomControls(_ sender: KnobCompleteModel){
        if(sender === indexControl){
            setIndexControl()
        }
    }
    
    func setIndexControl(){
        index = indexControl.realModValue * indexControl.range
        indexControl.display = String(format: "%.2f",index)
        displayWaveform = calculateDisplayWavetable()
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
        /*
        // Get the floating point's [Element] that makes a AKTable
        let table = waveforms[0].content
        
        // it can be converted from [Element] to [Float]
        let floats : [Float] = table
        
        // Creates a wavetable from [Float]
        let newTable = AKTable(floats)
        
        waveforms[1] = newTable
         */
        
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

/// A container for many morphing voices with FM
public class MorphingFMOscillatorBank: adsrPolyphonicController{
    
    var voices : [FMOscillatorVoice] = []
    var oscillatorMixer = AKMixer()
    
    var displayWaveform : [Float] = []

    var waveforms : [AKTable] = []
    var defaultWaves : [AKTable] = [AKTable(.sine, count: 4096), AKTable(.sawtooth, count: 4096)]
    
    var displayWaveTables : [DisplayWaveTable] = []
    @Published var displayIndex: Int = 0
    
    @Published var is3DView = false
    
    var numberOfWavePositions = 255
    
    var isSetup = false
    
    //This is handling both the on and the off events
    override func play(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel){
        if(velocity > 0){
            let newVoice = createSpecificVoice(note: note, velocity: velocity, channel: channel)
            //newVoice.setADSR(attackDuration: attack, decayDuration: decay, sustainLevel: sustain, releaseDuration: release)
            newVoice.source.setOutput(to: oscillatorMixer)
            newVoice.play()
            voices.append(newVoice)
            //print(AudioKit.engine.description)
        }
        else{
            let killVoices = voices.filter {$0.note == note}
            for killVoice in killVoices{
                killVoice.kill()
            }
            voices = voices.filter {$0.note != note}
        }
    }
    
    override func attackControlChange(){
        for voice in voices{
            voice.source.attackDuration = attack
        }
    }
     override func decayControlChange(){
         for voice in voices{
             voice.source.decayDuration = decay
         }
     }
     override func sustainControlChange(){
         for voice in voices{
             voice.source.sustainLevel = sustain
         }
     }
     override func releaseControlChange(){
         for voice in voices{
             voice.source.releaseDuration = release
         }
     }
    
    func handlePitchBend(pitchWheelValue: MIDIWord, channel: MIDIChannel){
        for voice in voices{
            if(voice.channel.hex == channel.hex){
                //print("same channel")
                voice.pitchBend = pitchWheelValue
            }
        }
    }
    
    /* Determines which KnobCompleteModel sent the change and forwards the update to the appropriate parameter */
    override func modulationValueWasChanged(_ sender: KnobCompleteModel) {
        checkCustomControls(sender)
        checkControlsADSR(sender)
    }
    
    func checkCustomControls(_ sender: KnobCompleteModel){
        if(sender === waveformIndexControl){
            setWaveformIndexControl()
        }
        else if(sender === modulationIndexControl){
            setModulationIndexControl()
        }
    }
    
    var wavePosition: Int = 0{
        didSet{
            for voice in voices{
                voice.setWaveTable(table: waveforms[wavePosition])
            }
        }
    }
    
    @Published var waveformIndexControl = KnobCompleteModel(){
        didSet{
            setWaveformIndexControl()
        }
    }
    
    @Published var modulationIndexControl = KnobCompleteModel(){
        didSet{
            setModulationIndexControl()
        }
    }
    
    override init(){
        super.init(toggle: oscillatorMixer, node: oscillatorMixer)
        
        calculateAllWaveTables()
        
        isSetup = true
        
        displayOnImage = Image(systemName: "o.circle.fill")
        displayOffImage = Image(systemName: "o.circle")
        setDisplayImage()
        
        waveformIndexControl.name = "Waveform"
        waveformIndexControl.handoffDelegate = self
        setWaveformIndexControl()
        
        modulationIndexControl.name = "Mod Index"
        modulationIndexControl.handoffDelegate = self
        modulationIndexControl.range = 10
        setModulationIndexControl()

        selectedBlockDisplay = SelectedBlockDisplay.controls
        name = "FM OSC 1"

        
    }
    
    func createSpecificVoice(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) -> FMOscillatorVoice{
        let newVoice = FMOscillatorVoice(note: note,
                                         velocity: velocity,
                                         channel: channel,
                                         waveform: waveforms[wavePosition],
                                         modulationIndex: modulationIndex,
                                         attackDuration: attack,
                                         decayDuration: decay,
                                         sustainLevel: sustain,
                                         releaseDuration: release)
        //newVoice.oscillator.index = wavePosition
        return newVoice
    }
    
    
    func setWaveformIndexControl(){
        wavePosition = Int(waveformIndexControl.realModValue * waveformIndexControl.range * numberOfWavePositions)
        waveformIndexControl.display = String(wavePosition)
        if(isSetup){
            displayWaveform = displayWaveTables[wavePosition].waveform //calculateDisplayWavetable()
        }
    }
    
    var modulationIndex: Double = 0.0{
        didSet{
            for voice in voices{
                voice.source.modulationIndex = modulationIndex
                //print(modulationIndex)
            }
        }
    }
    
    func setModulationIndexControl(){
        modulationIndex = modulationIndexControl.realModValue * modulationIndexControl.range
        waveformIndexControl.display = String(modulationIndex)
    }

    func calculateAllWaveTables(){
        
        /*
        // Get the floating point's [Element] that makes a AKTable
        let table = waveforms[0].content
        
        // it can be converted from [Element] to [Float]
        let floats : [Float] = table
        
        // Creates a wavetable from [Float]
        let newTable = AKTable(floats)
        
        waveforms[1] = newTable
         defaultWaves
         */
        
        // 85 = 256 / 3
        let rangeValue = (Double(numberOfWavePositions + 1) / Double(defaultWaves.count - 1)).rounded(.up)
        
        
        displayWaveTables = []
        waveforms = []
        
        // 0 -> 255 (256 total)
        for i in 0...numberOfWavePositions{
            
            // this lets us grab the appropriate wavetables in an arbitrary array of tables
            
            // 0 = Int(37 / 85)
            // 1 = Int(90 / 85)
            // 2 = Int(170 / 85)
            let waveformIndex = Int(i / rangeValue) // % defaultWaves.count
            
            // 0.4118 = 35 / 85 % 1.0
            // 0.5882 = 135 / 85 % 1.0
            let interpolatedIndex = (Double(i) / rangeValue).truncatingRemainder(dividingBy: 1.0)
            
            // calculate float values
            let tableElements = DisplayWaveTable([Float](vDSP.linearInterpolate([Float](defaultWaves[waveformIndex]),
                                                                        [Float](defaultWaves[waveformIndex+1]),
                                                                        using: Float(interpolatedIndex) ) ) )
            
            displayWaveTables.append(tableElements)
            
            /*
            for i in tableElements.waveform.indices {
                tableElements.waveform[i] *= 0.1
            }
            */
            
            waveforms.append( AKTable(tableElements.waveform.map { $0 * 0.75 } ) )
            
        }
    }
}

/// A container for many piano voices
public class RhodesPianoBank: ADSRVoiceBank{
    override init(){
        super.init()
        
        displayOnImage = Image(systemName: "p.circle.fill")
        displayOffImage = Image(systemName: "p.circle")
        setDisplayImage()

        selectedBlockDisplay = SelectedBlockDisplay.adsr
        name = "Piano 1"
    }
    
    override func createSpecificVoice(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) -> ADSRVoice{
        return RhodesPianoVoice(note: note, velocity: velocity, channel: channel)
    }
}

/// A container for many flute voices
public class FluteBank: ADSRVoiceBank{
    override init(){
        super.init()
        
        displayOnImage = Image(systemName: "f.circle.fill")
        displayOffImage = Image(systemName: "f.circle")
        setDisplayImage()

        selectedBlockDisplay = SelectedBlockDisplay.adsr
        name = "Flute 1"
    }
    
    override func createSpecificVoice(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) -> ADSRVoice{
        return FluteVoice(note: note, velocity: velocity, channel: channel)
    }
}

/// A container for many flute voices
public class StringBank: ADSRVoiceBank{
    override init(){
        super.init()
        
        displayOnImage = Image(systemName: "s.circle.fill")
        displayOffImage = Image(systemName: "s.circle")
        setDisplayImage()

        selectedBlockDisplay = SelectedBlockDisplay.adsr
        name = "String 1"
    }
    
    override func createSpecificVoice(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) -> ADSRVoice{
        return StringVoice(note: note, velocity: velocity, channel: channel)
    }
}

/// A container for many clarinet voices
public class ClarinetBank: ADSRVoiceBank{
    override init(){
        super.init()
        
        displayOnImage = Image(systemName: "c.circle.fill")
        displayOffImage = Image(systemName: "c.circle")
        setDisplayImage()

        selectedBlockDisplay = SelectedBlockDisplay.adsr
        name = "Clarinet 1"
    }
    
    override func createSpecificVoice(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) -> ADSRVoice{
        return ClarinetVoice(note: note, velocity: velocity, channel: channel)
    }
}

/// A container for many bell voices
public class BellBank: ADSRVoiceBank{
    override init(){
        super.init()
        
        displayOnImage = Image(systemName: "b.circle.fill")
        displayOffImage = Image(systemName: "b.circle")
        setDisplayImage()

        selectedBlockDisplay = SelectedBlockDisplay.adsr
        name = "Bell 1"
    }
    
    override func createSpecificVoice(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) -> ADSRVoice{
        return BellVoice(note: note, velocity: velocity, channel: channel)
    }
}

/// An audio sources that implements ADSR but does not itself have parameter controls (such as voices).
public class adsrSourceWithoutControl{
    
    var output: AKAmplitudeEnvelope = AKAmplitudeEnvelope()
    
    func connectToADSR(_ node: AKNode){
        node.setOutput(to: output)
    }
    
    func kill(){
        output.stop()
        DispatchQueue.main.asyncAfter(deadline: .now() + output.attackDuration + output.decayDuration + output.releaseDuration * 5.0) {
            
            self.killSourceNode()
            
            //self.output.disconnect()
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

/// An audio sources containing a sound source with individual pitch control.
public class FMOscillatorVoice{
    
    var source : AKFMOscillatorBank
    
    var frequency : Double = 100
    
    var pitchBendRange: UInt16 = 24

    var pitchBend: UInt16 = 16_384 / 2{
        didSet{
            frequency = getFrequencyFromNoteAndPitchBend(note: note, pitchBend: pitchBend)
        }
    }
    
    var channel: MIDIChannel
    var note: MIDINoteNumber
    var velocity: MIDIVelocity
    
    init(){
        fatalError("Voice Object should never be created this way")
    }
    
    init(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel, sourceNode: AKFMOscillatorBank, waveform: AKTable){
        self.note = note
        self.channel = channel
        self.source = sourceNode
        self.velocity = velocity
        
        
        source.waveform = waveform
        //setupNote(note: note, velocity: velocity)
    }
    
    init(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel, waveform: AKTable, modulationIndex: Double, attackDuration: Double, decayDuration: Double, sustainLevel: Double, releaseDuration: Double){
        self.note = note
        self.channel = channel
        self.source = AKFMOscillatorBank(waveform: waveform,
                                         carrierMultiplier: 1.0,
                                         modulatingMultiplier: 1.0,
                                         modulationIndex: modulationIndex,
                                         attackDuration: attackDuration,
                                         decayDuration: decayDuration,
                                         sustainLevel: sustainLevel,
                                         releaseDuration: releaseDuration,
                                         pitchBend: 0.0,
                                         vibratoDepth: 0.0,
                                         vibratoRate: 1.0)
        self.velocity = velocity
        
        source.rampDuration = 0.0001
        //source.modulationIndex = 0.0
        //source.vibratoDepth = 0.0
        
        
        
        //source.waveform = waveform
        //setupNote(note: note, velocity: velocity)
    }
    
    /*
    func setupNote(note: MIDINoteNumber, velocity: MIDIVelocity){
        //convert midi note to frequency
        setOscillatorFrequency()
        
        //convert 0 to 127 range to 0 to 0.5 (because it's LOUD - maybe even go less)
        amplitude = Double(velocity) / 127.0
        
        //oscillator.setOutput(to: output)
        //connectToADSR(sourceNode)
    }
    */
    
    func setADSR(attackDuration: Double, decayDuration: Double, sustainLevel: Double, releaseDuration: Double){
        source.attackDuration = attackDuration
        source.decayDuration = releaseDuration
        source.sustainLevel = sustainLevel
        source.releaseDuration = releaseDuration
    }
    
    func kill(){
        source.stop(noteNumber: note)
        //DispatchQueue.main.asyncAfter(deadline: .now() + source.attackDuration + source.decayDuration + source.releaseDuration * 5.0) {
        /*
        DispatchQueue.global.asyncAfter(deadline: .now() + source.attackDuration + source.decayDuration + source.releaseDuration * 5.0) {
            self.source.detach()
        }
        */
        let queue = DispatchQueue(label: "source-killer-queue")
        
        queue.asyncAfter(deadline: .now() + source.attackDuration + source.decayDuration + source.releaseDuration * 5.0) {
            self.source.detach()
        }
        
        //perform(#selector(killFM), with: nil, afterDelay: .now() + source.attackDuration + source.decayDuration + source.releaseDuration * 5.0)
    }
    
    
    @objc func killFM(){
        self.source.detach()
    }
    
    func setOscillatorFrequency(){
        frequency = getFrequencyFromNoteAndPitchBend(note: note, pitchBend: pitchBend)
        //print("Frequency: " + String(oscillator.frequency))
    }
    
    func getFrequencyFromNoteAndPitchBend(note: MIDINoteNumber, pitchBend: UInt16) -> Double {
        return 440.0 * pow(2.0, (((Double(note) - 69.0) / 12.0)
            + Double(pitchBendRange) * (Double(pitchBend) - 8192.0) / (4096.0 * 12.0)))
    }
    
    deinit{
        print("killed the voice")
    }
    
    func setWaveTable(table: AKTable){
        source.waveform = table
    }
    
    func play(){
        //let frequency = getFrequencyFromNoteAndPitchBend(note: note, pitchBend: pitchBend)
        source.play(noteNumber: note, velocity: velocity, channel: channel)
    }
}

/// An audio sources containing a sound source with individual pitch control and ADSR.
public class ADSRVoice: adsrSourceWithoutControl{
    
    var sourceNode : AKNode
    var amplitude : Double = 0{
        didSet{
            setSourceAmplitude()
        }
    }
    
    var frequency : Double = 100{
        didSet{
            setSourceFrequency()
        }
    }
    
    var pitchBendRange: UInt16 = 24

    var pitchBend: UInt16 = 16_384 / 2{
        didSet{
            frequency = getFrequencyFromNoteAndPitchBend(note: note, pitchBend: pitchBend)
        }
    }
    
    var channel: MIDIChannel
    var note: MIDINoteNumber
    
    override init(){
        fatalError("Voice Object should never be created this way")
    }
    
    init(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel, sourceNode: AKNode){
        self.note = note
        self.channel = channel
        self.sourceNode = sourceNode
        super.init()
        setupNote(note: note, velocity: velocity)
    }
    
    func setupNote(note: MIDINoteNumber, velocity: MIDIVelocity){
        //convert midi note to frequency
        setOscillatorFrequency()
        
        //convert 0 to 127 range to 0 to 0.5 (because it's LOUD - maybe even go less)
        amplitude = Double(velocity) / 127.0
        
        //oscillator.setOutput(to: output)
        connectToADSR(sourceNode)
    }
    
    func setOscillatorFrequency(){
        frequency = getFrequencyFromNoteAndPitchBend(note: note, pitchBend: pitchBend)
        //print("Frequency: " + String(oscillator.frequency))
    }
    
    func getFrequencyFromNoteAndPitchBend(note: MIDINoteNumber, pitchBend: UInt16) -> Double {
        return 440.0 * pow(2.0, (((Double(note) - 69.0) / 12.0)
            + Double(pitchBendRange) * (Double(pitchBend) - 8192.0) / (4096.0 * 12.0)))
    }
    
    deinit{
        print("killed the voice")
    }
    
    func setSourceAmplitude(){
        fatalError("This method must be overridden by the subclass")
    }
    func setSourceFrequency(){
        fatalError("This method must be overridden by the subclass")
    }
    func play(){
        fatalError("This method must be overridden by the subclass")
    }

}

/// An audio source that represents a rhodes piano
public class RhodesPianoVoice: ADSRVoice{
    var source : AKRhodesPiano
    
    init(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel){
        source = AKRhodesPiano()
        source.rampDuration = 0.001
        super.init(note: note, velocity: velocity, channel: channel, sourceNode: source)
    }
    
    override func play(){
        source.start()
        source.trigger(frequency: frequency, amplitude: amplitude)
        output.start()
    }

    override func killSourceNode(){
        self.source.stop()
        self.source.disconnectOutput()
        self.source.detach()
    }
    
    override func setSourceAmplitude(){
        self.source.amplitude = self.amplitude
    }
    override func setSourceFrequency(){
        self.source.frequency = self.frequency
    }
}

/// An audio source that represents a flute
public class FluteVoice: ADSRVoice{
    var source : AKFlute
    
    init(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel){
        source = AKFlute()
        source.rampDuration = 0.001
        super.init(note: note, velocity: velocity, channel: channel, sourceNode: source)
    }
    
    override func play(){
        source.start()
        source.trigger(frequency: frequency, amplitude: amplitude)
        output.start()
    }

    override func killSourceNode(){
        self.source.stop()
        self.source.disconnectOutput()
        self.source.detach()
    }
    
    override func setSourceAmplitude(){
        self.source.amplitude = self.amplitude
    }
    override func setSourceFrequency(){
        self.source.frequency = self.frequency
    }
}

/// An audio source that represents a plucked string
public class StringVoice: ADSRVoice{
    var source : AKPluckedString
    
    init(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel){
        source = AKPluckedString()
        source.rampDuration = 0.001
        super.init(note: note, velocity: velocity, channel: channel, sourceNode: source)
    }
    
    override func play(){
        source.start()
        source.trigger(frequency: frequency, amplitude: amplitude)
        output.start()
    }

    override func killSourceNode(){
        self.source.stop()
        self.source.disconnectOutput()
        self.source.detach()
    }
    
    override func setSourceAmplitude(){
        self.source.amplitude = self.amplitude
    }
    override func setSourceFrequency(){
        self.source.frequency = self.frequency
    }
}

/// An audio source that represents a plucked string
public class BellVoice: ADSRVoice{
    var source : AKTubularBells
    
    init(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel){
        source = AKTubularBells()
        source.rampDuration = 0.001
        super.init(note: note, velocity: velocity, channel: channel, sourceNode: source)
    }
    
    override func play(){
        source.start()
        source.trigger(frequency: frequency, amplitude: amplitude)
        output.start()
    }

    override func killSourceNode(){
        self.source.stop()
        self.source.disconnectOutput()
        self.source.detach()
    }
    
    override func setSourceAmplitude(){
        self.source.amplitude = self.amplitude
    }
    override func setSourceFrequency(){
        self.source.frequency = self.frequency
    }
}

/// An audio source that represents a clarinet
public class ClarinetVoice: ADSRVoice{
    var source : AKClarinet
    
    init(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel){
        source = AKClarinet()
        source.rampDuration = 0.001
        super.init(note: note, velocity: velocity, channel: channel, sourceNode: source)
    }
    
    override func play(){
        source.start()
        source.trigger(frequency: frequency, amplitude: amplitude)
        output.start()
    }

    override func killSourceNode(){
        self.source.stop()
        self.source.disconnectOutput()
        self.source.detach()
    }
    
    override func setSourceAmplitude(){
        self.source.amplitude = self.amplitude
    }
    override func setSourceFrequency(){
        self.source.frequency = self.frequency
    }
}

/// An audio sources containing an oscillator with individual pitch control and ADSR.
public class MorphingOscillatorVoice: ADSRVoice{
    
    var oscillator : AKMorphingOscillator

    init(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel, waveforms: [AKTable]){
        oscillator = AKMorphingOscillator(waveformArray: waveforms)
        oscillator.rampDuration = 0.001
        super.init(note: note, velocity: velocity, channel: channel, sourceNode: oscillator)
    }

    override func play(){
        oscillator.start()
        output.start()
    }

    override func killSourceNode(){
        self.oscillator.stop()
        self.oscillator.disconnectOutput()
        self.oscillator.detach()
    }
    
    override func setSourceAmplitude(){
        // it's loud if we don't factor this down
        self.oscillator.amplitude = self.amplitude * 0.2
    }
    override func setSourceFrequency(){
        self.oscillator.frequency = self.frequency
    }
}

/// A wrapper for a [Float]
class DisplayWaveTable{
    var waveform : [Float]
    init(_ waveform: [Float]){
        self.waveform = waveform
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
