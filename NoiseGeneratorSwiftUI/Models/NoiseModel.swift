import AudioKit
import Combine
import SwiftUI
import Foundation

final class NoiseModel : ObservableObject, ModulationDelegateUI, AudioEffectKnobHandoff{
    
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
    
    init(){
        
        masterVolumeControl.percentRotated = 0.7
        
        //create a filter to play with
        createNewEffect(pos: allControlEffects.count, effectNumber: 1)
        
        AKSettings.audioInputEnabled = true
        
        getInputDevicesAvailable()
        
        createMicrophoneInput(id: 1)
        
        //create a noise generator to play with
        createNewSource(sourceNumber: 1)
        
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
        //audioSource.handoffDelegate = self
    }
    
    func getSourceType(sourceNumber: Int) -> AudioSource{
        switch sourceNumber{
        case 1:
            return NoiseSource()
        default:
            print("I have an unexpected case.")
            return NoiseSource()
        }
    }
    
    func addSourceToControlArray(source: AudioSource){
        if let mySource = source as? NoiseSource {
            noiseControlSources.append(mySource)
        }
        if let mySource = source as? MicrophoneSource {
            microphoneSources.append(mySource)
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
        let modulation = Modulation()
        modulation.delegate = self
        modulation.start()
        modulations.append(modulation)
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
        print("we hit noise")
        for modulation in modulations{
            if(modulation.isDisplayed){
                modulation.addModulationTarget(newTarget: sender)
                print("knob added")
            }
        }
    }
    
    func KnobModelRemoveModulation(_ sender: KnobCompleteModel) {
        print("we hit noise")
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
                print("Range Should Adjust")
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

}

public enum SelectedScreen{
    case main, addEffect, addMicrophoneInput, adjustPattern
    var name: String {
        return "\(self)"
    }
}
