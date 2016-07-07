//
//  MailComposeViewController.m
//  Sueca
//
//  Created by Roger Luan on 7/7/16.
//  Copyright © 2016 Roger Luan. All rights reserved.
//

#import "MailComposeViewController.h"

@implementation MailComposeViewController

- (instancetype)init {
	self = [super init];
	if (self) {
		[self setToRecipients:@[@"rogerluan.oba@gmail.com"]];
		[self setSubject:NSLocalizedString(@"Sueca - Contact", nil)];
		[self setMessageBody:[NSString stringWithFormat:NSLocalizedString(@"Ok, let's talk.\n\n\n\n\n\n\n\nBest regards,\nFrom a Sueca Drinking Game fan.", nil)] isHTML:NO];
		NSDictionary *textTitleOptions = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], NSForegroundColorAttributeName, nil];
		[self.navigationBar setTitleTextAttributes:textTitleOptions];
	}
	return self;
}

@end
