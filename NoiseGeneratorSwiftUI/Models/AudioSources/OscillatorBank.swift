//
//  OscillatorBank.swift
//  NoiseGeneratorSwiftUI
//
//  Created by Macbook on 7/29/20.
//  Copyright © 2020 Matt Pfeiffer. All rights reserved.
//

import AudioKit
import Combine
import SwiftUI
import Accelerate

/// A container for many morphing voices with FM
public class OscillatorBank: adsrPolyphonicController{
    
    var voices : [OscillatorVoice] = []
    
    var oscillatorMixer = AKMixer()
    
    var displayWaveform : [Float] = []
    
    // actual highlighted wavetable
    //var displayWaveTable : DisplayWaveTable!
    
    /// actualWaveTable
    var actualWaveTable : AKTable!
    
    /// waveforms are the actual root wavetables that are used to calculate our current wavetable
    var waveforms : [AKTable] = []

    
    /*
    FROM:
    https://www.futur3soundz.com/wavetable-synthesis
    The waveform size in samples. It is usually a power-of-two value: 64, 128, 256, 512 ,1024, 2048, etc., yet it can be any value.
    Size does matter: as per the Nyquist theorem, a N-sized waveform can only hold N/2 partials.
    This means that smaller sized waveforms will sound duller than bigger waveforms.
    */
    //var defaultWaves : [AKTable] = [AKTable(.sine, count: 4096), AKTable(.sawtooth, count: 4096)]
    
    let wavetableSize = 2048
    //var defaultWaves : [AKTable] = [AKTable(.sine, count: 2048), AKTable(.sawtooth, count: 2048), AKTable(.square, count: 2048)]
    //var defaultWaves : [AKTable] = [AKTable(.sine, count: 2048),  AKTable(.square, count: 2048)]
    var defaultWaves : [AKTable] = [AKTable(.sine, count: 2048), AKTable(.triangle, count: 2048), AKTable(.square, count: 2048), AKTable(.sawtooth, count: 2048)]
    
    var displayWaveTables : [DisplayWaveTable] = []
    @Published var displayIndex: Int = 0
    
    @Published var is3DView = false
    
    var numberOfWavePositions = 256
    static var isWaveLocked = false
    
    var numberOfWarpPositions = 256
    
    var isSetup = false
    
    //This is handling both the on and the off events
    override func play(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel){
        if(velocity > 0){
            let newVoice = createSpecificVoice(note: note, velocity: velocity, channel: channel)
            newVoice.output.setOutput(to: oscillatorMixer)
            newVoice.play()
            voices.append(newVoice)
        }
        else{
            let killVoices = voices.filter {$0.note == note}
            for killVoice in killVoices{
                killVoice.kill()
            }
            voices = voices.filter {$0.note != note}
        }
    }
    
    override func attackControlChange(){
        for voice in voices{
            voice.source.attackDuration = attack
        }
    }
     override func decayControlChange(){
         for voice in voices{
             voice.source.decayDuration = decay
         }
     }
     override func sustainControlChange(){
         for voice in voices{
             voice.source.sustainLevel = sustain
         }
     }
     override func releaseControlChange(){
         for voice in voices{
             voice.source.releaseDuration = release
         }
     }
    
    func handlePitchBend(pitchWheelValue: MIDIWord, channel: MIDIChannel){
        for voice in voices{
            if(voice.channel.hex == channel.hex){
                //print("same channel")
                voice.pitchBend = pitchWheelValue
            }
        }
    }
    
    /* Determines which KnobCompleteModel sent the change and forwards the update to the appropriate parameter */
    override func modulationValueWasChanged(_ sender: KnobCompleteModel) {
        checkCustomControls(sender)
        checkControlsADSR(sender)
    }
    
    func checkCustomControls(_ sender: KnobCompleteModel){
        if(sender === waveformIndexControl){
            setWaveformIndexControl()
        }
        else if(sender === warpIndexControl){
            setWarpIndexControl()
        }
    }
    
    var wavePosition: Int = 0{
        didSet{
            calculateActualWaveTable()
        }
    }
    
    @Published var waveformIndexControl = KnobCompleteModel(){
        didSet{
            setWaveformIndexControl()
        }
    }
    
    @Published var warpIndexControl = KnobCompleteModel(){
        didSet{
            setWarpIndexControl()
        }
    }
    
