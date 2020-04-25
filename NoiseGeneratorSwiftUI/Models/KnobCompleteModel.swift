import Foundation

public class KnobCompleteModel : ObservableObject{
    
    var delegate:ModulationDelegate?
    
    @Published var percentRotated = 0.0{
    didSet {
        calculateRealValue()
        calculateRealRange()
        }
    }
    
    // sets the realModValue from the position + modulationValue logic
    // doesn't allow it to go below 0 or above 1.0
    func calculateRealValue(){
        if(percentRotated + modulationValue > 1.0){
            realModValue = 1.0
        }
        else if(percentRotated + modulationValue < 0.0){
            realModValue = 0.0
        }
        else{
            realModValue = modulationValue + percentRotated
        }
        delegate?.modulationValueWasChanged(self)
    }
    
    // sets the realModulationRange from the position + attemptedModulationRange logic
    // doesn't allow the position + range to go above 1.0 or below 0
    func calculateRealRange(){
        if(percentRotated + attemptedModulationRange > 1.0){
            realModulationRange = (1.0 - percentRotated)
        }
        else if(percentRotated + attemptedModulationRange < 0.0){
            realModulationRange = percentRotated
        }
        else{
            realModulationRange = attemptedModulationRange
        }
    }

    @Published var modSelected = false
    @Published var realModValue = 0.0
    
    //This value will be constantly adjusted by the modulation
    @Published var modulationValue = 0.0
    
    @Published var realModulationRange = 0.0
    @Published var attemptedModulationRange = 0.0{
    didSet {
        calculateRealRange()
        }
    }
    
    @Published var name = "Parameter"
    @Published var range = 1.0
    @Published var unit = ""
    @Published var display = "Display"

    init(){
        calculateRealValue()
        calculateRealRange()
    }
}

protocol ModulationDelegate {
    func modulationValueWasChanged(_ sender: KnobCompleteModel)
}
