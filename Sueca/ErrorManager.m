//
//  ErrorManager.m
//  Patient
//
//  Created by Roger Oba on 10/24/15.
//  Copyright © 2015 GoDoctor. All rights reserved.
//

#import "ErrorManager.h"
#import "Constants.h"
#import "AnalyticsManager.h"

@implementation ErrorManager

+ (NSError*)errorForErrorIdentifier:(NSInteger)errorIdentifier {
    return [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                               code:errorIdentifier
                           userInfo:[self userInfoForErrorIdentifier:errorIdentifier]];
}

+ (UIAlertController *)alertFromError:(NSError *)error {
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    if (error.localizedDescription) {
        [attributes addEntriesFromDictionary:@{@"error.description":error.localizedDescription}];
    }
    if (error.domain) {
        [attributes addEntriesFromDictionary:@{@"error.domain":error.domain}];
    }
    if (error.code) {
        [attributes addEntriesFromDictionary:@{@"error.code":[NSNumber numberWithInteger:error.code]}];
    }
	[AnalyticsManager logEvent:AnalyticsEventErrorAlert withAttributes:[attributes copy]];
    
    NSLog(@"An error occured. Error description: %@ Possible failure reason: %@ Possible recovery suggestion: %@", error.localizedDescription, error.localizedFailureReason, error.localizedRecoverySuggestion);
    
    NSString *alertTitle;
    NSString *alertMessage;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleDefault handler:nil];

    if ([error.domain isEqualToString:[[NSBundle mainBundle] bundleIdentifier]]) {
        switch (error.code) {
            case PPErrorNetworkUnavailable: {
                [alert setTitle:NSLocalizedString(@"Network Unavailable", nil)];
                [alert setMessage:NSLocalizedString(@"This application requires internet connection in order to function properly. Please ensure that you have an active internet connection, and refresh the page.", nil)];
                break;
            }
        }
    } else {
//        [alert setTitle:NSLocalizedString(@"Network Issues", nil)];
//        [alert setMessage:NSLocalizedString(@"A connection problem occured. Please try again later.", nil)];
//        UIAlertAction *reportAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Contact Us", @"Contact Us Alert Button") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            if ([PPMailComposeViewController canSendMail]) {
//                PPMailComposeViewController *mailComposeViewController = [[PPMailComposeViewController alloc] initWithError:error];
//                [Answers logCustomEventWithName:@"Present Mail Compose View Controller" customAttributes:@{}];
//                [[NSNotificationCenter defaultCenter] postNotificationName:kMailComposeNotification object:self userInfo:@{@"viewController":mailComposeViewController}];
//            } else {
//                UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Mail Unavailable", nil) message:NSLocalizedString(@"Your device isn't configured to send emails. Please contact us at contato@pagpouco.com",nil) preferredStyle:UIAlertControllerStyleAlert];
//                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleCancel handler:nil];
//                [alert addAction:cancelAction];
//                [Answers logCustomEventWithName:@"Cannot Present Mail Compose View Controller" customAttributes:@{}];
//                [[NSNotificationCenter defaultCenter] postNotificationName:kMailComposeNotification object:self userInfo:@{@"viewController":alert}];
//            }
//        }];
//        [alert addAction:reportAction];
//        NSString *possibleFailureReason = error.localizedFailureReason ? [NSString stringWithFormat:@"Possible reason: %@", error.localizedFailureReason] : @" ";
//        NSString *possibleRecoverySuggestion = error.localizedRecoverySuggestion ? [NSString stringWithFormat:@"\nPossible recovery suggestion: %@",error.localizedRecoverySuggestion] : @" ";
//        alertTitle = error.localizedDescription;
//        alertMessage = [NSString stringWithFormat:@"%@ %@", possibleFailureReason, possibleRecoverySuggestion];
    }
    [alert addAction:cancelAction];
    return alert;
}

+ (UIAlertController *)alertFromErrorIdentifier:(NSInteger)errorIdentifier {
    return [self alertFromError:[self errorForErrorIdentifier:errorIdentifier]];
}

#pragma mark - Helpers

+ (NSDictionary*)userInfoForErrorIdentifier:(NSInteger)error {
    switch (error) {
        case PPErrorNetworkUnavailable:
            return @{NSLocalizedDescriptionKey: NSLocalizedString(@"Network Unavailable", nil),
                     NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"The device isn't connected to the internet.", nil),
                     NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Provide internet connection to the device, either using cellular data or Wifi.", nil),
                     NSLocalizedRecoveryOptionsErrorKey: @[NSLocalizedString(@"OK", nil)]
                     };
        default:
            return @{NSLocalizedDescriptionKey: NSLocalizedString(@"Invalid error", nil),
                     NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"The action generated an unexpected error.", nil)
                     };
    }
}


@end
