import Foundation
import SwiftUI

public class Modulation : Identifiable, ObservableObject{
    
    var delegate:ModulationDelegateUI?
    
    static var numberOfModulations = 0
    public var name: String
    
    public var id: Int
    
    public var modulationColor: Color = Color.init(red: 1.0, green: 1.0, blue: 1.0)
    
    var xValue: CGFloat = 0.0
    
    var modulationValue = 0.0
    
    var numberOfSteps = 200.0
    
    var timeOfLastTimerAction: Double = 0.0
    
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
    @Published var isBypassed = false
    
    @Published var pattern = Pattern()
    
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
    
    init(){
        Modulation.numberOfModulations = Modulation.numberOfModulations + 1
        id = Modulation.numberOfModulations
        name = "Modulation " + String(id)
        modulationColor = self.getColorForModulation(num: id)
        timer.eventHandler = {self.timerAction()}
        
        timingControl.name = "Rate"
        timingControl.range = 0.099
        timingControl.unit = " Hz"
        timingControl.percentRotated = 0.0
        
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
        modulationTargets.append(modulationTarget)
        newTarget.modSelected = true
        print("mod selected")
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
        timeInterval = 0.001 + (1.0 - pow(timingControl.percentRotated, 0.2)) * timingControl.range
        timingControl.display = String(format: "%.3f", ((1/(0.001 + (1.0 - pow(timingControl.percentRotated, 0.2)) * timingControl.range)))/numberOfSteps) + timingControl.unit
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

    @objc func timerAction(){

        // Calculate next x value
        xValue = xValue + CGFloat(1.0 / numberOfSteps)
        
        // Reset if required
        if(xValue > 1.0){
            xValue = CGFloat(1.0 / numberOfSteps)
        }
        
        // Calculate next value
        modulationValue = Double(pattern.getValueFromX(xVal: xValue))
        
        // Relay the value to the targets
        for target in modulationTargets{
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

class ModulationTarget {
    
    @Published var knobModel: KnobCompleteModel
    
    // Always between -1.0 and 1.0
    @Published var modulationRange = 0.0{
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
        if(modulationRange < -1.0){
            modulationRange = -1.0
        }
        knobModel.attemptedModulationRange = modulationRange
    }
    
    public func calculateTargetModulation(modulationValue: Double){
        knobModel.modulationValue = modulationValue * modulationRange
    }
    
}
