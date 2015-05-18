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

import Cocoa

class InfoViewController: NSViewController {
    
    
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var formatLabel: NSTextField!
    @IBOutlet weak var md5Label: NSTextField!
    
    @IBOutlet weak var patternLabel: NSTextField!
    @IBOutlet weak var sampleLabel: NSTextField!
    @IBOutlet weak var speedLabel: NSTextField!
   
    @IBOutlet var comment: NSTextView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do view setup here.
        setLabels()
        
        let center = NSNotificationCenter.defaultCenter()
        center.addObserverForName(SpindleConfig.kSongChanged, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] _ in
            if let s = self {
                s.setLabels()
            }
        }
    }
    
    private func setLabels() {
        if let song = SpindleConfig.sharedInstance.currentSong {
            titleLabel.stringValue = song.name
            formatLabel.stringValue = song.format
            md5Label.stringValue = song.md5
            
            patternLabel.stringValue = "\(song.channelCount) Channels, \(song.patternCount) Patterns"
            sampleLabel.stringValue = "\(song.sampleCount) Samples, \(song.instrumentCount) Instruments"
            speedLabel.stringValue = "Speed: \(song.initialSpeed) BPM: \(song.initialBPM) Global Volume: \(song.globalVolume)"
            comment.string = song.comment
            
        } else {
            titleLabel.stringValue = ""
            formatLabel.stringValue = ""
            md5Label.stringValue = ""
            
            patternLabel.stringValue = ""
            sampleLabel.stringValue = ""
            speedLabel.stringValue = ""
            comment.string = ""
        }
    }
    
}
