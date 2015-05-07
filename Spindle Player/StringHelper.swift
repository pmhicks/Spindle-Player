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

import Foundation

//FUGLY hack
func int8TupleToString<T>(tuple:T) -> String {
    let reflection = reflect(tuple)
    var arr:[UInt8] = []
    for i in 0..<reflection.count {
        if let value = reflection[i].1.value as? Int8 {
            if value > 0 {
                arr.append(UInt8(value))
            }
        }
    }
    if arr.count > 0 {
        //return String(bytes: arr, encoding: NSASCIIStringEncoding) ?? ""
        return String(bytes: arr, encoding: NSISOLatin1StringEncoding) ?? ""
    }
    return ""
}