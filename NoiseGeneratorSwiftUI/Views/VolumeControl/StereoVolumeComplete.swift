//
//  StereoVolumeComplete.swift
//  NoiseGeneratorSwiftUI
//
//  Created by Macbook on 6/7/20.
//  Copyright © 2020 Matt Pfeiffer. All rights reserved.
//

import SwiftUI

struct StereoVolumeComplete: View {
    
    @Binding var volumeMixer: VolumeMixer
    
    
    var body: some View {
        GeometryReader { geometry in
            Group{
                /*
                if(!self.volumeMixer.isRightHanded){
                    
                    // Entire Control - Volume Bars intentionally have no frame set
                    // The size of the text frame + padding sets the volume bar
                    VStack(alignment: .trailing, spacing: 0)
                    {
                        // Text - Volume Control
                        Text(String(format: "%.1f", self.volumeMixer.volumeControl))
                            .textStyle(ShrinkTextStyle())
                            
                            .frame(width: geometry.size.width * 0.7,
                                   height: geometry.size.height * 0.1)
                            .padding(.bottom, geometry.size.height * 0.03)
                        
                        // Control - Volume Bars and Slider
                        VolumeControl(volume: self.$volumeMixer.amplitude,
                                      amplitudeControl:self.$volumeMixer.volumeControl,
                                      isRightHanded: self.$volumeMixer.isRightHanded,
                                      numberOfRects: self.$volumeMixer.numberOfRects)
                        
                        // Text - Title
                        Text(self.volumeMixer.name)
                            .bold()
                            .textStyle(ShrinkTextStyle())
                            .frame(width: geometry.size.width * 0.7,
                                   height: geometry.size.height * 0.1)
                            .padding(.top, geometry.size.height * 0.03)
                    }
                }
                */
                
                //else{
                    
                // Entire Control - Volume Bars intentionally have no frame set
                // The size of the text frame + padding sets the volume bar
                VStack(alignment: .leading, spacing: 0)
                {
                    
                    // Text - Volume Control
                    Text(String(format: "%.1f", self.volumeMixer.volumeControl))
                        .textStyle(ShrinkTextStyle())
                        .frame(width: geometry.size.width * 0.7,
                               height: geometry.size.height * 0.1)
                        .padding(.bottom, geometry.size.height * 0.03)
                        
                    // Control - Volume Bars and Slider
                    /*
                    VolumeControl(volume: self.$volumeMixer.amplitude,
                                  amplitudeControl: self.$volumeMixer.volumeControl,
                                  isRightHanded: self.$volumeMixer.isRightHanded,
                                  numberOfRects: self.$volumeMixer.numberOfRects)
                    */
                    
                    StereoVolumeControl(volumeControl: self.$volumeMixer.volumeControl,
                                        leftAmplitude: self.$volumeMixer.leftAmplitude,
                                        rightAmplitude: self.$volumeMixer.rightAmplitude,
                                        numberOfRects: self.$volumeMixer.numberOfRects)
                    
                    
                    // Text - Title
                    Text(self.volumeMixer.name)
                        .bold()
                        .textStyle(ShrinkTextStyle())
                        .frame(width: geometry.size.width * 0.7,
                               height: geometry.size.height * 0.1)
                        .padding(.top, geometry.size.height * 0.03)
                }
                
                //}
                
            }
        }
    }
}

struct StereoVolumeComplete_Previews: PreviewProvider {
    static var previews: some View {
        StereoVolumeComplete(volumeMixer: .constant(VolumeMixer()))
                .previewLayout(.fixed(width: 40, height: 200))
            }
        }
