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

+ (void)handleRemoteNotificationWithUserInfo:(NSDictionary *)userInfo withCompletionHandler:(RemoteNotificationCompletionHandler)completion {
	UIApplication *application = [UIApplication sharedApplication];
	if (application.applicationState == UIApplicationStateBackground) {
		NSLog(@"Inactive or Background");
		
		CKNotification *cloudKitNotification = [CKNotification notificationFromRemoteNotificationDictionary:userInfo];
		CKRecordID *promotionID = [(CKQueryNotification *)cloudKitNotification recordID];
		
		if (userInfo[@"aps"][@"content-available"]) {
			NSLog(@"Content available = YES");
			
			[[[CKContainer defaultContainer] publicCloudDatabase] fetchRecordWithID:promotionID completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
				NSLog(@"record: %@, error: %@", record, error);
				
				if (!error) {
					UILocalNotification *notification = [UILocalNotification new];
					notification.alertBody = record[@"push_message"];
					notification.soundName = record[@"push_soundName"];
					if ([record[@"push_shouldIncrementBadge"] intValue] == 1) {
						NSInteger iconBadgeNumber = [application applicationIconBadgeNumber];
						notification.applicationIconBadgeNumber = ++iconBadgeNumber;
					}
					notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:[record[@"push_fireDelayInSeconds"] doubleValue]];
					notification.userInfo = @{@"recordName":promotionID.recordName};
					[[UIApplication sharedApplication] scheduleLocalNotification:notification];
					completion(nil);
				} else {
					completion(error);
				}
			}];
		} else {
			NSLog(@"Content available = NO");
			
			[[[CKContainer defaultContainer] publicCloudDatabase] fetchRecordWithID:promotionID completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
				NSLog(@"record: %@, error: %@", record, error);
				if (!error) {
					completion(nil);
				} else {
					completion(error);
				}
			}];
		}
	} else {
		NSLog(@"Active");
		[CloudKitManager clearBadges];
		
		//To-do: Show an in-app banner
		
		completion(nil);
	}
}

+ (void)handleLocalNotificationWithUserInfo:(NSDictionary *)userInfo {
	UIApplication *application = [UIApplication sharedApplication];
	if (application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground) {
		NSLog(@"Opened local notification from background");
		NSString *recordName = [userInfo objectForKey:@"recordName"];
		NSLog(@"RecordName: %@", recordName);
	} else {
		NSLog(@"Opened local notification in foreground");
		//To-do: show an in-app banner
	}
	[CloudKitManager clearBadges];
}

@end
