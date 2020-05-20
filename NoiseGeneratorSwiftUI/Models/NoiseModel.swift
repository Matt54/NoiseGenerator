import AudioKit
import AudioKitUI
import Combine
import SwiftUI
import Foundation

final class NoiseModel : ObservableObject, ModulationDelegateUI, ParameterHandoff, AKMIDIListener{
    
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
    
    /*
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
    */
    
    // Updates display for modulation apply, delete, and midi learn
    @Published var specialSelection : SpecialSelection = .none
    
    //For MIDI learn
    var selectedKnob : KnobCompleteModel?
    
    // This controls the color of the modulation part of the knobs
    @Published var knobModColor = Color.init(red: 0.9, green: 0.9, blue: 0.9)
    
    @Published var keyboardViewController : KeyBoardViewController
    @Published var firstOctave: Int = 2{
        didSet{
            keyboardViewController.keyboardView.firstOctave = firstOctave
        }
    }
    
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
    
    var midiLearnMappings : [MIDILearnMapping] = []
    var isMIDISustained : Bool = false
    var midiSustainedNotes: [ActiveMIDINotes] = []
    
    public class ActiveMIDINotes{
        var note: MIDINoteNumber
        var channel: MIDIChannel
        init(note: MIDINoteNumber, channel: MIDIChannel){
            self.note = note
            self.channel = channel
        }
    }
    
    var limiter = AKPeakLimiter()
    
    init(){
        
        keyboardViewController = KeyBoardViewController()
        keyboardViewController.keyboardView.delegate = self
        
        masterVolumeControl.percentRotated = 0.7
        
        //create a filter to play with
        createNewEffect(pos: allControlEffects.count, effectNumber: 1)
        
        AKSettings.bufferLength = .medium
        AKSettings.audioInputEnabled = true
        AKSettings.defaultToSpeaker = true
        
        //AKSettings.bufferLength = .longest
        //AKSettings.BufferLength.
        
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
        
        //create a noise oscillator to play with
        //createNewSource(sourceNumber: 1)
        
        connectSourceToEffectChain()
        
        setupOutputChain()
        
        outputAmplitudeTracker.setOutput(to: limiter)
        AudioKit.output = limiter //mic //outputAmplitudeTracker//outputMixer

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
        
        /*
        let voice = Voice(note: MIDINoteNumber(clamping: 80), velocity: 80, channel: 0, waveforms: [AKTable(.sine), AKTable(.triangle),AKTable(.square), AKTable(.sawtooth)])
        voice.oscillator.setOutput(to: outputAmplitudeTracker)
        voice.setADSR(attackDuration: 0.1, decayDuration: 0.1, sustainLevel: 1.0, releaseDuration: 0.1)
        voice.oscillator.index = 1.0
        voice.play()
        */
        
        midi.createVirtualInputPort(98909, name: "AKMidiReceiver")
        midi.createVirtualOutputPort(97789, name: "AKMidiReceiver")
        midi.openInput()
        midi.openOutput()
        midi.addListener(self)
        
        
        
        //connectSourceToEffectChain()
        
        //setupOutputChain()
        
        //create a noise generator to play with
        //createNewSource(sourceNumber: 1)
        
        //connectSourceToEffectChain()
        //setupOutputChain()
        
        //connectSourceToEffectChain()
        //inputMixer.setOutput(to: allControlEffects[0].input)
        //allControlEffects[0].input.connect(input: inputMixer)
        
        //set the output of the last effect to our output mixer
        //allControlEffects[allControlEffects.count - 1].output.setOutput(to: outputMixer)
        
        //inputMixer.disconnectOutput()
        //inputMixer.setOutput(to: allControlEffects[0].input)
        //connectSourceToEffectChain()
        //setupOutputChain()
        
        /*
        let voice = Voice(note: MIDINoteNumber(clamping: 80), velocity: 80, channel: 0, waveforms: [AKTable(.sine), AKTable(.triangle),AKTable(.square), AKTable(.sawtooth)])
        voice.oscillator.setOutput(to: limiter)
        voice.setADSR(attackDuration: 0.1, decayDuration: 0.1, sustainLevel: 1.0, releaseDuration: 0.1)
        voice.oscillator.index = 1.0
        voice.play()
        */
        
        //connectSourceToEffectChain()
        //setupOutputChain()
        
        //create a tremolo to play with
        //createNewEffect(pos: allControlEffects.count, effectNumber: 2)
        
        //connectSourceToEffectChain()
        //oscillatorControlSources[0].output.setOutput(to: limiter)
        
        //oscillatorControlSources[0].setupInputRouting()
        //setupSourceAudioChain()
        //oscillatorControlSources[0].setupAudioRouting()
        //setupSourceAudioChain()
        //oscillatorControlSources[0].play(note: MIDINoteNumber(clamping: 80), velocity: 80, channel: 0)
        
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
        
        inputMixer.disconnectOutput()
        inputMixer.disconnectInput()
        
        /*
        for i in 0..<allControlSources.count {
            allControlSources[i].output.disconnectOutput()
        }
        */
        
        // Route each audio effect to the next in line
        for i in 0..<allControlSources.count {
            allControlSources[i].volumeMixer.output.setOutput(to: inputMixer)
        }
        
        fixInternalAudioRouting()
        
        
    }
    
