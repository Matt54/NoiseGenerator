//
//  VolumeComplete.swift
//  NoiseGeneratorSwiftUI
//
//  Created by Macbook on 4/28/20.
//  Copyright © 2020 Matt Pfeiffer. All rights reserved.
//

import SwiftUI

struct VolumeComplete: View {
    @Binding var amplitude: Double
    @Binding var volumeControl: Double
    @Binding var isRightHanded: Bool
    @Binding var numberOfRects: Int
    @State var title: String
    
    var body: some View {
        GeometryReader { geometry in
            Group{
                if(!self.isRightHanded){
                    VStack(alignment: .trailing, spacing: 0)
                    {
                        // Text - Volume Control
                        Text(String(format: "%.1f", self.volumeControl))
                            .textStyle(ShrinkTextStyle())
                            //.padding(.trailing, geometry.size.width * 0.05)
                            //.padding(geometry.size.width * 0.1)
                            
                            .frame(width: geometry.size.width * 0.7,
                                   height: geometry.size.height * 0.1)
                            .padding(.bottom, geometry.size.height * 0.03)
                        
                        // Control - Volume Bars and Slider
                        VolumeControl(volume: self.$amplitude,
                                      amplitudeControl:self.$volumeControl,
                                      isRightHanded: self.$isRightHanded,
                                      numberOfRects: self.$numberOfRects)
                        //.frame(height: geometry.size.height * 0.8)
                            //.padding(geometry.size.width * 0.1)
                            //.frame(height: geometry.size.height * 0.8)
                        
                        // Text - Title
                        Text(self.title)
                            .bold()
                            .textStyle(ShrinkTextStyle())
                            //.padding(.trailing, geometry.size.width * 0.05)
                            //.padding(geometry.size.width * 0.1)
                            .frame(width: geometry.size.width * 0.7,
                                   height: geometry.size.height * 0.1)
                            .padding(.top, geometry.size.height * 0.03)
                    }
                }
                else{
                    VStack(alignment: .leading, spacing: 0)
                    {
                        
                        // Text - Volume Control
                        Text(String(format: "%.1f", self.volumeControl))
                            .textStyle(ShrinkTextStyle())
                            //.padding(.leading, geometry.size.width * 0.1)
                            //.minimumScaleFactor(0.0001)
                            //.scaledToFit()
                            .frame(width: geometry.size.width * 0.7,
                                   height: geometry.size.height * 0.1)
                            .padding(.bottom, geometry.size.height * 0.03)
                            //.fixedSize()
                            
                        // Control - Volume Bars and Slider
                        VolumeControl(volume: self.$amplitude,
                                      amplitudeControl: self.$volumeControl,
                                      isRightHanded: self.$isRightHanded,
                                      numberOfRects: self.$numberOfRects)
                            //.padding(.leading, geometry.size.width * 0.1)
                                        //.frame(height: geometry.size.height * 0.8)
                        
                        // Text - Title
                        Text(self.title)
                            .bold()
                            .textStyle(ShrinkTextStyle())
                            //.padding(.trailing, geometry.size.width * 0.1)
                            //.fixedSize(horizontal: false, vertical: true)
                            //.minimumScaleFactor(0.0001)
                            //.scaledToFit()
                            .frame(width: geometry.size.width * 0.7,
                                   height: geometry.size.height * 0.1)
                            .padding(.top, geometry.size.height * 0.03)
                        
                        
                    }
                }
            }
        }
    }
}

struct VolumeComplete_Previews: PreviewProvider {
    static var previews: some View {
        VolumeComplete(amplitude: .constant(0.5),volumeControl: .constant(1.0), isRightHanded: .constant(false), numberOfRects: .constant(20), title: "IN")
        .previewLayout(.fixed(width: 40, height: 200))
    }
}

public struct ShrinkTextStyle: ViewModifier {
    public func body(content: Content) -> some View {
        content
            //.lineLimit(1)
            //.minimumScaleFactor(0.1)
            /*
            .font(.system(size: 500))
            .minimumScaleFactor(0.0001)
            .lineLimit(1)
            */
            .font(.system(size: 50))
            .minimumScaleFactor(0.0001)
            .lineLimit(1)
            .scaledToFit()
        
        
        
            //.padding()
    }
}
public extension Text {
    func textStyle<Style: ViewModifier>(_ style: Style) -> some View {
        ModifiedContent(content: self, modifier: style)
    }
}
