//
//  Promotion.m
//  Sueca
//
//  Created by Roger Luan on 7/8/16.
//  Copyright © 2016 Roger Luan. All rights reserved.
//

#import "Promotion.h"

@implementation Promotion

+ (instancetype)promotionWithRecord:(CKRecord *)record {
	Promotion *promotion = [[super alloc] initWithRecordType:record.recordType recordID:record.recordID];
	
	promotion.startDate = record[@"startDate"];
	promotion.endDate = record[@"endDate"];
	promotion.identifier = record[@"identifier"];
	promotion.prize = record[@"prize"];
	promotion.title = record[@"title"];
	promotion.buttonTitle = record[@"buttonTitle"];
	promotion.buttonURL = [NSURL URLWithString:record[@"buttonURL"]];
	promotion.shortDescription = record[@"shortDescription"];
	promotion.fullDescription = record[@"fullDescription"];
	
	UILocalNotification *notification = [UILocalNotification new];
	notification.alertBody = record[@"push_message"];
	notification.soundName = record[@"push_soundName"];
	if ([record[@"push_shouldIncrementBadge"] intValue] >= 1) {
		NSInteger iconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber];
		notification.applicationIconBadgeNumber = ++iconBadgeNumber;
	}
	notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:[record[@"push_fireDelayInSeconds"] doubleValue]];
	promotion.notification = notification;
	return promotion;
}

@end
