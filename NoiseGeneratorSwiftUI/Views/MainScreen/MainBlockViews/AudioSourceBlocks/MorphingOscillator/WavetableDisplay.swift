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
    //@State var pointCount: Int = 1
    var resolutionFactor: Int = 40
    
    var body: some View {
        GeometryReader
        { geometry in
            ZStack{
                Color.darkGray
                    //.onAppear{self.pointCount = self.wavetable.count}
                
                ZStack{
                    WavetableView(wavetable: self.$wavetable)
                }
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
        absmax = 1.0
    }
    
    @objc public init(_ wavetable: [Float], hasClearBackground: Bool, frame: CGRect = CGRect(x: 0, y: 0, width: 440, height: 150)) {
        super.init(frame: frame)
        self.hasClearBackground = hasClearBackground
        self.table = wavetable
        absmax = 1.0
    }
    
    @objc public init(_ wavetable: [Float], hasClearBackground: Bool, isHighlightView: Bool, frame: CGRect = CGRect(x: 0, y: 0, width: 440, height: 150)) {
        super.init(frame: frame)
        self.hasClearBackground = hasClearBackground
        self.isHighlightView = isHighlightView
        self.table = wavetable
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
        
        let border = UIBezierPath(rect: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        
        if(!hasClearBackground){
            let bgcolor = UIColor(red:0.2, green:0.2, blue:0.2, alpha: 1.0) //UIColor.white//AKStylist.sharedInstance.nextColor
            bgcolor.setFill()
            border.fill()
            UIColor.black.setStroke()
            //border.lineWidth =  CGFloat(width * 0.015) //8
            //border.stroke()
            UIColor.white.setStroke()
            UIColor(red:0.05, green:1.0, blue:0.3, alpha:0.7).setFill()
            
        }
        else{
            if(!isHighlightView){
                UIColor(red:1.0, green:1.0, blue:1.0, alpha:0.2).setStroke()
                UIColor(red:0.05, green:1.0, blue:0.3, alpha:0.005).setFill()
            }
            else{
                
                //neon yellow
                UIColor(red:0.98, green:0.93, blue:0.15, alpha:1.0).setStroke()
                UIColor(red:0.98, green:0.93, blue:0.15, alpha:0.8).setFill()
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
        for index in stride(from: 1, to: table.count, by: table.count / 256){

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
    
    @Binding var wavetable: [Float]

    func makeUIView(context: UIViewRepresentableContext<WavetableView>) -> DrawView {
        let myView = DrawView(wavetable)
        
        // Without this, the view does not respect the frame
        myView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        myView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        return myView
    }

    func updateUIView(_ uiView: DrawView, context: UIViewRepresentableContext<WavetableView>) {
        uiView.frame = CGRect(x:0, y:0, width: uiView.intrinsicContentSize.width, height: uiView.intrinsicContentSize.height)
        uiView.sizeToFit()
        
        uiView.table = wavetable
        
        uiView.setNeedsDisplay()
        
    }
}
