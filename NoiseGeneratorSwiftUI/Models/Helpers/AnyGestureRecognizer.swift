import Foundation
import AudioKitUI

struct GlobalGestureWatcher{
    static var isKeyboardBlocking = false
    static var touchesOnTheScreen = 0
}

class AnyGestureRecognizer: UIGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        
        if(Conductor.shared.selectedScreen == .main){
            Conductor.shared.transferKeyboardTouch(touches, with: event)
        }
        
        //To prevent keyboard hide and show when switching from one textfield to another
        if let textField = touches.first?.view, textField is UITextField {
            state = .failed
        } else {
            state = .began
        }
        
        /*
        if(numberOfTouches > 3){
            print("Four finger touch!")
        }
        
        GlobalGestureWatcher.touchesOnTheScreen = GlobalGestureWatcher.touchesOnTheScreen + touches.count
        print( "touchBegan")
        print( "numberOfTouches: " + String(GlobalGestureWatcher.touchesOnTheScreen) )

        if(GlobalGestureWatcher.touchesOnTheScreen == 1){
            if let keyBoard = touches.first?.view, keyBoard is AKKeyboardView {
                //print("first touch is on the keyboard")
            }
            else{
                //print("begin keyboard blocking")
                GlobalGestureWatcher.isKeyboardBlocking = true
            }
        }
        
        
        
        /*
        if let keyBoard = touches.first?.view, keyBoard is AKKeyboardView {
            if(GlobalGestureWatcher.isKeyboardBlocking){
                print("we need to catch this keyboard touch")
                Conductor.shared.transferKeyboardTouch(touches, with: event)
            }
        }
        */
        
        
        
        */
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        //state = .ended
        //GlobalGestureWatcher.touchesOnTheScreen = GlobalGestureWatcher.touchesOnTheScreen - touches.count
        
        if(Conductor.shared.selectedScreen == .main){
            Conductor.shared.transferKeyboardLift(touches, with: event)
        }
        
        /*
        if(GlobalGestureWatcher.isKeyboardBlocking){
            Conductor.shared.transferKeyboardLift(touches, with: event)
        }
        */
            
        /*
        for touch in touches{
            if let keyBoard = touch.view, keyBoard is AKKeyboardView {
                Conductor.shared.transferKeyboardLift(touches, with: event)
                break
            }
        }
        */
        
        /*
        if let keyBoard = touches.first?.view, keyBoard is AKKeyboardView {
            if(GlobalGestureWatcher.isKeyboardBlocking){
                print("we need to catch this keyboard touch")
                Conductor.shared.transferKeyboardLift(touches, with: event)
            }
        }
        */
        /*
        if(GlobalGestureWatcher.touchesOnTheScreen == 0){
            state = .ended
            if(GlobalGestureWatcher.isKeyboardBlocking){
                print("end keyboard blocking")
                GlobalGestureWatcher.isKeyboardBlocking = false
            }
        }
        
        print( "touchEnded")
        print( "numberOfTouches: " + String(GlobalGestureWatcher.touchesOnTheScreen) )
        */
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        
        if(Conductor.shared.selectedScreen == .main){
            Conductor.shared.transferKeyboardCancelled(touches, with: event)
        }
        
        /*
        if(GlobalGestureWatcher.isKeyboardBlocking){
            Conductor.shared.transferKeyboardCancelled(touches, with: event)
        }
        */
        
        state = .cancelled
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        
        if(Conductor.shared.selectedScreen == .main){
            Conductor.shared.transferKeyboardMoved(touches, with: event)
        }
        
        /*
        if(GlobalGestureWatcher.isKeyboardBlocking){
            Conductor.shared.transferKeyboardMoved(touches, with: event)
        }
        */
    }
    

}
