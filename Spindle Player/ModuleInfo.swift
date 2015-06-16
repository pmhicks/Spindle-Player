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


class ModuleInfo {
    let url:NSURL
    
    let comment:String
    let volumeBase:Int
    let sequenceCount:Int
    let md5:String
    
    var name:String    //use var to set from filname if unset
    let format:String
    
    var simpleFormat:String
    
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
    
    
    init(url:NSURL, info:xmp_module_info) {
        self.url = url
        
        self.comment = String.fromCString(info.comment) ?? ""
        self.volumeBase = Int(info.vol_base)
        self.sequenceCount = Int(info.num_sequences)
        self.md5 = md5UInt8ToString(info.md5)
        
        var mod = info.mod.memory
        
        //println(mod.name)
        self.name = int8TupleToString(mod.name)
        self.format = int8TupleToString(mod.type)
        self.simpleFormat = ModuleInfo.xmpFormatToSimple(self.format)
        
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
    
    
    static func xmpFormatToSimple(format:String) -> String {
        //MOD
        if format.hasSuffix("M.K.") {
            return "MOD"
        }
        if format.hasSuffix("M!K!") {
            return "MOD"
        }
        if format.hasSuffix("M&K!") {
            return "MOD"
        }
        if format.hasSuffix("N.T.") {
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
        if format.hasSuffix("12CH") {
            return "MOD"
        }
        if format == "Mod's Grave" {
            return "MOD"
        }
        if format.hasSuffix("FLT4") { //Startrekker
            return "MOD"
        }
        if format.hasSuffix("FLT8") { //Startrekker
            return "MOD"
        }
        if format.hasSuffix("FA04") { //Digital Tracker
            return "MOD"
        }
        if format.hasSuffix("FA06") { //Digital Tracker
            return "MOD"
        }
        if format.hasSuffix("FA08") { //Digital Tracker
            return "MOD"
        }
        if format.hasSuffix("CD81") {
            return "MOD"
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

        //MED or OctaMED
        if format.hasPrefix("MED") {
            return "MED"
        }
        if format.hasPrefix("OctaMED") {
            return "MED"
        }
        
        // Composer 669
        if format.hasSuffix("669") {
            return "669"
        }
        
        //MultiTracker
        if format.hasSuffix("MTM") {
            return "MTM"
        }
       
        //Digital Tracker
        if format.hasSuffix("DTM") {
            return "DTM"
        }
        
        //Ultra Tracker
        if format.hasPrefix("Ultra Tracker") {
            return "ULT"
        }
        
        //Poly Tracker
        if format.hasPrefix("Poly Tracker") {
            return "PTM"
        }

        //scream tracker
        if format.hasSuffix("STM") {
            return "STM"
        }
        //scream tracker 3
        if format.hasSuffix("S3M") {
            return "S3M"
        }
        if format == "Scream Tracker 3" {
            return "S3M"
        }

        
        //Liquid Tracker
        if format.hasPrefix("Liquid Tracker") {
            return "LIQ"
        }
        if format.hasPrefix("LiquidTrack") {
            return "LIQ"
        }
        
        //DIGI Booster
        if format.hasPrefix("DIGI Booster") {
            return "DIGI"
        }
        
        //DigiBooster Pro
        if format.hasPrefix("DigiBooster Pro") {
            return "DBM"
        }
        
        //Quadra Composer EMOD
        if format.hasPrefix("Quadra Composer") {
            return "EMOD"
        }
        
        //Oktalyzer
        if format == "Oktalyzer" {
            return "OKT"
        }
        
        //Protracker 3.6+
        if format.rangeOfString("IFFMODL") != nil {
            return "PT36"
        }
        
        // XM
        if format.rangeOfString("XM") != nil {
            return "XM"
        }
        
        //IT
        if format == "Impulse Tracker" {
            return "IT"
        }
        if format.rangeOfString("IT") != nil {
            return "IT"
        }

        
        return ""
    }
}
