//
//  NotificationManager.m
//  Sueca
//
//  Created by Roger Luan on 7/5/16.
//  Copyright © 2016 Roger Luan. All rights reserved.
//

#import "NotificationManager.h"
#import "CloudKitManager.h"

@implementation NotificationManager

- (void)registerForRemoteNotifications {
	UIApplication *application = [UIApplication sharedApplication];
	if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
		UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil];
		[application registerForRemoteNotifications];
		[application registerUserNotificationSettings:settings];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"requestedNotificationPermission"];
		[AnalyticsManager logEvent:AnalyticsEventNotificationPermissionView];
	}
}

- (void)registerForPromotionsWithCompletion:(DidRegisterForPromotions)completion {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	[[CKContainer defaultContainer] accountStatusWithCompletionHandler:^(CKAccountStatus accountStatus, NSError * _Nullable error) {
		[AnalyticsManager logEvent:AnalyticsEventCKAccountStatus withAttributes:@{@"status":[NSNumber numberWithInteger:accountStatus]}];
		switch (accountStatus) {
			case CKAccountStatusAvailable: {
				[self registerForRemoteNotifications];
				
				NSPredicate *truePredicate = [NSPredicate predicateWithValue:YES];
				CKSubscription *promotion = [[CKSubscription alloc] initWithRecordType:@"Promotion" predicate:truePredicate options:CKSubscriptionOptionsFiresOnRecordCreation];
				CKSubscription *contentPromotion = [[CKSubscription alloc] initWithRecordType:@"Promotion" predicate:truePredicate options:CKSubscriptionOptionsFiresOnRecordCreation];
				CKSubscription *promotionEdit = [[CKSubscription alloc] initWithRecordType:@"Promotion" predicate:truePredicate options:CKSubscriptionOptionsFiresOnRecordUpdate];
				
				CKNotificationInfo *notificationInfo = [CKNotificationInfo new];
				notificationInfo.shouldSendContentAvailable = YES;
				contentPromotion.notificationInfo = notificationInfo;
				
				notificationInfo.shouldSendContentAvailable = NO;
				notificationInfo.alertLocalizationKey = NSLocalizedString(@"There's a new promotion going on! Open Sueca to check the prizes!", nil);
				notificationInfo.shouldBadge = YES;
				notificationInfo.soundName = UILocalNotificationDefaultSoundName;
				promotion.notificationInfo = notificationInfo;
				
				notificationInfo.alertLocalizationKey = NSLocalizedString(@"One of our promotions were updated. Open Sueca to check the news!", nil);
				promotionEdit.notificationInfo = notificationInfo;
				
				[[NSUserDefaults standardUserDefaults] setObject:@[promotion.subscriptionID, contentPromotion.subscriptionID, promotionEdit.subscriptionID] forKey:@"PromotionSubscriptionIDs"];
				
				CKModifySubscriptionsOperation *operation = [[CKModifySubscriptionsOperation alloc] initWithSubscriptionsToSave:@[promotion, promotionEdit, contentPromotion] subscriptionIDsToDelete:nil];
				
				operation.modifySubscriptionsCompletionBlock = ^(NSArray <CKSubscription *> * __nullable savedSubscriptions, NSArray <NSString *> * __nullable deletedSubscriptionIDs, NSError * __nullable operationError) {
					[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
					if (operationError) {
						[AnalyticsManager logError:operationError];
						[AnalyticsManager logEvent:AnalyticsErrorFailedSubscriptionRegistration];
					} else {
						[AnalyticsManager logEvent:AnalyticsEventSuccessfullyRegisteredSubscription];
						[[NSUserDefaults standardUserDefaults] setBool:YES forKey:SuccessfullyRegisteredSubscription];
					}
					completion(operationError);
				};
				[[[CKContainer defaultContainer] publicCloudDatabase] addOperation:operation];
				break;
			}
			case CKAccountStatusNoAccount: {
				completion([ErrorManager errorForErrorIdentifier:CKAccountStatusNoAccount]);
				break;
			}
			case CKAccountStatusRestricted: {
				completion([ErrorManager errorForErrorIdentifier:CKAccountStatusRestricted]);
				break;
			}
			case CKAccountStatusCouldNotDetermine: {
				completion(error);
				break;
			}
		}
	}];
}

+ (void)clearBadges {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:SuccessfullyRegisteredSubscription]) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
			[CloudKitManager isUserLoggedIn:^(BOOL isUserLoggedIn) {
				if (isUserLoggedIn) {
					dispatch_async(dispatch_get_main_queue(), ^(void) {
						[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
						CKModifyBadgeOperation *clearOperation = [[CKModifyBadgeOperation alloc] initWithBadgeValue:0];
						clearOperation.modifyBadgeCompletionBlock = ^(NSError * __nullable operationError) {
							[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
							if (operationError) {
								[AnalyticsManager logError:operationError];
								[AnalyticsManager logEvent:AnalyticsErrorFailedClearBadges];
								NSLog(@"Clear badge operation failed with operation error: %@", operationError);
							}
						};
						[[CKContainer defaultContainer] addOperation:clearOperation];
					});
				} else {
					[AnalyticsManager logError:[ErrorManager errorForErrorIdentifier:SuecaErrorUserLoggedOut]];
				}
			}];
		});
	}
}

+ (void)handleRemoteNotificationWithUserInfo:(NSDictionary *)userInfo withCompletionHandler:(RemoteNotificationCompletionHandler)completion {
	UIApplication *application = [UIApplication sharedApplication];
	if (application.applicationState == UIApplicationStateBackground) {
		NSLog(@"Background");
		
		CKNotification *cloudKitNotification = [CKNotification notificationFromRemoteNotificationDictionary:userInfo];
		CKRecordID *promotionID = [(CKQueryNotification *)cloudKitNotification recordID];
		
		if (userInfo[@"aps"][@"content-available"]) {
			NSLog(@"Content available = YES");
			[AnalyticsManager logEvent:AnalyticsEventDidReceivePushInBackground];
			[[[CKContainer defaultContainer] publicCloudDatabase] fetchRecordWithID:promotionID completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
				NSLog(@"record: %@, error: %@", record, error);
				if (!error) {
					Promotion *promotion = [Promotion promotionWithRecord:record];
					[[UIApplication sharedApplication] scheduleLocalNotification:promotion.notification];
					[AnalyticsManager logEvent:AnalyticsEventDidRegisterLocalNotification withAttributes:promotion.attributes];
				}
				completion(error);
			}];
		} else {
			NSLog(@"Content available = NO");
			[NotificationManager incrementPendingNotificationCount];
			completion(nil);
		}
	} else {
		if (!userInfo[@"aps"][@"content-available"]) { //a condition just to cross this only once 
			NSLog(@"Active");
			[[NSNotificationCenter defaultCenter] postNotificationName:SuecaNotificationActiveRemoteNotification object:nil userInfo:userInfo];
			[[NSNotificationCenter defaultCenter] postNotificationName:SuecaNotificationUpdateLatestPromotion object:nil userInfo:userInfo];
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
	[[NSNotificationCenter defaultCenter] postNotificationName:SuecaNotificationUpdateLatestPromotion object:nil userInfo:userInfo];
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