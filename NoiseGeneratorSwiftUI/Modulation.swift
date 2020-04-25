import Foundation

public class Modulation : Identifiable, ObservableObject{
    
    var delegate:ModulationDelegateUI?
    
    static var numberOfModulations = 0
    public var name: String
    
    public var id: Int
    
    var numberOfSteps = 500.0
    
    @Published var timeInterval = 0.01{
    didSet {
        setTimeInterval(timeInterval: timeInterval)
        }
    }
    
    @Published var timingControl = KnobCompleteModel(){
        didSet{ setTimeInterval() }
    }
    
    // Is the modulation currently shown on GUI
    @Published var isDisplayed = true
    
    // Is the modulation currently shown on GUI
    @Published var isBypassed = false
    
    func toggleDisplayed(){
        isDisplayed.toggle()
    }
    
    var timer = RepeatingTimer(timeInterval: 0.01)
    
    init(){
        Modulation.numberOfModulations = Modulation.numberOfModulations + 1
        id = Modulation.numberOfModulations
        name = "Modulation " + String(id)
        timer.eventHandler = {self.timerAction()}
        
        timingControl.name = "Rate"
        timingControl.range = 0.0099
        timingControl.unit = " Hz"
        timingControl.percentRotated = 0.0
        
        setTimeInterval()
    }

    // Target Parameters
    var targets : [KnobCompleteModel] = []
    
    func addTarget(newTarget: KnobCompleteModel){
        targets.append(newTarget)
    }
    
    func removeTarget(removeTarget: KnobCompleteModel){
        for i in 0..<targets.count {
            if(targets[i] === removeTarget){
                targets.remove(at: i)
                break
            }
        }
    }
    
    func setTimeInterval(){
        timeInterval = 0.0001 + (1.0 - pow(timingControl.percentRotated, 0.2)) * timingControl.range
        timingControl.display = String(format: "%.3f", ((1/(0.0001 + (1.0 - pow(timingControl.percentRotated, 0.2)) * timingControl.range)))/numberOfSteps) + timingControl.unit
    }
    
    func setTimeInterval(timeInterval: Double){
        timer = RepeatingTimer(timeInterval: timeInterval)
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
    
    //new function
    @objc func timerAction(){
        for target in targets{
            // step the new modulation value
            target.modulationValue = target.modulationValue + (target.realModulationRange / numberOfSteps)
            
            // reset modulation value if it is outside of range
            if(target.modulationValue > target.realModulationRange){
                target.modulationValue = 0
            }
            
            // tell control that we have a new value to write
            target.calculateRealValue()
            
            // tell the UI to get new binding values
            DispatchQueue.main.async {
                self.delegate?.modulationUpdateUI(self)
                //self.objectWillChange.send()
            }
        }
    }
    
}

protocol ModulationDelegateUI {
    func modulationUpdateUI(_ sender: Modulation)
}
