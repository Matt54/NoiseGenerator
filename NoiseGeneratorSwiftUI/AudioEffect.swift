import AudioKit
import Combine
import SwiftUI

public class AudioEffect: Identifiable, ObservableObject{
    
    // We should never see a heart
    @Published var displayOnImage = Image(systemName: "heart.circle")
    @Published var displayOffImage = Image(systemName: "heart.circle.fill")
    
    public var name = ""
    public var id: UUID = UUID()
    var effect: AKInput
    
    @Published var isBypassed = false{
        didSet{
            setBypass()
        }
    }

    // Position in the audio effect chain
    @Published var position: Int
    
    // Is the effect currently shown on GUI
    @Published var isDisplayed = false
    
    init(pos: Int, toggle: AKToggleable, node: AKInput ){
        position = pos
        toggleControls = toggle
        effect = node
    }

    var toggleControls: AKToggleable
    
    func toggleDisplayed(){
        isDisplayed.toggle()
    }
    
    func setBypass(){
        if(isBypassed){
            toggleControls.stop()
        }
        else{
            toggleControls.start()
        }
    }
    
}

public class TwoControlAudioEffect: AudioEffect{
    override init(pos: Int, toggle: AKToggleable, node: AKInput){
        super.init(pos: pos, toggle: toggle, node: node)
    }
    @Published var control1 = KnobCompleteModel(){
        didSet{ setControl1() }
    }
    @Published var control2 = KnobCompleteModel(){
        didSet{ setControl2() }
    }
    func setControl1(){}
    func setControl2(){}
}

public class OneControlWithPresetsAudioEffect: AudioEffect{
    override init(pos: Int, toggle: AKToggleable, node: AKInput){
        super.init(pos: pos, toggle: toggle, node: node)
    }
    @Published var control1 = KnobCompleteModel(){
        didSet{ setControl1() }
    }
    @Published var presets: [String] = []
    @Published var presetIndex = 0{
        didSet{setPreset()}
    }
    func setControl1(){}
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
        
        filter.rampDuration = 0.0
        control1.name = "Cutoff"
        control1.range = 19980
        control1.unit = " Hz"
        control2.name = "Resonance"
    }
    override func setControl1(){
        filter.cutoffFrequency = 8 + pow(control1.realModValue, 5) * control1.range
        control1.display = String(format: "%.1f", 8 + pow(control1.percentRotated, 5) * control1.range) + control1.unit
    }
    override func setControl2(){
        filter.resonance = control2.realModValue * control2.range
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
        
        control1.name = "Depth"
        
        control2.name = "Frequency"
        control2.range = 20
        control2.unit = " Hz"
        control2.percentRotated = 0.4
    }
    override func setControl1(){
        tremolo.depth = control1.realModValue * control1.range
        control1.display = String(format: "%.1f", control1.percentRotated * control1.range) + control1.unit
    }
    override func setControl2(){
        tremolo.frequency = control2.realModValue * control2.range
        control2.display = String(format: "%.1f", control2.percentRotated * control2.range) + control2.unit
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
        
        presets = ["Cathedral", "Large Hall", "Large Hall 2",
        "Large Room", "Large Room 2", "Medium Chamber",
        "Medium Hall", "Medium Hall 2", "Medium Hall 3",
        "Medium Room", "Plate", "Small Room"]
        
        control1.name = "Dry/Wet"
        control1.unit = "%"

    }
    override func setControl1(){
        reverb.dryWetMix = control1.realModValue * control1.range
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
