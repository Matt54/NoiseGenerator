import AudioKit
import Combine
import SwiftUI

public class AudioEffect: Identifiable, ObservableObject, KnobModelHandoff{
    
    @Published var selectedBlockDisplay = SelectedBlockDisplay.controls
    
    // We should never see a heart
    @Published var displayImage = Image(systemName: "heart.circle")
    @Published var displayOnImage = Image(systemName: "heart.circle")
    @Published var displayOffImage = Image(systemName: "heart.circle.fill")
    
    static var numberOfEffects = 0
    
    public var name = ""
    public var id: Int//UUID = UUID()
    var effect: AKInput
    
    @Published var inputVolumeMixer = VolumeMixer(isRightHanded: false)
    @Published var outputVolumeMixer = VolumeMixer()
    
    @Published var dummyMixer = AKMixer()
    
    @Published var isBypassed = false{
        didSet{
            setBypass()
        }
    }
    
    var toggleControls: AKToggleable

    // Position in the audio effect chain
    @Published var position: Int
    
    // Is the effect currently shown on GUI
    @Published var isDisplayed = true/*{
        didSet{
            setDisplayImage()
        }
    }*/
    
    init(){
        self.toggleControls = AKMixer()
        id = -1
        position = -1
        effect = AKMixer()
    }
    
    init(pos: Int, toggle: AKToggleable, node: AKInput ){
        position = pos
        toggleControls = toggle
        effect = node
        AudioEffect.numberOfEffects = AudioEffect.numberOfEffects + 1
        id = AudioEffect.numberOfEffects
        setupAudioRouting()
    }

    func setupAudioRouting(){
        inputVolumeMixer.output.setOutput(to: effect)
        inputVolumeMixer.name = "IN"
        //effect.setOutput(to: outputVolumeMixer.output)
        
        effect.connect(to: dummyMixer)
        dummyMixer.connect(to: outputVolumeMixer.input)
        
        dummyMixer.volume = 1.0
        
        //effect.connect(to: outputVolumeMixer.output)
        //outputVolumeMixer.output.co//connect(to: effect)
    }
    
    func readAmplitudes(){
        inputVolumeMixer.updateAmplitude()
        outputVolumeMixer.updateAmplitude()
    }
    
    func toggleDisplayed(){
        isDisplayed.toggle()
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
    
    func setBypass(){
        if(isBypassed){
            toggleControls.stop()
        }
        else{
            toggleControls.start()
        }
        setDisplayImage()
    }

    // Called when any KnobCompleteModel notices a change
    func modulationValueWasChanged(_ sender: KnobCompleteModel) {}
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
    
    func ToggleModulationSpecialSelection() {
        handoffDelegate?.toggleModulationSpecialSelection()
    }
    
    func ToggleTempoSync(_ sender: KnobCompleteModel) {
        // this will be override by any tempo synced controls
    }
    
}

public class TwoControlAudioEffect: AudioEffect{
    
    override init(){
        super.init()
    }
    
    override init(pos: Int, toggle: AKToggleable, node: AKInput){
        super.init(pos: pos, toggle: toggle, node: node)
        control1.handoffDelegate = self
        control2.handoffDelegate = self
    }
    @Published var control1 = KnobCompleteModel(){
        didSet{ setControl1() }
    }
    @Published var control2 = KnobCompleteModel(){
        didSet{ setControl2() }
    }
    
    /// Determines which KnobCompleteModel sent the change and forwards the update to the appropriate parameter
    override func modulationValueWasChanged(_ sender: KnobCompleteModel) {
        if(sender === control1){
            setEffect1()
        }
        else if(sender === control2){
            setEffect2()
        }
    }
    
    override func handsFreeTextUpdate(_ sender: KnobCompleteModel) {
        if(sender === control1){
            setDisplay1()
        }
        else if(sender === control2){
            setDisplay2()
        }
    }
    
    func setControl1(){}
    func setControl2(){}
    func setDisplay1(){}
    func setDisplay2(){}
    func setEffect1(){}
    func setEffect2(){}
}

public class FourControlAudioEffect: AudioEffect{
    override init(){
        super.init()
    }
    override init(pos: Int, toggle: AKToggleable, node: AKInput){
        super.init(pos: pos, toggle: toggle, node: node)
        control1.handoffDelegate = self
        control2.handoffDelegate = self
        control3.handoffDelegate = self
        control4.handoffDelegate = self
    }
    @Published var control1 = KnobCompleteModel(){
        didSet{ setControl1() }
    }
    @Published var control2 = KnobCompleteModel(){
        didSet{ setControl2() }
    }
    @Published var control3 = KnobCompleteModel(){
        didSet{ setControl3() }
    }
    @Published var control4 = KnobCompleteModel(){
        didSet{ setControl4() }
    }
    
