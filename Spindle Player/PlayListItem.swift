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

class PlayListItem {
    
    let url:NSURL
    let md5:String
    
    var title:String
    var lengthSeconds:Int
    var format:String
    
    var time:String {
        if lengthSeconds > 0 {
            let min = String(format: "%02d", lengthSeconds / 60)
            let sec = String(format: "%02d", lengthSeconds % 60)
            return "\(min):\(sec)"
        }
        return ""
    }
    
    var filename:String {
        return url.lastPathComponent ?? ""
    }
    
    lazy var sortkey:String = Factory.generateSortKey(self.title)
    
    init(url:NSURL, md5:String) {
        self.url = url
        self.md5 = md5
        
        title = ""
        lengthSeconds = 0
        format = ""
    }
    
    init(module:ModuleInfo) {
        url = module.url
        md5 = module.md5
        
        title = module.name
        lengthSeconds = module.durationSeconds
        format = module.simpleFormat
    }
    
}


extension PlayListItem {
    
    private class Factory {
        static let charactersToRemove = NSCharacterSet.alphanumericCharacterSet().invertedSet
        
        class func generateSortKey(title:String)->String {
            return "".join((title.lowercaseString).componentsSeparatedByCharactersInSet(Factory.charactersToRemove))
        }
    }
}

