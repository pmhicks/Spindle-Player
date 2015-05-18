// Spindle Player
// Copyright (C) 2015 Mike Hicks
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation


struct ModuleInfo {
    let comment:String
    let volumeBase:Int
    let sequenceCount:Int
    let md5:String
    
    let name:String
    let format:String
    
    var simpleFormat:String {
        //has to be a better way than this
        get {
            if format.hasSuffix("M.K.") {  //standard 4-chan
                return "MOD"
            }
            if format.hasSuffix("2CHN") {
                return "MOD"
            }
            if format.hasSuffix("6CHN") {
                return "MOD"
            }
            if format.hasSuffix("8CHN") {
                return "MOD"
            }
            if format.hasSuffix("FLT4") { //Startrekker
                return "MOD"
            }
            if format.hasSuffix("FLT8") { //Startrekker
                return "MOD"
            }
            if format.hasSuffix("CD81") {
                return "MOD"
            }
            if format.hasSuffix("M!K!") {
                return "MOD"
            }
            if format.hasSuffix("669") {
                return "669"
            }
            if format.hasSuffix("MTM") {
                return "MTM"
            }
            if format.hasSuffix("S3M") {  //scream tracker 3
                return "S3M"
            }
            
            if format == "Soundtracker IX" {
                return "MOD"
            }
            if format == "Ultimate Soundtracker" {
                return "MOD"
            }
            
            if format.hasPrefix("D.O.C Soundtracker") {
                return "MOD"
            }
            if format.hasPrefix("OctaMED") {
                return "MED"
            }
            if format.hasPrefix("Ulta Tracker") {
                return "ULT"
            }
            if format.hasPrefix("Poly Tracker") {
                return "PTM"
            }
            
            if format.rangeOfString("PTM") != nil {
                return "PTM"
            }
            if format.rangeOfString("XM") != nil {
                return "XM"
            }
            if format.rangeOfString("IT") != nil {
                return "IT"
            }
            return "  "
        }
    }
    
    let patternCount:Int
    let trackCount:Int
    let channelCount:Int
    let instrumentCount:Int
    let sampleCount:Int
    
    let initialSpeed:Int
    let initialBPM:Int
    let lengthInPatterns:Int
    let restartPosition:Int
    let globalVolume:Int
    
    let instruments:[String]
    let samples:[String]
    
    let duration:Int                //duration of the first sequence in ms
    let durationSeconds:Int
    
    
    init(info:xmp_module_info) {
        self.comment = String.fromCString(info.comment) ?? ""
        self.volumeBase = Int(info.vol_base)
        self.sequenceCount = Int(info.num_sequences)
        self.md5 = md5UInt8ToString(info.md5)
        
        var mod = info.mod.memory
        
        //println(mod.name)
        self.name = int8TupleToString(mod.name)
        self.format = int8TupleToString(mod.type)
        
        self.patternCount = Int(mod.pat)
        self.trackCount = Int(mod.trk)
        self.channelCount =  Int(mod.chn)
        self.instrumentCount =  Int(mod.ins)
        self.sampleCount =  Int(mod.smp)
        self.initialSpeed =  Int(mod.spd)
        self.initialBPM =  Int(mod.bpm)
        self.lengthInPatterns = Int(mod.len)
        self.restartPosition = Int(mod.rst)
        self.globalVolume =  Int(mod.gvl)
        
        let seq = info.seq_data
        self.duration = Int(seq.memory.duration)  //
        self.durationSeconds = self.duration / 1000
        
        if sampleCount > 0 {
            var index = 0
            var sampleArray:[String] = []
            var samplePtr = mod.xxs
            while index < sampleCount {
                let sample = samplePtr.memory
                sampleArray.append(int8TupleToString(sample.name))
                samplePtr = samplePtr.advancedBy(1)
                index++
            }
            self.samples = sampleArray
        } else {
            self.samples = []
        }
        
        if instrumentCount > 0 {
            var iindex = 0
            var instArray:[String] = []
            var instPtr = mod.xxi
            while iindex < instrumentCount {
                let inst = instPtr.memory
                instArray.append(int8TupleToString(inst.name))
                instPtr = instPtr.advancedBy(1)
                iindex++
            }
            self.instruments = instArray
        } else {
            self.instruments = []
        }
    }
}
