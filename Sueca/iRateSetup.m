//
//  iRateSetup.m
//  Sueca
//
//  Created by Roger Luan on 2/15/16.
//  Copyright © 2016 Roger Luan. All rights reserved.
//

#import "iRateSetup.h"
#import "iRate.h"
#import "iVersion.h"

@implementation iRateSetup

+ (void)setup {
    [iRate sharedInstance].daysUntilPrompt = 0;
    [iRate sharedInstance].usesUntilPrompt = 0;
    [iRate sharedInstance].promptAtLaunch = NO;
    [iRate sharedInstance].eventsUntilPrompt = 80;
    [iRate sharedInstance].promptForNewVersionIfUserRated = YES;
    [iVersion sharedInstance].checkAtLaunch = NO;
}

+ (void)resetEventCount {
    [iRate sharedInstance].eventCount = 0;
}

@end
