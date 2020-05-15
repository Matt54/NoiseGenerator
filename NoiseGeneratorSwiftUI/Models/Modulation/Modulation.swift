import Foundation
import SwiftUI

public class Modulation : Identifiable, ObservableObject{
    
    //@EnvironmentObject var noise: NoiseModel
    
    var tempo: Tempo
    
    var delegate:ModulationDelegateUI?
    
    static var numberOfModulations = 0
    public var name: String
    
    public var id: Int
    
    public var modulationColor: Color = Color.init(red: 1.0, green: 1.0, blue: 1.0)
    
    var xValue: CGFloat = 0.0
    
    var modulationValue = 0.0
    
    var numberOfSteps = 200.0
    
    var timeOfLastTimerAction: Double = 0.0
    
    var isTempoSynced: Bool = false{
        didSet{ setTimeInterval() }
    }
    
    @Published var timeInterval = 0.01{
    didSet {
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
        }
    }
    
    @Published var timingControl = KnobCompleteModel(){
        didSet{ setTimeInterval() }
    }
    
    // Is the modulation currently shown on GUI
    @Published var isDisplayed = false
    
    // Is the modulation currently shown on GUI
    @Published var isBypassed = false{
        didSet{setBypass()}
    }
    
    @Published var pattern: Pattern
    
    func toggleDisplayed(){
        isDisplayed.toggle()
        
        if(isDisplayed){
            for target in modulationTargets{
                target.knobModel.modSelected = true
            }
        }
        else{
            for target in modulationTargets{
                target.knobModel.modSelected = false
            }
        }
        
        DispatchQueue.main.async {
            self.delegate?.modulationDisplayChange(self)
        }
        
    }
    
    var timer = RepeatingTimer(timeInterval: 0.01)
    
    init(tempo: Tempo){
        
        self.tempo = tempo
        
        Modulation.numberOfModulations = Modulation.numberOfModulations + 1
        id = Modulation.numberOfModulations
        name = "LFO " + String(id)
        
        pattern = Pattern(color: Color.black)
        
        modulationColor = self.getColorForModulation(num: id)
        pattern.modulationColor = modulationColor
        
        timer.eventHandler = {self.timerAction()}
        
        timingControl.name = "Rate"
        timingControl.range = 0.099
        timingControl.unit = " Hz"
        timingControl.percentRotated = 0.0
        //timingControl.isTempoSynced = true
        
        setTimeInterval()
        
        toggleDisplayed()
    }
    
    func getColorForModulation(num: Int) -> Color{
        switch num{
        case 1:
            return Color.init(red: 0, green: 1.0, blue: 0) //green
        case 2:
            return Color.init(red: 0, green: 0, blue: 1.0) //blue
        case 3:
            return Color.init(red: 1.0, green: 0, blue: 0) //red
        case 4:
            return Color.init(red: 1.0, green: 1.0, blue: 0) //yellow
        default:
            return Color.init(red: 1.0, green: 1.0, blue: 1.0) //white
        }
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
                print("adjusting range for " + modulationTargets[i].knobModel.name + " to " + String(modulationTargets[i].modulationRange))
                break
            }
        }
    }
    
    func setTimeInterval(){
        
        if(isTempoSynced){
            
            //Determine the number of tempo selection segments
            let numberOfSegments = tempo.regularIntervals.count
            
            //Determine which segment we are rotated into
            let segment = Int(timingControl.percentRotated * Double(numberOfSegments - 1))
            
            //get the time interval while accounting for how many steps we need to take
            timeInterval = tempo.getTimeWithSteps(intNumber: segment, numberOfSteps: numberOfSteps)
            
            // display the time interval (may need this adjusted)
            timingControl.display = tempo.regularIntervalStrings[segment]
            
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
    
    func setBypass(){
        if(isBypassed){
            stop()
        }
        else{
            start()
        }
    }

    @objc func timerAction(){

        // Calculate next x value
        xValue = xValue + CGFloat(1.0 / numberOfSteps)
        
        // Reset if required
        if(xValue > 1.0){
            xValue = CGFloat(1.0 / numberOfSteps)
        }
        
        // Calculate next value
        modulationValue = Double(pattern.getValueFromX(xVal: xValue))
        
        print("There are currently " + String(modulationTargets.count) + " modulationTargets." )
        
        // Relay the value to the targets
        for target in modulationTargets{
            //print("Modulating knob: " + target.knobModel.name + " with value " + String(modulationValue))
            target.calculateTargetModulation(modulationValue: modulationValue)
        }
        
        // tell the UI to get new binding values
        DispatchQueue.main.async {
            self.delegate?.modulationUpdateUI(self)
        }
        
        timeOfLastTimerAction = Double(DispatchTime.now().uptimeNanoseconds)
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
    var modulationRange: Double = 0.1 {
    didSet {
        //print("didSet modulationRange for " + knobModel.name + " to " + String(self.modulationRange))
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
        //print("limitRange for " + knobModel.name + " to " + String(self.modulationRange))
        knobModel.attemptedModulationRange = modulationRange
    }
    
    public func calculateTargetModulation(modulationValue: Double){
        //print("calculateTargetModulation range for " + knobModel.name + " was " + String(self.modulationRange))
        //print("calculateTargetModulation for " + knobModel.name + " with value " + String(modulationValue * modulationRange))
        knobModel.modulationValue = modulationValue * modulationRange
    }
    
}
