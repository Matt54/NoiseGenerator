//
//  WavetableDisplay.swift
//  NoiseGeneratorSwiftUI
//
//  Created by Macbook on 5/21/20.
//  Copyright © 2020 Matt Pfeiffer. All rights reserved.
//

import SwiftUI
import UIKit
import AudioKit

struct WavetableDisplay: View {
    
    @Binding var wavetable: [Float]
    @State var pointCount: Int = 1
    var resolutionFactor: Int = 40
    
    var body: some View {
        GeometryReader
        { geometry in
            ZStack{
                Color.darkGray
                    .onAppear{self.pointCount = self.wavetable.count}
                
                //Draw the Area Under the curve
                
                ZStack{
                    //Rectangle()
                    WavetableView(wavetable: self.$wavetable)//,frame: CGRect(x: 0, y: 0, width: geometry.size.width, height: geometry.size.height))
                        /*
                    .frame(width: geometry.size.width,
                           height: geometry.size.height)
                        */
                }
                
                
                /*
                ZStack{
                    
                    
                    ForEach(self.wavetable.indices, id: \.self){ i in
                        Group{
                            if(i < self.pointCount - 2 - self.resolutionFactor){
                                if(i % self.resolutionFactor == 0){
                    Path{ path in
                        
                        //Start at first Point
                        path.move(to: CGPoint(x: CGFloat(i) / CGFloat(self.pointCount) * geometry.size.width,
                                              y: (1 + CGFloat(self.wavetable[i])) / 2 * geometry.size.height))
                        
                        path.addLine(to: CGPoint(x: CGFloat(i + self.resolutionFactor) / CGFloat(self.pointCount) * geometry.size.width,
                                                 y: (1 + CGFloat(self.wavetable[i+self.resolutionFactor])) / 2 * geometry.size.height))
                        
                        
                        // Curve Line through the interior Points
                        /*
                        self.wavetable.forEach(items.enumeratedArray(), id: \.element) { index, item in
                          Text("\(index): Item \(item)")
                        }
                        */
                        
                        /*
                        self.wavetable.enumerate().map { (index, position) in
                            path.addLine(to: CGPoint(x: CGFloat(index) / CGFloat(self.pointCount) * geometry.size.width,
                                                    y: CGFloat(position) * geometry.size.height))
                        }
                        */
                        /*
                        ForEach(wavetable.indices, id: \.self) { index in
                            path.addLine(to: CGPoint(x: CGFloat(index) / CGFloat(self.pointCount) * geometry.size.width,
                                                     y: CGFloat(wavetable[index]) * geometry.size.height))
                        }
                        */
                        /*
                        self.wavetable.forEach{ index, i in
                            path.addLine(to: CGPoint(x: CGFloat(index) / CGFloat(self.pointCount) * geometry.size.width,
                                                     y: CGFloat(i) * geometry.size.height))
                        }
                        */
                    }
                    .stroke(Color(red: 1.0, green: 1.0, blue: 1.0), lineWidth: geometry.size.width * 0.01)
                        }
                            }
                        }
                    }
                }
                */
                    /*
                ForEach(self.wavetable.indices, id: \.self){ i in
                    Circle()
                        .frame(width: geometry.size.width * 0.015)
                        .position(CGPoint(x: CGFloat(i) / CGFloat(self.pointCount) * geometry.size.width,
                                          y: CGFloat(self.wavetable[i]) * geometry.size.height))
                        /*
                        .fill(Color(red: 0.1, green: 0.1, blue: 0.1, opacity: 0.8))
                        
                        .position(CGPoint(x: Float(i) / Float(self.pointCount) * geometry.size.width,
                                          y: self.wavetable[i] * geometry.size.height))
                        */
                }
                */
            }
        }
    }
}

struct WavetableDisplay_Previews: PreviewProvider {
    static var previews: some View {
        WavetableDisplay(wavetable: .constant(Array(repeating: 1.0, count: 4000)))
        .previewLayout(.fixed(width: 568, height: 320))
    }
}

class DrawView : UIView {
    
