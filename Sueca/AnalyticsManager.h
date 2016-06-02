//
//  AnalyticsManager.h
//  Sueca
//
//  Created by Roger Luan on 2/15/16.
//  Copyright © 2016 Roger Luan. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Interactions & Gestures
#define AnalyticsEventWelcomeBack @"Interacted With Welcome Back"
#define AnalyticsGestureEventTapCard @"SwipeableView Tap Gesture"

#pragma mark - Buttons
#define AnalyticsEventReviewedViaButton @"Reviewed Via WelcomeBack Button"
#define AnalyticsEventUpdatedViaButton @"Updated Via Notification Button"

#pragma mark - iRate
#define AnalyticsEventiRateUserDidAttemptToRateApp @"iRate UserDidAttemptToRateApp"
#define AnalyticsEventiRateUserDidDeclineToRateApp @"iRate UserDidDeclineToRateApp"
#define AnalyticsEventiRateUserDidRequestReminderToRateApp @"iRate UserDidRequestReminderToRateApp"
#define AnalyticsEventiRateDidOpenAppStore @"iRate DidOpenAppStore"

#pragma mark - Opt Out
#define AnalyticsEventOptedOutShuffleWarning @"Opted Out Shuffle Warning"


@interface AnalyticsManager : NSObject

+ (void)trackGlobalSortCount;
+ (void)increaseGlobalSortCount;
+ (void)logEvent:(NSString *)eventName;
+ (void)logEvent:(NSString *)eventName withAttributes:(NSDictionary *)attributes;

@end
