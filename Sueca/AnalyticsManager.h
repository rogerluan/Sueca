//
//  AnalyticsManager.h
//  Sueca
//
//  Created by Roger Luan on 2/15/16.
//  Copyright © 2016 Roger Luan. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Interactions & Gestures
static NSString * const AnalyticsEventWelcomeBack = @"Interacted With Welcome Back";
static NSString * const AnalyticsGestureEventTapCard = @"SwipeableView Tap Gesture";

#pragma mark - Buttons
static NSString * const AnalyticsEventReviewedViaButton = @"Reviewed Via WelcomeBack Button";
static NSString * const AnalyticsEventUpdatedViaButton = @"Updated Via Notification Button";

#pragma mark - iRate
static NSString * const AnalyticsEventiRateUserDidAttemptToRateApp = @"iRate UserDidAttemptToRateApp";
static NSString * const AnalyticsEventiRateUserDidDeclineToRateApp = @"iRate UserDidDeclineToRateApp";
static NSString * const AnalyticsEventiRateUserDidRequestReminderToRateApp = @"iRate UserDidRequestReminderToRateApp";
static NSString * const AnalyticsEventiRateDidOpenAppStore = @"iRate DidOpenAppStore";

#pragma mark - Opt Out
static NSString * const AnalyticsEventOptedOutShuffleWarning = @"Opted Out Shuffle Warning";


@interface AnalyticsManager : NSObject

+ (void)trackGlobalSortCount;
+ (void)increaseGlobalSortCount;
+ (void)logEvent:(NSString *)eventName;
+ (void)logEvent:(NSString *)eventName withAttributes:(NSDictionary *)attributes;

@end
