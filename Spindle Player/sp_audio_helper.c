/// Spindle Player
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

#include "sp_audio_helper.h"
#include "NotificationHelper.h"


static const int channelsPerFrame = 2;  //1 - mono, 2 - stereo
static const int bitsPerChannel = 16;   //16 or 8 for XMP
static const int bytesPerChannel = 2;



void sp_queue_callback(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer);
void sp_property_listener(void *inUserData, AudioQueueRef inAQ, AudioQueuePropertyID inID );


sp_playerState sp_create_playerstate(xmp_context context, UInt32 buffer_size_bytes) {
    sp_playerState state;
    
    state = malloc(sizeof(struct sp_queue_player_state));
    memset(state, 0, sizeof(struct sp_queue_player_state));
    
    state->context = context;
    state->bufferByteSize = buffer_size_bytes;
    
    
    state->mDataFormat.mSampleRate =  44100;
    state->mDataFormat.mFormatID = kAudioFormatLinearPCM;
    state->mDataFormat.mFormatFlags = kAudioFormatFlagIsPacked | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsSignedInteger;
    state->mDataFormat.mBytesPerPacket = bytesPerChannel * channelsPerFrame;
    state->mDataFormat.mFramesPerPacket = 1;
    state->mDataFormat.mBytesPerFrame = bytesPerChannel * channelsPerFrame;
    state->mDataFormat.mChannelsPerFrame = channelsPerFrame;
    state->mDataFormat.mBitsPerChannel = bitsPerChannel;
    state->mDataFormat.mReserved = 0;
    
    return state;
}




OSStatus sp_queue_init(sp_playerState state) {
    OSStatus status;
    //printf("sp_queue_init() %d\n", state->mDataFormat.mBitsPerChannel);
    
    status = AudioQueueNewOutput(&state->mDataFormat, sp_queue_callback, state, NULL, NULL, 0, &state->mQueue);
    if (status == noErr) {
        status = AudioQueueAddPropertyListener(state->mQueue, kAudioQueueProperty_IsRunning, sp_property_listener, NULL);
    }
    return status;
}


OSStatus sp_alloc_buffer (sp_playerState state, int buffer) {
    //printf("sp_alloc_buffer() buffer=%d size=%d\n", buffer, state->bufferByteSize);
    return AudioQueueAllocateBuffer(state->mQueue, state->bufferByteSize, &state->mBuffers[buffer]);
}


void sp_queue_callback( void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer ) {
    OSStatus status;
    sp_playerState state;
    
    state = (sp_playerState) inUserData;
    
    if (state->mIsRunning == 0) {
        //printf("sp_queue_callback() Not Running\n");
        return;
    }

    if (sp_queue_frame(state, inAQ, inBuffer) == 0) {
        AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
    } else {
        //printf("sp_queue_callback() stopping...\n");
        //nothing else to read
        state->mIsRunning = 0;
        status = AudioQueueStop(state->mQueue, false);
        if (status != noErr) {
            printf("sp_queue_callback() stop failed. OSStatus=%d\n", status);
        }
    }
}

void sp_property_listener(void *inUserData, AudioQueueRef inAQ, AudioQueuePropertyID inID ) {
    UInt32 running, psize;
    OSStatus status;
    
    //send notification if queue has finished
    if (inID == kAudioQueueProperty_IsRunning) {
        psize = sizeof(running);
        status = AudioQueueGetProperty(inAQ, kAudioQueueProperty_IsRunning, &running, &psize);
        if (status == noErr) {
            if (0 == running) {
                notifySongFinished();
            }
        } else {
            printf("Spindle: Failed getting kAudioQueueProperty_IsRunning. OSStatus=%d\n", status);
        }
    }
}

int sp_prime_frame(sp_playerState state, int buffer) {
    OSStatus status;
    int frame_status;
    AudioQueueRef inAQ;
    AudioQueueBufferRef inBuffer;

    //printf("sp_prime_frame() buffer=%d\n", buffer);
    
    inAQ = state->mQueue;
    inBuffer = state->mBuffers[buffer];
    
    frame_status = sp_queue_frame(state, inAQ, inBuffer);
    if(0 == frame_status) {
        status = AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
        if (status != noErr) {
            printf("Spindle: Failed to enqueue buffer in prime_frame. OSSStatus=%d", status);
        }
    }
    return frame_status;
}

int sp_queue_frame(sp_playerState state, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer ) {
    struct xmp_frame_info fi;
    int frame_status;
    int seconds;
    
    
    frame_status = xmp_play_frame(state->context);
    if (0 == frame_status) {
        xmp_get_frame_info(state->context, &fi);
        //printf("frame %d loop %d\n", fi.frame, fi.loop_count);
        //TODO: why is this necessary?. Fix if adding repeat
        if (fi.loop_count != 0) {
            return XMP_END;
        }
        memcpy(inBuffer->mAudioData, fi.buffer, fi.buffer_size);
        inBuffer->mAudioDataByteSize = fi.buffer_size;
        
        
        //send notification via helper to update UI
        //close enough values
        if (state->mIsRunning) {
            if (fi.pos != state->position) {
                state->position = fi.pos;
                notifyPositionChange(fi.pos);
            }
            seconds = fi.time / 1000;
            if (seconds != state->seconds) {
                state->seconds = seconds;
                notifyTimeChange(seconds);
            }
        }
        
    } else {
        printf("no frame. status=%d\n", frame_status);
    }
    return frame_status;
}