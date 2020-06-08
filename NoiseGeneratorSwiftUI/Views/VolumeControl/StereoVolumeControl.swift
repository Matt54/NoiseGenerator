//
//  StereoVolumeControl.swift
//  NoiseGeneratorSwiftUI
//
//  Created by Macbook on 6/7/20.
//  Copyright © 2020 Matt Pfeiffer. All rights reserved.
//

import SwiftUI

struct StereoVolumeControl: View {
    
    @Binding var volumeControl: Double
    @Binding var leftAmplitude: Double
    @Binding var rightAmplitude: Double
    @Binding var numberOfRects: Int
    var spacing: CGFloat = 4
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                
                //if(!self.isRightHanded){
                    
                //}
                
                VStack(spacing: 0) {
                    
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: (geometry.size.width * 0.15 - geometry.size.height / CGFloat(self.numberOfRects) * 0.15))
                    
                    StereoVolumeDisplay(leftAmplitude: self.$leftAmplitude,
                                        rightAmplitude: self.$rightAmplitude,
                                        numberOfRects: .constant(self.numberOfRects))
                    
                    Rectangle()
                    .fill(Color.clear)
                        .frame(height: (geometry.size.width * 0.15 - geometry.size.height / CGFloat(self.numberOfRects) * 0.15 * 2))
                    
                }
                
                VStack(spacing: 0) {
                    SlidingTriangle(volumeControl: self.$volumeControl,
                                    isRightHanded: .constant(true))
                }
                .frame(width: geometry.size.width * 0.3)
                
                /*
                if(self.isRightHanded){
                    VStack(spacing: 0) {
                        SlidingTriangle(amplitudeControl: self.$amplitudeControl,
                                        isRightHanded: self.$isRightHanded)
                    }
                    .frame(width: geometry.size.width * 0.5)
                }
                */
            }
        }
        //,amplitudeControl: .constant(1.0))
    }
}

struct StereoVolumeControl_Previews: PreviewProvider {
    static var previews: some View {
        StereoVolumeControl(volumeControl: .constant(1.0),
                            leftAmplitude: .constant(0.6),
                            rightAmplitude: .constant(0.8),
                            numberOfRects: .constant(30))
                .previewLayout(.fixed(width: 50, height: 200))
    }
}
