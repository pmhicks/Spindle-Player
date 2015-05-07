// Spindle Player
// Copyright (C) 2105 Mike Hicks
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

public class PlayerViewController: NSViewController {
    private static let kShuffleKey = "spindle_player_shuffle"
    private static let kRepeatKey = "spindle_player_repeat"
    
    
    //MARK: Class variables
    var player:MusicPlayer?
    var volume:Float = 1.0
    var infoWindowController:NSWindowController?
    var listWindowController:NSWindowController?
    var repeat = false {
        didSet {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setBool(repeat, forKey: PlayerViewController.kRepeatKey)
            if repeat {
                repeatLabel.stringValue = "Repeat"
            } else {
                repeatLabel.stringValue = ""
            }
        }
    }
    
    var shuffle = false {
        
        didSet {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setBool(shuffle, forKey: PlayerViewController.kShuffleKey)
            if shuffle {
                shuffleLabel.stringValue = "Shuffle"
                let cfg = SpindleConfig.sharedInstance
                cfg.playList.shuffle = true
            } else {
                shuffleLabel.stringValue = "       " //need to fix ui layout
                let cfg = SpindleConfig.sharedInstance
                cfg.playList.shuffle = false
            }
            
        }
    }
    
    
    //MARK: IBOutlets
    @IBOutlet weak var songTime: NSTextField!
    @IBOutlet weak var songTitle: NSTextField!
    @IBOutlet weak var songIndexList: NSTextField!
    @IBOutlet weak var songPatternIndex: NSTextField!
    @IBOutlet weak var songTotalTime: NSTextField!
    @IBOutlet weak var songSoundDetails: NSTextField!
    @IBOutlet weak var songType: NSTextField!
    @IBOutlet weak var shuffleIndicator: NSTextField!
    @IBOutlet weak var positionSlider: NSSliderCell!
    @IBOutlet weak var volumeSlider: NSSlider!
    @IBOutlet weak var repeatLabel: NSTextField!
    @IBOutlet weak var shuffleLabel: NSTextField!
    
    
    //MARK: IBActions
    @IBAction func loadAction(sender: NSButton) {
        let cfg = SpindleConfig.sharedInstance
        
        var openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        openPanel.beginWithCompletionHandler { (result) -> Void in
            if result == NSFileHandlingPanelOKButton {
                if let url = openPanel.URL {
                    self.player = nil
                    self.player = MusicPlayer(volume: self.volume)
                    let status = self.player!.load(url)
                    if status.success {
                        cfg.currentSong = status.module
                        self.songIndexList.stringValue = "Song 0000 of 0000"
                        self.player?.play()
                    } else {
                        let alert = NSAlert()
                        alert.messageText = "Module Load Failed"
                        alert.informativeText = status.error
                        alert.runModal()
                    }
                }
            }
        }
    }
    @IBAction func playAction(sender: NSButton) {
        if let pl = self.player {
            pl.play()
        } else {
            let list = SpindleConfig.sharedInstance.playList
            playAtIndex(list.index)
            
        }
    }
    @IBAction func stopAction(sender: NSButton) {
        self.player?.stop()
    }
    
    @IBAction func pauseAction(sender: NSButton) {
        self.player?.pause()
    }
    @IBAction func nextSongAction(sender: NSButton) {
        self.nextSong()
    }
    @IBAction func previousSongAction(sender: NSButton) {
        self.previousSong()
    }
    @IBAction func fastForwardAction(sender: NSButton) {
        self.player?.nextPosition()
    }
    @IBAction func rewindAction(sender: NSButton) {
        self.player?.previousPosition()
    }
    @IBAction func positionSliderAction(sender: NSSlider) {
        if let song = SpindleConfig.sharedInstance.currentSong {
            let pos = Float(song.durationSeconds) * (sender.floatValue / 100)
            self.player?.seek(Int(pos))
        }
    }
    
    @IBAction func volumeSliderAction(sender: NSSlider) {
        self.volume = sender.floatValue
        self.player?.volume = self.volume
    }
        
   
    @IBAction func infoAction(sender: NSButton) {
        if let  storyboard = NSStoryboard(name: "SongInfo", bundle: nil) {
            if let controller = storyboard.instantiateInitialController() as? NSWindowController {
                infoWindowController = controller
                controller.showWindow(nil)
            }
        }
    }
    
    @IBAction func playListAction(sender: NSButton) {
        if let  storyboard = NSStoryboard(name: "PlayList", bundle: nil) {
            if let controller = storyboard.instantiateInitialController() as? NSWindowController {
                listWindowController = controller
                controller.showWindow(nil)
            }
        }
    }
    
    @IBAction func repeatAction(sender: NSButton) {
        repeat = !repeat
    }
    
