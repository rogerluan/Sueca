//
//  NotificationManager.m
//  Sueca
//
//  Created by Roger Luan on 7/5/16.
//  Copyright © 2016 Roger Luan. All rights reserved.
//

#import "NotificationManager.h"

@implementation NotificationManager

- (void)registerForRemoteNotifications {
	if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
		UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil];
		[[UIApplication sharedApplication] registerForRemoteNotifications];
		[[UIApplication sharedApplication] registerUserNotificationSettings:settings];
	} else {
		[[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge];
	}
}

- (void)registerForPromotionsWithCompletion:(DidRegisterForPromotions)completion {
	[self registerForRemoteNotifications];
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"requestedNotificationPermission"];
	
	
	NSPredicate *truePredicate = [NSPredicate predicateWithValue:YES];
	CKSubscription *promotion = [[CKSubscription alloc] initWithRecordType:@"Promotion" predicate:truePredicate options:CKSubscriptionOptionsFiresOnRecordCreation | CKSubscriptionOptionsFiresOnRecordUpdate];
	CKSubscription *contentPromotion = [[CKSubscription alloc] initWithRecordType:@"Promotion" predicate:truePredicate options:CKSubscriptionOptionsFiresOnRecordCreation | CKSubscriptionOptionsFiresOnRecordUpdate];
	
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
					Promotion *promotion = [Promotion promotionWithRecord:record];
					[[UIApplication sharedApplication] scheduleLocalNotification:promotion.notification];
				}
				completion(error);
			}];
		} else {
			NSLog(@"Content available = NO");
			[NotificationManager incrementPendingNotificationCount];
			completion(nil);
		}
	} else {
		if (userInfo[@"aps"][@"content-available"]) {
			NSLog(@"Active");
			[[NSNotificationCenter defaultCenter] postNotificationName:SuecaNotificationActiveRemoteNotification object:nil userInfo:userInfo];
		}
		[NotificationManager clearBadges];
		completion(nil);
	}
}

+ (void)handleLocalNotificationWithUserInfo:(NSDictionary *)userInfo {
	UIApplication *application = [UIApplication sharedApplication];
	if (application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground) {
		NSLog(@"Opened local notification from background");
	} else {
		NSLog(@"Opened local notification in foreground");
		[[NSNotificationCenter defaultCenter] postNotificationName:SuecaNotificationActiveLocalNotification object:nil userInfo:userInfo];
	}
	[NotificationManager clearBadges];
}

+ (NSInteger)pendingNotificationCount {
	return [[NSUserDefaults standardUserDefaults] integerForKey:@"pendingNotificationCount"];
}

+ (void)incrementPendingNotificationCount {
	NSInteger pendingNotificationCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"pendingNotificationCount"];
	pendingNotificationCount++;
	[[NSUserDefaults standardUserDefaults] setInteger:pendingNotificationCount forKey:@"pendingNotificationCount"];
}

+ (void)resetPendingNotificationCount {
	[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"pendingNotificationCount"];
}

@end