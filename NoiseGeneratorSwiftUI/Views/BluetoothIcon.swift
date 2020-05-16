//
//  BluetoothIcon.swift
//  NoiseGeneratorSwiftUI
//
//  Created by Macbook on 5/16/20.
//  Copyright © 2020 Matt Pfeiffer. All rights reserved.
//

import SwiftUI

struct BluetoothIcon: View {
    var body: some View {
        GeometryReader
        { geometry in
                BluetoothShape()
                    .stroke(lineWidth: geometry.size.height * 0.07)
                    .aspectRatio(0.5, contentMode: .fit)
                    .padding(geometry.size.height * 0.07)
        }
    }
}

struct BluetoothIcon_Previews: PreviewProvider {
    static var previews: some View {
        BluetoothIcon()
            .previewLayout(.fixed(width: 200, height: 200))
    }
}

struct BluetoothShape: Shape {
    
    //this is going to need a specific aspect ratio something like:
    // height = 2.0
    // width =  1.0
    
    var anchor : CGFloat = 0.25
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        //high left
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY * anchor))
        
        //low right
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY * (1 - anchor)))
        
        // mid bottom
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        
        // mid top
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        
        // high right
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY * anchor))
        
        //low left
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY * (1 - anchor)))
        
        return path
    }
    
}