    override init(){
        super.init(toggle: oscillatorMixer, node: oscillatorMixer)
        
        calculateAllWaveTables()
        calculateActualWaveTable()
        
        //actualWaveTable = calculateActualWaveTable(waveTable: waveforms[wavePosition])
        
        isSetup = true
        
        displayOnImage = Image(systemName: "o.circle.fill")
        displayOffImage = Image(systemName: "o.circle")
        setDisplayImage()
        
        waveformIndexControl.name = "Waveform"
        waveformIndexControl.handoffDelegate = self
        setWaveformIndexControl()
        
        warpIndexControl.name = "Warp Index"
        warpIndexControl.handoffDelegate = self
        //warpIndexControl.range = 1.0
        setWarpIndexControl()

        selectedBlockDisplay = SelectedBlockDisplay.controls
        name = "OSC 1"
        
        // These oscillators are loud by default
        volumeMixer.volumeControl = 0.5

    }
    
    func createSpecificVoice(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) -> OscillatorVoice{
        let newVoice = OscillatorVoice(note: note,
                                         velocity: velocity,
                                         channel: channel,
                                         waveform: actualWaveTable,
                                         attackDuration: attack,
                                         decayDuration: decay,
                                         sustainLevel: sustain,
                                         releaseDuration: release)
        return newVoice
    }
    
    
    /// sets the new wavePosition, which when set will calculate the actual WaveTable and displayWaveform
    func setWaveformIndexControl(){
        
        // Get Integer position of the waveform (root wavetable)
        // This will call our wavePosition didSet which will calculate the actualWaveTable and displayWaveform
        wavePosition = Int(waveformIndexControl.realModValue * waveformIndexControl.range * (numberOfWavePositions-1) )
        
        // Get a String value of the integer for display
        waveformIndexControl.display = String(wavePosition)
    }
    
    var warpIndex: Int = 0{
        didSet{
            
            if(!OscillatorBank.isWaveLocked){
                calculateActualWaveTable()
            }
            
            //TODO: we need a "catch up" swap
            
            /*
            for voice in voices{
                voice.source.modulationIndex = modulationIndex
            }
            */
        }
    }
    
    func setWarpIndexControl(){
        
        //warpIndex = Int(warpIndexControl.realModValue * warpIndexControl.range)
        
        warpIndex = Int(warpIndexControl.realModValue * warpIndexControl.range * (numberOfWarpPositions-1) )
        
        waveformIndexControl.display = String(warpIndex)
    }
    
    func switchWaveForms(newWaveforms: [AKTable]){
        //waveforms = newWaveforms
        defaultWaves = newWaveforms
        calculateAllWaveTables()
        calculateActualWaveTable()
    }
    
    /// This is called whenever we have an waveTable index or warp change to create a new waveTable
    func calculateActualWaveTable() {

        // get [Float] from our root table
        /*
        let rootFloats : [Float] = [Float](waveforms[wavePosition].content) //table
        
        // mirror warp
        var newFloats : [Float] = []
        for index in 1...rootFloats.count {
            
            if(warpIndex > index / rootFloats.count ){
                //mirror it
                newFloats.append(rootFloats[rootFloats.count - index])
            }
            else{
                //get regular value
                newFloats.append(rootFloats[index - 1])
            }
        }
        */
        
        // set the actualWaveTable to the new floating point values
        //actualWaveTable = mirrorWarp(rootFloats: [Float](waveforms[wavePosition].content))
        //actualWaveTable = syncWarp(rootFloats: [Float](waveforms[wavePosition].content))
        actualWaveTable = pwmWarp(rootFloats: [Float](waveforms[wavePosition].content))
        
        
        // apply waveTable to our voices
        for voice in voices{
            //voice.setWaveTable(table: actualWaveTable)//waveforms[wavePosition])
            voice.switchWaveTable(table: actualWaveTable)
        }
        
        // calculate the new displayed wavetable
        displayWaveform = [Float](actualWaveTable.content)
        
    }

    /// returns a mirror warped waveTable created from the input floating point numbers and the modulationIndex
    func mirrorWarp(rootFloats: [Float]) -> AKTable{
        
        let warpPosition = Int(Double(warpIndex) / (numberOfWarpPositions - 1) * rootFloats.count)
        
        //mirrored values
        var newFloats = vDSP.multiply(-1.0, rootFloats[0..<warpPosition])
        
        // regular values
        newFloats += rootFloats[warpPosition..<rootFloats.count]
        
        return AKTable(newFloats)
    }
    
    /// returns a mirror warped waveTable created from the input floating point numbers and the modulationIndex
    func pwmWarp(rootFloats: [Float]) -> AKTable{
        
        var newFloats : [Float] = rootFloats
        let warpPercent = Double(warpIndex) / Double(numberOfWarpPositions - 1) // 0.0 to 1.0
        var sampled = [Float](repeating: 0.0,count: newFloats.count)
        
        if(warpPercent != 1.0){
            let addAmount = Int(newFloats.count / (1.0 - warpPercent) - newFloats.count)
            newFloats += [Float](repeating: ( (-1) * rootFloats[wavetableSize-1] ),count: addAmount)
            sampled = resample(array: newFloats, toSize: wavetableSize)
        }
        
        return AKTable(sampled)
    }
    
