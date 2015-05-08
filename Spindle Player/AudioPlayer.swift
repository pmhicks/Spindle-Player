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
import AudioToolbox
import AudioUnit
import CoreAudio


private let kQueueSize:UInt32 = 50000
private let kBufferCount:Int32 = 3

class AudioPlayer {
    
    var playerState: sp_playerState
    
    var volume:Float {
        didSet {
            if playerState != nil {
                AudioQueueSetParameter(playerState.memory.mQueue, AudioQueueParameterID(kAudioQueueParam_Volume), Float32(volume))
            }
            
        }
    }
    
    init(context:xmp_context, volume:Float) {
        self.volume = volume
        playerState = sp_create_playerstate(context, kQueueSize)
    }
    
    deinit {
        println("deinit AudioPlayer")
       disposePlayer()
    }
    
    private func disposePlayer() {
        if playerState != nil {
            playerState.memory.mIsRunning = false
            playerState.memory.mIsValid = false
            xmp_stop_module(playerState.memory.context)
            if playerState.memory.mQueue != nil {
                let disposeStatus = AudioQueueDispose(playerState.memory.mQueue, Boolean(1))
            }
            free(playerState)
            playerState = nil
        }
    }
    
    func initPlayer() {
       // setupComponent()
        
        let bufferCount:Int32 = 3
        var err:OSStatus
        
        //playerState.memory.mIsValid = true
        
        //setup queue
        err = sp_queue_init(playerState)
        if err != noErr {
            println("Queue init failed. OSStatus \(err)")
            disposePlayer()
            return
        }
        AudioQueueSetParameter(playerState.memory.mQueue, AudioQueueParameterID(kAudioQueueParam_Volume), Float32(volume))
        
        //setup buffers
        for(var i:Int32 = 0; i < kBufferCount; i++) {
            err = sp_alloc_buffer(playerState, i)
            if err != noErr {
                println("Buffer Alloc failed. OSStatus \(err)")
                disposePlayer()
                return
            }
        }
    }
    
    func pause() {
        let status = AudioQueuePause(playerState.memory.mQueue)
        if status != noErr {
            audioQueueError("Pause failed: \(status)")
        }
    }
    func unpause() {
        let status = AudioQueueStart(playerState.memory.mQueue, nil)
        if status != noErr {
            audioQueueError("Unpause failed: \(status)")
        }
    }
    
     func play() {
        
        //enqueue data
        for(var i:Int32 = 0; i < kBufferCount; i++) {
            let xmpStatus = sp_prime_frame(playerState, i)
            if xmpStatus != 0 {
                println("Prime fames failed. xmp_status \(xmpStatus)")
                //disposePlayer()
                return
            }
        }
        let status = AudioQueueStart(playerState.memory.mQueue, nil)
        if status == 0 {
            playerState.memory.mIsRunning = Bool(1)
        }
        //println("Start status \(status)")
    }
    
    private func audioQueueError(msg:String) {
        let alert = NSAlert()
        alert.messageText = "Audio Queue Error"
        alert.informativeText = msg
        alert.runModal()

    }
}
