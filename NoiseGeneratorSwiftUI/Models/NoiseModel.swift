import AudioKit
import AudioKitUI
import Combine
import SwiftUI
import Foundation

final class NoiseModel : ObservableObject, ModulationDelegateUI, AudioEffectKnobHandoff, AKMIDIListener{
    
    // Single shared data model
    static let shared = NoiseModel()
    
    // Enum that changes to a different screen
    @Published var selectedScreen = SelectedScreen.main
    
    // Master Toggle Control
    @Published var masterBypass = false{
        didSet{
            setMasterBypass()
        }
    }
    func setMasterBypass(){
        if(masterBypass){
            outputMixer.stop()
        }
        else{
            outputMixer.start()
        }
    }
    
    // Master Volume Control
    @Published var masterVolume = 1.0{
        didSet { outputMixer.volume = masterVolume }
    }
    @Published var masterVolumeControl = KnobCompleteModel(){
        didSet{ outputMixer.volume = masterVolumeControl.realModValue}
    }
    
    @Published var tempo = Tempo(bpm: 120)
    
    
    // Master Ouput Amplitude Tracker
    var outputAmplitudeTracker = AKAmplitudeTracker()
    @Published var outputAmplitudeLeft: Double = 0.0
    @Published var outputAmplitudeRight: Double = 0.0
    
    // External Sound (Disables Inputted Sound)
    @Published var enabledExternalInput = false {
        didSet { setExternalSource() }
    }
    
    //External Input (Currently Unused)
    let externalInput = AKStereoInput()
    
    // Audio Sources
    @Published var allControlSources = [AudioSource]()
    @Published var oscillatorControlSources = [MorphingOscillatorBank]()
    @Published var noiseControlSources = [NoiseSource]()
    @Published var microphoneSources = [MicrophoneSource]()
    
    @Published var noiseSource = NoiseSource()
    
    var availableInputSources : [AvailableInputSource] = []
    
    // Mixers
    var inputMixer = AKMixer()
    var effectMixer = AKMixer()
    var outputMixer = AKMixer()
    
    // Control Effects (What the user interracts with)
    @Published var allControlEffects = [AudioEffect]()
    @Published var twoControlEffects = [TwoControlAudioEffect]()
    @Published var fourControlEffects = [FourControlAudioEffect]()
    @Published var oneControlWithPresetsEffects = [OneControlWithPresetsAudioEffect]()
    
    // Used for navigation of the UI when adding a new effect
    @Published var addingEffects: Bool = false
    
    // Modulations
    var modulations : [Modulation] = []
    
    @Published var selectedPattern = Pattern(color: Color.init(red: 0.9, green: 0.9, blue: 0.9))

    // ON - modulation range and color is shown on knobs
    @Published var modulationSelected: Bool = true
    
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
    
    
    @Published var firstOctave: Int = 2
    
    
    
    //var bank: AKOscillatorBank!
    
    enum MidiEventType: String {
        case
            noteNumber          = "Note Number",
            continuousControl   = "Continuous Control",
            programChange       = "Program Change"
    }
    let midi = AKMIDI()
    var midiSignalReceived = false
    var midiTypeReceived: MidiEventType = .noteNumber
    
    var numberOfNotesOn: Int = 0
    var isModulationTriggered: Bool = false{
        didSet{
            setModulationTriggers()
        }
    }
    
