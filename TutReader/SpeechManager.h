//
//  SpeechManager.h
//  TutReader
//
//  Created by crekby on 8/15/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpeechManager : NSObject

+ (SpeechManager*) instance;

@property (nonatomic, strong) NSString* speakingText;
@property (nonatomic, assign, readonly) BOOL isSpeaking;
@property (nonatomic, strong) UIBarButtonItem* playPauseButton;

- (void) speakText:(NSString*) text;
- (void) stopSpeaking;
- (void) startSpeaking;
- (void) continueSpeaking;
- (void) pauseSpeaking;

@end
