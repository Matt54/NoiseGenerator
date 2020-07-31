import AudioKit
import AudioKitUI
import Combine
import SwiftUI
import Foundation

final class Conductor : ObservableObject{
    
    // Single shared data model
    static let shared = Conductor()
    
    //Adjusts application padding around UI and size of keyboard (increases on ipad)
    var deviceLayout = DeviceLayout()
    
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
    
    @Published var tempo = Global.masterTempo//Tempo(bpm: 120)
    
    var volumeUpdateTimer : Double = 0.06
    
    //var frequencyUpdateTimer : Double = 0.001
    
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
    
    @Published var adsrPolyphonicControllers = [adsrPolyphonicController]()
    
    @Published var basicSourceControllers = [adsrPolyphonicController]()
    
    @Published var customOscillatorControlSources = [OscillatorBank]()
    @Published var FMOscillatorControlSources = [MorphingFMOscillatorBank]()
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
    
    
    // Updates display for modulation apply, delete, and midi learn
    @Published var specialSelection : SpecialSelection = .none
    
    //For MIDI learn
    var selectedKnob : KnobCompleteModel?
    
    // This controls the color of the modulation part of the knobs
    @Published var knobModColor = Color.init(red: 0.9, green: 0.9, blue: 0.9)
    
    @Published var keyboardViewController = KeyBoardViewController()
    @Published var firstOctave: Int = 2{
        didSet{
            keyboardViewController.keyboardView.firstOctave = firstOctave
        }
    }
    
    @Published var octaveCount: Int = 3{
        didSet{
            keyboardViewController.setKeyboardOctave(octaveCount)
        }
    }
    
    var isModulationTriggered: Bool = false{
        didSet{
            setModulationTriggers()
        }
    }
    
    var limiter = AKPeakLimiter()
    
    //var midiSignalReceived = false
    //var midiTypeReceived: MidiEventType = .noteNumber
    
    let midi = AKMIDI()
    var numberOfNotesOn: Int = 0
    
    // Maps midi cc to control
    var midiLearnMappings : [MIDILearnMapping] = []
    var isMIDISustained : Bool = false
    var midiSustainedNotes: [ActiveMIDINotes] = []

    var isMicrophoneDisplayed : Bool = false
    
    init(){
        
        outputAmplitudeTimer = RepeatingTimer(timeInterval: screenUpdateTimeDuration)
        
        keyboardViewController.keyboardView.delegate = self
        keyboardViewController.keyboardView.isExclusiveTouch = false

        masterVolumeControl.percentRotated = 0.7
        
        //create a filter to play with
        createNewEffect(pos: allControlEffects.count, effectNumber: 1)
        
        AKSettings.bufferLength = .short//.medium
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
        //createNewSource(sourceNumber: 2)
        //createNewSource(sourceNumber: 8)
        createNewSource(sourceNumber: 9)
        
        connectSourceToEffectChain()
        
        setupOutputChain()
        
        outputAmplitudeTracker.setOutput(to: limiter)
        
        AudioKit.output = limiter

        //START AUDIOKIT
        do{
            try AudioKit.start()
        }
        catch{
            assert(false, error.localizedDescription)
        }
        
        AKAudioFile.cleanTempDirectory()
        
        //START AUDIOBUS
        Audiobus.start()

        createNewModulation()
        
        setupMidi()
        
        //Calculate the padding and size of the keyboard based on the aspect ratio
        deviceLayout.calculateLayoutPadding()
        
        parseWave()
    }
    
    func getAllPListFrom(_ subdir:String)->[URL]? {
        guard let fURL = Bundle.main.urls(forResourcesWithExtension: "plist", subdirectory: subdir) else { return nil }
        return fURL
    }
    
