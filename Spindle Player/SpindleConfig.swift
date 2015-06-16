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

class SpindleConfig {
    static let kSongChanged = "spindle_SongChanged"
    static let kPositionChanged = "spindle_PositionChanged"
    static let kTimeChanged = "spindle_TimeChanged"
    static let kSongFinished = "spindle_SongFinished"
    static let kQueueFinished = "spindle_QueueFinished"
    static let kPlayListChanged = "spindle_playListChanged"
    static let kPlayAtIndex = "spindle_playAtIndex"
    static let kOpenFile = "spindle_openFile"
    
    let playList:PlayListModel
    let spindleDirectory:String
    let moduleDirectory:String
    
    var autoAddModules:Bool   //auto add modules to play list
    var manageModules:Bool    //copy modules to ~/Music/SpindlePlayer
    
    var currentSong:ModuleInfo? {
        didSet {
            let center = NSNotificationCenter.defaultCenter()
            center.postNotificationName(SpindleConfig.kSongChanged, object: nil)
        }
    }
    
    class var sharedInstance: SpindleConfig {
        struct StaticConfigInstance {
            static var onceToken: dispatch_once_t = 0
            static var instance: SpindleConfig? = nil
        }
        dispatch_once(&StaticConfigInstance.onceToken) {
            StaticConfigInstance.instance = SpindleConfig()
            StaticConfigInstance.instance?.load()
        }
        return StaticConfigInstance.instance!
    }

    
    private init() {
        var error: NSError?

        playList = PlayListModel.load()
        
        let fm = NSFileManager.defaultManager()
        let paths = NSSearchPathForDirectoriesInDomains(.MusicDirectory, .UserDomainMask, true) as NSArray
        let musicDir = paths.firstObject as! NSString
        
        spindleDirectory = musicDir.stringByAppendingPathComponent("SpindlePlayer")
        moduleDirectory = spindleDirectory.stringByAppendingPathComponent("modules")
        if !fm.fileExistsAtPath(spindleDirectory) {
            fm.createDirectoryAtPath(spindleDirectory, withIntermediateDirectories: false, attributes: nil, error: &error)
            if error != nil {
                println("Error creating Spindle dir: \(error)")
            }
        }
        error = nil
        if !fm.fileExistsAtPath(moduleDirectory) {
            fm.createDirectoryAtPath(moduleDirectory, withIntermediateDirectories: false, attributes: nil, error: &error)
            if error != nil {
                println ("Error creating modules dir: \(error)")
            }
        }
        
        //TODO: Make Configurable
        manageModules = true
        autoAddModules = true
        
    }
    
    //returns new filename on success or nil on failure
    func addModuleToMusic(sourceFileUrl:NSURL) -> NSURL? {
        let fm = NSFileManager.defaultManager()
        
        let mod = sourceFileUrl.lastPathComponent!
        let destFile = moduleDirectory.stringByAppendingPathComponent(mod)
        let destFileUrl = NSURL(fileURLWithPath: destFile)!
        
        if fm.fileExistsAtPath(destFile) {
            //treat as success
            return destFileUrl
        }
        
        var err: NSError?
        let copied = fm.copyItemAtURL(sourceFileUrl, toURL: destFileUrl, error: &err)
        
        if copied {
            return destFileUrl
        }
        //else failure
        println("Module copy failed \(err)")
        return nil
    }
    
    private func load() {
    }
    
    func save() {
        
    }
    
    
    
}