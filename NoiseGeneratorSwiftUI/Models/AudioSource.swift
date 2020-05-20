import AudioKit
import Combine
import SwiftUI

public class AudioSource: Identifiable, ObservableObject, KnobModelHandoff{
    
    
    
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
    
    /*
    func KnobModelAssignToModulation(_ sender: KnobCompleteModel) {
        handoffDelegate?.KnobModelAssignToModulation(sender)
    }
    func KnobModelRemoveModulation(_ sender: KnobCompleteModel) {
        handoffDelegate?.KnobModelRemoveModulation(sender)
    }
    func KnobModelAdjustModulationRange(_ sender: KnobCompleteModel, adjust: Double) {
        handoffDelegate?.KnobModelAdjustModulationRange(sender, adjust: adjust)
    }
    */
    
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
    
    var isAllocated: Bool = false
    
    var pitchBend: UInt16 = 16_384 / 2{
        didSet{
            print("didSet pitchBend")
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
    
    /*
    init(waveforms: [AKTable]){
        oscillator = AKMorphingOscillator(waveformArray: waveforms)
        oscillator.setOutput(to: output)
        oscillator.rampDuration = 0.001
    }
    */
    
    init(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel, waveforms: [AKTable]){
        
        print("")
        print("New Voice!")
        print("Note Number: " + String(note))
        print("Velocity: " + String(velocity))
        print("channel: " + String(channel))
        
        oscillator = AKMorphingOscillator(waveformArray: waveforms)
        oscillator.rampDuration = 0.001
        self.channel = channel
        self.note = note
        setupNote(note: note, velocity: velocity)
    }
    
    func allocateVoice(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel){
        isAllocated = true
        self.channel = channel
        self.note = note
        setupNote(note: note, velocity: velocity)
        oscillator.setOutput(to: output)
    }
    
    func setupNote(note: MIDINoteNumber, velocity: MIDIVelocity){
        
        //output.releaseDuration = 0.1
        
        //convert midi note to frequency
        setOscillatorFrequency()
        
        //convert 0 to 127 range to 0 to 1.0
        oscillator.amplitude = Double(velocity) / 127.0 * 0.5
        
        print("Amplitude: " + String(oscillator.amplitude))
        
        oscillator.setOutput(to: output)
    }
    
    func setOscillatorFrequency(){
        oscillator.frequency = getFrequencyFromNoteAndPitchBend(note: note, pitchBend: pitchBend)
        //oscillator.frequency = note.midiNoteToFrequency()
        print("Frequency: " + String(oscillator.frequency))
    }
    
    func getFrequencyFromNoteAndPitchBend(note: MIDINoteNumber, pitchBend: UInt16) -> Double {
        return 440.0 * pow(2.0, (((Double(note) - 69.0) / 12.0)
            + Double(pitchBendRange) * (Double(pitchBend) - 8192.0) / (4096.0 * 12.0)))
    }
    
    func setADSR(attackDuration: Double, decayDuration: Double, sustainLevel: Double, releaseDuration: Double){
        setAttack(attackDuration)
        setDecay(decayDuration)
        setSustain(sustainLevel)
        setRelease(releaseDuration)
    }
    
    func setAttack(_ attackDuration: Double){
        output.attackDuration = attackDuration
    }
    func setDecay(_ decayDuration: Double){
        output.decayDuration = decayDuration
    }
    func setSustain(_ sustainLevel: Double){
        output.sustainLevel = sustainLevel
    }
    func setRelease(_ releaseDuration: Double){
        output.releaseDuration = releaseDuration
    }
    
    func play(){
        
        oscillator.start()
        output.start()
    }
    
    func stop(){
        oscillator.stop()
    }
    
    func kill(){
        output.stop()
        //oscillator.stop()
        //oscillator.disconnectOutput()
        //isAllocated = false
        //print("killed the voice")
        //oscillator.detach()
        //output.detach()
        
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + output.attackDuration + output.decayDuration + output.releaseDuration * 5.0) {
            // your code here
            self.oscillator.stop()
            self.oscillator.detach()
            self.output.detach()
        }
        
        
        /*
        let t = DispatchSource.makeTimerSource()
        t.schedule(deadline: DispatchTime.now() + output.releaseDuration * 5.0, leeway: DispatchTimeInterval.nanoseconds(500_000_000))
        t.setEventHandler(handler: { [weak self] in
            // called every so often by the interval we defined above
            //self!.timerAction()
            //self!.oscillator.stop()
            //self!.oscillator.disconnectOutput()
            //self!.output.disconnectOutput()
            DispatchQueue.main.async {
                self!.oscillator.detach()
                self!.output.detach()
            }
            //print("killed the voice")
            t.setEventHandler {}
            t.cancel()
        })
        */
    }
    
    /*
    @objc func timerAction(){
        oscillator.stop()
        oscillator.disconnectOutput()
        output.disconnectOutput()
    }*/
    
    
    deinit{
        //self!.oscillator = nil
        //self!.output = nil
        print("killed the voice")
    }
    
}

class MorphingOscillatorBank: MonoAudioSource{

