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

#ifndef __Spindle_Player__AudioHelper__
#define __Spindle_Player__AudioHelper__

#include <stdio.h>
#include <stdlib.h>
#include <AudioToolbox/AudioToolbox.h>
#include <AudioToolbox/AudioQueue.h>
#include "xmp.h"

static const int kNumberBuffers = 3;
struct sp_queue_player_state {
    xmp_context                   context;
    AudioStreamBasicDescription   mDataFormat;
    AudioQueueRef                 mQueue;
    AudioQueueBufferRef           mBuffers[kNumberBuffers];
    UInt32                        bufferByteSize;
    int                           position;                 //current position of mod. Set by callback
    int                           seconds;                  //current second of mod. Set by callback
    bool                          mIsRunning;
    bool                          mIsValid;     //true if all initializing completed without errors
};
typedef struct sp_queue_player_state * sp_playerState;

sp_playerState sp_create_playerstate(xmp_context context, UInt32 buffer_size_bytes);


OSStatus sp_queue_init(sp_playerState state);
OSStatus sp_alloc_buffer(sp_playerState state, int buffer);
int sp_prime_frame(sp_playerState state, int buffer);
int sp_queue_frame(sp_playerState state, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer);

#endif /* defined(__Spindle_Player__AudioHelper__) */
