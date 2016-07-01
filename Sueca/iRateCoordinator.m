//
//  iRateCoordinator.m
//  Sueca
//
//  Created by Roger Luan on 2/15/16.
//  Copyright © 2016 Roger Luan. All rights reserved.
//

#import "iRateCoordinator.h"
#import "iVersion.h"
#import "AnalyticsManager.h"

@implementation iRateCoordinator

- (void)awakeFromNib {
	[super awakeFromNib];
	[[iRate sharedInstance] setDelegate:self];
}

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

#pragma mark - iRate Delegate Methods -

- (void)iRateUserDidAttemptToRateApp {
	[AnalyticsManager logEvent:AnalyticsEventiRateUserDidAttemptToRateApp];
}

- (void)iRateUserDidDeclineToRateApp {
	[AnalyticsManager logEvent:AnalyticsEventiRateUserDidDeclineToRateApp];
}

- (void)iRateUserDidRequestReminderToRateApp {
	[AnalyticsManager logEvent:AnalyticsEventiRateUserDidRequestReminderToRateApp];
}

- (void)iRateDidOpenAppStore {
	[AnalyticsManager logEvent:AnalyticsEventiRateDidOpenAppStore];
}

@end