    /// returns a mirror warped waveTable created from the input floating point numbers and the modulationIndex
    func syncWarp(rootFloats: [Float]) -> AKTable{
        
        var newFloats : [Float] = rootFloats
        let percentageIncrease = 15.0 * pow(Double(warpIndex) / (numberOfWarpPositions - 1), 3) + 1.0
        let newLength : Int = Int(rootFloats.count * percentageIncrease)
        
        while (newLength - newFloats.count) > rootFloats.count{
           newFloats += rootFloats
        }
        
        let lastIndex = newLength - newFloats.count - 1
        
        if(lastIndex >= 0){
            newFloats += rootFloats[0..<lastIndex]
        }

        let sampled = resample(array: newFloats, toSize: wavetableSize)
        
        return AKTable(sampled)

    }
    
    /// returns a mirror warped waveTable created from the input floating point numbers and the modulationIndex
    /*
    func bendPlus(rootFloats: [Float]) -> AKTable{
        
        var newFloats : [Float] = rootFloats
        let percentageIncrease = 15.0 * pow(Double(warpIndex) / (numberOfWarpPositions - 1), 3) + 1.0
        let newLength : Int = Int(rootFloats.count * percentageIncrease)
        
        while (newLength - newFloats.count) > rootFloats.count{
           newFloats += rootFloats
        }
        
        let lastIndex = newLength - newFloats.count - 1
        
        if(lastIndex >= 0){
            newFloats += rootFloats[0..<lastIndex]
        }

        let sampled = resample(array: newFloats, toSize: wavetableSize)
        
        return AKTable(sampled)

    }*/
    
    func resample<T>(array: [T], toSize newSize: Int) -> [T] {
        let size = array.count
        return (0 ..< newSize).map { array[$0 * size / newSize] }
    }
    

    func calculateAllWaveTables(){
        
        /*
        // Get the floating point's [Element] that makes a AKTable
        let table = waveforms[0].content
        
        // it can be converted from [Element] to [Float]
        let floats : [Float] = table
        
        // Creates a wavetable from [Float]
        let newTable = AKTable(floats)
        
        waveforms[1] = newTable
         defaultWaves
         */
        
        // 85 = 256 / 3
        let rangeValue = (Double(numberOfWavePositions) / Double(defaultWaves.count - 1)).rounded(.up)
        
        
        displayWaveTables = []
        waveforms = []
        
        let thresholdForExact = 0.01 * defaultWaves.count
        
        // 1 -> 256 (256 total)
        for i in 1...numberOfWavePositions{
            
            // this lets us grab the appropriate wavetables in an arbitrary array of tables
            
            // 0 = Int(37 / 85)
            // 1 = Int(90 / 85)
            // 2 = Int(170 / 85)
            let waveformIndex = Int( (i-1) / rangeValue) // % defaultWaves.count
            
            // 0.4118 = 35 / 85 % 1.0
            // 0.5882 = 135 / 85 % 1.0
            var interpolatedIndex = (Double(i-1) / rangeValue).truncatingRemainder(dividingBy: 1.0)
            
            if((1.0 - interpolatedIndex) < thresholdForExact){
                //interpolatedIndex = 1.0
                let tableElements = DisplayWaveTable([Float](defaultWaves[waveformIndex+1]))
                displayWaveTables.append(tableElements)
                waveforms.append( AKTable(tableElements.waveform) )
            }
            else if(interpolatedIndex < thresholdForExact){
                //interpolatedIndex = 0.0
                let tableElements = DisplayWaveTable([Float](defaultWaves[waveformIndex]))
                displayWaveTables.append(tableElements)
                waveforms.append( AKTable(tableElements.waveform) )
            }
            else{
                // calculate float values
                let tableElements = DisplayWaveTable([Float](vDSP.linearInterpolate([Float](defaultWaves[waveformIndex]),
                                                                            [Float](defaultWaves[waveformIndex+1]),
                                                                            using: Float(interpolatedIndex) ) ) )
                displayWaveTables.append(tableElements)
                waveforms.append( AKTable(tableElements.waveform) )
            }
        }
    }
}

/// An audio sources containing a sound source with individual pitch control.
public class OscillatorVoice{
    
    var output = AKMixer()
    
    var source : AKOscillatorBank
    var sourceMixer = AKMixer()
    var switchSource : AKOscillatorBank
    var switchSourceMixer = AKMixer()
    var isSwitched = true
    
    var frequency : Double = 100
    
    var pitchBendRange: UInt16 = 24

    var pitchBend: UInt16 = 16_384 / 2{
        didSet{
            frequency = getFrequencyFromNoteAndPitchBend(note: note, pitchBend: pitchBend)
        }
    }
    
