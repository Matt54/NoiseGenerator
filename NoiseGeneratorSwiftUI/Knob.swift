//
//  Knob.swift
//  NoiseGeneratorSwiftUI
//
//  Created by Macbook on 4/7/20.
//  Copyright © 2020 Matt Pfeiffer. All rights reserved.
//

import SwiftUI

struct Knob: View {
    
    @Binding var percentRotated: Double
    
    var startAngle: Double = -135.0;
    var endAngle: Double = 135.0;
    
    var sensitivity: Double = 2.5;
    var range: Double = 270.0;
    
    @State var currentAngle: Double = -135.0; //frame width
    @State var h: CGFloat = 0; //frame height
    
    @State var deltaX: Double = 0.0
    @State var deltaY: Double = 0.0
    
    @State var currentX: CGFloat = 0.0
    @State var currentY: CGFloat = 0.0
    
    var body: some View {
        GeometryReader{ geometry in
            ZStack{
                    Circle()
                        .strokeBorder(Color.init(red: 0.4, green: 0.4, blue: 0.4), lineWidth: 10)
                        .frame(width:geometry.size.width)
                    Circle()
                        .fill(Color.init(red: 0.2, green: 0.2, blue: 0.2))
                        .onAppear{
                            self.currentAngle = self.percentRotated * self.range + self.startAngle
                        }
                        .frame(width:geometry.size.width * 0.975)
                
                        .overlay(
                            Rectangle()
                                .fill(Color.white)
                                .frame(width:geometry.size.width * 0.04,
                                       height: geometry.size.width * 0.42)
                                .offset(y: -1 * geometry.size.width * 0.27)
                        )
                        .rotationEffect(
                            .degrees(
                                self.currentAngle
                            )
                        )
                //User touches the circle and drags it to a new location
                
                .gesture(DragGesture()
                    
                    // event fires when there is drag translation
                    .onChanged{
                        value in //Value stores event details (value inputted)
                        
                        
                        //self.deltaX = Double(value.translation.width)
                        //self.deltaY = Double(value.translation.height)
                        
                        if (self.currentX != 0.0 && self.currentY != 0.0){
                            self.deltaX = Double(self.currentX - value.location.x)
                            self.deltaY = Double(self.currentY - value.location.y)
                        }
                        self.currentX = value.location.x
                        self.currentY = value.location.y
                        
                        
                        //let y_move = self.deltaY
                        //let x_move = self.deltaX
                        
                        self.currentAngle = self.currentAngle + self.deltaY * self.sensitivity
                        self.currentAngle = self.currentAngle - self.deltaX * self.sensitivity
                        
                        if( self.currentAngle > self.endAngle){
                            self.currentAngle = self.endAngle
                        }
                        else if(self.currentAngle < self.startAngle){
                            self.currentAngle = self.startAngle
                        }
                        
                        self.percentRotated = (self.currentAngle + self.endAngle) / self.range
                        
                        
                        
                        /*
                        if (y_move > 0){
                            
                        }
                            
                        else{
                            
                        }*/
                            
                    }
                .onEnded{
                    value in //Value stores event details (value inputted)
                    self.currentX = 0.0
                    self.currentY = 0.0
                    }
                
                )
            }
        }
    }
}

struct Knob_Previews: PreviewProvider {
    static var previews: some View {
        Knob(percentRotated: .constant(0.5))
        .previewLayout(.fixed(width: 400, height: 450))
    }
}