    init(){
        
        //bank = AKOscillatorBank(waveform: AKTable(.sawtooth))
        //bank.setOutput(to: inputMixer)
        
        masterVolumeControl.percentRotated = 0.7
        
        //create a filter to play with
        createNewEffect(pos: allControlEffects.count, effectNumber: 1)
        
        AKSettings.bufferLength = .medium
        AKSettings.audioInputEnabled = true
        AKSettings.defaultToSpeaker = true
        
        // Allow audio to play while the iOS device is muted.
        AKSettings.playbackWhileMuted = true
        
        do {
            try AKSettings.setSession(category: .playAndRecord, with: [.defaultToSpeaker, .allowBluetooth, .mixWithOthers])
        } catch {
            AKLog("Could not set session category.")
        }
        
        getInputDevicesAvailable()
        
        createMicrophoneInput(id: 1)

        //create a morphing oscillator to play with
        createNewSource(sourceNumber: 2)
        
        connectSourceToEffectChain()
        
        setupOutputChain()
        
        AudioKit.output = outputAmplitudeTracker //mic //outputAmplitudeTracker//outputMixer

        //START AUDIOKIT
        do{
            try AudioKit.start()
        }
        catch{
            assert(false, error.localizedDescription)
        }
        
        //START AUDIOBUS
        Audiobus.start()
        
        
        createNewModulation()
        
        midi.createVirtualInputPort(98909, name: "AKMidiReceiver")
        midi.createVirtualOutputPort(97789, name: "AKMidiReceiver")
        midi.openInput()
        midi.openOutput()
        midi.addListener(self)
        
        //create a noise generator to play with
        //createNewSource(sourceNumber: 1)
    }
    
    func hideSources(){
        for source in allControlSources{
            source.isDisplayed = false
        }
    }
    func hideEffects(){
        for effect in allControlEffects{
            effect.isDisplayed = false
        }
    }
    func hideModulations(){
        for modulation in modulations{
            modulation.isDisplayed = false
        }
    }
    
    func getInputDevicesAvailable(){
        let inputDevicesAvailable = AudioKit.inputDevices ?? []
        
        for input in inputDevicesAvailable{
            //print(input.name) // iPhone Microphone
            print(input.deviceID) //Built-In Microphone Bottom
            print(input.description) //<Device: iPhone Microphone (Built-In Microphone Bottom)>
            let availableInputDevice = AvailableInputSource(device: input)
            availableInputSources.append(availableInputDevice)
        }
    }
    
