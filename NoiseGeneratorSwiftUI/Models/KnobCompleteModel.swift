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
            //let _percentRotated = percentRotated
            //let _modulationValue = modulationValue
            //let _realModValue = modulationValue + percentRotated
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
    
    func ToggleTempoSync(){
        handoffDelegate?.ToggleTempoSync(self)
    }
    
    func ToggleModulationAssignment(){
        handoffDelegate?.ToggleModulationAssignment()
    }
    
    func ToggleModulationSpecialSelection(){
        handoffDelegate?.ToggleModulationSpecialSelection()
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
    
    var modulationTrackers: [ModulationTracker] = []

    
    func addModulationTracker(_ modulation: Modulation){
        
        var isFound = false
        
        for mod in modulationTrackers{
            if(mod.modulationSource === modulation){
                isFound = true
            }
        }
        
        if(!isFound){
            print("modulation tracker added")
            modulationTrackers.append(ModulationTracker(modulation))
        }
    }
    
    func removeModulationTracker(_ modulation: Modulation){
        for i in 0..<modulationTrackers.count {
            if(modulationTrackers[i].modulationSource === modulation){
                print("modulation tracker removed")
                modulationTrackers.remove(at: i)
                break
            }
        }
        sumModulations()
    }
    
    func sumModulations(){
        var sum = 0.0

        for mod in modulationTrackers{
            sum = sum + mod.valueAdjust
        }

        self.modulationValue = sum
    }
    
    /// Recalculates the new sum of  all modulations on the parameter. Called when any modulation changes it's value.
    func sumModulations(_ modulation: Modulation, newValueAdjust: Double){
        
        var sum = 0.0
        
        // sum the modulations
        for mod in modulationTrackers{
            
            // change the value
            if(mod.modulationSource === modulation){
                mod.valueAdjust = newValueAdjust
            }
            
            sum = sum + mod.valueAdjust
        }
        
        //end result gives a new value to modulationValue
        self.modulationValue = sum
    }
    
}

protocol KnobModelHandoff{
    func KnobModelHandoff(_ sender: KnobCompleteModel)
    func KnobModelRangeHandoff(_ sender: KnobCompleteModel, adjust: Double)
    func modulationValueWasChanged(_ sender: KnobCompleteModel)
    func handsFreeTextUpdate(_ sender: KnobCompleteModel)
    
    func ToggleModulationAssignment()
    func ToggleModulationSpecialSelection()
    func ToggleTempoSync(_ sender: KnobCompleteModel)
}


class ModulationTracker{
    var valueAdjust : Double = 0.0
    var modulationSource : Modulation
    
    init(_ modulation: Modulation){
        self.modulationSource = modulation
    }
}
