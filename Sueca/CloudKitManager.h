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

@interface CloudKitManager : NSObject

+ (void)isUserLoggedIn:(AccountAvailability)completion;
- (void)fetchPromotionsWithCompletion:(PromotionsCompletionHandler)completion;
- (void)fetchLatestPromotionWithCompletion:(PromotionCompletionHandler)completion;

@end