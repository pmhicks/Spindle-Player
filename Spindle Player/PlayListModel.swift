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

//note: shuffle value is set by PlayerViewController
class PlayListModel {
    private static let kIndex = "spindle_play_index"
    
    private var list:[PlayListItem]
    
    
    private var listIndex:Int = -1 {
        didSet {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setInteger(listIndex, forKey: PlayListModel.kIndex)
        }
    }
    
    private var shuffleIndexList:[Int]
    
    var index:Int {
        get {
            if shuffle && listIndex >= 0 {
                return shuffleIndexList[listIndex]
            }
            return listIndex
        }
    }
    
    var count:Int {
        get {
            return list.count
        }
    }
    
    var shuffle:Bool {
        didSet {
            if shuffle && !oldValue {
                shuffleShuffleIndex()
            }
        }
    }
    
    var copy:PlayListModel {
        get {
            let rval = PlayListModel(list: self.list)
            rval.listIndex = self.listIndex
            return rval
        }
    }
    
    var next:PlayListItem? {
        get {
            
            if list.count > 0 {
                var nextIndex = listIndex + 1
                if nextIndex >= list.count {
                    nextIndex = 0
                }
                listIndex = nextIndex
                listChanged()
                if shuffle {
                    return list[shuffleIndexList[listIndex]]
                }
                return list[listIndex]
            }
            return nil
        }
    }
    
    var previous:PlayListItem? {
        get {
            if list.count > 0 {
                let prevIndex = listIndex - 1
                if prevIndex >= 0 {
                    listIndex = prevIndex
                    listChanged()
                    if shuffle {
                        return list[shuffleIndexList[listIndex]]
                    }
                    return list[listIndex]
                }
            }
            return nil
        }
    }
    
    func getAtIndex(i:Int) -> PlayListItem? {
        if list.count > 0 {
            if i >= 0 && i < list.count {
                listIndex = i
                listChanged()
                return list[listIndex]
            }
        }
        return nil
    }

    
    
    init() {
        self.list = []
        self.shuffleIndexList = []
        self.shuffle = false
        
    }
    private init(list:[PlayListItem]) {
        self.list = list
        self.shuffle = false
        
        self.shuffleIndexList = []
        buildShuffleIndex()
    }
    
    private func listChanged() {
        let center = NSNotificationCenter.defaultCenter()
        center.postNotificationName(SpindleConfig.kPlayListChanged, object: nil)
    }
    
    private func buildShuffleIndex() {
        shuffleIndexList = []
        let c = list.count
        if c > 0 {
            shuffleIndexList.reserveCapacity(c)
            for i in 0..<c {
                shuffleIndexList.append(i) 
            }
        }
     }
    private func shuffleShuffleIndex() {
        if list.count > 1 {
            let c = shuffleIndexList.count
            for i in 0..<(c - 1) {
                let j = Int(arc4random_uniform(UInt32(c - i))) + i
                swap(&shuffleIndexList[i], &shuffleIndexList[j])
            }
        }
    }
    
    func setListItems(model:PlayListModel) {
        let oldCount = list.count
        list = model.list
        
        if list.count != oldCount {
            buildShuffleIndex()
            if shuffle {
                shuffleShuffleIndex()
            }
            if listIndex >= list.count {
                listIndex = list.count - 1
            }
            listChanged()
        }
        save()
    }
    
    //MARK: Table View Functions
    
    func viewAppend(item:PlayListItem) {
        list.append(item)
    }
    
    func viewRemove(index:Int) {
        list.removeAtIndex(index)
    }
    
    func viewClearList() {
        list = []
        listIndex = -1
        shuffleIndexList = []
    }
    
    
    func viewGet(index:Int) -> PlayListItem {
        return list[index]
    }
    
    //returns new index or -1
    func viewMoveUp(index:Int) -> Int {
        if list.count > 1 &&  index > 0 {
            swap(&list[index], &list[index - 1])
            return index - 1
        }
        return -1
    }
    
    //returns new index or -1
    func viewMoveDown(index:Int) -> Int {
        if list.count > 1 &&  index + 1 < list.count {
            swap(&list[index], &list[index + 1])
            return index + 1
        }
        return -1
    }
    
    func viewShuffleItems() {
        let c = list.count
        for i in 0..<(c - 1) {
            let j = Int(arc4random_uniform(UInt32(c - i))) + i
            swap(&list[i], &list[j])
        }
    }
    
    func viewSort() {
        list.sort({ $0.sortkey < $1.sortkey })
    }
    
    
    class func load() -> PlayListModel {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths.objectAtIndex(0) as! NSString
        let path = documentsDirectory.stringByAppendingPathComponent(".SpindlePlayer.plist")
        let fileManager = NSFileManager.defaultManager()
        
        var itemList:[PlayListItem] = []
        
        if fileManager.fileExistsAtPath(path) {
            let dict = NSMutableDictionary(contentsOfFile: path)
            if let array = dict?.objectForKey("List") as? [NSMutableDictionary] {
                //println("Found array")
                for i in 0..<array.count {
                    let d = array[i]
                    if let title = d.objectForKey("Title") as? String,
                        time = d.objectForKey("Length") as? NSNumber,
                        urlStr = d.objectForKey("Url") as? String {
                            //println("found keys")
                            
                            if let url = NSURL(string: urlStr) {
                                //println("have url")
                                let item = PlayListItem(url: url)
                                item.title = title
                                item.lengthSeconds = time.integerValue
                                itemList.append(item)
                                
                            }
                    }
                }
                
            }
        }
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.registerDefaults([PlayListModel.kIndex : -1])
        
        if itemList.count > 0 {
            let rval = PlayListModel(list: itemList)
            
            var index = defaults.integerForKey(PlayListModel.kIndex)
            
            if index < itemList.count {
                rval.listIndex = index
            }
            return rval
        }

        return PlayListModel()
        
    }
    
    
    func save() {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths.objectAtIndex(0) as! NSString
        let path = documentsDirectory.stringByAppendingPathComponent(".SpindlePlayer.plist")
        
        
        var dict = NSMutableDictionary()
        var array:[NSMutableDictionary] = []
        
        for i in 0..<list.count {
            var d = NSMutableDictionary()
            d.setObject(list[i].title, forKey: "Title")
            d.setObject(list[i].lengthSeconds, forKey: "Length")
            d.setObject(list[i].url.description, forKey: "Url")
            array.append(d)
        }
        
        dict.setObject(array, forKey: "List")
        let result = dict.writeToFile(path, atomically: false)
    }
    
    
}