    var table: [Float] = []
    var absmax: Double = 0
    var hasClearBackground = false
    var isHighlightView = false
    
    @objc public init(_ wavetable: [Float], frame: CGRect = CGRect(x: 0, y: 0, width: 440, height: 150)) {
        super.init(frame: frame)
        self.table = wavetable
        //let max = 1.0// Double(table.max() ?? 1.0)
        //let min = -1.0// Double(table.min() ?? -1.0)
        absmax = 1.0// [max, abs(min)].max() ?? 1.0
    }
    
    @objc public init(_ wavetable: [Float], hasClearBackground: Bool, frame: CGRect = CGRect(x: 0, y: 0, width: 440, height: 150)) {
        super.init(frame: frame)
        self.hasClearBackground = hasClearBackground
        self.table = wavetable
        //let max = Double(table.max() ?? 1.0)
        //let min = Double(table.min() ?? -1.0)
        //absmax = [max, abs(min)].max() ?? 1.0
        absmax = 1.0
    }
    
    @objc public init(_ wavetable: [Float], hasClearBackground: Bool, isHighlightView: Bool, frame: CGRect = CGRect(x: 0, y: 0, width: 440, height: 150)) {
        super.init(frame: frame)
        self.hasClearBackground = hasClearBackground
        self.isHighlightView = isHighlightView
        self.table = wavetable
        //let max = Double(table.max() ?? 1.0)
        //let min = Double(table.min() ?? -1.0)
        //absmax = [max, abs(min)].max() ?? 1.0
        absmax = 1.0
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Draw the table view
    public override func draw(_ rect: CGRect) {

        let width = Double(frame.width)
        let height = Double(frame.height) / 2.0
        let padding = 0.9
        
        
        //darkGray = Color.init(red: 0.2, green: 0.2, blue: 0.2)
        
        let border = UIBezierPath(rect: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        
        if(!hasClearBackground){
            let bgcolor = UIColor(red:0.2, green:0.2, blue:0.2, alpha: 1.0) //UIColor.white//AKStylist.sharedInstance.nextColor
            bgcolor.setFill()
            border.fill()
            UIColor.black.setStroke()
            border.lineWidth =  CGFloat(width * 0.015) //8
            border.stroke()
            UIColor.white.setStroke()
            UIColor(red:0.05, green:1.0, blue:0.3, alpha:0.7).setFill()
            
        }
        else{
            if(!isHighlightView){
                UIColor(red:1.0, green:1.0, blue:1.0, alpha:0.5).setStroke()
                UIColor(red:0.05, green:1.0, blue:0.3, alpha:0.025).setFill()
            }
            else{
                
                //neon yellow
                UIColor(red:0.98, green:0.93, blue:0.15, alpha:1.0).setStroke()
                UIColor(red:0.98, green:0.93, blue:0.15, alpha:0.4).setFill()
                
                //UIColor(red:0.4, green:0.1, blue:0.7, alpha:1.0).setStroke()
                //UIColor(red:0.4, green:0.1, blue:0.7, alpha:0.4).setFill()
                
                //UIColor.init(red: 0.4, green: 0.1, blue: 0.7, alpha: 1.0)
            }
        }

        let bezierPath = UIBezierPath()
        if(!hasClearBackground){
            bezierPath.lineWidth = CGFloat(width * 0.01)
        }
        else{
            bezierPath.lineWidth = CGFloat(width * 0.005)
        }

        bezierPath.move(to: CGPoint(x: 0, y: frame.height / 2))
        bezierPath.addLine(to: CGPoint(x: 0.0, y: (1.0 - table[0] / absmax * padding) * height))
            
        //for index in 1..<table.count {
        for index in stride(from: 1, to: table.count, by: 100){

            let xPoint = Double(index) / table.count * width

            let yPoint = (1.0 - table[index] / absmax * padding) * height

            bezierPath.addLine(to: CGPoint(x: xPoint, y: yPoint))
        }

        bezierPath.addLine(to: CGPoint(x: Double(frame.width), y: (1.0 - table[table.count-1] / absmax * padding) * height))

        bezierPath.addLine(to: CGPoint(x: frame.width, y: frame.height / 2))
        bezierPath.stroke()
        UIColor.clear.setStroke()
        bezierPath.addLine(to: CGPoint(x: 0, y: frame.height / 2))
        bezierPath.stroke()
        bezierPath.fill()
        
        
    }
}


struct WavetableView: UIViewRepresentable {
    typealias UIViewType = DrawView
    //@State var thisView : DrawView// = DrawView()
    
    
    //@State var keyboardView : AKKeyboardView = AKKeyboardView()
    //@State var firstOctave = 1
    
    //@ObservedObject var noise: NoiseModel
    //@Binding var octave: Int
    
    //@EnvironmentObject var noise: NoiseModel
    
    //@Binding var midiNoteKeyboardChange : MIDINoteKeyboardChange
    //@Binding var midiExternalNotesOn: [MIDINoteNumber]
    //@State var notesCurrentlyOn: [MIDINoteNumber] = []
    
    //@Binding var midiExternalNotesOff: [MIDINoteNumber]
    
    @Binding var wavetable: [Float]
    //var path = UIBezierPath()

    func makeUIView(context: UIViewRepresentableContext<WavetableView>) -> DrawView {
        let myView = DrawView(wavetable)
        
        //view.delegate = noise
        
        //let max = Double(table.max() ?? 1.0)
        //let min = Double(table.min() ?? -1.0)
        //absmax = [max, abs(min)].max() ?? 1.0
        
        // Without this, the keyboard does not respect the frame
        myView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        myView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        /*
        let width = Double(thisView.frame.width)
        let height = Double(thisView.frame.height) / 2.0
        
        path.move(to: CGPoint(x: Double(frame.width), y: (1.0 - (1 + wavetable[0] / 2) * height))
        
        for index in 1..<wavetable.count {

            let xPoint = Double(index) / wavetable.count * width

            let yPoint = 1.0 - (1 + wavetable[0] / 2) * height)

            path.addLine(to: CGPoint(x: xPoint, y: yPoint))
        }
        
        path.addLine(to: CGPoint(x: Double(frame.width), y: (1.0 - (1 + wavetable[0] / 2) * height))

        UIColor.black.setStroke()
        path.lineWidth = 2
        path.stroke()
        */
        
        return myView
    }

    func updateUIView(_ uiView: DrawView, context: UIViewRepresentableContext<WavetableView>) {
        uiView.frame = CGRect(x:0, y:0, width: uiView.intrinsicContentSize.width, height: uiView.intrinsicContentSize.height)
        uiView.sizeToFit()
        
        uiView.table = wavetable
        
        uiView.setNeedsDisplay()
        
        //uiView.firstOctave = firstOctave
        
        /*
        if(midiNoteKeyboardChange.isOn){
            uiView.programmaticNoteOn(midiNoteKeyboardChange.note)
        }else{
            uiView.programmaticNoteOff(midiNoteKeyboardChange.note)
        }
        */
        
        /*
        let newNotes = midiExternalNotesOn.filter {
            !notesCurrentlyOn.contains($0)
        }
        
        let cutNotes = notesCurrentlyOn.filter {
            !midiExternalNotesOn.contains($0)
        }
        
        newNotes.forEach { note in
            uiView.programmaticNoteOn(note)
            //notesCurrentlyOn.append(note)
        }
 
        
        cutNotes.forEach { note in
            uiView.programmaticNoteOff(note)
        }
        */
        
        /*
        midiExternalNotesOff.forEach { note in
            uiView.programmaticNoteOff(note)
            midiExternalNotesOn = midiExternalNotesOn.filter{$0 != note}
            midiExternalNotesOff = midiExternalNotesOff.filter{$0 != note}
        }
        */
        
    }
    
    /*
    class Coordinator: NSObject, AKKeyboardDelegate {
        func noteOn(note: MIDINoteNumber) {
            <#code#>
        }
        
        func noteOff(note: MIDINoteNumber) {
            <#code#>
        }
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    */
    

}
