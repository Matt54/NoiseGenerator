//
//  Conductor+MidiListener.swift
//  NoiseGeneratorSwiftUI
//
//  Created by Macbook on 5/28/20.
//  Copyright © 2020 Matt Pfeiffer. All rights reserved.
//

import Foundation
import AudioKit
import AudioKitUI


extension Conductor: AKMIDIListener {
    
    func setupMidi(){
        midi.createVirtualInputPort(98909, name: "AKMidiReceiver")
        midi.createVirtualOutputPort(97789, name: "AKMidiReceiver")
        midi.openInput()
        midi.openOutput()
        midi.addListener(self)
    }
    
    func playNote(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        numberOfNotesOn = numberOfNotesOn + 1
        handleMidiNote(note: note, velocity: velocity, channel: channel)
        
        if(!isModulationTriggered){
            isModulationTriggered = true
        }
        if(isMIDISustained){
            
        }
        
        checkForDeadModulation()
    }

    func stopNote(note: MIDINoteNumber, channel: MIDIChannel) {
        if(!isMIDISustained){
            numberOfNotesOn = numberOfNotesOn - 1
            handleMidiNote(note: note, velocity: 0, channel: channel)
            
            if(numberOfNotesOn == 0){
                isModulationTriggered = false
            }
        }
        else{
            midiSustainedNotes.append(ActiveMIDINotes(note: note, channel: channel))
        }
    }
    
    func releaseNotes(){
        isMIDISustained = false
        for midiSustainedNote in midiSustainedNotes{
            stopNote(note: midiSustainedNote.note, channel: midiSustainedNote.channel)
        }
    }
    
    func handleMidiNote(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel){
        
        for source in adsrPolyphonicControllers{
            source.play(note: note, velocity: velocity, channel: channel)
        }
        
        /*
        for oscillator in oscillatorControlSources{
            oscillator.play(note: note, velocity: velocity, channel: channel)
        }
        
        for piano in pianoControlSources{
            piano.play(note: note, velocity: velocity, channel: channel)
        }
        */
        
        // This simply prevents noise off when there are still notes on
        if( (velocity > 0)  || (numberOfNotesOn == 0) ){
            for noiseGenerator in noiseControlSources{
                noiseGenerator.play(note: note, velocity: velocity, channel: channel)
            }
        }
        
    }
    
    func handlePitchBend(pitchWheelValue: MIDIWord, channel: MIDIChannel){
        print("handlePitch in Noise")
        for oscillator in oscillatorControlSources{
            print("inside the for loop")
            oscillator.handlePitchBend(pitchWheelValue: pitchWheelValue, channel: channel)
        }
    }
    
    enum MidiEventType: String {
        case
            noteNumber          = "Note Number",
            continuousControl   = "Continuous Control",
            programChange       = "Program Change"
    }
    
    
    public class ActiveMIDINotes{
        var note: MIDINoteNumber
        var channel: MIDIChannel
        init(note: MIDINoteNumber, channel: MIDIChannel){
            self.note = note
            self.channel = channel
        }
    }

    // Note On Number + Velocity + MIDI Channel
    func receivedMIDINoteOn(noteNumber: MIDINoteNumber,
                            velocity: MIDIVelocity,
                            channel: MIDIChannel,
                            portID: MIDIUniqueID? = nil,
                            offset: MIDITimeStamp = 0) {
        
        /*
        print("")
        print("Got Note On!")
        print("Note Number: " + String(noteNumber))
        print("Velocity: " + String(velocity))
        print("channel: " + String(channel))
        */
        
        //midiTypeReceived = .noteNumber
        /*
        let outputMIDIMessage = "\(midiTypeReceived.rawValue)\nChannel: \(channel+1)  noteOn: \(noteNumber)  velocity: \(velocity)"
        print(outputMIDIMessage)
        */
        //midiSignalReceived = true
        playNote(note: noteNumber, velocity: velocity, channel: channel)
        
        DispatchQueue.main.async {
            self.keyboardViewController.keyboardView.programmaticNoteOn(noteNumber)
        }
    }

    // Note Off Number + Velocity + MIDI Channel
    func receivedMIDINoteOff(noteNumber: MIDINoteNumber,
                             velocity: MIDIVelocity,
                             channel: MIDIChannel,
                             portID: MIDIUniqueID? = nil,
                             offset: MIDITimeStamp = 0) {
        
        /*
        print("")
        print("Got Note Off!")
        print("Note Number: " + String(noteNumber))
        print("Velocity: " + String(velocity))
        print("channel: " + String(channel))
        */
        
        //midiTypeReceived = .noteNumber
        //midiSignalReceived = false
        
        stopNote(note: noteNumber, channel: channel)
        DispatchQueue.main.async {
            self.keyboardViewController.keyboardView.programmaticNoteOff(noteNumber)
        }
    }

