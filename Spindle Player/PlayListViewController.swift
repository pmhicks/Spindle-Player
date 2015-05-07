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

class PlayListViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    var playList:PlayListModel!
    
    @IBOutlet weak var playListTableView: NSTableView!
    
    
    @IBAction func okAction(sender: NSButton) {
        let cfg = SpindleConfig.sharedInstance
        cfg.playList.setListItems(self.playList)
        self.view.window?.close()
    }
    
    @IBAction func cancelAction(sender: NSButton) {
        self.view.window?.close()
    }
    
    @IBAction func clearListAction(sender: NSButton) {
        playList.viewClearList()
        self.playListTableView.reloadData()
    }
    
    @IBAction func addAction(sender: NSButton) {
        var openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = true
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        openPanel.beginWithCompletionHandler { (result) -> Void in
            if result == NSFileHandlingPanelOKButton {
                if let urlList = openPanel.URLs as? [NSURL] {
                    for url in urlList {
                        if url.fileURL {
                            //TODO: add testing of mod
                            let item = PlayListItem(url: url)
                            self.playList.viewAppend(item)
                        }
                        
                    }
                    self.playListTableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func removeAction(sender: NSButton) {
        let index = self.playListTableView.selectedRow
        if index >= 0 {
            playList.viewRemove(index)
            self.playListTableView.reloadData()
            
        }
    }
    
    @IBAction func moveUpAction(sender: NSButton) {
        let index = self.playListTableView.selectedRow
        if index >= 0 {
            let newIndex = playList.viewMoveUp(index)
            if newIndex >= 0 {
                self.playListTableView.reloadData()
                playListTableView?.selectRowIndexes(NSIndexSet(index: newIndex), byExtendingSelection: false)
            }
        }
    }
    
    @IBAction func moveDownAction(sender: NSButton) {
        let index = self.playListTableView.selectedRow
        if index >= 0 {
            let newIndex = playList.viewMoveDown(index)
            if newIndex >= 0 {
                self.playListTableView.reloadData()
                playListTableView?.selectRowIndexes(NSIndexSet(index: newIndex), byExtendingSelection: false)
            }
        }
    }
    
    @IBAction func shuffleAction(sender: NSButton) {
        playList.viewShuffleItems()
        self.playListTableView.reloadData()
    }
    @IBAction func sortAction(sender: NSButton) {
        playList.viewSort()
        self.playListTableView.reloadData()
    }
    
    
    
    func doubleClickAction(sender: AnyObject) {
        let cfg = SpindleConfig.sharedInstance
        cfg.playList.setListItems(self.playList)
        
        let num = NSNumber(integer: playListTableView.clickedRow)
        self.view.window?.close()
        
        let center = NSNotificationCenter.defaultCenter()
        center.postNotificationName(SpindleConfig.kPlayAtIndex, object: num)
        
    }
    
    override func viewDidLoad() {
        let cfg = SpindleConfig.sharedInstance
        self.playList = cfg.playList.copy
        super.viewDidLoad()
        // Do view setup here.
        playListTableView?.setDataSource(self)
        playListTableView?.setDelegate(self)
        
        if self.playList.count > 0 {
            let set = NSIndexSet(index: self.playList.index)
            playListTableView?.selectRowIndexes(set, byExtendingSelection: false)
        }
        
        let selector:Selector = "doubleClickAction:"
        playListTableView?.doubleAction = selector
        
        
    }
    
    //MARK: Data Source
    func tableView(aTableView: NSTableView, objectValueForTableColumn aTableColumn: NSTableColumn?, row rowIndex: Int) -> AnyObject? {
        
        let item = playList.viewGet(rowIndex)
        
        if let colId = aTableColumn?.identifier {
            switch colId {
            case "title":
                return item.title
            case "time":
                return item.time
            case "filename":
                return item.filename
            default:
                return nil
            }
        }
        return nil
    }
    
    func numberOfRowsInTableView(aTableView: NSTableView) -> Int {
        return playList.count
    }
    
    
    
}