    /// Determines which KnobCompleteModel sent the change and forwards the update to the appropriate parameter
    override func modulationValueWasChanged(_ sender: KnobCompleteModel) {
        if(sender === control1){
            setEffect1()
        }
        else if(sender === control2){
            setEffect2()
        }
        else if(sender === control3){
            setEffect3()
        }
        else if(sender === control4){
            setEffect4()
        }
    }
    
    override func handsFreeTextUpdate(_ sender: KnobCompleteModel) {
        if(sender === control1){
            setDisplay1()
        }
        else if(sender === control2){
            setDisplay2()
        }
        else if(sender === control3){
            setDisplay3()
        }
        else if(sender === control4){
            setDisplay4()
        }
    }
    
    func setControl1(){}
    func setControl2(){}
    func setControl3(){}
    func setControl4(){}
    
    func setDisplay1(){}
    func setDisplay2(){}
    func setDisplay3(){}
    func setDisplay4(){}
    
    func setEffect1(){}
    func setEffect2(){}
    func setEffect3(){}
    func setEffect4(){}
    
}

public class OneControlWithPresetsAudioEffect: AudioEffect{
    override init(){
        super.init()
    }
    override init(pos: Int, toggle: AKToggleable, node: AKInput){
        super.init(pos: pos, toggle: toggle, node: node)
        control1.handoffDelegate = self
    }
    @Published var control1 = KnobCompleteModel(){
        didSet{ setControl1() }
    }
    @Published var presets: [String] = []
    @Published var presetIndex = 0{
        didSet{setPreset()}
    }
    func setControl1(){}
    func setDisplay1(){}
    func setEffect1(){}
    func setPreset(){}
}

public class MoogLadderAudioEffect: TwoControlAudioEffect{
    var filter = AKMoogLadder()
    init(pos: Int){
        super.init(pos: pos, toggle: filter, node: filter)
        setDefaults()
        setControl1()
        setControl2()
    }
    func setDefaults(){
        name = "Moog Ladder Filter"
        displayOnImage = Image(systemName: "f.circle.fill")
        displayOffImage = Image(systemName: "f.circle")
        setDisplayImage()
        
        filter.rampDuration = 0.02
        control1.name = "Cutoff"
        control1.range = 20992
        control1.unit = " Hz"
        control1.percentRotated = 1.0
        
        control2.name = "Resonance"
    }
    
    override func setControl1(){
        setEffect1()
        setDisplay1()
    }
    override func setEffect1(){
         filter.cutoffFrequency = 8 + pow(control1.realModValue, 3) * control1.range
    }
    override func setDisplay1(){
         let displayValue = 8 + pow(control1.percentRotated, 3) * control1.range
         
         if(displayValue > 1000){
             control1.unit = " kHz"
             control1.display = String(format: "%.2f", (8 + pow(control1.percentRotated, 3) * control1.range) / 1000) + control1.unit
         }
         else{
             control1.unit = " Hz"
             control1.display = String(format: "%.0f", 8 + pow(control1.percentRotated, 3) * control1.range) + control1.unit
         }
    }
    
    override func setControl2(){
        setEffect2()
        setDisplay2()
    }
    override func setEffect2(){
         filter.resonance = control2.realModValue * control2.range
    }
    override func setDisplay2(){
         control2.display = String(format: "%.1f", control2.percentRotated * control2.range) + control2.unit
    }
}

public class TremoloAudioEffect: TwoControlAudioEffect{
    var tremolo = AKTremolo()
    init(pos: Int){
        super.init(pos: pos, toggle: tremolo, node: tremolo)
        setDefaults()
        setControl1()
        setControl2()
    }
    func setDefaults(){
        name = "Tremolo"
        displayOnImage = Image(systemName: "t.circle.fill")
        displayOffImage = Image(systemName: "t.circle")
        setDisplayImage()
        
        control1.name = "Depth"
        
        control2.name = "Frequency"
        control2.range = 20
        control2.unit = " Hz"
        control2.percentRotated = 0.4
    }
    override func setControl1(){
        setEffect1()
        setDisplay1()
    }
    override func setControl2(){
        setEffect2()
        setDisplay2()
    }
    
    override func setEffect1(){
         tremolo.depth = control1.realModValue * control1.range
    }
    override func setDisplay1(){
         control1.display = String(format: "%.1f", control1.percentRotated * control1.range) + control1.unit
    }
    
