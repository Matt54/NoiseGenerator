import Foundation

public class KnobCompleteModel : ObservableObject{
    
    //var delegate:ModulationDelegate?
    var handoffDelegate:KnobModelHandoff?
    
    @Published var percentRotated = 0.0{
    didSet {
        //print("percent rotated was updated: " + String(percentRotated))
        calculateRealValue()
        calculateRealRange()
        }
    }
    
    @Published var currentAngle: Double = -135.0
    
    func handfreeKnobRotate(_ newPercentRotate: Double){
        percentRotated = newPercentRotate
        currentAngle = percentRotated * 270.0 - 135.0
        handoffDelegate?.handsFreeTextUpdate(self)
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
    
    @Published var midiAssignment : String = "nil"
    @Published var isMidiLearning : Bool = false
    
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
        handoffDelegate?.modulationValueWasChanged(self)
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
        //print("handoffKnobModel")
        //handoffDelegate?.KnobModelAssignToModulation(self)
        handoffDelegate?.KnobModelHandoff(self)
    }
    
    func removeKnobModel(){
        //print("removeModulation")
        handoffDelegate?.KnobModelHandoff(self)
        //handoffDelegate?.KnobModelRemoveModulation(self)
    }
    
    
    func adjustModulationRange(adjust: Double){
        handoffDelegate?.KnobModelRangeHandoff(self, adjust: adjust)
    }
    
}

protocol KnobModelHandoff{
    func KnobModelHandoff(_ sender: KnobCompleteModel)
    func KnobModelRangeHandoff(_ sender: KnobCompleteModel, adjust: Double)
    func modulationValueWasChanged(_ sender: KnobCompleteModel)
    func handsFreeTextUpdate(_ sender: KnobCompleteModel)
}
