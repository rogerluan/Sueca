//
//  CloudKitManager.m
//  Sueca
//
//  Created by Roger Luan on 7/5/16.
//  Copyright © 2016 Roger Luan. All rights reserved.
//

#import "CloudKitManager.h"

@implementation CloudKitManager

+ (void)registerForPromotionsWithCompletion:(DidRegisterForPromotions)completion {
	NSPredicate *promotionPredicate = [NSPredicate predicateWithFormat:@"TRUEPREDICATE"];
	CKSubscription *promotion = [[CKSubscription alloc] initWithRecordType:@"Promotion" predicate:promotionPredicate options:CKSubscriptionOptionsFiresOnRecordCreation | CKSubscriptionOptionsFiresOnRecordUpdate];
	CKSubscription *contentPromotion = [[CKSubscription alloc] initWithRecordType:@"Promotion" predicate:promotionPredicate options:CKSubscriptionOptionsFiresOnRecordCreation | CKSubscriptionOptionsFiresOnRecordUpdate];
	
	CKNotificationInfo *notificationInfo = [CKNotificationInfo new];
	notificationInfo.shouldSendContentAvailable = YES;
	contentPromotion.notificationInfo = notificationInfo;
	
	notificationInfo.shouldSendContentAvailable = NO;
	notificationInfo.alertLocalizationKey = @"There's a new promotion going on! Open Sueca to check the prizes!";
	notificationInfo.shouldBadge = YES;
	notificationInfo.soundName = UILocalNotificationDefaultSoundName;
	promotion.notificationInfo = notificationInfo;
	
	
	CKModifySubscriptionsOperation *operation = [[CKModifySubscriptionsOperation alloc] initWithSubscriptionsToSave:@[promotion, contentPromotion] subscriptionIDsToDelete:nil];
	
	operation.modifySubscriptionsCompletionBlock = ^(NSArray <CKSubscription *> * __nullable savedSubscriptions, NSArray <NSString *> * __nullable deletedSubscriptionIDs, NSError * __nullable operationError) {
		completion(operationError);
	};
	[[[CKContainer defaultContainer] publicCloudDatabase] addOperation:operation];
}

+ (void)clearBadges {
	[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
	CKModifyBadgeOperation *clearOperation = [[CKModifyBadgeOperation alloc] initWithBadgeValue:0];
	clearOperation.modifyBadgeCompletionBlock = ^(NSError * __nullable operationError) {
		if (operationError) {
			NSLog(@"Clear badge operation failed with operation error: %@", operationError);
		}
	};
	[[CKContainer defaultContainer] addOperation:clearOperation];
}

@end
