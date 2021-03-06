//
//  CloudKitManager.m
//  Sueca
//
//  Created by Roger Luan on 7/5/16.
//  Copyright © 2016 Roger Luan. All rights reserved.
//

#import "CloudKitManager.h"
#import "NotificationManager.h"

@implementation CloudKitManager

#pragma mark - Class Methods - 

+ (void)isUserLoggedIn:(AccountAvailability)completion {
	[[CKContainer defaultContainer] accountStatusWithCompletionHandler:^(CKAccountStatus accountStatus, NSError * _Nullable error) {
		if (accountStatus == CKAccountStatusAvailable) {
			completion(YES);
		} else {
			completion(NO);
		}
	}];
}

#pragma mark - Instance Methods - 

- (void)fetchPromotionsWithCompletion:(PromotionsCompletionHandler)completion {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(startDate <= %@) AND (endDate > %@)", [NSDate date], [NSDate date]];
	
	CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Promotion" predicate:predicate];
	NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO];
	[query setSortDescriptors:@[sortDescriptor]];
	[[[CKContainer defaultContainer] publicCloudDatabase] performQuery:query inZoneWithID:nil completionHandler:^(NSArray<CKRecord *> * _Nullable results, NSError * _Nullable error) {
		NSMutableArray *promotions = [NSMutableArray new];
		if (!error) {
			for (CKRecord *promoRecord in results) {
				Promotion *promotion = [Promotion promotionWithRecord:promoRecord];
				[promotions addObject:promotion];
			}
			completion(nil, [promotions copy]);
		} else {
			if ([error.domain isEqualToString:CKErrorDomain] && (error.code == CKErrorRequestRateLimited || error.code == CKErrorServiceUnavailable)) {
				NSInteger retryAfter = [[error.userInfo objectForKey:CKErrorRetryAfterKey] integerValue];
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(retryAfter * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
					[[[CKContainer defaultContainer] publicCloudDatabase] performQuery:query inZoneWithID:nil completionHandler:^(NSArray<CKRecord *> * _Nullable results, NSError * _Nullable error) {
						NSMutableArray *promotions = [NSMutableArray new];
						if (!error) {
							for (CKRecord *promoRecord in results) {
								Promotion *promotion = [Promotion promotionWithRecord:promoRecord];
								[promotions addObject:promotion];
							}
						}
						[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
						completion(error, [promotions copy]);
					}];
				});
			} else {
				[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
				completion(error, [promotions copy]);
			}
		}
	}];
}

- (void)fetchLatestPromotionWithCompletion:(PromotionCompletionHandler)completion {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	[self fetchPromotionsWithCompletion:^(NSError *error, NSArray<Promotion *> *promotions) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
		if (promotions.count > 0) {
			completion(error, [promotions firstObject]);
		} else {
			NSLog(@"Returned no Promotions");
			if (error) {
				completion(error, nil);
			} else {
				completion([ErrorManager errorForErrorIdentifier:SuecaErrorNoValidPromotionsFound], nil);
			}
		}
	}];
}

@end