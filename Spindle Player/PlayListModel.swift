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
     enum SortKey {
        case Title
        case Time
        
    }
    
    private var list:[PlayListItem]
    private var dict:[String:PlayListItem]
    
    
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
    
    var current:PlayListItem? {
        if list.count > 0 {
            return list[listIndex]
        }
        return nil
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
        self.dict = [String:PlayListItem]()
        
    }
    private init(list:[PlayListItem]) {
        self.list = list
        self.shuffle = false
        
        self.shuffleIndexList = []
        self.dict = [String:PlayListItem]()
        buildShuffleIndexAndDict()
    }
    
    private func listChanged() {
        let center = NSNotificationCenter.defaultCenter()
        center.postNotificationName(SpindleConfig.kPlayListChanged, object: nil)
    }
    
    private func buildShuffleIndexAndDict() {
        shuffleIndexList = []
        
        let c = list.count
        if c > 0 {
            dict = [String:PlayListItem](minimumCapacity: c)
            shuffleIndexList.reserveCapacity(c)
            for i in 0..<c {
                let item = list[i]
                shuffleIndexList.append(i)
                dict[item.md5] = item
            }
        } else {
            dict = [String:PlayListItem]()
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
    
    func moduleInList(md5:String) -> Bool {
        if let mod = dict[md5] {
            return true
        }
        return false
    }
    
    func add(item:PlayListItem) {
        if dict[item.md5] == nil {
            dict[item.md5] = item
            let c = list.count
            list.append(item)
            shuffleIndexList.append(c)
        }
        
    }
    
    func setListItems(model:PlayListModel) {
        let oldCount = list.count
        list = model.list
        
        if list.count != oldCount {
            buildShuffleIndexAndDict()
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
    
        
    
    func viewGet(index:Int) -> PlayListItem {
        return list[index]
    }
    
       
    func viewShuffleItems() {
        let c = list.count
        for i in 0..<(c - 1) {
            let j = Int(arc4random_uniform(UInt32(c - i))) + i
            swap(&list[i], &list[j])
        }
    }
    
    func sortList(sorter:(PlayListItem,PlayListItem) -> Bool) {
        list.sort(sorter)
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
                        md5 = d.objectForKey("MD5") as? String,
                        format = d.objectForKey("Format") as? String,
                        urlStr = d.objectForKey("Url") as? String {
                            //println("found keys")
                            
                            if let url = NSURL(string: urlStr) {
                                //println("have url")
                                let item = PlayListItem(url: url, md5:md5)
                                item.title = title
                                item.lengthSeconds = time.integerValue
                                item.format = format
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
    
    func remove(index:Int, moveToTrash:Bool) {
        let set = NSIndexSet(index: index)
        remove(set, moveToTrash: moveToTrash)
    }
    
    func remove(indexSet:NSIndexSet, moveToTrash:Bool) {
        indexSet.enumerateIndexesWithOptions(.Reverse) {
            let removed = self.list.removeAtIndex($0.0)
            if moveToTrash {
                let fileManager = NSFileManager.defaultManager()
                fileManager.trashItemAtURL(removed.url, resultingItemURL: nil, error: nil)
            }
            self.dict.removeValueForKey(removed.md5)
        }

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
            d.setObject(list[i].md5, forKey: "MD5")
            d.setObject(list[i].format, forKey: "Format")

            array.append(d)
        }
        
        dict.setObject(array, forKey: "List")
        let result = dict.writeToFile(path, atomically: false)
    }
}

//Mark: Extension for Sorting
extension PlayListModel {
    class func getSorter(property:String, ascending:Bool) -> (PlayListItem,PlayListItem) -> Bool {
        switch property {
        case "title":
            if ascending {
                return PlayListModel.sortTitleAscending
            }
            return PlayListModel.sortTitleDescending
        case "time":
            if ascending {
                return PlayListModel.sortTimeAscending
            }
            return PlayListModel.sortTimeDescending
        case "filename":
            if ascending {
                return PlayListModel.sortFilenameAscending
            }
            return PlayListModel.sortFilenameDescending
        case "format":
            if ascending {
                return PlayListModel.sortFormatAscending
            }
            return PlayListModel.sortFormatDescending
        default:
            println("WARN: getSorter() invalid property \"\(property)\"")
            if ascending {
                return PlayListModel.sortTitleAscending
            }
            return PlayListModel.sortTitleDescending
        }
    }
    
    private class func sortTitleAscending(left:PlayListItem, right:PlayListItem) -> Bool {
        return left.sortkey < right.sortkey
    }
    private class func sortTitleDescending(left:PlayListItem, right:PlayListItem) -> Bool {
        return right.sortkey < left.sortkey
    }
    private class func sortTimeAscending(left:PlayListItem, right:PlayListItem) -> Bool {
        return left.lengthSeconds < right.lengthSeconds
    }
    private class func sortTimeDescending(left:PlayListItem, right:PlayListItem) -> Bool {
        return right.lengthSeconds < left.lengthSeconds
    }
    private class func sortFilenameAscending(left:PlayListItem, right:PlayListItem) -> Bool {
        return left.filename.lowercaseString < right.filename.lowercaseString
    }
    private class func sortFilenameDescending(left:PlayListItem, right:PlayListItem) -> Bool {
        return right.filename.lowercaseString < left.filename.lowercaseString
    }
    private class func sortFormatAscending(left:PlayListItem, right:PlayListItem) -> Bool {
        if left.format != right.format {
            return left.format < right.format
        }
        return left.sortkey < right.sortkey
    }
    private class func sortFormatDescending(left:PlayListItem, right:PlayListItem) -> Bool {
        if right.format != left.format {
            return right.format < left.format
        }
        return right.sortkey < left.sortkey
    }
}