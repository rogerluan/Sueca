//
//  ShareViewController.m
//  Sueca
//
//  Created by Roger Luan on 7/7/16.
//  Copyright © 2016 Roger Luan. All rights reserved.
//

#import "ShareViewController.h"
#import "Deck.h"
#import "AnalyticsManager.h"

@interface ShareViewController ()

@end

@implementation ShareViewController

+ (instancetype)initWithCard:(Card *)card {
	
	NSString *sharingString = [NSString stringWithFormat: NSLocalizedString(@"Everyone's drinking shots on Sueca Drinking Game. Come over to have some fun! #sueca", @"Activity View Sharing String")];
	UIImage *sharingImage = nil;
	
	if (card.deck.isDefault) {
		sharingImage = [UIImage imageNamed:card.cardName];
	} else {
		sharingImage = [UIImage imageNamed:@"sharingSuecaLogoImage"];
	}
	
	NSURL *sharingURL = [NSURL URLWithString:@"bit.ly/1JwDmry"];
	NSString *fullSharingString = [NSString stringWithFormat:@"%@ %@", sharingString, sharingURL];
	
	ShareViewController *viewController = [[super alloc] initWithActivityItems:@[fullSharingString, sharingImage, sharingURL] applicationActivities:nil];
	
	viewController.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr, UIActivityTypePostToVimeo, UIActivityTypeAirDrop];
	
	/**
	 * Analytics
	 */
	if ([viewController respondsToSelector:@selector(setCompletionWithItemsHandler:)]) {
		[viewController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
			
			NSMutableDictionary *attributes;
			if (activityType) {
				[attributes addEntriesFromDictionary:@{@"Activity Type":activityType}];
			}
			[attributes addEntriesFromDictionary:@{@"Completed":[NSNumber numberWithBool:completed]}];
			if (activityError.description) {
				[attributes addEntriesFromDictionary:@{@"Error":activityError.description}];
			}
			[attributes addEntriesFromDictionary:[self attributesForCard:card]];
			[Answers logShareWithMethod:activityType contentName:AnalyticsEventDidShareCard contentType:nil contentId:nil customAttributes:[attributes copy]];
		}];
	} else {
		[viewController setCompletionHandler:^(NSString *activityType, BOOL completed) {
			
			NSMutableDictionary *attributes;
			if (activityType) {
				[attributes addEntriesFromDictionary:@{@"Activity Type":activityType}];
			}
			[attributes addEntriesFromDictionary:@{@"Completed":[NSNumber numberWithBool:completed]}];
			[attributes addEntriesFromDictionary:[self attributesForCard:card]];
			[Answers logShareWithMethod:activityType contentName:AnalyticsEventDidShareCard contentType:nil contentId:nil customAttributes:[attributes copy]];
		}];
	}
	return viewController;
}

+ (NSDictionary *)attributesForCard:(Card *)card {
	NSMutableDictionary *attributes = [NSMutableDictionary new];
	if (card.cardName) {
		[attributes addEntriesFromDictionary:@{@"Card Name":card.cardName}];
	}
	if (card.cardRule) {
		[attributes addEntriesFromDictionary:@{@"Card Rule":card.cardRule}];
	}
	if (card.cardDescription) {
		[attributes addEntriesFromDictionary:@{@"Card Description":card.cardDescription}];
	}
	return [attributes copy];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end