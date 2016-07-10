//
//  CloudKitManager.h
//  Sueca
//
//  Created by Roger Luan on 7/5/16.
//  Copyright © 2016 Roger Luan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CloudKit/CloudKit.h>
#import "Constants.h"
#import "Promotion.h"

#warning possible erros already generated
//when user is not logged in iCloud: Not Authenticated when clearing badges, and "internal error" when fetching promotions

@interface CloudKitManager : NSObject

- (void)fetchPromotionsWithCompletion:(PromotionsCompletionHandler)completion;
- (void)fetchLatestPromotionWithCompletion:(PromotionCompletionHandler)completion;

@end
