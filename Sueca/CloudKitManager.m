//
//  CloudKitManager.m
//  Sueca
//
//  Created by Roger Luan on 7/5/16.
//  Copyright © 2016 Roger Luan. All rights reserved.
//

#import "CloudKitManager.h"
#import "NotificationManager.h"
#import "Promotion.h"

@implementation CloudKitManager

#pragma mark - Instance Methods - 

- (void)fetchPromotionsWithCompletion:(PromotionsCompletionHandler)completion {

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
		}
		completion(error, [promotions copy]);
	}];
}

- (void)fetchLatestPromotionWithCompletion:(PromotionCompletionHandler)completion {
	[self fetchPromotionsWithCompletion:^(NSError *error, NSArray<Promotion *> *promotions) {
		if (promotions.count > 0) {
			completion(error, [promotions firstObject]);
		} else {
			NSLog(@"Returned no Promotions");
#warning create error here. Maybe if there isn't promotions, link the button to facebook fanpage.
		}
	}];
}

@end