    func fixInternalAudioRouting(){
        for source in oscillatorControlSources{
            source.setupInputRouting()
            //source.setupAudioRouting()
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
        setupSourceAudioChain()
        
        if(allControlEffects.count > 0){
            inputMixer.setOutput(to: allControlEffects[0].inputVolumeMixer.input)
        }
        else{
            //inputMixer.connect(to: outputMixer)
            inputMixer.setOutput(to: outputMixer)
        }
    }
    
    func setupEffectAudioChain(){
        
        // Break all current connections
        for i in 0..<allControlEffects.count {
            allControlEffects[i].outputVolumeMixer.output.disconnectOutput()
        }
        
        // Route each audio effect to the next in line
        for i in 0..<allControlEffects.count - 1  {
            allControlEffects[i].outputVolumeMixer.output.setOutput(to: allControlEffects[i+1].inputVolumeMixer.input)
        }
        
        //set the output of the last effect to our output mixer
        allControlEffects[allControlEffects.count - 1].outputVolumeMixer.output.setOutput(to: outputMixer)
        
        // Connect input
        connectSourceToEffectChain()
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
                    print(self.allControlSources[i].volumeMixer.amplitude)
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
        //setupSourceAudioChain()
        connectSourceToEffectChain()
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
        
        //setupSourceAudioChain()
        //connectSourceToEffectChain()
        //fixInternalAudioRouting()
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
        modulation.handoffDelegate = self
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
            //self.modulationBeingAssigned = false
            
            if( (self.specialSelection == .assignModulation) || (self.specialSelection == .deleteModulation) ){
                self.specialSelection = .none
            }
        }
        self.objectWillChange.send()
    }
    
    func KnobModelHandoff(_ sender: KnobCompleteModel) {
        if(specialSelection == .assignModulation){
            print("we hit noise modulation assignment")
            for modulation in modulations{
                if(modulation.isDisplayed){
                    modulation.addModulationTarget(newTarget: sender)
                    print("knob assigned in noise")
                }
            }
        }
        else if(specialSelection == .deleteModulation){
            print("we hit noise modulation delete")
            for modulation in modulations{
                if(modulation.isDisplayed){
                    modulation.removeModulationTarget(removeTarget: sender)
                    print("knob removed in noise")
                }
            }
            sender.modSelected = false
            sender.modulationValue = sender.percentRotated
        }
        else if(specialSelection == .midiLearn){
            print("we hit noise midi learn")
            
            if selectedKnob != nil {
                selectedKnob?.isMidiLearning = false
            }
            
            selectedKnob = sender
            selectedKnob?.isMidiLearning = true
        }
    }
    
