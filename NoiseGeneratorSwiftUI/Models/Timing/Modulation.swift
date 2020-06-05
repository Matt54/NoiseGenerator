import Foundation
import SwiftUI

public class Modulation : Identifiable, ObservableObject, KnobModelHandoff{

    @Published var selectedBlockDisplay = SelectedBlockDisplay.pattern
    
    //var tempo: Tempo
    
    var delegate:ModulationDelegateUI?
    
    static var numberOfModulations = 0
    public var name: String
    
    public var id: Int
    
    public var modulationColor: Color = Color.init(red: 1.0, green: 1.0, blue: 1.0)
    
    var xValue: CGFloat = 0.0
    
    var modulationValue = 0.0
    
    var numberOfSteps = 100.0
    //var refreshPerSecond = 60
    
    public var timeOfLastTimerAction: Double = 0.0
    
    //Would've rather these be an enum, but I used toggles to adjust them
    var isFreeMode: Bool = true{
        didSet{
            if(isFreeMode){
                isTriggerMode = false
                isEnvelopeMode = false
            }
        }
    }
    var isTriggerMode: Bool = false{
        didSet{
            if(isTriggerMode){
                isFreeMode = false
                isEnvelopeMode = false
            }
        }
    }
    var isEnvelopeMode: Bool = false{
        didSet{
            if(isEnvelopeMode){
                isTriggerMode = false
                isFreeMode = false
            }
        }
    }
    
    
    var isTriggered: Bool = false{
        didSet{
            if(isTriggerMode && !isTriggered){
                reset()
            }
            if(isEnvelopeMode && isTriggered){
                reset()
            }
        }
    }
    
    var isTempoSynced: Bool = false{
        didSet{ setTimeInterval() }
    }
    
    @Published var timeInterval = 0.01{
        didSet {
            print("Hit timeInterval didSet")
            if(!isBypassed){
                var leftoverTime = 0.0
                if(!(timeOfLastTimerAction == 0)){
                    leftoverTime = (Double(DispatchTime.now().uptimeNanoseconds) - timeOfLastTimerAction) / 1_000_000_000
                }
                if(leftoverTime > 0)
                {
                    setTimeInterval(timeInterval: timeInterval, leftoverTime: leftoverTime)
                }
                else{
                    setTimeInterval(timeInterval: timeInterval)
                }
                print("timeInterval didSet: " +  String(timeInterval))
            }
        }
    }
    
    @Published var timingControl : KnobCompleteModel{
        didSet{ setTimeInterval() }
    }
    
    // Is the modulation currently shown on GUI
    @Published var isDisplayed = false{
        didSet{
            if(isDisplayed){
                for target in modulationTargets{
                    target.knobModel.modSelected = true
                    target.updateTargetRange()
                }
            }
            else{
                for target in modulationTargets{
                    target.knobModel.modSelected = false
                    //target.updateTargetRange()
                }
            }
            
            DispatchQueue.main.async {
                self.delegate?.modulationDisplayChange(self)
            }
            
        }
    }
    
    // Is the modulation currently shown on GUI
    @Published var isBypassed = true{
        didSet{setBypass()}
    }
    
    @Published var pattern: Pattern
    
    func toggleDisplayed(){
        isDisplayed = !isDisplayed
    }
    
    var timer = RepeatingTimer(timeInterval: 0.01)
    
    //init(tempo: Tempo){
    init(){
        
        //self.tempo = tempo
        
        Modulation.numberOfModulations = Modulation.numberOfModulations + 1
        id = Modulation.numberOfModulations
        name = "LFO " + String(id)
        
        pattern = Pattern(color: Color.black)
        
        timingControl = KnobCompleteModel()
        timingControl.handoffDelegate = self
        
        modulationColor = self.getColorForModulation(num: id)
        pattern.modulationColor = modulationColor

        timer.eventHandler = {self.timerAction()}
        
        timingControl.name = "Rate"
        timingControl.range = 0.099
        timingControl.unit = " Hz"
        timingControl.percentRotated = 0.0
        
        setTimeInterval()
        
        toggleDisplayed()
        
        setBypass()
    }
    
    
    
