//
//  ErrorManager.m
//  Patient
//
//  Created by Roger Oba on 10/24/15.
//  Copyright © 2015 GoDoctor. All rights reserved.
//

#import "ErrorManager.h"

@implementation ErrorManager

+ (NSError*)errorForErrorIdentifier:(NSInteger)errorIdentifier {
    return [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                               code:errorIdentifier
                           userInfo:[self userInfoForErrorIdentifier:errorIdentifier]];
}

+ (UIAlertController *)alertFromError:(NSError *)error {
	[self sendAnalyticsForError:error];
    NSLog(@"An error occured. Error description: %@ Possible failure reason: %@ Possible recovery suggestion: %@", error.localizedDescription, error.localizedFailureReason, error.localizedRecoverySuggestion);
    
	NSString *alertTitle = error.localizedDescription;
	NSString *alertMessage = [NSString stringWithFormat:@"%@ %@", error.localizedFailureReason, error.localizedRecoverySuggestion];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleDefault handler:nil];
	
    [alert addAction:cancelAction];
    return alert;
}

+ (UIAlertController *)alertFromErrorIdentifier:(NSInteger)errorIdentifier {
    return [self alertFromError:[self errorForErrorIdentifier:errorIdentifier]];
}

#pragma mark - Helpers

+ (NSDictionary*)userInfoForErrorIdentifier:(NSInteger)error {
    switch (error) {
        case SuecaErrorNoValidPromotionsFound:
            return @{NSLocalizedDescriptionKey: NSLocalizedString(@"No Promotions Found", nil),
                     NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Currently, there isn't a valid promotion.", nil),
                     NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Come back later and check for our promotions.", nil)
                     };
		case SuecaErrorFailedToEmail:
			return @{NSLocalizedDescriptionKey: NSLocalizedString(@"Failed To Send Email", nil),
					 NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Something unexpected happened and we weren't able to process the email.", nil),
					 NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Please try again later.", nil)
					 };
		case SuecaErrorInvalidURL:
			return @{NSLocalizedDescriptionKey: NSLocalizedString(@"Invalid URL", nil),
					 NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"We're very sorry for this error.", nil),
					 NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"We'll work harder to get this fixed asap.", nil)
					 };
		case CKAccountStatusNoAccount:
			return @{NSLocalizedDescriptionKey: NSLocalizedString(@"Login Required", nil),
					 NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"In order to register to promotions, you need to be logged with an iCloud account.", nil),
					 NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Please go to your device's settings and login to iCloud.", nil)
					 };
		case CKAccountStatusRestricted:
			return @{NSLocalizedDescriptionKey: NSLocalizedString(@"iCloud Account Restricted", nil),
					 NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"It seems that your iCloud account has parental control or device management restrictions.", nil),
					 NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Unfortunately, you won't be able to register to promotions using this iCloud account.", nil)
					 };
        default:
            return @{NSLocalizedDescriptionKey: NSLocalizedString(@"Invalid Error", nil),
                     NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"The action generated an unexpected error.", nil)
                     };
    }
}

+ (void)sendAnalyticsForError:(NSError *)error {
	NSMutableDictionary *attributes = [NSMutableDictionary new];
	if (error.code) {
		[attributes addEntriesFromDictionary:@{@"error.code":[NSNumber numberWithInteger:error.code]}];
	}
	if (error.localizedDescription) {
		[attributes addEntriesFromDictionary:@{@"error.description":error.localizedDescription}];
	}
	if (error.domain) {
		[attributes addEntriesFromDictionary:@{@"error.domain":error.domain}];
	}
	[AnalyticsManager logEvent:AnalyticsEventErrorAlertView withAttributes:[attributes copy]];
}


@end