    func parseWave(){
        
        var wavetablePath = ""
        var wavetableName = ""
        
        
        let directoryPath = Bundle.main.resourcePath! + "/Wavetables"
        let fileManager = FileManager.default

        do {
            let directoryArray = try fileManager.contentsOfDirectory(atPath: directoryPath)
            for file in directoryArray{
                print(file)
            }
            let wavetableDirectory = directoryArray.randomElement()!
            let wavetableDirectoryPath = Bundle.main.resourcePath! + "/Wavetables/" + wavetableDirectory
            let wavetableArray = try fileManager.contentsOfDirectory(atPath: wavetableDirectoryPath)
            for file in wavetableArray{
                print(file)
            }
            
            // grab the name of the file without the extension to display
            let wavetableFileName = wavetableArray.randomElement()!
            let split = wavetableFileName.components(separatedBy: ".")
            wavetableName = split[0]
            
            wavetablePath = "Wavetables/" + wavetableDirectory + "/" + wavetableFileName
        } catch {
            print(error)
        }
        
        /*
        if let files = try? FileManager.default.contentsOfDirectory(atPath: Bundle.main.bundlePath ){
            for file in files {
                print(file)
            }
        }
        */
        
        print("chosen wavetable: " + wavetableName)
        
        do {
            // Let's create an AKaudioFile :
            let akAudioFile = try AKAudioFile(readFileName: wavetablePath)
            print("akAudioFile.sampleRate: \(akAudioFile.sampleRate)")
            print("akAudioFile.duration: \(akAudioFile.duration)")
            print("akAudioFile.length: \(akAudioFile.length)")
            let numberOfCycles = akAudioFile.length / 2048
            print("number of cycles:  \(numberOfCycles)")
            
            var waveforms : [AKTable] = []
            
            let myGroup = DispatchGroup()
            
            
            
            for i in 0 ..< numberOfCycles {
                myGroup.enter()
                let name : String = "exported_" + String(i) + ".wav"
                akAudioFile.exportAsynchronously(name: name,
                                                 baseDir: .temp,
                                                      exportFormat: .wav,
                                                      fromSample: 2048 * i,
                                                      toSample: 2048 * (i+1)) { exportedFile, error in
                    //print("myExportCallBack has been triggered. It means that export ended")
                    if error == nil {
                        //print("Export succeeded")
                        // If it is valid, we can play it :
                        if let successfulFile = exportedFile {
                            //print(successfulFile.fileNamePlusExtension)
                            
                            do{
                                let tempFile = try AKAudioFile(readFileName: name,baseDir: .temp)
                                let tempTable = AKTable(file: tempFile)
                                waveforms.append(tempTable)
                                myGroup.leave()
                            }
                            catch let error as NSError {
                                print("There's an error: \(error)")
                            }
                            
                        }

                    } else {
                        print(akAudioFile.fileNamePlusExtension)
                        print("Export failed: \(error)")
                    }
                }
            }
            
            myGroup.notify(queue: .main) {
                print("Finished all requests.")
                self.customOscillatorControlSources[0].switchWaveForms(newWaveforms: waveforms, name: wavetableName)
                AKAudioFile.cleanTempDirectory()
            }
            
        } catch let error as NSError {
            print("There's an error: \(error)")
        }
        
        /*
        let url = Bundle.main.url(forResource: "Acid", withExtension: "wav")!
        let asset = AVAsset(url: url)
        let formatsKey = "availableMetadataFormats"

        
        asset.loadValuesAsynchronously(forKeys: [formatsKey]) {
            var error: NSError? = nil
            let status = asset.statusOfValue(forKey: formatsKey, error: &error)
            if status == .loaded {
                for format in asset.availableMetadataFormats {
                    let metadata = asset.metadata(forFormat: format)
                    print(format)
                    print(metadata)
                    // process format-specific metadata collection
                }
            }
        }
        */
        /*
        asset.loadValuesAsynchronously(forKeys: [formatsKey]) {
            var error: NSError? = nil
            let status = asset.statusOfValue(forKey: formatsKey, error: &error)
            if status == .loaded {
                for format in asset.availableMetadataFormats {
                    let metadata = asset.metadata(forFormat: format)
                    print("format:\(format)")
                    print("metadata description:\(metadata.description)")
                }
            }
        }
        */
        // Create reference to the file whose metadata we want to retrieve
        //let forestRef = storageRef.child("Acid.wav")
        
        /*
        asset.loadValuesAsynchronously(forKeys: [formatsKey]) {
            for metadata in asset.metadata{
                print("metadata description:\(metadata.description)")
            }
        }
        */

        // Get metadata properties
        /*
        asset.metadata { metadata, error in
          if let error = error {
            // Uh-oh, an error occurred!
          } else {
            // Metadata now contains the metadata for 'images/forest.jpg'
          }
        }
        */
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
    func changeEffectsDisplay(){
        for effect in allControlEffects{
            effect.selectedBlockDisplay = .controls
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
        
        // Route each audio effect to the next in line
        for i in 0..<allControlSources.count {
            allControlSources[i].volumeMixer.output.setOutput(to: inputMixer)
        }
        
        fixInternalAudioRouting()
        
    }
    
    /// Connects the audio source to it's Volume Mixer
    func fixInternalAudioRouting(){
        for source in adsrPolyphonicControllers{
            source.setupInputRouting()
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

    
    /// connects the output mixer to the amplitude tracker and begins tracking amplitude
    func setupOutputChain(){
        outputMixer.volume = masterVolume
        outputAmplitudeTracker = AKAmplitudeTracker(outputMixer)
        outputAmplitudeTracker.mode = .peak
        outputAmplitudeTimer.eventHandler = {self.getOutputAmplitude()}
        outputAmplitudeTimer.resume()
    }
    
    var outputAmplitudeTimer : RepeatingTimer
    
    //This enum determines how fast the screen will refresh
    var screenUpdateSetting = ScreenUpdateSetting.custom
    
    //These are required to limit the screen to a custom refresh rate
    var screenUpdateTimeDuration : Double = 1/60
    var timeOfLastScreenUpdate : Double = 0.0
    
    @objc func getOutputAmplitude(){
        DispatchQueue.main.async {
            
            //Read amplitude coming out of the master
            self.outputAmplitudeLeft = self.outputAmplitudeTracker.leftAmplitude
            self.outputAmplitudeRight = self.outputAmplitudeTracker.rightAmplitude
            
            //Read amplitude of any audio source that is displayed
            for i in 0..<self.allControlSources.count {
                if(self.allControlSources[i].isDisplayed){
                    self.allControlSources[i].readAmplitudes()
                    //print(self.allControlSources[i].volumeMixer.amplitude)
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
    
    /// Does all the setup required to create the specific audio source based on the number provided
    public func createNewSource(sourceNumber: Int){
        hideSources()
        let audioSource = getSourceType(sourceNumber: sourceNumber)
        addSourceToControlArray(source: audioSource)
        allControlSources.append(audioSource)
        connectSourceToEffectChain()
        audioSource.handoffDelegate = self
    }
    
    /// Returns the specific audio source based on the number provided
    func getSourceType(sourceNumber: Int) -> AudioSource{
        switch sourceNumber{
        case 1:
            return NoiseSource()
        case 2:
            return MorphingOscillatorBank()
        case 3:
            return RhodesPianoBank()
        case 4:
            return FluteBank()
        case 5:
            return StringBank()
        case 6:
            return ClarinetBank()
        case 7:
            return BellBank()
        case 8:
            return MorphingFMOscillatorBank()
        case 9:
            return OscillatorBank()
        default:
            print("I have an unexpected case.")
            return NoiseSource()
        }
    }
    
    /// Adds the audio source to a control array
    func addSourceToControlArray(source: AudioSource){
        if let mySource = source as? NoiseSource {
            noiseControlSources.append(mySource)
        }
        else if let mySource = source as? MorphingOscillatorBank {
            oscillatorControlSources.append(mySource)
            adsrPolyphonicControllers.append(mySource)
        }
        else if let mySource = source as? MorphingFMOscillatorBank {
            FMOscillatorControlSources.append(mySource)
            adsrPolyphonicControllers.append(mySource)
        }
        else if let mySource = source as? OscillatorBank {
            customOscillatorControlSources.append(mySource)
            adsrPolyphonicControllers.append(mySource)
        }
        else if let mySource = source as? MicrophoneSource {
            microphoneSources.append(mySource)
        }
        else if let mySource = source as? adsrPolyphonicController {
            adsrPolyphonicControllers.append(mySource)
            basicSourceControllers.append(mySource)
        }
    }
    
    func createMicrophoneInput(id: Int){
        
        if(microphoneSources.count == 0){
            for availableInput in availableInputSources{
                if(availableInput.id == id){
                    
                    for source in allControlSources{
                        source.isDisplayed = true
                    }
                    
                    let mic = MicrophoneSource(device: availableInput.device)
                    mic.isHiddenSource = true

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
                microphoneSources[0].isHiddenSource = false
                microphoneSources[0].setBypass()
            }
        }
    }
    
    /// Does all the setup required to create the specific audio effect based on the number provided
    public func createNewEffect(pos: Int, effectNumber: Int){
        hideEffects()
        let audioEffect = getEffectType(pos: pos, effectNumber: effectNumber)
        addEffectToControlArray(effect: audioEffect)
        allControlEffects.append(audioEffect)
        setupEffectAudioChain()
        audioEffect.handoffDelegate = self
    }
    
    /// Returns the specific audio effect based on the number provided
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
        case 8:
            return AutoWahAudioEffect(pos: pos)
        case 9:
            return HighPassFilterAudioEffect(pos: pos)
        case 10:
            return LowPassFilterAudioEffect(pos: pos)
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
    
    
    // All Effects that can be added
    @Published var listedEffects = [
        ListedDevice(id: 1,
                     display: "Moog Filter",
                     symbol: Image(systemName: "f.circle.fill"),
                     description: "Digital Implementation of the Moog Ladder Filter",
                     parameters: ["Cutoff", "Resonance"]
        ),
        ListedDevice(id: 2,
                     display: "Tremelo",
                     symbol: Image(systemName: "t.circle.fill"),
                     description: "A Variation in Amplitude",
                     parameters: ["Depth", "Frequency"]
        ),
        ListedDevice(id: 3,
                     display: "Reverb",
                     symbol: Image(systemName: "r.circle.fill"),
                     description: "Apple's Reverb Audio Unit",
                     parameters: ["Preset", "Dry/Wet"]
        ),
        ListedDevice(id: 4,
                     display: "Delay",
                     symbol: Image(systemName: "d.circle.fill"),
                     description: "Apple's Delay Audio Unit",
                     parameters: ["Time","Feedback","LP Cutoff","Dry/Wet"]
        ),
        ListedDevice(id: 5,
                     display: "Chorus",
                     symbol: Image(systemName: "c.circle.fill"),
                     description: "Delays/Pitch Modulates the Signal",
                     parameters: ["Time","Feedback","LP Cutoff","Dry/Wet"]
        ),
        ListedDevice(id: 6,
                     display: "Bit Crusher",
                     symbol: Image(systemName: "b.circle.fill"),
                     description: "Reduces Resolution/Bandwidth of Signal",
                     parameters: ["Bit Depth","Sample Rate"]
        ),
        ListedDevice(id: 7,
                     display: "Flanger",
                     symbol: Image(systemName: "l.circle.fill"),
                     description: "Swept Comb Filter Effect",
                     parameters: ["Depth","Feedback","Frequency","Dry/Wet"])
        ,
        ListedDevice(id: 8,
                     display: "Auto Wah",
                     symbol: Image(systemName: "w.circle.fill"),
                     description: "An Automatic Wah Effect",
                     parameters: ["Wah","Dry/Wet"])
        ,
        ListedDevice(id: 9,
                     display: "High Pass Filter",
                     symbol: Image(systemName: "f.circle.fill"),
                     description: "A Simple High Pass Filter",
                     parameters: ["Cutoff","Resonance"])
        ,
        ListedDevice(id: 10,
                     display: "Low Pass Filter",
                     symbol: Image(systemName: "f.circle.fill"),
                     description: "A Simple Low Pass Filter",
                     parameters: ["Cutoff","Resonance"])
    ]
    
    // All Categories of Audio Sources
    @Published var listedSourceCategories = [
        ListedCategory(id: 1,
                     display: "Audio Input",
                     symbol: Image(systemName: "mic.circle.fill"),
                     description: "Available Input Audio Sources"
        ),
        ListedCategory(id: 2,
                     display: "Oscillator",
                     symbol: Image(systemName: "waveform.circle.fill"),
                     description: "Oscillator Audio Sources"
        ),
        ListedCategory(id: 3,
                     display: "Physical Model",
                     symbol: Image(systemName: "pesosign.circle.fill"),
                     description: "Physically Modeled Audio Sources"
        ),
    ]
    
    func setSourceCategory(id: Int){
        if(id == 1){
            self.selectedScreen = .addMicrophoneInput
        }
        else if(id == 2){
            self.selectedScreen = .addOscillator
        }
        else if(id == 3){
            self.selectedScreen = .addInstrument
        }
        else{
            
        }
    }
    
    // All Oscillator Sources that can be added
    @Published var listedOscillators = [
        ListedDevice(id: 2,
                     display: "Morphing Oscillator",
                     symbol: Image(systemName: "waveform.circle.fill"),
                     description: "A wavetable oscillator",
                     parameters: ["Amplitude", "Waveform"]
        ),
        ListedDevice(id: 1,
                     display: "Noise Generator",
                     symbol: Image(systemName: "nairasign.circle.fill"),
                     description: "A noise generator",
                     parameters: ["Amplitude", "White Value", "Pink Value", "Brown Value"]
        ),
        ListedDevice(id: 8,
                     display: "FM Oscillator",
                     symbol: Image(systemName: "waveform.circle"),
                     description: "A wavetable oscillator with FM",
                     parameters: ["Amplitude", "Waveform"]
        ),
        ListedDevice(id: 9,
                     display: "Oscillator",
                     symbol: Image(systemName: "waveform.circle"),
                     description: "A wavetable oscillator",
                     parameters: ["Amplitude", "Waveform"]
        )
    ]
    
    // All Physical Sources that can be added
    @Published var listedInstruments = [
        ListedDevice(id: 3,
                     display: "Rhodes Piano",
                     symbol: Image(systemName: "rublesign.circle.fill"),
                     description: "STK Fender Rhodes-like Electric Piano",
                     parameters: ["Amplitude"]
        ),
        ListedDevice(id: 4,
                     display: "Flute",
                     symbol: Image(systemName: "f.circle.fill"),
                     description: "STK Flute",
                     parameters: ["Amplitude"]
        ),
        ListedDevice(id: 5,
                     display: "String",
                     symbol: Image(systemName: "s.circle.fill"),
                     description: "Karplus-Strong plucked string instrument",
                     parameters: ["Amplitude"]
        ),
        ListedDevice(id: 6,
                     display: "Clarinet",
                     symbol: Image(systemName: "c.circle.fill"),
                     description: "STK Clarinet",
                     parameters: ["Amplitude"]
        ),
        ListedDevice(id: 7,
                     display: "Tubular Bell",
                     symbol: Image(systemName: "b.circle.fill"),
                     description: "STK Tubular Bells",
                     parameters: ["Amplitude"]
        )
    ]

}
 
public enum ScreenUpdateSetting{
    case slowest, fastest, custom
    var name: String {
        return "\(self)"
    }
}

public enum SelectedScreen{
    case main, addEffect, addSource, addOscillator, addInstrument, addMicrophoneInput, adjustPattern, bluetoothMIDI, settings
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

public enum SelectedBlockDisplay{
    case controls, volume, adsr, list, pattern
    var name: String {
        return "\(self)"
    }
}
