//
//  SoundManager.m
//  Sueca
//
//  Created by Roger Luan on 2/15/16.
//  Copyright © 2016 Roger Luan. All rights reserved.
//

#import "SoundManager.h"
#import <AVFoundation/AVFoundation.h>

@interface SoundManager()

@property (assign) SystemSoundID cardShuffle;
@property (assign) SystemSoundID cardSlide;

@end

@implementation SoundManager

#pragma mark - Sound FX

- (void)playRandomCardSlideSoundFX {
    [self stopAllSounds];
    
    /* Randomly sorts a cardSlide sound */
    NSUInteger randomIndex = arc4random() % 8;
    
    /* Plays Card Slide Sound FX */
    NSString *cardSlidePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"cardSlide%ld",(unsigned long)randomIndex] ofType:@"wav"];
    NSURL *cardSlideURL = [NSURL fileURLWithPath:cardSlidePath];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)cardSlideURL, &_cardSlide);
    AudioServicesPlaySystemSound(self.cardSlide);
}

- (void)playShuffleSoundFX {
    [self stopAllSounds];
    
    /* Plays Card Shuffle Sound FX */
    NSString *cardShufflePath = [[NSBundle mainBundle] pathForResource:@"cardShuffle" ofType:@"wav"];
    NSURL *cardShuffleURL = [NSURL fileURLWithPath:cardShufflePath];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)cardShuffleURL, &_cardShuffle);
    AudioServicesPlaySystemSound(self.cardShuffle);
}

- (void)stopAllSounds {
    AudioServicesDisposeSystemSoundID(self.cardShuffle);
    AudioServicesDisposeSystemSoundID(self.cardSlide);
}

@end
