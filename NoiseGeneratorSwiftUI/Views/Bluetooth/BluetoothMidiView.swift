//
//  BluetoothMidiView.swift
//  NoiseGeneratorSwiftUI
//
//  Created by Macbook on 5/14/20.
//  Copyright © 2020 Matt Pfeiffer. All rights reserved.
//

import SwiftUI
import CoreAudioKit

struct BluetoothMidiView: View {
    
    @EnvironmentObject var noise: Conductor
    
    var body: some View {
        GeometryReader{ geometry in
            VStack(spacing: 0){
                HStack(spacing: 0){
                    Spacer()
                    Button(action: {
                        self.noise.selectedScreen = .main
                    }){
                            Text("Done")
                                .foregroundColor(.black)
                                .padding(.trailing, geometry.size.width * 0.05)
                    }
                    
                }
                .frame(width:geometry.size.width,
                       height: geometry.size.height * 0.1)
                .background(Color.lightGray)
                
                BluetoothMIDIPopup()
                    .frame(height: geometry.size.height * 0.9)
            }
        }
    }
}

struct BluetoothMidiView_Previews: PreviewProvider {
    static var previews: some View {
        BluetoothMidiView()
    }
}

struct BluetoothMIDIPopup: UIViewControllerRepresentable {
    typealias UIViewControllerType = AKBTMIDICentralViewController
    
    func makeUIViewController(context: Context) -> AKBTMIDICentralViewController {
        let view = AKBTMIDICentralViewController()
        return view
    }
    
    func updateUIViewController(_ uiViewController: AKBTMIDICentralViewController, context: Context) {
    }
}

class AKBTMIDICentralViewController: CABTMIDICentralViewController {
    var uiViewController: UIViewController?

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                            target: self,
                                                            action: #selector(doneAction))
    }

    @objc public func doneAction() {
        uiViewController?.dismiss(animated: true, completion: nil)
    }
}