    // Modulation Targets (New)
    var modulationTargets : [ModulationTarget] = []
    
    func addModulationTarget(newTarget: KnobCompleteModel){
        let modulationTarget = ModulationTarget(knobModel: newTarget)
        if(modulationTargets.contains(modulationTarget)){
            print("Caught a double add!")
        }
        else{
            modulationTargets.append(modulationTarget)
            print("knob added")
            newTarget.modSelected = true
            print("mod selected")
        }
    }
    
    func removeModulationTarget(removeTarget: KnobCompleteModel){
        for i in 0..<modulationTargets.count {
            if(modulationTargets[i].knobModel === removeTarget){
                modulationTargets.remove(at: i)
                break
            }
        }
    }
    
    func adjustModulationRange(target: KnobCompleteModel, val: Double){
        for i in 0..<modulationTargets.count {
            if(modulationTargets[i].knobModel === target){
                modulationTargets[i].modulationRange = modulationTargets[i].modulationRange + val
                break
            }
        }
    }
    
    func setTimeInterval(){
        
        if(isTempoSynced){
            
            //let bpm = Global.masterTempo.bpm
            
            //Determine the number of tempo selection segments
            let numberOfSegments = Global.masterTempo.regularIntervals.count
            
            //Determine which segment we are rotated into
            let segment = Int(timingControl.percentRotated * Double(numberOfSegments - 1))
            
            //get the time interval while accounting for how many steps we need to take
            timeInterval = Global.masterTempo.getTimeWithSteps(intNumber: segment, numberOfSteps: numberOfSteps)
            
            // display the time interval (may need this adjusted)
            timingControl.display = Global.masterTempo.regularIntervalStrings[segment]
            
            print("bpm: " +  String(Global.masterTempo.bpm))
            print("number of Steps: " +  String(numberOfSteps))
            print("timeInterval: " +  String(timeInterval))
            
        }
        else{
            timeInterval = 0.001 + (1.0 - pow(timingControl.percentRotated, 0.2)) * timingControl.range
            
            timingControl.display = String(format: "%.3f", ((1/(0.001 + (1.0 - pow(timingControl.percentRotated, 0.2)) * timingControl.range)))/numberOfSteps) + timingControl.unit
        }
    }
    
    func setTimeInterval(timeInterval: Double){
        timer = RepeatingTimer(timeInterval: timeInterval)
        timer.eventHandler = {self.timerAction()}
        timer.resume()
        self.delegate?.modulationUpdateUI(self)
    }
    
    func setTimeInterval(timeInterval: Double, leftoverTime: Double){
        timer = RepeatingTimer(timeInterval: timeInterval, leftoverTime: leftoverTime)
        timer.eventHandler = {self.timerAction()}
        timer.resume()
        self.delegate?.modulationUpdateUI(self)
    }
    
    func start(){
        timer.resume()
    }
    
    func stop(){
        timer.suspend()
    }
    
    func reset(){
        xValue = 0.0
    }
    
    func setBypass(){
        if(isBypassed){
            stop()
        }
        else{
            start()
        }
    }

    
    /// Modulation's timer callback - a modulation step.
    @objc func timerAction(){
        
        if( ( (!isTriggerMode && !isEnvelopeMode) || isTriggered) && (modulationTargets.count > 0) ){

            // Calculate next x value
            xValue = xValue + CGFloat(1.0 / numberOfSteps)
            
            // Reset if required
            if(xValue > 1.0){
                if(!isEnvelopeMode){
                    xValue = CGFloat(1.0 / numberOfSteps)
                }
                else{
                    xValue = 1.0
                }
            }
            
            // Calculate next value
            modulationValue = Double(pattern.getValueFromX(xVal: xValue))
            
            //print("There are currently " + String(modulationTargets.count) + " modulationTargets." )
            
            // Relay the value to the targets
            for target in modulationTargets{
                //print("Modulating knob: " + target.knobModel.name + " with value " + String(modulationValue))
                //target.calculateTargetModulation(modulationValue: modulationValue)
                target.calculateTargetModulation(self, modulationValue: modulationValue)
            }
            
            // tell the UI to get new binding values
            DispatchQueue.main.async {
                self.delegate?.modulationUpdateUI(self)
            }
            
        }
        
        timeOfLastTimerAction = Double(DispatchTime.now().uptimeNanoseconds)
    }
    
    
    var handoffDelegate:ParameterHandoff?
    func KnobModelHandoff(_ sender: KnobCompleteModel) {
        print("hit modulation parameter handoff")
        handoffDelegate?.KnobModelHandoff(sender)
    }
    
