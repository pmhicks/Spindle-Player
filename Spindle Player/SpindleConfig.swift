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
    
    let playList:PlayListModel
    
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
        playList = PlayListModel.load()
    }
    
    private func load() {
    }
    
    func save() {
        
    }
    
    
    
}