    func setupSourceAudioChain(){
        
        for i in 0..<allControlSources.count {
            allControlSources[i].output.disconnectOutput()
        }
        
        
        // Route each audio effect to the next in line
        for i in 0..<allControlSources.count {
            allControlSources[i].output.setOutput(to: inputMixer)
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
    
    func connectSourceToEffectChain(){
        
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
        connectSourceToEffectChain()
        
        // Break all current connections
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
        outputMixer.volume = masterVolume
        outputAmplitudeTracker = AKAmplitudeTracker(outputMixer)
        outputAmplitudeTracker.mode = .peak
        outputAmplitudeTimer.eventHandler = {self.getOutputAmplitude()}
        outputAmplitudeTimer.resume()
    }
    
    var outputAmplitudeTimer = RepeatingTimer(timeInterval: 0.03)
    @objc func getOutputAmplitude(){
        DispatchQueue.main.async {
            
            //Read amplitude coming out of the master
            self.outputAmplitudeLeft = self.outputAmplitudeTracker.leftAmplitude
            self.outputAmplitudeRight = self.outputAmplitudeTracker.rightAmplitude
            
            //print(self.outputAmplitude)
            
            //Read amplitude of any audio source that is displayed
            for i in 0..<self.allControlSources.count {
                if(self.allControlSources[i].isDisplayed){
                    self.allControlSources[i].readAmplitudes()
                }
            }
            
            // Read the amplitudes of any audio effects that are displayed
            for i in 0..<self.allControlEffects.count {
                if(self.allControlEffects[i].isDisplayed){
                    self.allControlEffects[i].readAmplitudes()
                }
            }
            
        }
    }
    
    public func createNewSource(sourceNumber: Int){
        let audioSource = getSourceType(sourceNumber: sourceNumber)
        addSourceToControlArray(source: audioSource)
        allControlSources.append(audioSource)
        setupSourceAudioChain()
        audioSource.handoffDelegate = self
        //audioSource.handoffDelegate = self
    }
    
    func getSourceType(sourceNumber: Int) -> AudioSource{
        switch sourceNumber{
        case 1:
            return NoiseSource()
        case 2:
            return MorphingOscillatorBank()
        default:
            print("I have an unexpected case.")
            return NoiseSource()
        }
    }
    
    func addSourceToControlArray(source: AudioSource){
        if let mySource = source as? NoiseSource {
            noiseControlSources.append(mySource)
        }
        if let mySource = source as? MorphingOscillatorBank {
            oscillatorControlSources.append(mySource)
        }
        if let mySource = source as? MicrophoneSource {
            microphoneSources.append(mySource)
        }
    }
    
    func createMicrophoneInput(id: Int){
        
        if(microphoneSources.count == 0){
            for availableInput in availableInputSources{
                if(availableInput.id == id){
                    
                    for source in allControlSources{
                        source.isDisplayed = false
                    }
                    
                    let mic = MicrophoneSource(device: availableInput.device)

                    addSourceToControlArray(source: mic)
                    allControlSources.append(mic)
                    setupSourceAudioChain()
                    print("we added the mic!")
                    microphoneSources[0].isDisplayed = false
                }
            }
        }
        else{
            setMicrophoneDevice(id: id)
        }
    }
    
    func setMicrophoneDevice(id: Int){
        for availableInput in availableInputSources{
            if(availableInput.id == id){
                microphoneSources[0].setDevice(device: availableInput.device)
            }
            
        }
    }
    
    public func createNewEffect(pos: Int, effectNumber: Int){
        hideEffects()
        let audioEffect = getEffectType(pos: pos, effectNumber: effectNumber)
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
        let modulation = Modulation(tempo: tempo)
        modulation.delegate = self
        modulations.append(modulation)
    }
    
    func stopModulations(){
        for modulation in modulations{
            modulation.stop()
        }
    }
    
    func startModulations(){
        for modulation in modulations{
            modulation.start()
        }
    }
    
    func updateModulations(){
        for modulation in modulations{
            modulation.setTimeInterval()
        }
    }
    
    func setModulationTriggers(){
        for modulation in modulations{
            modulation.isTriggered = isModulationTriggered
        }
    }
    
    // Updates UI when modulation timer triggers
    func modulationUpdateUI(_ sender: Modulation) {
        self.objectWillChange.send()
    }
    
    func modulationDisplayChange(_ sender: Modulation) {
        if(sender.isDisplayed){
            knobModColor = sender.modulationColor
            selectedPattern = sender.pattern
        }
        else{
            knobModColor = Color.init(red: 0.9, green: 0.9, blue: 0.9)
            self.modulationBeingAssigned = false
        }
        self.objectWillChange.send()
    }
    
    func KnobModelAssignToModulation(_ sender: KnobCompleteModel) {
        //print("we hit noise")
        for modulation in modulations{
            if(modulation.isDisplayed){
                modulation.addModulationTarget(newTarget: sender)
            }
        }
    }
    
    func KnobModelRemoveModulation(_ sender: KnobCompleteModel) {
        //print("we hit noise")
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
                print("Range Should Adjust by " + String(adjust))
                modulation.adjustModulationRange(target: sender, val: adjust)
            }
        }
    }
    
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

    func handleMidiNote(note: MIDINoteNumber, velocity: MIDIVelocity){
        print("got something!")
        print(note)
        print(velocity)
        //bank.play(noteNumber: note, velocity: velocity)
        
        for oscillator in oscillatorControlSources{
            oscillator.play(note: note, velocity: velocity)
        }
    }
    
    // MARK: MIDI received
    
    @Published var midiExternalNotesOn: [MIDINoteNumber] = []
    //@Published var midiExternalNotesOff: [MIDINoteNumber] = []

    // Note On Number + Velocity + MIDI Channel
    func receivedMIDINoteOn(noteNumber: MIDINoteNumber,
                            velocity: MIDIVelocity,
                            channel: MIDIChannel,
                            portID: MIDIUniqueID? = nil,
                            offset: MIDITimeStamp = 0) {
        midiTypeReceived = .noteNumber
        let outputMIDIMessage = "\(midiTypeReceived.rawValue)\nChannel: \(channel+1)  noteOn: \(noteNumber)  velocity: \(velocity)"
        print(outputMIDIMessage)
        midiSignalReceived = true
        playNote(note: noteNumber, velocity: velocity, channel: channel)
        
        DispatchQueue.main.async {
            self.midiExternalNotesOn.append(noteNumber)
        }
    }