    func KnobModelRangeHandoff(_ sender: KnobCompleteModel, adjust: Double) {
        handoffDelegate?.KnobModelRangeHandoff(sender, adjust: adjust)
    }
    
    func modulationValueWasChanged(_ sender: KnobCompleteModel) {
        //print("we're trying to modulate a modulation.")
        // DONT FORGET THAT YOU SHOULDN'T ADD THIS WITHOUT SPLITTING DISPLAY FROM ACTUAL TIMEINTERVAL
    }
    
    func handsFreeTextUpdate(_ sender: KnobCompleteModel) {
        print("we're trying to midi cc or macro a modulation.")
        
        //DONT FORGET TO CHANGE THIS IF YOU ALLOW MODS TO CHANGE MODS
        setTimeInterval()
    }
    
    func ToggleModulationAssignment() {
        handoffDelegate?.toggleModulationAssignment()
    }
    
    func ToggleModulationSpecialSelection() {
        //
        handoffDelegate?.toggleModulationSpecialSelection()
    }
    
    func ToggleTempoSync(_ sender: KnobCompleteModel) {
        // We should change the rate between frequency and timing for the modulation
        isTempoSynced = !isTempoSynced
    }
    
    /// Returns a color for the modulation based on how many modulations are currently existing.
    func getColorForModulation(num: Int) -> Color{
        switch num{
        case 1:
            return Color.init(red: 0, green: 1.0, blue: 0) //green
        case 2:
            return Color.init(red: 0.7, green: 0.0, blue: 1.0) // electric purple
        case 3:
            return Color.init(red: 1.0, green: 0.14, blue: 0) // scarlet
        case 4:
            return Color.init(red: 1.0, green: 0.65, blue: 0.0) // orange
        case 5:
            return Color.init(red: 0.46, green: 0.85, blue: 1.0) // royal blue
        default:
            return Color.init(red: 1.0, green: 1.0, blue: 1.0) //white
        }
    }
}

protocol ModulationDelegateUI {
    func modulationUpdateUI(_ sender: Modulation)
    func modulationDisplayChange(_ sender: Modulation)
}

class ModulationTarget : Equatable {
    
    static func == (lhs: ModulationTarget, rhs: ModulationTarget) -> Bool {
        lhs.knobModel === rhs.knobModel
    }
    
     var knobModel: KnobCompleteModel
    
    // Always between -1.0 and 1.0
    var modulationRange: Double = 0.0 {
    didSet {
        limitRange()
        }
    }

    init(knobModel: KnobCompleteModel) { // Constructor
        self.knobModel = knobModel
    }
    
    func limitRange(){
        if(modulationRange > 1.0){
            modulationRange = 1.0
        }
        else if(modulationRange < -1.0){
            modulationRange = -1.0
        }
        knobModel.attemptedModulationRange = modulationRange
    }
    
    public func calculateTargetModulation(_ modulation : Modulation, modulationValue: Double){
        //knobModel.modulationValue = modulationValue * modulationRange
        let newValueAdjust = modulationValue * modulationRange
        knobModel.sumModulations(modulation, newValueAdjust: newValueAdjust)
    }
    
    func updateTargetRange(){
        limitRange()
    }
    
}