    override func setEffect2(){
         tremolo.frequency = control2.realModValue * control2.range
    }
    override func setDisplay2(){
         control2.display = String(format: "%.1f", control2.percentRotated * control2.range) + control2.unit
    }
}

public class AutoWahAudioEffect: TwoControlAudioEffect{
    var wah = AKAutoWah()
    init(pos: Int){
        super.init(pos: pos, toggle: wah, node: wah)
        setDefaults()
        setControl1()
        setControl2()
    }
    func setDefaults(){
        name = "Auto Wah"
        displayOnImage = Image(systemName: "w.circle.fill")
        displayOffImage = Image(systemName: "w.circle")
        setDisplayImage()
        
        control1.name = "Wah"
        control1.unit = " %"
        
        control2.name = "Dry/Wet"
        control2.unit = " %"
        control2.percentRotated = 1.0
        
        wah.amplitude = 0.5
    }
    override func setControl1(){
        setEffect1()
        setDisplay1()
    }
    override func setControl2(){
        setEffect2()
        setDisplay2()
    }
    
    override func setEffect1(){
         wah.wah = control1.realModValue * control1.range
    }
    override func setDisplay1(){
         control1.display = String(format: "%.0f", control1.percentRotated * control1.range * 100) + control1.unit
    }
    
    override func setEffect2(){
         wah.mix = control2.realModValue * control2.range
    }
    override func setDisplay2(){
         control2.display = String(format: "%.0f", control2.percentRotated * control2.range * 100) + control2.unit
    }
}

public class BitCrusherAudioEffect: TwoControlAudioEffect{
    var bitCrusher = AKBitCrusher()
    init(pos: Int){
        super.init(pos: pos, toggle: bitCrusher, node: bitCrusher)
        setDefaults()
        setControl1()
        setControl2()
    }
    func setDefaults(){
        name = "Bit Crush"
        displayOnImage = Image(systemName: "b.circle.fill")
        displayOffImage = Image(systemName: "b.circle")
        setDisplayImage()
        
        bitCrusher.rampDuration = 0.01
        
        control1.name = "Bit Depth"
        control1.range = 23
        control1.unit = " bits"
        control1.percentRotated = 1.0
        
        control2.name = "Sample Rate"
        control2.range = 19992
        control2.unit = " Hz"
        control2.percentRotated = 1.0
    }
    
    override func setControl1(){
        setEffect1()
        setDisplay1()
    }
    override func setEffect1(){
         bitCrusher.bitDepth = 1 + control1.realModValue * control1.range
    }
    override func setDisplay1(){
         control1.display = String(format: "%.1f", 1 + control1.percentRotated * control1.range) + control1.unit
    }
    
    override func setControl2(){
        setEffect2()
        setDisplay2()
    }
    override func setEffect2(){
         bitCrusher.sampleRate = 8 + pow(control2.realModValue, 5) * control2.range
    }
    override func setDisplay2(){
         let displayValue = 8 + pow(control2.percentRotated, 5) * control2.range
         
         if(displayValue > 1000){
             control2.unit = " kHz"
             control2.display = String(format: "%.1f", (8 + pow(control2.percentRotated, 5) * control2.range) / 1000) + control2.unit
         }
         else{
             control2.unit = " Hz"
             control2.display = String(format: "%.1f", 8 + pow(control2.percentRotated, 5) * control2.range) + control2.unit
         }
    }
}

public class ChorusAudioEffect: FourControlAudioEffect{
    var chorus = AKChorus()
    init(pos: Int){
        super.init(pos: pos, toggle: chorus, node: chorus)
        setDefaults()
        setControl1()
        setControl2()
        setControl3()
        setControl4()
    }
    func setDefaults(){
        name = "Chorus"
        displayOnImage = Image(systemName: "c.circle.fill")
        displayOffImage = Image(systemName: "c.circle")
        setDisplayImage()
        
        control1.name = "Depth" //in seconds
        control1.unit = "%"
        control1.range = 1
        control1.percentRotated = 0.5
        
        control2.name = "Feedback" //0-1
        //control2.range = 20
        control2.unit = "%"
        
        control3.name = "Frequency"
        control3.range = 10
        control3.unit = " Hz"
        control3.percentRotated = 0.1
        
        control4.name = "Dry/Wet"
        control4.unit = "%"
    }
    override func setControl1(){
        setEffect1()
        setDisplay1()
    }
    override func setControl2(){
        setEffect2()
        setDisplay2()
    }
    override func setControl3(){
        setEffect3()
        setDisplay3()
    }
    override func setControl4(){
        setEffect4()
        setDisplay4()
    }
    