    // Note Off Number + Velocity + MIDI Channel
    func receivedMIDINoteOff(noteNumber: MIDINoteNumber,
                             velocity: MIDIVelocity,
                            channel: MIDIChannel,
                            portID: MIDIUniqueID? = nil,
                            offset: MIDITimeStamp = 0) {
        midiTypeReceived = .noteNumber
        let outputMIDIMessage = "\(midiTypeReceived.rawValue)\nChannel: \(channel+1)  noteOff: \(noteNumber)  velocity: \(velocity)"
        print(outputMIDIMessage)
        midiSignalReceived = false
        stopNote(note: noteNumber, channel: channel)
        DispatchQueue.main.async {
            self.midiExternalNotesOn = self.midiExternalNotesOn.filter{$0 != noteNumber}
        }
        /*
        DispatchQueue.main.async {
            self.midiExternalNotesOff.append(noteNumber)
        }
        */
    }
    
    //midiExternalNotesOn = midiExternalNotesOn.filter{$0 != noteNumber}
    //midiExternalNotesOff = midiExternalNotesOff.filter{$0 != noteNumber}

    // Controller Number + Value + MIDI Channel
    func receivedMIDIController(_ controller: MIDIByte, value: MIDIByte, channel: MIDIChannel) {
        // If the controller value reaches 127 or above, then trigger the `demoSampler` note.
        // If the controller value is less, then stop the note.
        // This creates an on/off type of "momentary" MIDI messaging.
        if value >= 127 {
            playNote(note: 30 + controller, velocity: 80, channel: channel)
        } else {
            stopNote(note: 30 + controller, channel: channel)
        }
        midiTypeReceived = .continuousControl
        let outputMIDIMessage = "\(midiTypeReceived.rawValue)\nChannel: \(channel+1)  controller: \(controller)  value: \(value)"
        print(outputMIDIMessage)
        midiSignalReceived = true
    }

    // Program Change Number + MIDI Channel
    func receivedMIDIProgramChange(_ program: MIDIByte, channel: MIDIChannel) {
        // Trigger the `demoSampler` note and release it after half a second (0.5), since program changes don't have a note off release.
        //triggerSamplerNote(program, channel: channel)
        midiTypeReceived = .programChange
        let outputMIDIMessage = "\(midiTypeReceived.rawValue)\nChannel: \(channel+1)  programChange: \(program)"
        print(outputMIDIMessage)
        midiSignalReceived = true
    }

    func receivedMIDISetupChange() {
        print("midi setup change")
        print("midi.inputNames: \(midi.inputNames)")

        let listInputNames = midi.inputNames

        for inputNames in listInputNames {
            print("inputNames: \(inputNames)")
            midi.openInput(name: inputNames)
        }
    }

    
    func playNote(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        handleMidiNote(note: note, velocity: velocity)
        numberOfNotesOn = numberOfNotesOn + 1
        if(!isModulationTriggered){
            isModulationTriggered = true
        }
    }

    func stopNote(note: MIDINoteNumber, channel: MIDIChannel) {
        handleMidiNote(note: note, velocity: 0)
        numberOfNotesOn = numberOfNotesOn - 1
        if(numberOfNotesOn == 0){
            isModulationTriggered = false
        }
    }
    
    
}

// Keyboard protocol conformance
extension NoiseModel: AKKeyboardDelegate {
    
    func noteOn(note: MIDINoteNumber) {
        playNote(note: note, velocity: 80, channel: MIDIChannel())
      //bank.play(noteNumber: note, velocity: 80)
        //handleMidiNote(note: note, velocity: 80)
    }
      
    func noteOff(note: MIDINoteNumber) {
        stopNote(note: note, channel: MIDIChannel())
      //bank.stop(noteNumber: note)
        //handleMidiNote(note: note, velocity: 0)
    }
    
}

public enum SelectedScreen{
    case main, addEffect, addMicrophoneInput, adjustPattern, bluetoothMIDI
    var name: String {
        return "\(self)"
    }
}
