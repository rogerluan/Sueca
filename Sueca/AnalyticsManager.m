//
//  AnalyticsManager.m
//  Sueca
//
//  Created by Roger Luan on 2/15/16.
//  Copyright © 2016 Roger Luan. All rights reserved.
//

#import "AnalyticsManager.h"
#import "iRate.h"

/**
 *
 *  Places to add analytics
 */

//to-do: detect most engaging card(s) by calculating time of exposure

static NSString * const kGlobalSortCount = @"globalSortCount";

@implementation AnalyticsManager

+ (void)trackGlobalSortCount {
	NSNumber *globalSortCount = [NSNumber numberWithInteger:[[NSUserDefaults standardUserDefaults] integerForKey:kGlobalSortCount]];
	NSLog(@"\n\nGlobal Sort Count: %@\n", globalSortCount);
    NSDictionary *attributes = @{kGlobalSortCount:globalSortCount};
	[self logEvent:AnalyticsEventTrackGlobalSortCount withAttributes:attributes];
}

+ (void)increaseGlobalSortCount {
    [[iRate sharedInstance] logEvent:NO];
    NSInteger globalSortCount = [[NSUserDefaults standardUserDefaults] integerForKey:kGlobalSortCount];
    globalSortCount++;
    [[NSUserDefaults standardUserDefaults] setInteger:globalSortCount forKey:kGlobalSortCount];
}

+ (void)logEvent:(NSString *)eventName {
	[self logEvent:eventName withAttributes:@{}];
}

+ (void)logEvent:(NSString *)eventName withAttributes:(NSDictionary *)attributes {
	[Answers logCustomEventWithName:eventName customAttributes:attributes];
}

+ (void)logContentViewEvent:(NSString *)eventName contentType:(NSString *)contentType {
	[self logContentViewEvent:eventName contentType:contentType customAttributes:nil];
}

+ (void)logContentViewEvent:(NSString *)eventName contentType:(NSString *)contentType customAttributes:(NSDictionary *)attributes {
	[Answers logContentViewWithName:eventName contentType:contentType contentId:nil customAttributes:attributes];
}

+ (void)logShare:(NSString *)activityType withAttributes:(NSDictionary *)attributes {
	[Answers logShareWithMethod:activityType contentName:AnalyticsEventDidShareCard contentType:nil contentId:nil customAttributes:attributes];
}

+ (void)logError:(NSError *)error {
	[self logError:error withAttributes:nil];
}

+ (void)logError:(NSError *)error withAttributes:(NSDictionary *)attributes {
	if (attributes) {
		return [[Crashlytics sharedInstance] recordError:error withAdditionalUserInfo:attributes];
	}
	[[Crashlytics sharedInstance] recordError:error];
}

@end
