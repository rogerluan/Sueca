//
//  NotificationManager.m
//  Sueca
//
//  Created by Roger Luan on 7/5/16.
//  Copyright © 2016 Roger Luan. All rights reserved.
//

#import "NotificationManager.h"

@implementation NotificationManager

+ (void)registerForRemoteNotifications {
	UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
	[[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
	[[UIApplication sharedApplication] registerForRemoteNotifications];
}

@end