    @IBAction func shuffleAction(sender: NSButton) {
        shuffle = !shuffle
    }
    
    
    //MARK: Class functions
    private func setLabels() {
        songTime.stringValue = "00:00"
        positionSlider.integerValue = 0
        
        if repeat {
            repeatLabel.stringValue = "Repeat"
        } else {
            repeatLabel.stringValue = ""
        }
        
        if shuffle {
            shuffleIndicator.stringValue = "Shuffle"
        } else {
            shuffleIndicator.stringValue = "       "

        }
        
        let list = SpindleConfig.sharedInstance.playList
        let index = String(format: "%04d", list.index + 1)
        let count = String(format: "%04d", list.count)
        songIndexList.stringValue = "Song \(index) of \(count)"
        
        if let curr = SpindleConfig.sharedInstance.currentSong {
            songTitle.stringValue = curr.name
            songType.stringValue = "\(curr.channelCount)-Chan \(curr.simpleFormat)"
            //indexlist
            
            let patLen = String(format: "%03d", curr.lengthInPatterns)
            songPatternIndex.stringValue = "001/\(patLen)"
            
            
            let min = String(format: "%02d", curr.duration / 60000)
            let sec = String(format: "%02d", (curr.duration / 1000) % 60)
            songTotalTime.stringValue = "\(min):\(sec)"
            songSoundDetails.stringValue = "44kHz 16-Bit Stereo"
            
        } else {
            songTitle.stringValue = ""
            songType.stringValue = ""
            songPatternIndex.stringValue = "000/000"
            songTotalTime.stringValue = "00:00"
            songSoundDetails.stringValue = "44kHz 16-Bit Stereo"
            
        }
        
    }
    
    func previousSong() {
        let list = SpindleConfig.sharedInstance.playList
        playSong(list.previous)
    }
    
    func nextSong() {
        if repeat && player != nil {
            player?.play()
        } else {
            let list = SpindleConfig.sharedInstance.playList
            playSong(list.next)
        }
    }
    
    private func playAtIndex(index:Int) {
        let list = SpindleConfig.sharedInstance.playList
        playSong(list.getAtIndex(index))
    }
    
    private func playSong(mod:PlayListItem?) {
        if let song = mod {
            let cfg = SpindleConfig.sharedInstance
            self.player = nil
            self.player = MusicPlayer(volume: self.volume)
            let status = self.player!.load(song)
            if status.success {
                cfg.currentSong = status.module
                self.player?.play()
            } else {
                let alert = NSAlert()
                alert.messageText = "Module Load Failed"
                alert.informativeText = status.error
                alert.runModal()
            }
        }
    }


    override public func viewDidLoad() {
        super.viewDidLoad()
        self.setLabels()
        self.volumeSlider.floatValue = self.volume
        
        let defaults = NSUserDefaults.standardUserDefaults()
        self.repeat = defaults.boolForKey(PlayerViewController.kRepeatKey)
        self.shuffle = defaults.boolForKey(PlayerViewController.kShuffleKey)
        
        
        let cfg = SpindleConfig.sharedInstance
        let center = NSNotificationCenter.defaultCenter()
        
        center.addObserverForName(SpindleConfig.kSongChanged, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self]_ in
            self?.setLabels()
        }
        
        center.addObserverForName(SpindleConfig.kSongFinished, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] _ in
            self?.nextSong()
        }
        
        center.addObserverForName(SpindleConfig.kPlayListChanged, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] _ in
            let list = SpindleConfig.sharedInstance.playList
            let index = String(format: "%04d", list.index + 1)
            let count = String(format: "%04d", list.count)
            self?.songIndexList.stringValue = "Song \(index) of \(count)"
        }
    
        center.addObserverForName(SpindleConfig.kPositionChanged, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] note in
            if let curr = cfg.currentSong {
                if let num = note.object as? NSNumber {
                    let pat = String(format: "%03d", num.integerValue + 1)
                    let patLen = String(format: "%03d", curr.lengthInPatterns)
                    self?.songPatternIndex.stringValue = "\(pat)/\(patLen)"
                    
                }
            }
        }
        
        center.addObserverForName(SpindleConfig.kTimeChanged, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] note in
            if let curr = cfg.currentSong {
                if let num = note.object as? NSNumber {
                    //println("Time \(num)")
                    let min = String(format: "%02d", num.integerValue / 60)
                    let sec = String(format: "%02d", num.integerValue % 60)
                    self?.songTime.stringValue = "\(min):\(sec)"
                    
                    let percent = num.floatValue / Float(curr.durationSeconds) * Float(100);
                    self?.positionSlider.floatValue = percent
                }
            }
        }
        center.addObserverForName(SpindleConfig.kPlayAtIndex, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] note in
            if let num = note.object as? NSNumber {
                self?.playAtIndex(num.integerValue)
            }
        }
    }
    

    public override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

