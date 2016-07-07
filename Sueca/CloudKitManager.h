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

@interface CloudKitManager : NSObject

+ (void)registerForPromotionsWithCompletion:(DidRegisterForPromotions)completion;
+ (void)clearBadges;
+ (void)handleRemoteNotificationWithUserInfo:(NSDictionary *)userInfo withCompletionHandler:(RemoteNotificationCompletionHandler)completion;
+ (void)handleLocalNotificationWithUserInfo:(NSDictionary *)userInfo;
	
@end
