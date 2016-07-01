//
//  iVersionCoordinator.m
//  Sueca
//
//  Created by Roger Luan on 6/30/16.
//  Copyright © 2016 Roger Luan. All rights reserved.
//

#import "iVersionCoordinator.h"

@implementation iVersionCoordinator

- (void)awakeFromNib {
	[[iVersion sharedInstance] checkForNewVersion];
	[[iVersion sharedInstance] setDelegate:self];
}

- (void)openAppPageInAppStore {
	[[iVersion sharedInstance] openAppPageInAppStore];
}

#pragma mark - iVersion Delegate Methods -

- (void)iVersionDidDetectNewVersion:(NSString *)version details:(NSString *)versionDetails {
	NSLog(@"New version detected!");
	[[NSNotificationCenter defaultCenter] postNotificationName:@"newVersionAvailable" object:nil];
}

- (void)iVersionDidNotDetectNewVersion {
	NSLog(@"No new version. Your app is up to date.");
}

@end
