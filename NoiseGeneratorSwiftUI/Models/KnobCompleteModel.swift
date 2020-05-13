import Foundation

public class KnobCompleteModel : ObservableObject{
    
    var delegate:ModulationDelegate?
    var handoffDelegate:KnobModelModulationHandoff?
    
    @Published var percentRotated = 0.0{
    didSet {
        calculateRealValue()
        calculateRealRange()
        }
    }
    
    // This controls the display of the modulation amount
    // When a mod is selected that targets this knob
    @Published var modSelected = false
    
    // Can never be below 0 or above 1
    @Published var realModValue = 0.0
    
    //This value will be constantly adjusted by the modulations
    //This value can be above 1 and below zero
    @Published var modulationValue = 0.0{
    didSet {
        calculateRealValue()
        }
    }
    
    // can never be outside the range of the arc
    @Published var realModulationRange = 0.0
    
    // can be outside the range of the arc
    @Published var attemptedModulationRange = 0.0{
    didSet {
        calculateRealRange()
        }
    }
    
    @Published var name = "Parameter"
    @Published var range = 1.0
    @Published var unit = ""
    @Published var display = "Display"
    
    public var isTempoSynced: Bool = false
    
    init(){
        calculateRealValue()
        calculateRealRange()
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
            realModulationRange = -1 * percentRotated
        }
        else{
            realModulationRange = attemptedModulationRange
        }
    }

    func handoffKnobModel(){
        print("handoffKnobModel")
        handoffDelegate?.KnobModelAssignToModulation(self)
    }
    
    func removeKnobModel(){
        print("removeModulation")
        handoffDelegate?.KnobModelRemoveModulation(self)
    }
    
    func adjustModulationRange(adjust: Double){
        handoffDelegate?.KnobModelAdjustModulationRange(self, adjust: adjust)
    }
    
}

protocol ModulationDelegate {
    func modulationValueWasChanged(_ sender: KnobCompleteModel)
}

protocol KnobModelModulationHandoff{
    func KnobModelAssignToModulation(_ sender: KnobCompleteModel)
    func KnobModelRemoveModulation(_ sender: KnobCompleteModel)
    func KnobModelAdjustModulationRange(_ sender: KnobCompleteModel, adjust: Double)
}
