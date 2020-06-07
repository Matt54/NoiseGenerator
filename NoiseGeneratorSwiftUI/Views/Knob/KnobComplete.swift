import SwiftUI
import Combine

struct KnobComplete: View {

    @Binding var knobModel : KnobCompleteModel
    @Binding var knobModColor: Color
    @Binding var specialSelection: SpecialSelection
    
    var sensitivity: Double = 0.01;
    
    @State var deltaX: Double = 0.0
    @State var deltaY: Double = 0.0
    
    @State var currentX: CGFloat = 0.0
    @State var currentY: CGFloat = 0.0
    
    var body: some View {
        GeometryReader{ geometry in
            ZStack{
                
                //modulation background
                Arc(startAngle: .constant(130 * .pi / 180),
                    endAngle: .constant( (270.0 * 1.0 + 140.0) * .pi / 180.0),
                    lineWidth: geometry.size.width * 0.05,
                    center: CGPoint(x: geometry.size.width/2, y: geometry.size.height/2),
                    radius: geometry.size.width/2 - geometry.size.width * 0.05 * 0.5)
                    .fill(Color.init(red: 0.5, green: 0.5, blue: 0.5))
                
                //modulation background border
                Arc(startAngle: .constant(130 * .pi / 180),
                    endAngle: .constant( (270.0 * 1.0 + 140.0) * .pi / 180.0),
                    lineWidth: geometry.size.width * 0.05,
                    center: CGPoint(x: geometry.size.width/2, y: geometry.size.height/2),
                    radius: geometry.size.width/2 - geometry.size.width * 0.05 * 0.5)
                    .stroke(Color.init(red: 0.2, green: 0.2, blue: 0.2),
                            lineWidth: geometry.size.width * 0.005)
                
                //modulation
                if(self.knobModel.modSelected)
                {
                    if(self.knobModel.realModulationRange > 0.0)
                    {
                    Arc(startAngle: .constant((270.0 * self.knobModel.percentRotated + 130) * .pi / 180),
                        endAngle: .constant((270 * self.knobModel.realModulationRange + 270.0 * self.knobModel.percentRotated + 140.0) * .pi / 180.0),
                        lineWidth: geometry.size.width * 0.05,
                        center: CGPoint(x: geometry.size.width/2, y: geometry.size.height/2),
                        radius: geometry.size.width/2 - geometry.size.width * 0.05 * 0.5)
                        .fill(self.knobModColor)
                    }
                    else{
                        Arc(startAngle: .constant((270 * self.knobModel.realModulationRange + 270.0 * self.knobModel.percentRotated + 130.0) * .pi / 180.0),
                        endAngle: .constant((270.0 * self.knobModel.percentRotated + 140) * .pi / 180),
                        lineWidth: geometry.size.width * 0.05,
                        center: CGPoint(x: geometry.size.width/2, y: geometry.size.height/2),
                        radius: geometry.size.width/2 - geometry.size.width * 0.05 * 0.5)
                        .fill(self.knobModColor)
                    }
                }
                
                // the actual knob control
                KnobControl(percentRotated: self.$knobModel.percentRotated,
                            realModValue: self.$knobModel.realModValue,
                            knobModColor: self.$knobModColor,
                            currentAngle: self.$knobModel.currentAngle)
                    .frame(width:geometry.size.width * 0.9)
                
                    //long press on a knob brings up modulation controls
                    .simultaneousGesture(LongPressGesture().onEnded({ _ in
                        self.knobModel.ToggleModulationAssignment()
                        }
                    ))
                
                // double tap - switch to modulation delete
                .simultaneousGesture(TapGesture(count: 2).onEnded({ _ in
                    self.knobModel.ToggleTempoSync()
                }))
                
                // OVERLAYS GO HERE
                if(self.specialSelection == .assignModulation && self.knobModel.isModulatable){
                    ZStack{
                        
                        // Color changing layer
                        VStack(spacing: 0){
                            if(self.knobModel.modSelected){
                                Color(red: 0.0, green: 0, blue: 1.0, opacity: 0.2)
                            }
                            else{
                                Color(red: 1.0, green: 0, blue: 1.0, opacity: 0.2)
                            }
                        }
                            
                        //Clear unchanging layer allows for no lapse in the gesture
                        Color(red: 1.0, green: 1.0, blue: 1.0, opacity: 0.01)
                        .gesture(DragGesture(minimumDistance: 0)
                            .onChanged{ value in
                                //print("touch began")
                                
                                if(!self.knobModel.modSelected){
                                    self.knobModel.handoffKnobModel()
                                }
                                
                                if (self.currentX != 0.0 && self.currentY != 0.0){
                                    self.deltaX = Double(self.currentX - value.location.x)
                                    self.deltaY = Double(self.currentY - value.location.y)
                                }
                                self.currentX = value.location.x
                                self.currentY = value.location.y
                                
                                let modulationAdjust = self.deltaY * self.sensitivity - self.deltaX * self.sensitivity
                            
                                print("modulationAdjust: " + String(modulationAdjust))
                                
                                self.knobModel.adjustModulationRange(adjust: modulationAdjust)
                                
                            }
                            .onEnded{ value in
                                print("touch ended")
                                self.currentX = 0.0
                                self.currentY = 0.0
                            }
                        )
                        
                        // long hold - switch on/off the mod assignment mode
                        .simultaneousGesture(LongPressGesture().onEnded({ _ in
                            self.knobModel.ToggleModulationAssignment()
                            }
                        ))
                        
                        // double tap - switch to modulation delete
                        .simultaneousGesture(TapGesture(count: 2).onEnded({ _ in
                            self.knobModel.ToggleModulationSpecialSelection()
                        }))
                        
                        // switch images once modulation is assigned
                        if(self.knobModel.modSelected){
                            Image(systemName: "arrow.up.and.down.circle.fill").resizable()
                            .frame(width:geometry.size.width * 0.3, height: geometry.size.height * 0.3)
                            .foregroundColor(Color.white)
                        }
                        else{
                            Image(systemName: "plus.circle.fill").resizable()
                            .frame(width:geometry.size.width * 0.3, height: geometry.size.height * 0.3)
                            .foregroundColor(Color.white)
                        }
                        
                    }
                    
                }
                
                if(self.specialSelection == .deleteModulation && self.knobModel.isModulatable){
                    VStack{
                        if(self.knobModel.modSelected){
                            ZStack{
                                Color(red: 1.0, green: 0, blue: 0.0, opacity: 0.2)
                                
                                
                                // long hold - deletes modulation
                                .simultaneousGesture(LongPressGesture().onEnded({ _ in
                                    self.knobModel.removeKnobModel()
                                    }
                                ))
                                    
                                //double tap - switch to modulation apply
                                .simultaneousGesture(TapGesture(count: 2).onEnded({ _ in
                                    self.knobModel.ToggleModulationSpecialSelection()
                                }))
                                
                                Image(systemName: "minus.circle.fill").resizable()
                                .frame(width:geometry.size.width * 0.3, height: geometry.size.height * 0.3)
                                .foregroundColor(Color.white)
                            }
                        }
                    }
                }
                if(self.specialSelection == .midiLearn){
                    VStack{
                        ZStack{
                            Color(red: 1.0, green: 0.5, blue: 0.0, opacity: 0.2)
                            .gesture(DragGesture(minimumDistance: 0)
                                .onChanged{ value in
                                    //self.knobModel.isMidiLearning = true
                                    self.knobModel.handoffKnobModel()
                            })
                            
                            if(self.knobModel.isMidiLearning){
                                ZStack{
                                    Circle()
                                        .foregroundColor(Color(red: 1.0, green: 1.0, blue: 1.0, opacity: 0.9))
                                    Image(systemName: "ear").resizable()
                                        .padding(geometry.size.width * 0.05)
                                }
                                .frame(width:geometry.size.width * 0.3,
                                       height: geometry.size.height * 0.3)
                                .foregroundColor(Color.black)
                            }
                            else{
                                Image(systemName: "link.circle.fill").resizable()
                                .frame(width:geometry.size.width * 0.3, height: geometry.size.height * 0.3)
                                .foregroundColor(Color.white)
                            }
                            
                            if(self.knobModel.isMidiLearning){
                                VStack{
                                    HStack{
                                        Spacer()
                                        ZStack{
                                        Rectangle()
                                            .cornerRadius(geometry.size.width * 0.1)
                                            
                                            .frame(width:geometry.size.width * 0.25,
                                                   height: geometry.size.height * 0.25)
                                            .foregroundColor(Color(red: 1.0, green: 1.0, blue: 1.0, opacity: 0.9))
                                            
                                            
                                            Text(self.knobModel.midiAssignment)
                                                .bold()
                                                .textStyle(ShrinkTextStyle())
                                        }
                                        
                                        .frame(width:geometry.size.width * 0.25,
                                               height: geometry.size.height * 0.25)
                                    }
                                    .padding(geometry.size.width * 0.02)
                                    Spacer()
                                }
                            }
                        }
                    }
                }
            }//ZStack
        }
    }
}

struct KnobComplete_Previews: PreviewProvider {
    static var previews: some View {
        KnobComplete(knobModel: .constant(KnobCompleteModel()),
                     knobModColor: .constant(Color.yellow),
                     specialSelection: .constant(SpecialSelection.midiLearn))
        .previewLayout(.fixed(width: 400, height: 400))
    }
}