    var channel: MIDIChannel
    var note: MIDINoteNumber
    var velocity: MIDIVelocity
    
    init(){
        fatalError("Voice Object should never be created this way")
    }
    
    init(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel, sourceNode: AKOscillatorBank, waveform: AKTable){
        self.note = note
        self.channel = channel
        self.source = sourceNode
        self.switchSource = sourceNode
        self.velocity = velocity
        source.waveform = waveform
    }
    
    init(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel, waveform: AKTable, attackDuration: Double, decayDuration: Double, sustainLevel: Double, releaseDuration: Double){
        self.note = note
        self.channel = channel
        self.source = AKOscillatorBank(waveform: waveform,
                                         attackDuration: attackDuration,
                                         decayDuration: decayDuration,
                                         sustainLevel: sustainLevel,
                                         releaseDuration: releaseDuration,
                                         pitchBend: 0.0,
                                         vibratoDepth: 0.0,
                                         vibratoRate: 1.0)
        
        self.switchSource = AKOscillatorBank(waveform: waveform,
                                                attackDuration: attackDuration,
                                                decayDuration: decayDuration,
                                                sustainLevel: sustainLevel,
                                                releaseDuration: releaseDuration,
                                                pitchBend: 0.0,
                                                vibratoDepth: 0.0,
                                                vibratoRate: 1.0)
    
        source.setOutput(to: sourceMixer)
        sourceMixer.setOutput(to: output)
        switchSource.setOutput(to: switchSourceMixer)
        switchSourceMixer.setOutput(to: output)
        switchSourceMixer.volume = 0.0
        
        self.velocity = velocity
        
        source.rampDuration = 0.0
        switchSource.rampDuration = 0.0
    }
    
    func setADSR(attackDuration: Double, decayDuration: Double, sustainLevel: Double, releaseDuration: Double){
        source.attackDuration = attackDuration
        source.decayDuration = releaseDuration
        source.sustainLevel = sustainLevel
        source.releaseDuration = releaseDuration
    }
    
    func kill(){
        source.stop(noteNumber: note)
        switchSource.stop(noteNumber: note)

        let queue = DispatchQueue(label: "source-killer-queue")
        
        queue.asyncAfter(deadline: .now() + source.attackDuration + source.decayDuration + source.releaseDuration * 5.0) {
            self.source.detach()
            self.sourceMixer.detach()
            self.switchSource.detach()
            self.switchSourceMixer.detach()
            self.output.detach()
        }
    }
    
    
    @objc func killFM(){
        self.source.detach()
        self.switchSource.detach()
        self.sourceMixer.detach()
        self.switchSourceMixer.detach()
        self.output.detach()
    }
    
    func setOscillatorFrequency(){
        frequency = getFrequencyFromNoteAndPitchBend(note: note, pitchBend: pitchBend)
    }
    
    func getFrequencyFromNoteAndPitchBend(note: MIDINoteNumber, pitchBend: UInt16) -> Double {
        return 440.0 * pow(2.0, (((Double(note) - 69.0) / 12.0)
            + Double(pitchBendRange) * (Double(pitchBend) - 8192.0) / (4096.0 * 12.0)))
    }
    
    deinit{
        print("killed the voice")
    }
    
    func setWaveTable(table: AKTable){
        source.waveform = table
    }
    
    func switchWaveTable(table: AKTable){
        if(!OscillatorBank.isWaveLocked){
            OscillatorBank.isWaveLocked = true
            if(isSwitched){
                source.waveform = table
            }
            else{
                switchSource.waveform = table
            }
            fadeSwitch()
        }
    }
    
    func fadeSwitch(){
        
        //trigger switching
        let timer = RepeatingTimer(timeInterval: 0.0003)

        
        timer.eventHandler = {
            if(self.isSwitched){
                self.sourceMixer.volume = self.sourceMixer.volume + 0.01
                self.switchSourceMixer.volume = self.switchSourceMixer.volume - 0.01
                
                if self.sourceMixer.volume >= 1.0 {
                    self.isSwitched = false
                    OscillatorBank.isWaveLocked = false
                    timer.cancel()
                }
            }
            else{
                self.switchSourceMixer.volume = self.switchSourceMixer.volume + 0.01
                self.sourceMixer.volume = self.sourceMixer.volume - 0.01

                if self.switchSourceMixer.volume >= 1.0 {
                    self.isSwitched = true
                    OscillatorBank.isWaveLocked = false
                    timer.cancel()
                }
            }
        }
        timer.resume()
    }
    
    func play(){
        source.play(noteNumber: note, velocity: velocity, channel: channel)
        switchSource.play(noteNumber: note, velocity: velocity, channel: channel)
    }
}
