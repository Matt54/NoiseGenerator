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
        VStack{
            if(!self.isRightHanded){
                VStack(alignment: .trailing, spacing: 5)
                {
                    Text(String(format: "%.1f", self.volumeControl))
                        .font(.system(size: 12))
                        .padding(.trailing, 2)
                    VolumeControl(volume: self.$amplitude,
                                  amplitudeControl:self.$volumeControl,
                                  isRightHanded: self.$isRightHanded,
                                  numberOfRects: self.$numberOfRects)
                    Text(self.title)
                        .font(.system(size: 12))
                        .bold()
                        .padding(.trailing, 4)
                }
            }
            else{
                VStack(alignment: .leading, spacing: 5)
                {
                    Text(String(format: "%.1f", self.volumeControl))
                        .font(.system(size: 12))
                        .padding(.leading, 2)
                    VolumeControl(volume: self.$amplitude,
                                  amplitudeControl: self.$volumeControl,
                                  isRightHanded: self.$isRightHanded,
                                  numberOfRects: self.$numberOfRects)
                    Text(self.title)
                        .font(.system(size: 12))
                        .bold()
                        //.padding(.leading, 4)
                }
            }
        }
    }
}

struct VolumeComplete_Previews: PreviewProvider {
    static var previews: some View {
        VolumeComplete(amplitude: .constant(0.5),volumeControl: .constant(1.0), isRightHanded: .constant(false), numberOfRects: .constant(30), title: "IN")
        .previewLayout(.fixed(width: 30, height: 200))
    }
}