    func KnobModelRangeHandoff(_ sender: KnobCompleteModel, adjust: Double) {
        if(specialSelection == .assignModulation){
            for modulation in modulations{
                if(modulation.isDisplayed){
                    print("Range Should Adjust by " + String(adjust))
                    modulation.adjustModulationRange(target: sender, val: adjust)
                }
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

    
    
    func handleMidiNote(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel){
        for oscillator in oscillatorControlSources{
            oscillator.play(note: note, velocity: velocity, channel: channel)
            
        }
    }
    
    func handlePitchBend(pitchWheelValue: MIDIWord, channel: MIDIChannel){
        print("handlePitch in Noise")
        for oscillator in oscillatorControlSources{
            print("inside the for loop")
            oscillator.handlePitchBend(pitchWheelValue: pitchWheelValue, channel: channel)
        }
    }
    
    // MARK: MIDI received

    // Note On Number + Velocity + MIDI Channel
    func receivedMIDINoteOn(noteNumber: MIDINoteNumber,
                            velocity: MIDIVelocity,
                            channel: MIDIChannel,
                            portID: MIDIUniqueID? = nil,
                            offset: MIDITimeStamp = 0) {
        print("")
        print("Got Note On!")
        print("Note Number: " + String(noteNumber))
        print("Velocity: " + String(velocity))
        print("channel: " + String(channel))
        
        midiTypeReceived = .noteNumber
        let outputMIDIMessage = "\(midiTypeReceived.rawValue)\nChannel: \(channel+1)  noteOn: \(noteNumber)  velocity: \(velocity)"
        print(outputMIDIMessage)
        midiSignalReceived = true
        playNote(note: noteNumber, velocity: velocity, channel: channel)
        
        DispatchQueue.main.async {
            self.keyboardViewController.keyboardView.programmaticNoteOn(noteNumber)
        }
    }

    // Note Off Number + Velocity + MIDI Channel
    func receivedMIDINoteOff(noteNumber: MIDINoteNumber,
                             velocity: MIDIVelocity,
                             channel: MIDIChannel,
                             portID: MIDIUniqueID? = nil,
                             offset: MIDITimeStamp = 0) {
        print("")
        print("Got Note Off!")
        print("Note Number: " + String(noteNumber))
        print("Velocity: " + String(velocity))
        print("channel: " + String(channel))
        
        midiTypeReceived = .noteNumber
        midiSignalReceived = false
        
        stopNote(note: noteNumber, channel: channel)
        DispatchQueue.main.async {
            self.keyboardViewController.keyboardView.programmaticNoteOff(noteNumber)
        }
    }

    // Controller Number + Value + MIDI Channel
    func receivedMIDIController(_ controller: MIDIByte, value: MIDIByte, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp) {
        
        /*
        if value >= 127 {
            playNote(note: 30 + controller, velocity: 80, channel: channel)
        } else {
            stopNote(note: 30 + controller, channel: channel)
        }
        */
        
        print("")
        print("Got CC!")
        print("Controller: " + String(controller))
        print("Value: " + String(value))
        print("channel: " + String(channel))
        
        midiTypeReceived = .continuousControl
        midiSignalReceived = true
        
        if(specialSelection == .midiLearn){
            
            guard let selectedKnob = selectedKnob else {
              return
            }
            
            var knobPreviouslyMapped = false
            
            // Check if this knob is already assigned to anything
            for midiLearnMapping in midiLearnMappings{
                if(selectedKnob === midiLearnMapping.control){
                    knobPreviouslyMapped = true
                    midiLearnMapping.ccNumber = controller
                    midiLearnMapping.channel = channel
                    break
                }
            }
            
            if(!knobPreviouslyMapped){
                let newMapping = MIDILearnMapping(control: selectedKnob, ccNumber: controller, channel: channel)
                selectedKnob.midiAssignment = String(newMapping.ccNumber)
                midiLearnMappings.append(newMapping)
            }
            
        }
        else{
            
            //catch the defined midi notes
            if(controller == MIDISupportedBytes.damperOnOff.rawValue){
                if(value > 63){
                    isMIDISustained = true
                }
                else{
                    releaseNotes()
                }
            }
            
            // adjust anything assigned to that cc number
            for midiLearnMapping in midiLearnMappings{
                if(midiLearnMapping.ccNumber == controller){
                    midiLearnMapping.control.handfreeKnobRotate(Double(value) * (1.0 / 127.0))
                }
            }
        }
        
        
    }
    
    func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIWord, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp){
         /*
         pitchWheelValue: MIDI Pitch Wheel Value (0-16383) [0 = max down, 8_192 = no bend, 16_383 = max up]
         channel: MIDI Channel (1-16)
         portID: MIDI Unique Port ID
         offset: the offset in samples that this event occurs in the buffer
         */
        
        print("")
        print("Got Pitch Wheel!")
        print("Pitch Wheel Value: " + String(pitchWheelValue))
        print("channel: " + String(channel))
        
        handlePitchBend(pitchWheelValue: pitchWheelValue, channel: channel)
    }
    
    func receivedMIDISystemCommand(_ data: [MIDIByte], portID: MIDIUniqueID?, offset: MIDITimeStamp){
        /*
         Receive a MIDI system command (such as clock, sysex, etc)
         data: Array of integers
         portID: MIDI Unique Port ID
         offset: the offset in samples that this event occurs in the buffer
         */
        
        print("")
        print("Got System Command!")
        for byte in data{
            print("Byte: " + String(byte))
        }
    }

    // Program Change Number + MIDI Channel
    func receivedMIDIProgramChange(_ program: MIDIByte, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp) {
        
        print("")
        print("Got Program Change!")
        print("Program: " + String(program))
        print("channel: " + String(channel))
        
        midiTypeReceived = .programChange
        //let outputMIDIMessage = "\(midiTypeReceived.rawValue)\nChannel: \(channel+1)  programChange: \(program)"
        //print(outputMIDIMessage)
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
        handleMidiNote(note: note, velocity: velocity, channel: channel)
        numberOfNotesOn = numberOfNotesOn + 1
        if(!isModulationTriggered){
            isModulationTriggered = true
        }
        if(isMIDISustained){
            
        }
    }

    func stopNote(note: MIDINoteNumber, channel: MIDIChannel) {
        if(!isMIDISustained){
            handleMidiNote(note: note, velocity: 0, channel: channel)
            numberOfNotesOn = numberOfNotesOn - 1
            if(numberOfNotesOn == 0){
                isModulationTriggered = false
            }
        }
        else{
            midiSustainedNotes.append(ActiveMIDINotes(note: note, channel: channel))
        }
    }
    
    func releaseNotes(){
        isMIDISustained = false
        for midiSustainedNote in midiSustainedNotes{
            stopNote(note: midiSustainedNote.note, channel: midiSustainedNote.channel)
        }
    }
}

public enum MIDISupportedBytes: MIDIByte{
    case modulationWheel = 1
    case damperOnOff = 64
}

public class MIDILearnMapping{
    var control: KnobCompleteModel
    var ccNumber: MIDIByte
    var channel: MIDIChannel
    init(control: KnobCompleteModel, ccNumber: MIDIByte, channel: MIDIChannel){
        self.control = control
        self.ccNumber = ccNumber
        self.channel = channel
    }
}

// Keyboard protocol conformance
extension NoiseModel: AKKeyboardDelegate {
    
    func noteOn(note: MIDINoteNumber) {
        playNote(note: note, velocity: 80, channel: MIDIChannel())
    }
      
    func noteOff(note: MIDINoteNumber) {
        stopNote(note: note, channel: MIDIChannel())
    }
    
}

public enum SelectedScreen{
    case main, addEffect, addMicrophoneInput, adjustPattern, bluetoothMIDI
    var name: String {
        return "\(self)"
    }
}

public enum SpecialSelection{
    case none, assignModulation, deleteModulation, midiLearn
    var name: String {
        return "\(self)"
    }
}
