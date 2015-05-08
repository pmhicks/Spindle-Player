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

public class InfoTableController: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    
    
    weak var table:NSTableView?
    
    public override init() {
        super.init()
       
        let center = NSNotificationCenter.defaultCenter()
        center.addObserverForName(SpindleConfig.kSongChanged, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] _ in
            if let s = self {
                if let tab = s.table {
                    tab.reloadData()
                }
            }
        }
    }
    
    //MARK: Data Source
    public func tableView(aTableView: NSTableView, objectValueForTableColumn aTableColumn: NSTableColumn?, row rowIndex: Int) -> AnyObject? {
        let cfg = SpindleConfig.sharedInstance
        if let song = cfg.currentSong {
            if aTableView.identifier == "samples" {
                if aTableColumn?.identifier == "text" {
                    return song.samples[rowIndex]
                }
                return String(format: "%02d", rowIndex + 1)
            }
            if aTableView.identifier == "instruments" {
                if aTableColumn?.identifier == "text" {
                    return song.instruments[rowIndex]
                }
                return String(format: "%02d", rowIndex + 1)
            }
        }
        return nil
    }
    
    public func numberOfRowsInTableView(aTableView: NSTableView) -> Int {
        self.table = aTableView
        let cfg = SpindleConfig.sharedInstance
        if let song = cfg.currentSong {
            if aTableView.identifier == "samples" {
                return song.samples.count
            }
            if aTableView.identifier == "instruments" {
                return song.instruments.count
            }
        }
        return 0
    }
    
    //MARK: Delegate
    
    
   }