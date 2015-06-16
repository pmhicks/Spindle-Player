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

private enum PlayerState: String, Printable {
    case Unloaded = "Unloaded"
    case Loaded = "Loaded"
    case FailedLoad = "FailedLoad"
    case Error = "Error"
    case Playing = "Playing"
    case Stopped = "Stopped"
    case Paused = "Paused"
    
    var description : String {
        get {
            return self.rawValue
        }
    }
}

class MusicPlayer {
    private var ap:AudioPlayer?
    private let context:xmp_context
    private var state:PlayerState {
        didSet {
            println("StateChange Old: \(oldValue) New: \(state)")
        }
    }
    
    var volume:Float {
        didSet {
            if volume > 1.0 {
                volume = 1.0
            }
            if volume < 0.0 {
                volume = 0.0
            }
            ap?.volume = volume
        }
    }
    
    init(volume:Float) {
        self.volume = volume
        self.state = .Unloaded
        self.context = xmp_create_context()
        
        let cfg = SpindleConfig.sharedInstance
        let center = NSNotificationCenter.defaultCenter()
        
        center.addObserverForName(SpindleConfig.kQueueFinished, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] _ in
            if let s = self {
                if s.state == .Playing {
                    xmp_stop_module(s.context)
                    s.ap = nil
                    s.state = .Stopped
                    center.postNotificationName(SpindleConfig.kSongFinished, object: nil)
                }
            }
        }
    }
   
    deinit {
        println("deinit MusicPlayer")
        xmp_stop_module(context)
        ap = nil
        sendEndNotification()
        if !(state == .Unloaded || state == .FailedLoad) {
            println("releasing XMP")
            xmp_end_player(context)
            xmp_release_module(context)
        }
        xmp_free_context(context)
    }
    
    func load(url:NSURL) -> (module:ModuleInfo?, success:Bool, error:String) {
        return loadAndAdd(url, doAdd: true)
    }
    
    private func loadAndAdd(url:NSURL, doAdd:Bool) -> (module:ModuleInfo?, success:Bool, error:String) {
        let cfg = SpindleConfig.sharedInstance
        
        if !url.fileURL {
            self.state = .FailedLoad
            return (nil, false, "URL is not a file")
        }
        let filename = url.fileSystemRepresentation
        let loadResult = Int(xmp_load_module(context, filename))
        if loadResult != 0 {
            //let err = lastError()
            self.state = .FailedLoad
            let message:String = {
                switch loadResult {
                case -3:
                    return "Unrecognized Module Format"
                case -4:
                    return "Error Loading Module (corrupt file?)"
                default:
                    return "XMP code \(loadResult)"
                }

            }()
            return (nil, false, message)
        }
        
        var rawinfo = xmp_module_info()
        xmp_get_module_info(context, &rawinfo)
        let info = ModuleInfo(url: url, info: rawinfo)
        
        if info.name == "" {
            info.name = url.lastPathComponent ?? ""
        }
        
        if doAdd {
            var newUrl:NSURL?
            if cfg.manageModules {
                newUrl = cfg.addModuleToMusic(url)
                
            }
            if cfg.autoAddModules {
                if let modUrl = newUrl {
                    let item = PlayListItem(module: info)
                    cfg.playList.add(item)
                }
            }
        }
        
        state = .Loaded
        return (info, true, "")
    }
    
    func load(item:PlayListItem) -> (module:ModuleInfo?, success:Bool, error:String) {
        let status = loadAndAdd(item.url, doAdd: false)
        
        if status.success {
            item.title = status.module?.name ?? ""
            item.lengthSeconds = status.module?.durationSeconds ?? 0
            item.format = status.module?.simpleFormat ?? ""
        }
        return status
    }
    
    func play() {
        
        switch self.state {
        case .Unloaded, .FailedLoad, .Error:
            return
        case .Playing:
            return
        case .Paused:
            ap?.unpause()
            self.state = .Playing
            return
        case .Loaded, .Stopped:
            let start = xmp_start_player(context, 44100, 0)
            //println("xmp start status: \(start)")
            if start != 0 {
                self.state = .Error
                musicPlayerError("XMP start failed: \(start)")
                return
            }
            ap = AudioPlayer(context: context, volume: volume)
            ap?.initPlayer()
            ap?.play()
            self.state = .Playing
        }
    }
    
    func pause() {
        switch self.state {
        case .Playing:
            ap?.pause()
            self.state = .Paused
        case .Paused:
            ap?.unpause()
            self.state = .Playing
        default:
            break
        }
    }
    
    func endPlayer() {
        println("End Player")
        let cfg = SpindleConfig.sharedInstance
       // let center = NSNotificationCenter.defaultCenter()
        //center.removeObserver(SpindleConfig.kNotificationSongFinished)
        self.stop()
    }
    
    func stop() {
        switch self.state {
        case .Playing, .Paused:
            self.state = .Stopped
            xmp_stop_module(context)
            ap = nil
            sendEndNotification()
        default:
            break
        }
    }
    
    private func sendEndNotification() {
        let center = NSNotificationCenter.defaultCenter()
        center.postNotificationName(SpindleConfig.kTimeChanged, object: NSNumber(integer: 0))
        center.postNotificationName(SpindleConfig.kPositionChanged, object: NSNumber(integer: 0))

    }
    
    func nextPosition() {
        xmp_next_position(context)
    }
    func previousPosition() {
        xmp_prev_position(context)
    }
    
    //return false if not playing
    func seek(seconds:Int) -> Bool {
        if self.state == .Playing || self.state == .Paused {
            xmp_seek_time(context, Int32(seconds * 1000))
            return true
        }
        return false
    }
    
    private func musicPlayerError(msg:String) {
        let alert = NSAlert()
        alert.messageText = "Music Player Error"
        alert.informativeText = msg
        alert.runModal()
        
    }
    
    
}