    //var oscillator : AKMorphingOscillatorBank = AKMorphingOscillatorBank(waveformArray: [AKTable(.sine), AKTable(.triangle),AKTable(.square), AKTable(.sawtooth)])
    
    var waveforms = [AKTable(.sine), AKTable(.triangle),AKTable(.square), AKTable(.sawtooth)]
    
    var voices : [Voice] = []
    
    //var voices = [Voice?](repeating: nil, count: 64)
    //var allocatedVoices : [Voice] = []
    //var waveforms: [AKTable] = [AKTable(.sine), AKTable(.triangle),AKTable(.square), AKTable(.sawtooth)]
    var index: Double = 1.0{
        didSet{
            //oscillator.index = control1.realModValue * control1.range
            
            for voice in voices{
                voice.oscillator.index = control1.realModValue * control1.range
            }
            
        }
    }
    
    /*
    func createVoices(){
        for i in 0...voices.count-1{
            voices[i] = Voice(waveforms: waveforms)
            voices[i]!.setADSR(attackDuration: attack, decayDuration: decay, sustainLevel: sustain, releaseDuration: release)
            voices[i]!.oscillator.index = index
        }
    }
    */
    
    var attack: Double = 0.1
    var decay: Double = 0.1
    var sustain: Double = 1.0
    var release: Double = 0.01
    
    var oscillatorMixer = AKMixer()
    
    @Published var control1 = KnobCompleteModel(){
        didSet{ setControl1() }
    }
    
    init(){
        super.init(toggle: oscillatorMixer, node: oscillatorMixer)
        
        //createVoices()
        
        displayOnImage = Image(systemName: "o.circle.fill")
        displayOffImage = Image(systemName: "o.circle")
        setDisplayImage()
        
        control1.name = name + " waveform"
        //control1.delegate = self
        control1.handoffDelegate = self
        control1.range = Double(waveforms.count - 1)
        setControl1()
        
        //oscillator.setOutput(to: oscillatorMixer)

        name = "OSC 1"
    }
    
    //This is handling both the on and the off events
    func play(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel){
        //oscillator.play(noteNumber: note, velocity: velocity)
        
        if(velocity > 0){
            /*
            for i in 0...voices.count-1{
                if(!voices[i]!.isAllocated){
                    voices[i] = Voice(waveforms: waveformArray)
                    voices[i]!.setADSR(attackDuration: attack, decayDuration: decay, sustainLevel: sustain, releaseDuration: release)
                    voices[i]!.oscillator.index = index
                    
                    voices[i]!.allocateVoice(note: note, velocity: velocity, channel: channel)
                    voices[i]!.setADSR(attackDuration: attack, decayDuration: decay, sustainLevel: sustain, releaseDuration: release)
                    oscillatorMixer.connect(input: voices[i]!.output)
                    voices[i]!.play()
                    allocatedVoices.append(voices[i]!)
                    print(allocatedVoices)
                    break
                }
                //voices[i] = Voice(waveforms: waveformArray)
            }
            */
            
            
            let newVoice = Voice(note: note, velocity: velocity, channel: channel, waveforms: waveforms)
            newVoice.setADSR(attackDuration: attack, decayDuration: decay, sustainLevel: sustain, releaseDuration: release)
            newVoice.oscillator.index = index
            newVoice.output.setOutput(to: oscillatorMixer)
            //oscillatorMixer.connect(input: newVoice.output)
            newVoice.play()
            voices.append(newVoice)
            print(voices)
            print(AudioKit.engine.description)
        }
        else{
            /*
            let killVoices = allocatedVoices.filter {$0.note == note}
            for killVoice in killVoices{
                killVoice.kill()
                //killVoice.output.disconnectOutput(from: oscillatorMixer)
                oscillatorMixer.disconnectOutput(from: killVoice.output)
                //oscillatorMixer.dis//(input: killVoice.output)
            }
            allocatedVoices = allocatedVoices.filter {$0.note != note}
            */
            
            let killVoices = voices.filter {$0.note == note}
            for killVoice in killVoices{
                killVoice.kill()
            }
            voices = voices.filter {$0.note != note}
            print(voices)
            
        }
        
        //oscillatorBank.play(noteNumber: note, velocity: velocity)
    }
    
    func handlePitchBend(pitchWheelValue: MIDIWord, channel: MIDIChannel){
        print("handlePitch")
        
        for voice in voices{
            if(voice.channel.hex == channel.hex){
                print("same channel")
                voice.pitchBend = pitchWheelValue
            }
        }
        
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
        index = control1.realModValue * control1.range
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