    override func setEffect1(){
         chorus.depth = control1.realModValue * control1.range
    }
    override func setDisplay1(){
         control1.display = String(format: "%.0f", control1.percentRotated * control1.range * 100) + control1.unit
    }
    
    override func setEffect2(){
         chorus.feedback = control2.realModValue * control2.range
    }
    override func setDisplay2(){
         control2.display = String(format: "%.0f", control2.percentRotated * control2.range * 100) + control2.unit
    }
    
    override func setEffect3(){
         chorus.frequency = 0.03 + pow(control3.realModValue, 5) * control3.range
    }
    override func setDisplay3(){
         control3.display = String(format: "%.2f", 0.03 + pow(control3.percentRotated, 5) * control3.range) + control3.unit
    }
    
    override func setEffect4(){
         chorus.dryWetMix = control4.realModValue * control4.range
    }
    override func setDisplay4(){
         control4.display = String(format: "%.0f", control4.percentRotated * control4.range * 100) + control4.unit
    }
}

public class FlangerAudioEffect: FourControlAudioEffect{
    var flanger = AKFlanger()
    init(pos: Int){
        super.init(pos: pos, toggle: flanger, node: flanger)
        setDefaults()
        setControl1()
        setControl2()
        setControl3()
        setControl4()
    }
    func setDefaults(){
        name = "Flanger"
        displayOnImage = Image(systemName: "l.circle.fill")
        displayOffImage = Image(systemName: "l.circle")
        setDisplayImage()
        
        control1.name = "Depth" //in seconds
        control1.unit = "%"
        control1.range = 1
        control1.percentRotated = 0.5
        
        control2.name = "Feedback" //0-1
        control2.unit = "%"
        
        control3.name = "Frequency"
        control3.range = 10
        control3.unit = " Hz"
        control3.percentRotated = 0.1
        
        control4.name = "Dry/Wet"
        control4.unit = "%"
        control4.percentRotated = 0.5
    }
    
    override func setControl1(){
        setEffect1()
        setDisplay1()
    }
    override func setControl2(){
        setEffect2()
        setDisplay2()
    }
    override func setControl3(){
        setEffect3()
        setDisplay3()
    }
    override func setControl4(){
        setEffect4()
        setDisplay4()
    }
    
    override func setEffect1(){
         flanger.depth = control1.realModValue * control1.range
    }
    override func setDisplay1(){
         control1.display = String(format: "%.0f", control1.percentRotated * control1.range * 100) + control1.unit
    }
    
    override func setEffect2(){
         flanger.feedback = control2.realModValue * control2.range
    }
    override func setDisplay2(){
         control2.display = String(format: "%.0f", control2.percentRotated * control2.range * 100) + control2.unit
    }
    
    override func setEffect3(){
         flanger.frequency = 0.03 + pow(control3.realModValue, 5) * control3.range
    }
    override func setDisplay3(){
         control3.display = String(format: "%.2f", 0.03 + pow(control3.percentRotated, 5) * control3.range) + control3.unit
    }
    
    override func setEffect4(){
         flanger.dryWetMix = control4.realModValue * control4.range
    }
    override func setDisplay4(){
         control4.display = String(format: "%.0f", control4.percentRotated * control4.range * 100) + control4.unit
    }
}

public class AppleDelayAudioEffect: FourControlAudioEffect{
    var delay = AKDelay()
    init(pos: Int){
        super.init(pos: pos, toggle: delay, node: delay)
        setDefaults()
        setControl1()
        setControl2()
        setControl3()
        setControl4()
    }
    func setDefaults(){
        name = "Simple Delay"
        displayOnImage = Image(systemName: "d.circle.fill")
        displayOffImage = Image(systemName: "d.circle")
        setDisplayImage()
        
        control1.name = "Time" //in seconds
        control1.range = 5
        control1.percentRotated = 0.7
        control1.unit = "s"
        
        control2.name = "Feedback" //0-1
        //control2.range = 20
        control2.unit = "%"
        control2.percentRotated = 0.5
        
        control3.name = "LP Cutoff"
        control3.range = 21000
        control3.unit = " Hz"
        control3.percentRotated = 0.8
        
        control4.name = "Dry/Wet"
        control4.unit = "%"
    }
    
