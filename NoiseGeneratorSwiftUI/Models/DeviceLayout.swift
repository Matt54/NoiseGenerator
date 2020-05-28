//
//  DeviceLayout.swift
//  NoiseGeneratorSwiftUI
//
//  Created by Macbook on 5/28/20.
//  Copyright © 2020 Matt Pfeiffer. All rights reserved.
//

import Foundation

class DeviceLayout{
    var padLeft : CGFloat = 0.0
    var padRight: CGFloat = 0.0
    var padTop : CGFloat = 0.0
    var padBottom : CGFloat = 0.05
    
    // This variable is used to increase the size of the keyboard area on ipad
    // Useful - because we can use more screen real estate without adjusting
    //          the aspect ratio of the rest of the UI
    var keyboardAdjust: CGFloat = 0.0
    
    // Desired aspect ratio = 1.77777777778
    func calculateLayoutPadding(){
        
        let screenSize: CGRect = UIScreen.main.bounds
        //keyboardAdjust = screenSize.height * -0.1
        
        var w = screenSize.width - screenSize.width * padLeft - screenSize.width * padRight
        var h = screenSize.height - screenSize.height * padTop - screenSize.height * padBottom - keyboardAdjust
        var aspectRatio = w / h
        
        var xLimits = false
        var yLimits = false
        
        while (abs(16/9 - aspectRatio)) > 0.01 {
            if(aspectRatio > 16/9){
                //make aspectRatio smaller by increasing height / decreasing width
                
                //first try full screen on the height
                if(!yLimits){
                    
                    //Always leave room for the bottom bar thing
                    padBottom = 0.05
                    
                    yLimits = true
                }
                else{
                    padLeft = padLeft + 0.005
                    padRight = padRight + 0.005
                }
            }
            else{
                //make aspectRatio bigger by increasing width / decreasing height
                //first try full screen on the height
               if(!xLimits){
                
                    //Always leave room for the bottom bar navigation control
                    padBottom = 0.05
                
                    //This is likely an ipad, so give it a top header too
                    padTop = 0.05
                
                   xLimits = true
               }
               else{
                
                    // Grow the keyboard size to some limit first,
                    // then adjust the rest of the UI to the aspect ratio
                    if(keyboardAdjust < screenSize.height * 0.25){
                        keyboardAdjust = keyboardAdjust + 5
                    }
                    else{
                        padTop = padTop + 0.005
                        padBottom = padBottom + 0.005
                    }
                
                
               }
            }
            w = screenSize.width - screenSize.width * padLeft - screenSize.width * padRight
            h = screenSize.height - screenSize.height * padTop - screenSize.height * padBottom - keyboardAdjust
            aspectRatio = w / h
            print("Aspect Ratio: \(aspectRatio)")
        }
    }
}
