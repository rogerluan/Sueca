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
	if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
		UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil];
		[[UIApplication sharedApplication] registerForRemoteNotifications];
		[[UIApplication sharedApplication] registerUserNotificationSettings:settings];
	} else {
		[[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge];
	}
}

@end