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

class AboutViewController: NSViewController {
    static let dict: NSDictionary = NSBundle.mainBundle().infoDictionary!
    static let productBuild = dict["CFBundleVersion"] as! String
    static let productVersion = dict["CFBundleShortVersionString"] as! String
    
    let productName = dict["CFBundleName"] as! String
    let productVersionBuild = "Version \(productVersion) (\(productBuild))"
    let copyright = dict["NSHumanReadableCopyright"] as! String
    let xmpVersion = "libxmp " + String.fromCString(xmp_version)!
    
    @IBOutlet weak var label: NSTextField!
    @IBOutlet weak var xmpUrl: NSTextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do view setup here.
        
        let url = NSURL(string: "http://github.com/pmhicks/Spindle-Player", relativeToURL: nil)
        
        label.allowsEditingTextAttributes = true
        label.selectable = true
        label.attributedStringValue = hyperlinkFromString(url!.absoluteString!, withURL: url!)
        
        let xmp = NSURL(string: "http://xmp.sourceforge.net/", relativeToURL: nil)
        xmpUrl.allowsEditingTextAttributes = true
        xmpUrl.selectable = true
        xmpUrl.attributedStringValue = hyperlinkFromString(xmp!.absoluteString!, withURL: xmp!)
        
    }
    
    
    
    func hyperlinkFromString(inString:String, withURL:NSURL) -> NSAttributedString {
        
        var attrString = NSMutableAttributedString(string: inString)
        let range = NSMakeRange(0, attrString.length)
        
        attrString.beginEditing()
        attrString.addAttribute(NSLinkAttributeName, value: withURL.absoluteString!, range: range)
        attrString.addAttribute(NSForegroundColorAttributeName, value:NSColor.blueColor(), range:range)
        attrString.addAttribute(NSUnderlineStyleAttributeName, value: NSNumber(integer: NSUnderlineStyleSingle), range: range)
        attrString.endEditing()
        
        return attrString
        
    }
    
    
}