    override func setControl1(){
        setEffect1()
        setDisplay1()
    }
    override func setControl2(){
        setEffect2()
        setDisplay2()
    }
    override func setControl3(){
        setEffect3()
        setDisplay3()
    }
    override func setControl4(){
        setEffect4()
        setDisplay4()
    }
    
    override func setEffect1(){
         delay.time = pow(control1.realModValue,5) * control1.range
    }
    override func setDisplay1(){
         control1.display = String(format: "%.3f", pow(control1.percentRotated,5) * control1.range) + control1.unit
    }
    
    override func setEffect2(){
         delay.feedback = control2.realModValue * control2.range
    }
    override func setDisplay2(){
         control2.display = String(format: "%.0f", control2.percentRotated * control2.range * 100) + control2.unit
    }
    
    override func setEffect3(){
         delay.lowPassCutoff = control3.realModValue * control3.range
    }
    override func setDisplay3(){
         let displayValue = control3.realModValue * control3.range
         
         if(displayValue > 1000){
             control3.unit = " kHz"
             control3.display = String(format: "%.1f", (8 + pow(control3.percentRotated, 5) * control3.range) / 1000) + control3.unit
         }
         else{
             control3.unit = " Hz"
             control3.display = String(format: "%.1f", 8 + pow(control3.percentRotated, 5) * control3.range) + control3.unit
         }
    }
    
    override func setEffect4(){
         delay.dryWetMix = control4.realModValue * control4.range
    }
    override func setDisplay4(){
         control4.display = String(format: "%.0f", control4.percentRotated * control4.range * 100) + control4.unit
    }
    
}

public class AppleReverbAudioEffect: OneControlWithPresetsAudioEffect{
    var reverb = AKReverb()
    init(pos: Int){
        super.init(pos: pos, toggle: reverb, node: reverb)
        setDefaults()
        setControl1()
    }
    func setDefaults(){
        name = "Apple Preset Reverb"
        displayOnImage = Image(systemName: "r.circle.fill")
        displayOffImage = Image(systemName: "r.circle")
        setDisplayImage()
        
        presets = ["Cathedral", "Large Hall", "Large Hall 2",
        "Large Room", "Large Room 2", "Medium Chamber",
        "Medium Hall", "Medium Hall 2", "Medium Hall 3",
        "Medium Room", "Plate", "Small Room"]
        
        control1.name = "Dry/Wet"
        control1.unit = "%"

    }
    override func setControl1(){
        setEffect1()
        setDisplay1()
    }
    
    override func setEffect1(){
         reverb.dryWetMix = control1.realModValue * control1.range
    }
    
    override func setDisplay1(){
         control1.display = String(format: "%.0f", control1.percentRotated * control1.range * 100) + control1.unit
    }

    override func setPreset(){
        switch presets[presetIndex]{
        case "Cathedral":
            reverb.loadFactoryPreset(.cathedral)
        case "Large Hall":
            reverb.loadFactoryPreset(.largeHall)
        case "Large Hall 2":
            reverb.loadFactoryPreset(.largeHall2)
        case "Large Room":
            reverb.loadFactoryPreset(.largeRoom)
        case "Large Room 2":
            reverb.loadFactoryPreset(.largeRoom2)
        case "Medium Chamber":
            reverb.loadFactoryPreset(.mediumChamber)
        case "Medium Hall":
            reverb.loadFactoryPreset(.mediumHall)
        case "Medium Hall 2":
            reverb.loadFactoryPreset(.mediumHall2)
        case "Medium Hall 3":
            reverb.loadFactoryPreset(.mediumHall3)
        case "Medium Room":
            reverb.loadFactoryPreset(.mediumRoom)
        case "Plate":
            reverb.loadFactoryPreset(.plate)
        case "Small Room":
            reverb.loadFactoryPreset(.smallRoom)
        default:
            print("Error - reverb not found")
        }
    }
}

public class ListedDevice{
    @Published var id: Int
    @Published var display: String
    @Published var symbol: Image
    @Published var description: String = ""
    @Published var parameters: [String] = []
    init(id: Int, display: String, symbol: Image){
        self.id = id
        self.display = display
        self.symbol = symbol
    }
    init(id: Int, display: String, symbol: Image, description: String, parameters: [String]){
        self.id = id
        self.display = display
        self.symbol = symbol
        self.description = description
        self.parameters = parameters
    }
}

protocol ParameterHandoff{
    func KnobModelHandoff(_ sender: KnobCompleteModel)
    func KnobModelRangeHandoff(_ sender: KnobCompleteModel, adjust: Double)
    func toggleModulationAssignment()
    func toggleModulationSpecialSelection()
}
