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

//card description alert view
//card label edition
//direction of the card swipe/flip
//interaction with TSMessages
//interaction with iRate
//detect most engaging card(s) by calculating time of exposure
//----tap on the card 


@implementation AnalyticsManager

+ (void)trackGlobalSortCount {
	NSNumber *globalSortCount = [NSNumber numberWithInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"globalSortCount"]];
	NSLog(@"\n\nGlobal Sort Count: %@\n",globalSortCount);
	
    NSDictionary *attributes = @{@"globalSortCount":globalSortCount};
	
	[self logEvent:@"globalSortCount" withAttributes:attributes];
}

+ (void)increaseGlobalSortCount {
    [[iRate sharedInstance] logEvent:NO];
    
    NSInteger globalSortCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"globalSortCount"];
    globalSortCount++;
    [[NSUserDefaults standardUserDefaults] setInteger:globalSortCount forKey:@"globalSortCount"];
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

@end