    // Controller Number + Value + MIDI Channel
    func receivedMIDIController(_ controller: MIDIByte, value: MIDIByte, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp) {
        
        /*
        print("")
        print("Got CC!")
        print("Controller: " + String(controller))
        print("Value: " + String(value))
        print("channel: " + String(channel))
        */
        
        //midiTypeReceived = .continuousControl
        //midiSignalReceived = true
        
        if(specialSelection == .midiLearn){
            
            guard let selectedKnob = selectedKnob else {
              return
            }
            
            var knobPreviouslyMapped = false
            
            // Check if this knob is already assigned to anything
            for midiLearnMapping in midiLearnMappings{
                if(selectedKnob === midiLearnMapping.control){
                    knobPreviouslyMapped = true
                    midiLearnMapping.ccNumber = controller
                    midiLearnMapping.channel = channel
                    break
                }
            }
            
            if(!knobPreviouslyMapped){
                let newMapping = MIDILearnMapping(control: selectedKnob, ccNumber: controller, channel: channel)
                selectedKnob.midiAssignment = String(newMapping.ccNumber)
                midiLearnMappings.append(newMapping)
            }
            
        }
        else{
            
            //catch the defined midi notes
            if(controller == MIDISupportedBytes.damperOnOff.rawValue){
                if(value > 63){
                    isMIDISustained = true
                }
                else{
                    releaseNotes()
                }
            }
            
            // adjust anything assigned to that cc number
            for midiLearnMapping in midiLearnMappings{
                if(midiLearnMapping.ccNumber == controller){
                    midiLearnMapping.control.handfreeKnobRotate(Double(value) * (1.0 / 127.0))
                }
            }
        }
        
        
    }
    
    func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIWord, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp){
         /*
         pitchWheelValue: MIDI Pitch Wheel Value (0-16383) [0 = max down, 8_192 = no bend, 16_383 = max up]
         channel: MIDI Channel (1-16)
         portID: MIDI Unique Port ID
         offset: the offset in samples that this event occurs in the buffer
         */
        
        /*
        print("")
        print("Got Pitch Wheel!")
        print("Pitch Wheel Value: " + String(pitchWheelValue))
        print("channel: " + String(channel))
        */
        
        handlePitchBend(pitchWheelValue: pitchWheelValue, channel: channel)
    }
    
    func receivedMIDISystemCommand(_ data: [MIDIByte], portID: MIDIUniqueID?, offset: MIDITimeStamp){
        /*
         Receive a MIDI system command (such as clock, sysex, etc)
         data: Array of integers
         portID: MIDI Unique Port ID
         offset: the offset in samples that this event occurs in the buffer
         */
        
        print("")
        print("Got System Command!")
        for byte in data{
            print("Byte: " + String(byte))
        }
    }

    // Program Change Number + MIDI Channel
    func receivedMIDIProgramChange(_ program: MIDIByte, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp) {
        
        print("")
        print("Got Program Change!")
        print("Program: " + String(program))
        print("channel: " + String(channel))
        
        //midiTypeReceived = .programChange
        //midiSignalReceived = true
    }

    func receivedMIDISetupChange() {
        print("midi setup change")
        print("midi.inputNames: \(midi.inputNames)")

        let listInputNames = midi.inputNames

        for inputNames in listInputNames {
            print("inputNames: \(inputNames)")
            midi.openInput(name: inputNames)
        }
    }
    
}

// Keyboard protocol conformance
extension Conductor: AKKeyboardDelegate {
    
    func noteOn(note: MIDINoteNumber) {
        playNote(note: note, velocity: 127, channel: MIDIChannel())
    }
      
    func noteOff(note: MIDINoteNumber) {
        stopNote(note: note, channel: MIDIChannel())
    }
    
}

public enum MIDISupportedBytes: MIDIByte{
    case modulationWheel = 1
    case damperOnOff = 64
}

public class MIDILearnMapping{
    var control: KnobCompleteModel
    var ccNumber: MIDIByte
    var channel: MIDIChannel
    init(control: KnobCompleteModel, ccNumber: MIDIByte, channel: MIDIChannel){
        self.control = control
        self.ccNumber = ccNumber
        self.channel = channel
    }
}
