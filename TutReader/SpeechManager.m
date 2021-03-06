//
//  SWSpeechManager.m
//  Nordkurier
//
//  Created by crekby on 8/14/14.
//  Copyright (c) 2014 IntexSoft. All rights reserved.
//

#define SPEECH_SYNTESIZER_RATE 0.2f
#define SPEECH_SYNTESIZER_PITCH 1.0f

#import "SpeechManager.h"
#import <AVFoundation/AVSpeechSynthesis.h>

@interface SpeechManager() <AVSpeechSynthesizerDelegate>

@property (nonatomic, strong) AVSpeechSynthesizer* syntesizer;

@property (nonatomic, strong) AVSpeechUtterance *utterance;

@end

@implementation SpeechManager

SINGLETON(SpeechManager)

- (id)init
{
    self = [super init];
    if (self) {
        self.syntesizer = [[AVSpeechSynthesizer alloc] init];
        self.syntesizer.delegate = self;
    }
    return self;
}

- (BOOL)isSpeaking
{
    if (self.syntesizer.isSpeaking && !self.syntesizer.isPaused) {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)stopSpeaking
{
    if (self.syntesizer.isSpeaking) {
        [self.syntesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
        if (self.playPauseButton) {
            self.playPauseButton.image = [UIImage imageNamed:@"speech"];
        }
    }
}

- (void)continueSpeaking
{
    if (self.syntesizer.isSpeaking && self.syntesizer.paused) {
        [self.syntesizer continueSpeaking];
        NSLog(@"continue speaking");
    }
    
}

- (void)startSpeaking
{
    if (self.speakingText) {
        [self.syntesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
        self.utterance = [[AVSpeechUtterance alloc] initWithString:self.speakingText];
        float rate = [[NSUserDefaults standardUserDefaults] floatForKey:@"speakingRate"];
        if (rate == 0) {
            rate = 0.3f;
        }
        self.utterance.rate = rate;
        self.utterance.pitchMultiplier = [[NSUserDefaults standardUserDefaults] floatForKey:@"speakingPitch"];
        self.utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"ru-RU"];
        [self.syntesizer speakUtterance:self.utterance];
        NSLog(@"start speaking");
    }
}

- (void)pauseSpeaking
{
    if (self.syntesizer.isSpeaking && !self.syntesizer.isPaused) {
        [self.syntesizer pauseSpeakingAtBoundary:AVSpeechBoundaryImmediate];
        NSLog(@"pause speaking");
    }
}

- (void)speakText:(NSString *)text
{
    self.speakingText = text;
    [self startSpeaking];
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didStartSpeechUtterance:(AVSpeechUtterance *)utterance
{
    if (self.playPauseButton) {
        self.playPauseButton.image = PAUSE_IMAGE;
    }
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance
{
    if (self.playPauseButton) {
        self.playPauseButton.image = SPEAK_IMAGE;
    }
}


@end
